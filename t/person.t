#! /usr/bin/env perl

use Test::Most;
use Test::Trap;

BEGIN {
	use_ok('MTV::Birthday');
	use_ok('MTV::Person');
}

# simple
{
	my $birthday = MTV::Birthday->new( contents => '01.10.1970' );
	$birthday->parse;
	my $person = MTV::Person->new(
		first_name => 'Gregor',
		last_name  => 'Goldbach',
		birthday   => $birthday
	);

	eq_or_diff $birthday->ddmm, '01.10.', 'simple date works';
}
done_testing;
