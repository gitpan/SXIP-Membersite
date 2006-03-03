#!/usr/bin/env perl
use warnings;
use strict;
use CGI;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SXIP::Membersite;
use MIME::Base64;
use URI;
my $c = CGI->new;
my $this_url = $c->url;
my $q = CGI->new($ENV{QUERY_STRING}); # XXX odd - i thought CGI combined POST and GET params
if (my $do = $c->param('do') || $q->param('do')) {
    if ($do eq 'button') {
        print $c->header('image/gif'),
        decode_base64(<<EOT);
R0lGODlhPgAUANU/AJ3UcvHx8eXl5YSEhM3NzWK9GuDg4N7e3o2Nje3t7XR0dJGRkdjY2IzOV2Rk
ZLS0tFJSUr29vHnGPMbGxqKiounp6cLjqcHBwaysrNLS0nx8fLO73fX19WxsbOPj437IQmV4wjxT
sZ+fn6vahKOszgAgn9DQz8/Qz8/Q0OHh4dDP0OLh4UBYtV9fX9TU0+Li4tDQ0Nzc3FpaWvLy8ouL
i9XV1cPDw/T09E5OTsnJyfPz8/b29vn5+ff39/j4+P///yH5BAEAAD8ALAAAAAA+ABQAAAb/wJ/u
IVosEEiacslsOp/QqHKgGYgCv8RikuB5v+CweEwuk32VR0eAyXl98Lh8Tq/b7/WefvdA0GZyeoKD
hIWGhnGHhjs3FS0DgzuSk5STHJWTGyAbmJM9Fg0WPZ2YHDMJFRAakhytHDewsbKzsyAlILSxOw0F
DYy5swGoAhAKrbA6ycrLzM06mhvOyTegFjfSy8IVAi/F18kz4eLj5OXm5To7PjutljrkAdoCBsXv
4PH48RgdDhgHAwMeuAD4IAcLEAEAUnDQL5+OEb0s9CrQa4c4fMM8HKh3MV+8BzIQXHARAKQDBTIW
BNhQgsUMGTIcDICZA58OAAU+SCyAs8AI/x0eM25UIKCoBw8vkiqlEHPAhKRMZQxISqJEiBcwYbxg
ukCpAJw6C0i4gRMAN6UpDMRgUANGMaNJU8iduxVlB7kLYCpg8KJqiBQwGawAOWCF3K85JUoIUFbA
3LQH1rpQ8RapXAOYLz+gYNJAXgWfGfgFLEMDhQ4yKGA2gDishASNV2OOXCMDAQgdLKeVjXkmTAwI
YtqogVKBXwN6YQ6Q7QGs4gplPciOzMAFjNsOdkeOwb17DAIRXHgf7x1mjAsXxh94YbSoAfYvtnNn
UP16DggtqLOtwb+///8A8gdTgAQW6IJtBEwwAQ4OZFCddSfAAIMJElaIQoQTqnCCCRGqIGQhCjBR
CIMKKEhIIYkVekiiiB0SQEAOE9gQQUgiIPhiDjjmqOOOPPbo4485KmgDeggM4EELC0QgpA1MNunk
k1BGKeWUTKJ3QQQPzPRCFjS0AAEOYIYp5phklmnmmWa2QEMCPwQBADs=
EOT
        exit;
    }
    elsif ($do eq 'logo') {
        print $c->header('image/gif'),
        decode_base64(<<EOT);
R0lGODlh6gA8AOYAAP//////7///3///z///v+//7///r///n///j9//3///f///b//v////X//v
7///T///P8//z+/v////L///H///D7//v///AK//r8/yz//f///f35//n9/f/4//j//P/3//f//P
z2//b8/P/1//X/+///+/v0//Tz//P/+v/7+//y//L/+vrx//H/+f/w//DwD/AK+v//+fn/+P//+P
j5+f//9///9/f/9v/4+P//9vb/9f/39///9fX/9P/29v//8///9PT19f//8v//8/P/8f/09P//8v
L/8P//8fHz8///8A//8PDy8v//8AAB8f/w8P/wAA/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5
BAAHAP8ALAAAAADqADwAAAf/gACCg4SFhoeIiYqLjI2Oj5CRkpOUlZaXmJmam5ydnp+goaKjpKWm
p6ipqqusra6vsLGys7S1tre4ubq7vL2+v8DBwsPExcbHyMnKy8zNzs/Q0dLT1NXW19jZ2tvc3d7f
4OHi4+SCKiO3CBAK2Q5HTkcOkx8fjC4uqxJNUVE8tQgXArIzJCQKFHSaErSAwbChw4YoCoSS4aTi
DUk4lizBoWiHRh+qVPCL8qQWhIAXIBjqMFLJJhIPYzr0EOpGRScXI2nUWALRh51LNKQSOfIfygaG
iEZxqQmmTJkiat7M+agEUCCIMu7Eh0ppFFsK1gVI2nJTAQ8nUKhdyLCFWrUg/ySCsmkxklWgPQ0h
AQqy68ivv5Qy/QSiIQhHAgggGiHkCUkjNRDRxRkpBdAlWAtZBopkUQILhgIgUDBAwAEFBsYKMqBA
wQHVg7xOMrFhEQMXNmzMYEDIAwqGKEQkKMTawCHBjWhLKszwsKIDD1CmHEAoBpS//JpIGOSAyM3v
TpLUZmTj8pK8g3yYr2eIwwmHKCIMaiAdZQUFAU7aP0BIdo0fSghRw3aHbKBDEjcxQRUALgABBG57
7YRECoL8FhMHgxCAEnWD/IDdSFDEUIiBCFakICTMweDcIQNMUF9AFXAowXUfRpHDID2AB96CiZR3
WWaCMGDeEjMUEsEKMr0gH/8A+r14QQVODgSAVzSO9ARChEwGXg+DDMmZBik+9MIgCqAkZQ01ljWI
lt9x6UiKKxYyAJROXkCBIDn85dhINwrCJng0NOKReejNIOFOOxASwQtPwdCCIE3W6aRiU6YJIoGC
5KjjTTIIEqGX5zHK0AuiwjCmIGUKFJulURiB46acvmnYIQHQCSMEkVJnxEj+SFCDET9gCsANRJQY
HhFEBNoIEDsVsROQzmrk4xJFDFJAqaaq5ZB8kTagAAXS3XeArUhVymo/a4J3RLE3BSGICz+mMMNe
Q2TQ0AsSRSDCCRiQaWZ1SuzDDxRKKBGsn+qyW5G7jcB5CEAwIjBIk4rtyo//Eh0sMhmPjDCrEbw7
9fSTRtUCNYgH99JUYUOgNbnAIOAGxB8AB6CkkrkgDlgQPyUJwsRNRIxnAtBdIjqIBiUwEIFDGB6S
6gVSrnqxIT9XFLQgQ1sta3OHUCyIaLYKAACaev6AZSEb67QTAINixvZOHHl83soMgQbAWaUO5zWk
KFGqYUA3U4kQSyNtl7UTRAwSgncVuQmAyYew1dAJHMiF6r+FIEfI4YkLsvhNji/isCH2BXBAA7Ze
UC4AAmP3wyFpQ2KyBkCl8Gk9WhEpyL0FcEACtiTwHRClTPYtyN8pmQPi2X+pMOxNNIRwwzsJhlC0
RohgIFMLSwLwdNTKT50l//TSU2+i9Q3PSrqkqhMiwc7Y+YP2VJAIuTYAuX86hCCGapQoAI1iSPCE
dwHi7Q15gVPTIJr3PFg5gQnoEwTkDoEByfHucqrKnAIR5kAIPmJ0hZAUBIhHiA7kQAl/gYIhYueI
u7gNAAz41E6KBAAXZqZRKLAbAQ1oPAAgMHxLKcRfMvYnE91AHoSYYPZIYEGVfY8s4kvXphSExK2p
6BAukg4EECA2AAyAUgAyAoE6UCXnja8uVXnWIKa1E97AUEKCQBJ8PDAcAETAbnsr3vCOZzMgDgYA
eRqYIFgAniT0gAWCcIByJHg/I6mlaQAQAUQwCDUoBpEQhPyOIREJAEWOh/8RICTEAkqXIf1MYAQj
aULGAIBCfphRipR5RP9eCEMZ9oWR2IvkBQVhAQutQI8FnFgPf4gzVQKgAzz4ixAS+R2qOOAGVeOk
EgfxHoaozAKT9B7m+rPBTjaTO9CsCCdFp75CCCBcuIoZSlD5lwD9RVgNjKUjpvU/QbCRQoOQW08S
4JAXrOUhwOThHn3Yx7GdKwqrBICmKrIuxtHvcY0kRDXbwsSGREWbGeRmFF91k4buKH1cexj7LvAy
+H3IVfNDoyNyZwNCxJBkhZAbPlEWwKjkcZQDJaZJayS/RBpriuOZpiAW1aglPVGDG/WpAx/4SUWE
shBPq899OlQjKCR0EBT4qYiyHKGej2kGCD5gzyByh08AhKmfzmkShzB6gS4OACUPEEQMLAWFPhEi
BOYDDxEiCMdDRMCCFh1EzQIisUIQrlWHwCus9uoIhdRNEQRAXUAm0ADjZK6VF7sqd3pAhCBUsRF3
GYIbGaGBvQCJl79jyApI0K9BGCAgL3NtBSowM0GMcgJrHYEKYiCEghlMRIhwAA2ox4RkNRUA/ePK
IQoAglK9QGVfcxEEYEMIHhTsbIQQLnGNKwkL1DETElCBCjSrCQagpxyKsoAO0cve9rr3vfCNr3zn
S9/62ve++M2vfvfL3/76978ADrCAB0zgAhv4wAhOsII3EQgAOw==
EOT
        exit;
    }
    elsif ($do eq 'discover') {
        my $ms = SXIP::Membersite->new;
        my $homesite_info = eval {$ms->discover($c->param('dix:/homesite'))};
        if ($@) {
            default_page($@);
        }
        else {
            auto_post_page($homesite_info->{endpoint});
        }
    }
    elsif ($do eq 'verify') {
        my $ms = SXIP::Membersite->new;
        my %message;
        foreach my $name ($c->param) {
            push @{$message{$name}}, $c->param($name);
        }
        my $verified = eval{$ms->verify(\%message, $c->param('persona_url'))};
        if ($@) {
            default_page($@);
        }
        elsif (!$verified) {
            default_page("Homesite message verification failed");
        }
        else {
            success_page();
        }
    }
    else {
        default_page();
    }
}
else {
    default_page();
}

sub auto_post_page {
    my $action = shift;
    print
        $c->header(-cookie=>$c->cookie(-name=>'dix:/homesite', -value=>$c->param('dix:/homesite'), -expires=>'+1y')),
        $c->start_html(-title=>"One moment please...", -onLoad=>'document.sxipForm.submit()'),
        $c->start_form({-name=>"sxipForm", -method=>"post", -action=>$action});
    foreach my $name ($c->param) {
        next if $name eq 'do';
        next if $name eq 'dix:/homesite';
        foreach my $value ($c->param($name)) {
            print $c->hidden($name,$value), "\n";
        }
    }
    print $c->end_form;
}

sub success_page {
    print 
        $c->header,
        $c->start_html("Test Membersite"),
        $c->h1("Test Membersite");
    print $c->div({-style=>'margin: 10px;background: #e6ffe6; padding: 5px;'}, "You successfully sxipped in!");
    print $c->h2("Response message");
    print $c->start_table;
    foreach my $name ($c->param) {
        foreach my $value ($c->param($name)) {
            print $c->Tr($c->td($name),$c->td($value)), "\n";
        }
    }
    print $c->end_table;
    print $c->p($c->a({-href=>"$this_url"}, "Start over"));
}

sub default_page {
    my $error = shift;
    my $homesite = $c->param('dix:/homesite') || $c->cookie('dix:/homesite') || "";
    print 
        $c->header,
        $c->start_html("Test Membersite"),
        $c->h1("Test Membersite");
    print $c->div({-style=>'margin: 10px;background: #ffe6e6; padding: 5px;'}, $error) if $error;
    print <<EOT;
<form class="DIX" method="post" action="?do=discover" accept-charset="utf-8">
    <input type="hidden" name="dix:/message-type" value="dix:/fetch-request" />
    <input type="hidden" name="dix:/membersite-url" value="$this_url?do=verify" />
    <input type="hidden" name="dix:/membersite-path" value="$this_url" />
    <input type="hidden" name="dix:/membersite-name" value="Test Membersite" />
    <input type="hidden" name="dix:/membersite-explanation" value="Test Membersite needs this data to demonstrate how SXIP works" />
    <input type="hidden" name="dix:/membersite-cancel-url" value="$this_url?do=cancel" />
    <input type="hidden" name="dix:/membersite-logo-url" value="$this_url?do=logo" />
    <input type="hidden" name="dix:/required" value="email" />
    <input type="hidden" name="dix:/required" value="persona_url" />
    <input type="hidden" name="alias" value="dix://sxip.net/namePerson/friendly" />
    <input type="hidden" name="email" value="dix://sxip.net/contact/internet/email" />
    <input type="hidden" name="blog_url" value="dix://sxip.net/contact/web/blog" />
    <input type="hidden" name="web_image" value="dix://sxip.net/media/image/small" />
    <input type="hidden" name="persona_url" value="dix:/persona-url" />
    <label for="homesite">homesite</label><br />
    <input type="text" size="12" name="dix:/homesite" value="$homesite" id="homesite" class="input_box"/>
    <input type="image" alt="sxip in" value="sxip in" src="$this_url?do=button" class="btn_sxip_in" id="sxip in" height="20" width="62" /> 
    </form
EOT

    print $c->end_html;
}

