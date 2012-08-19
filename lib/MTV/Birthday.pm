package MTV::Birthday;

# ABSTRACT: a birthday

use strict;
use warnings;

use Moose;

has 'contents' => ( is => 'rw', isa => 'Str' );

has 'day'   => ( is => 'rw', isa => 'Str' );
has 'month' => ( is => 'rw', isa => 'Str' );
has 'year'  => ( is => 'rw', isa => 'Str' );

sub parse {
	my ($self) = @_;
	
	if ( $self->contents =~ m/^(\d{2}).(\d{2}).(\d{4})$/ ) {
		$self->day($1);
		$self->month($2);
		$self->year($3);
		return $self;
	}
	
	die "Unable to parse birthday: '".$self->contents."'";
}

=head2 ddmm

Returns a concatenation of day and month, seperated by periods.

Throws exceptions if day or month is not set.

=cut

sub ddmm {
	my ($self) = @_;
	
	die 'day is not set' unless defined $self->day;
	die 'month is not set' unless defined $self->month;
	
	return $self->day.'.'.$self->month.'.';
}

1;
