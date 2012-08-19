#! /usr/bin/env perl

use Test::Most;
use Test::Trap;

BEGIN {
	use_ok('MTV::Birthday');
}

# simple
{
	my $birthday = MTV::Birthday->new( contents => '01.10.1970' );
	$birthday->parse;

	eq_or_diff $birthday->ddmm, '01.10.', 'simple date works';
}

# chained
{
	my $birthday = MTV::Birthday->new( contents => '01.10.1970' );

	eq_or_diff $birthday->parse->ddmm, '01.10.', 'parse call may be chained';
}

# exception if unable to parse
{
	my $birthday = MTV::Birthday->new( contents => 'i am no date' );
	trap { $birthday->parse };
	like( $trap->die, qr/^Unable to parse birthday\b/, 'exception raised upon parsing error' );
}

done_testing;
