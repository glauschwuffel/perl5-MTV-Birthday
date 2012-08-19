package MTV::NameCellFormatter;

# ABSTRACT: formats a person's name as a LyX table cell

use strict;
use warnings;

use Moose;

has 'person'   => ( is => 'rw', isa => 'MTV::Person' );

sub format {
	my ($self)=@_;
	
	return '<cell alignment="left" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\size footnotesize
' . $self->person->first_name . ' ' . $self->person->last_name . '
\end_layout

\end_inset
</cell>
';
}

1;

