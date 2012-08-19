#! /usr/bin/env perl

use Test::Most;
use Test::Trap;

use Test::MockModule;

BEGIN {
	use_ok('MTV::Person');
	use_ok('MTV::NameCellFormatter');
}

# simple
{
	my $birthday = Test::MockModule->new('MTV::Birthday');
	my $person = MTV::Person->new(
		first_name => 'Gregor',
		last_name  => 'Goldbach',
		birthday   => $birthday
	);
	my $formatter=MTV::NameCellFormatter->new(person => $person);

	my $expected='<cell alignment="left" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\size footnotesize
Gregor Goldbach
\end_layout

\end_inset
</cell>
';
	eq_or_diff $formatter->format, $expected;
}
done_testing;
