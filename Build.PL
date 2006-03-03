use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'SXIP::Membersite',
    license             => 'bsd',
    dist_author         => 'Sxip Identity <dev@sxip.org>',
    dist_version_from   => 'lib/SXIP/Membersite.pm',
    build_requires => {

        # required by SXIP::Membersite:
        'Carp' => 0,
        'HTML::TreeBuilder' => 0,
        'LWP::UserAgent' => 0,
        'SXIP::Digest' => '0.0.1',
        'URI' => 0,

        # required for the demo membersite CGI:
        'CGI' => 0,
        'FindBin' => 0,
        'MIME::Base64' => 0,

        # required to run tests:
        'Test::More' => 0,
    },
    create_makefile_pl  => 'passthrough',
    add_to_cleanup      => [ 'SXIP-Membersite-*' ],
);

$builder->create_build_script();
