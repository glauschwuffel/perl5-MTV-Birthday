package MTV::BirthdayCellFormatter;

# ABSTRACT: formats a person's birthday as a LyX table cell

use strict;
use warnings;

use Moose;

has 'person'   => ( is => 'rw', isa => 'MTV::Person' );

sub format {
	my ($self)=@_;
	
	return '<cell alignment="right" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\size footnotesize
' . $self->person->birthday->ddmm . '
\end_layout

\end_inset
</cell>
';
}

1;

