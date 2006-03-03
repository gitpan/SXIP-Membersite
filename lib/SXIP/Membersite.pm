package SXIP::Membersite;

=head1 NAME

SXIP::Membersite - SXIP Membersite API

=head1 SYNOPSIS

    use SXIP::Membersite;

    my $ms = SXIP::Membersite->new;

    my $homesite_info = $ms->discover($homesite_path);

    if ($ms->verify(\%message, $persona_url)) {
        ...
    }

=head1 DESCRIPTION

SXIP::Membersite encapsulates core parts of the Simple eXtensible Identity
Protocol, providing functionality required by SXIP Membersites (identity data
consumers), compliant with version 2.0 of the SXIP protocol:

Discovery

The process of discovering a Homesite's protocol endpoint based on input typed
in by a user.

Verification

The process of verifying that a) the Homesite that sent a message is
authoritative for the user, and b) the Homesite did indeed send the message.

The package contains a simple demo Membersite to help you get started.

Integrating the SXIP protocol into your site has many benefits, including:

- Easier for the user to give rich identity data

- Single sign-on for all SXIP-enabled sites

- Verifiable third-party claims, which enable things like portable reputation

Visit http://sxip.org for information and support.

=cut

use warnings;
use strict;
use Carp;
use URI;
use HTML::TreeBuilder;
use SXIP::Digest 'sxip_digest';

our $VERSION = '1.0.0';

=head1 METHODS

=over

=item B<my $ms = new(useragent => $useragent, logger => $logger)>

Returns a SXIP::Membersite object.

Parameters:

=over

=item useragent 

Specify an LWP::UsgerAgent-compatible HTTP client (optional).  By default an
agent is used that follows redirects (maximum 7), and has a timeout of 5
seconds.

=item logger 

Specify a Log4perl-compatible logger object (optional).  Logs to STDERR by
default.

=back

=cut

sub new {
    my $class = shift;
    my %opts = @_;
    $opts{useragent} ||= SXIP::Membersite::UserAgent->new(Timeout=>5);
    $opts{logger} ||= SXIP::Membersite::Logger->new;
    return bless \%opts, $class;
}

=item B<my $info = disover($homesite_path)>

Attempts to discover the protocol endpoint URL of a Homesite, given some user
input.  If successful, it returns a hashref containing data about the Homesite.
Right now it populates a single key, "endpoint", with the endpoint URL.

Example:
  
  Given: $homesite_path = "example.com"

  - expand URL to http://example.com.
  - fetch http://example.com/dix.html and http://example.com,
    looking for a Homesite delegation tag.
  - if we find a valid tag, return the endpoint URL.
  - if we find no valid tags, croak.
  - if anything goes wrong, croak.

Parameters:

=over

=item $homesite_path

The data typed in by the user.  Most likely a hostname, but possibly a domain
name followed by a path. E.g. example.com, example.com/homesite.

=back

=cut

sub discover {
    my ($self, $hs_path) = @_;

    # try to pare out common typos and validate
    my ($scheme, $host, $port, $path) = ($hs_path =~ m#
        ^\s*(https?)?(?::/+)?
        ((?:[0-9A-Za-z][0-9A-Za-z-]*[0-9A-Za-z]?\.)*
        [0-9A-Za-z][0-9A-Za-z-]*[0-9A-Za-z]?)(:\d+)?(/.*)?\s*$
    #xi);

    $self->_croak("Could not find a valid hostname in the Homesite Path") 
        unless defined $host and length $host;

    my $hs_path_clean = URI->new(($scheme || 'http') . '://' . $host . ($port || '') . ($path || ''));
    $hs_path_clean = $hs_path_clean->canonical;
    $self->{logger}->debug("Canonicalized $hs_path to $hs_path_clean");

    my $dix_html = $hs_path_clean->clone;
    my @path = $dix_html->path_segments;
    pop @path while @path and (!defined $path[$#path] or !length $path[$#path]);
    $dix_html->path_segments(@path, 'dix.html');

    my $endpoint_url;
    URL: for my $url ($dix_html, $hs_path_clean) {
        $self->{logger}->debug("Attempting to retrieve homesite tag from $url");
        my $response = $self->{useragent}->get($url);
        if ($response->is_success) {
            my @tags = _find_dix_tags($response->content);
            $self->{logger}->debug("No DIX tags found in document $url");
            for my $tag (@tags) {
                if (defined $tag->attr('href') and length $tag->attr('href')) {
                    $endpoint_url = $tag->attr('href');
                    last URL;
                }
            }
        }
        else {
            $self->{logger}->debug("Error fetching $url: " . $response->status_line);
        }
    }

    $self->_croak("Could not find an entry point for $hs_path_clean") unless $endpoint_url;

    $self->{logger}->debug("Discovered endpoint $endpoint_url from path $hs_path");

    return {endpoint => $endpoint_url};
}

=item B<verify(\%message, $persona_url)>

Given a SXIP response message, and persona URL, attempts to verify that 

a) the Homesite that sent a message is authoritative for the user, and 

b) the Homesite did indeed send the message.

Note that the first verification step is optional, and only takes place if 
a persona URL is given.
 
Example:
   
  Given:
 
  $message['dix:/homesite-url'] = "http:/example.com/sxip"
  $persona_url = "http://example.com/personas/42"    

  - fetch "http://example.com/personas/42"
  - look for a persona delegation tag matching "http:/example.com/sxip"
  - if none found, croak
  - if found send a "verify-request" message to the Homesite
  - if the Homesite responds with dix:/true, return true
  - if the Homesite responds with dix:/false, return false
  - if anything goes wrong, croak

Parameters:

=over

=item $message 

The SXIP response message.  Normally this will just be a hashref of all the
POST parameters received by the Membersite.  For a repeating POST parameter,
the hash value should be an array ref.

=item $persona_url 

The persona URL of the user (optional).

=back

=cut

sub verify {
    my ($self, $message, $persona_url) = @_;

    # capture signature from fetch response, do not continue without it.
    my $sig = _value($message->{'dix:/signature'});
    $self->_croak('Message does not contain a signature.') unless defined $sig and length $sig;

    my $msgid = defined _value($message->{'dix:/message-id'}) ? _value($message->{'dix:/message-id'}) : "";
    $self->{logger}->debug("Attempting to verify response $msgid");

    # if we have a persona_url, check that homesite-path is authoritative for it
    my $hs_url = _value($message->{'dix:/homesite-url'});
    if ($persona_url) {
        $self->{logger}->debug("Fetching persona document from $persona_url");
        my $response = $self->{useragent}->get($persona_url);
        if ($response->is_success and lc $response->content_type eq 'text/html') {
            my @tags = _find_dix_tags($response->content);
            $self->_croak("No DIX tags found at $persona_url") unless @tags;
            my $match;
            foreach my $tag (@tags) {
                if (URI::eq($tag->attr('href'),$hs_url)) {
                    $match++;
                    $self->{logger}->debug("Verified that $hs_url is authoritative for $persona_url");
                    last;
                }
            }
            $self->_croak("No DIX tags at $persona_url match $hs_url") unless $match;
        }
        else {
            $self->_croak("Error fetching $persona_url: " . $response->status_line);
        }
    }

    # prepare verify-request message
    my %msg = (
        'dix:/message-type' => 'dix:/verify-request',
        'dix:/signature'    => $sig,
        'dix:/digest'  => sxip_digest($message),
    );

    # POST dix:/verify-request to homesite verification endpoint
    $self->{logger}->debug("Sending verify-request to Homesite $hs_url");
    my $response = $self->{useragent}->post($hs_url, \%msg);
    if ($response->is_success and lc $response->content_type eq 'text/plain') {
        # parse response
        if ($response->content =~ /([^\015\012]+)(\015\012.+)?/mis) {
            my $code = lc $1;
            my $message = substr($2,2);
            
            # evaluate response
            if ($code eq 'dix:/true') {
                $self->{logger}->info("Homesite $hs_url verified request $msgid");
                return 1;
            }
            elsif ($code eq 'dix:/false') {
                $self->{logger}->info("Homesite $hs_url denied verification for request $msgid");
                return 0;
            }
            elsif ($code eq 'dix:/unknown') {
                $self->_croak("Homesite $hs_url was unable to verify" . ($message ? ": $message" : ""));
            }
            else {
                $self->_croak("Homesite $hs_url gave a unknown response code: '$code'");
            }
        }
        else {
            $self->_croak("Homesite $hs_url gave a malformed response: " . $response->content);
        }
    }
    else {
        $self->_croak('Verification HTTP request failed: ' . $response->status_line); 
    }
}

sub _find_dix_tags {
    my $root = HTML::TreeBuilder->new_from_content($_[0]);
    my $head = $root->look_down(_tag => 'head') or return ();
    return $head->look_down(_tag => 'link', rel => 'dix:/homesite');
}

sub _croak {
    my $self = shift;
    my $message = shift;
    $self->{logger}->error($message);
    Carp::croak($message);
}

sub _value {
    my $v = shift;
    return defined $v ? (ref $v eq 'ARRAY' ? $v->[0] : $v) : $v;
}

package SXIP::Membersite::UserAgent;
use strict;
use warnings;
use base 'LWP::UserAgent';
sub redirect_ok {1}

package SXIP::Membersite::Logger;
use strict;
use warnings;
sub new { return bless {}, shift }
sub debug { shift->_log('debug', @_) }
sub info  { shift->_log('info', @_) }
sub warn  { shift->_log('warn', @_) }
sub error { shift->_log('error', @_) }
sub fatal { shift->_log('fatal', @_) }
sub _log {
    my $self = shift;
    my $level = shift;
    my $message = shift;
    print STDERR join(" ", scalar localtime, $level, $message); 
    print STDERR "\n" unless @_ and defined $_[$#_] and  $_[$#_] !~ /\n$/mis;
}

1; # End of SXIP::Membersite

=head1 AUTHOR

Sxip Identity, C<< <dev at sxip.org> >>

=head1 COPYRIGHT & LICENSE

The Sxip Identity Software License, Version 1

Copyright (c) 2004-2006 Sxip Identity Corporation. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

3. The end-user documentation included with the redistribution,
   if any, must include the following acknowledgment:
      "This product includes software developed by
       Sxip Identity Corporation (http://sxip.org)."
   Alternately, this acknowledgment may appear in the software itself,
   if and wherever such third-party acknowledgments normally appear.

4. The names "Sxip" and "Sxip Identity" must not be used to endorse
   or promote products derived from this software without prior
   written permission. For written permission, please contact
   bizdev@sxip.org.

5. Products derived from this software may not be called "Sxip",
   nor may "Sxip" appear in their name, without prior written
   permission of Sxip Identity Corporation.

THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
WARRANTIES OR CONDITIONS, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OR CONDITIONS OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL SXIP NETWORKS OR ITS
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut


