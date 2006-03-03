#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'SXIP::Membersite' );
}

diag( "Testing SXIP::Membersite $SXIP::Membersite::VERSION, Perl $], $^X" );
