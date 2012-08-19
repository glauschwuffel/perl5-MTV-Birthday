#! /usr/bin/env perl

use Test::Most;
use Test::Trap;

use Test::MockModule;

BEGIN {
	use_ok('MTV::Person');
	use_ok('MTV::Birthday');
	use_ok('MTV::PersonCellPairFormatter');
}

# simple
{
	my $birthday=MTV::Birthday->new(day=>'01', month => '10');
	my $person = MTV::Person->new(
		first_name => 'Gregor',
		last_name  => 'Goldbach',
		birthday   => $birthday
	);
	my $formatter=MTV::PersonCellPairFormatter->new(person => $person);

	my $expected='<cell alignment="left" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\size footnotesize
Gregor Goldbach
\end_layout

\end_inset
</cell>
<cell alignment="right" valignment="top" usebox="none">
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
