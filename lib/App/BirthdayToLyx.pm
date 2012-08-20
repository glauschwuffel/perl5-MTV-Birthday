package App::BirthdayToLyx;

# ABSTRACT: main package for the birthday2lyx tool

use strict;
use warnings;

use English qw( -no_match_vars );    # Avoids regex performance penalty
use Getopt::Long;
use Text::CSV;
use Encode qw(from_to);

use MTV::Birthday;
use MTV::Person;
use MTV::PersonCellPairFormatter;

our @entries;

=head2 new

The C<new> constructor is quite trivial at this point, and is provided
merely as a convenience. You don't really need to think about this.

=cut

sub new {
	return bless {}, shift;
}

=method process_args (@args)

Processes the arguments with <Getopt::Long>. Results of the parsing
will be stuffed in the object's attributes. What's not an option is
stuffed in the C<argv> attribute for later procession.

=cut

sub process_args {
	my ( $self, @args ) = @_;

	# Getopt::Long processes ARGV
	local @ARGV = @args;
	Getopt::Long::Configure(qw(no_ignore_case bundling pass_through));

	GetOptions(
		'f|file=s'    => \$self->{file},
		'o|outfile=s' => \$self->{outfile},
		'h|help|?'    => \$self->{show_help},
		'man'         => sub {
			require Pod::Usage;
			Pod::Usage::pod2usage( { -verbose => 2 } );
			exit;
		},
		'v|verbose!' => \$self->{verbose},
		'version'    => \$self->{show_version}
	) or App::Perlanalyst::die('Unable to parse options');

	# Stash the remainder of argv for later
	$self->{argv} = [@ARGV];
}

sub run {
	my ($self) = @_;

	# Show version or help?
	return $self->show_version if $self->{show_version};
	return $self->show_help    if $self->{show_help};

	$self->_redirect_stdout_to_file if $self->{outfile};

	return 1 if $self->_process_file;

	# We should never get here. If we do, the logic above is strange
	# and we have a bug.
	_bug('Strange logic in run()');

}

=head2 die ($message)

Exits the program with the given message and a proper error
code for the shell.

=cut

# taken from App::Ack
sub die {
	my $program = File::Basename::basename($0);
	return CORE::die( $program, ': ', @_, "\n" );
}

=head2 _bug ($message)

This is an internal function that exits the program with
the given message and adds a phrase asking the user to report
this bug.

=cut

sub _bug {
	my ($message) = @_;
	$message .= '. This is a bug. Please report it so we can fix it.';
	&die($message);    # The ampersand calls the die() in this package.
}

sub _process_file {
	my ($self) = @_;

	my $csv = Text::CSV->new(
		{
			binary   => 1,
			sep_char => ';'
		}
	) or &die( "Cannot use CSV: " . Text::CSV->error_diag() );

	open my $fh, "<", $self->{file}
	  or &die( "Unable to open file '" . $self->{file} . "': " . $OS_ERROR );

	my $last_month = 'i am no month';
	while ( my $row = $csv->getline($fh) ) {
		my $first_name = $row->[1];
		my $last_name  = $row->[0];
		my $birthday   = $row->[2];

		next
		  if (  ( $first_name eq 'Vorname' )
			and ( $last_name eq 'Nachname' )
			and ( $birthday  eq 'Geburtsdatum' ) );

		from_to( $first_name, 'iso-8859-1', 'utf-8' );
		from_to( $last_name,  'iso-8859-1', 'utf-8' );

		my $b = MTV::Birthday->new( contents => $birthday )->parse;
		my $this_month = $b->month;
		_add_month_cell($this_month) if $this_month ne $last_month;
		$last_month = $this_month;

		_add_entry( $first_name, $last_name, $b );

	}

	$csv->eof or $csv->error_diag();
	close $fh;

	_print_document();

	return 1;
}

sub _redirect_stdout_to_file {
	my ($self) = @_;

	open my $fh, '>', $self->{outfile}
	  or &die(
		"Unable to open output file '" . $self->{outfile} . "': $OS_ERROR" );

	select $fh;
}

sub _add_entry {
	my ( $first_name, $last_name, $birthday ) = @_;

	my $person = MTV::Person->new(
		first_name => $first_name,
		last_name  => $last_name,
		birthday   => $birthday
	);

	push @entries, $person;
}

sub _add_month_cell {
	my ($month) = @_;

	my @month_names=qw(Januar Februar MŠrz April Mai Juni Juli August
	September Oktober November Dezember);

	my $month_number=($month+0)-1; # force conversion to number by adding 0
	my $month_name=$month_names[$month_number];
	
	my $month_cell_pair =
	  _start_month_multi_cell($month_name) . _end_month_multi_cell();

	push @entries, $month_cell_pair;
}

sub _print_document {
	_print_preamble();
	_print_open_table();
	_print_table();
	_print_close_table();
	_print_closing();
}

=head2 _print_open_table

…ffnet die Tabellenbeschreibung. Es werden fest sechs Spalten angegeben.
Dies sind drei Spaltenpaare: In der ersten steht der Name und in der zweiten der
Geburtstag.

=cut

sub _print_open_table {
	my ( $number_of_lines, undef ) = _number_of_lines( scalar @entries, 3 );

	print '\begin_layout Standard
\noindent
\begin_inset Tabular
<lyxtabular version="3" rows="' . $number_of_lines . '" columns="6">
<features tabularvalignment="middle">
'
	  . _name_cell_declaration()
	  . _birthday_cell_declaration()
	  . _name_cell_declaration()
	  . _birthday_cell_declaration()
	  . _name_cell_declaration()
	  . _birthday_cell_declaration();

=pod

      . '
<row>
'
      . _start_month_multi_cell('August')
      . _end_month_multi_cell()
      . _start_month_multi_cell('August')
      . _end_month_multi_cell()
      . _start_month_multi_cell('August')
      . _end_month_multi_cell() . '</row>
'

=cut

}

sub _print_rows {
	_print_row(0);
	for my $row (@entries) {
		print "<row>\n";
		print $row;
		print _empty_cell();
		print _empty_cell();
		print _empty_cell();
		print _empty_cell();
		print "</row>\n";
	}
}

sub _print_close_table {
	print '</lyxtabular>

\end_inset


\end_layout
';
}

sub _print_preamble {
	print '#LyX 2.0 created this file. For more info see http://www.lyx.org/
\lyxformat 413
\begin_document
\begin_header
\textclass scrartcl
\use_default_options true
\maintain_unincluded_children false
\language ngerman
\language_package babel
\inputencoding auto
\fontencoding global
\font_roman default
\font_sans default
\font_typewriter default
\font_default_family default
\use_non_tex_fonts false
\font_sc false
\font_osf false
\font_sf_scale 100
\font_tt_scale 100

\graphics default
\default_output_format default
\output_sync 0
\bibtex_command default
\index_command default
\paperfontsize default
\spacing single
\use_hyperref true
\pdf_author "Gregor Goldbach"
\pdf_bookmarks true
\pdf_bookmarksnumbered false
\pdf_bookmarksopen false
\pdf_bookmarksopenlevel 1
\pdf_breaklinks false
\pdf_pdfborder false
\pdf_colorlinks false
\pdf_backref false
\pdf_pdfusetitle true
\papersize default
\use_geometry false
\use_amsmath 1
\use_esint 1
\use_mhchem 1
\use_mathdots 1
\cite_engine basic
\use_bibtopic false
\use_indices false
\paperorientation portrait
\suppress_date false
\use_refstyle 1
\index Index
\shortcut idx
\color #008000
\end_index
\secnumdepth 3
\tocdepth 3
\paragraph_separation indent
\paragraph_indentation default
\quotes_language danish
\papercolumns 1
\papersides 1
\paperpagestyle default
\tracking_changes false
\output_changes false
\html_math_output 0
\html_css_as_file 0
\html_be_strict false
\end_header

\begin_body

';
}

sub _print_closing {
	print '
\begin_layout Standard

\end_layout

\end_body
\end_document

';
}

sub _empty_cell {
	return '<cell alignment="right" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\end_layout

\end_inset
</cell>
';
}

sub _empty_cell_pair {
	return '<cell alignment="left" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\size footnotesize

\end_layout

\end_inset
</cell>
<cell alignment="right" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\size footnotesize

\end_layout

\end_inset
</cell>
';
}

sub _name_cell_declaration {
	return '<column alignment="left" valignment="top" width="4cm">
';
}

sub _birthday_cell_declaration {
	return '<column alignment="right" valignment="top" width="0">
';
}

sub _start_month_multi_cell {
	my ($month_name) = @_;

	return
	  '<cell multicolumn="1" alignment="center" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\series bold
\size footnotesize
' . $month_name . '\end_layout

\end_inset
</cell>
';
}

sub _end_month_multi_cell {
	return
	  '<cell multicolumn="2" alignment="right" valignment="top" usebox="none">
\begin_inset Text

\begin_layout Plain Layout

\end_layout

\end_inset
</cell>
';
}

=head2 _number_of_lines ($number_of_entries, $columns)

Berechnet die Anzahl der Zeilen, die benötigt werden, um
eine Anzahl von Einträgen auf eine Anzahl von Spalten zu verteilen.

Ergebnis: Anzahl Zeilen und Anzahl der leeren Zellen am Ende.

=cut

sub _number_of_lines {
	my ( $number_of_entries, $columns ) = @_;

	my $number_of_lines = int( $number_of_entries / $columns ) + 1;
	my $empty_cells = $number_of_entries - ( $number_of_lines * $columns );

	return ( $number_of_lines, $empty_cells );
}

# wir haben Spaltenpaare, daher 3 und nicht 6
sub _print_table {
	my ( $number_of_lines, undef ) = _number_of_lines( scalar(@entries), 3 );
	for my $row_number ( 0 .. $number_of_lines - 1 ) {
		_print_row($row_number);
	}
}

# wir haben Spaltenpaare, daher 3 und nicht 6
sub _print_row {
	my ($row_number) = @_;
	my ( $number_of_lines, undef ) = _number_of_lines( scalar @entries, 3 );
	my @r;
	$r[0] = _get_cell_pair($row_number);
	$r[1] = _get_cell_pair( $row_number + $number_of_lines );
	$r[2] = _get_cell_pair( $row_number + $number_of_lines * 2 );

	print STDERR $row_number, ' ', $row_number + $number_of_lines, ' ',
	  $row_number + $number_of_lines * 2, "\n";
	print "<row>\n$r[0]$r[1]$r[2]</row>\n";
}

sub _get_cell_pair {
	my ($cell_number) = @_;

	return _empty_cell_pair() if $cell_number >= scalar @entries;

	my $entry = $entries[$cell_number];

	# is the entry a person?
	if ( ref($entry) eq 'MTV::Person' ) {
		my $formatter = MTV::PersonCellPairFormatter->new( person => $entry );
		return $formatter->format();
	}

	# no person, return as it is
	return $entry;
}

1;
