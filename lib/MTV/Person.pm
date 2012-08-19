package MTV::Person;

# ABSTRACT: a person having a first and a last name and a birthday

use strict;
use warnings;

use Moose;

has 'first_name'   => ( is => 'rw', isa => 'Str' );
has 'last_name' => ( is => 'rw', isa => 'Str' );
has 'birthday'  => ( is => 'rw' );

1;
