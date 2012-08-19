package MTV::PersonCellPairFormatter;

# ABSTRACT: formats a person name and birthday as a LyX pair of table cells

use strict;
use warnings;

use Moose;

use MTV::NameCellFormatter;
use MTV::BirthdayCellFormatter;

has 'person'   => ( is => 'rw' );

sub format {
	my ($self)=@_;
	
	my $name_formatter=MTV::NameCellFormatter->new(person=>$self->{person});
	my $birthday_formatter=MTV::BirthdayCellFormatter->new(person=>$self->{person});

	return $name_formatter->format()	.$birthday_formatter->format();
}

1;

