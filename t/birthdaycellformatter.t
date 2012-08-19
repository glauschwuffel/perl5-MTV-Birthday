#! /usr/bin/env perl

use Test::Most;
use Test::Trap;

use Test::MockModule;

BEGIN {
	use_ok('MTV::Person');
	use_ok('MTV::Birthday');
	use_ok('MTV::BirthdayCellFormatter');
}

# simple
{
	my $birthday=MTV::Birthday->new(day=>'01', month => '10');
	my $person = MTV::Person->new(
		first_name => 'unused',
		last_name  => 'unused',
		birthday   => $birthday
	);
	my $formatter=MTV::BirthdayCellFormatter->new(person => $person);

	my $expected='<cell alignment="right" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\size footnotesize
01.10.
\end_layout

\end_inset
</cell>
';
	eq_or_diff $formatter->format, $expected;
}
done_testing;
