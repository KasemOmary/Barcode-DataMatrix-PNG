#!/usr/bin/perl

package Barcode::DataMatrix::PNG;

use GD;
use Moose;
use Barcode::DataMatrix;

our $VERSION = '0.02';

has 'barcode', is=>'rw', default=>"";
has 'data', is=>'rw', default=>"";
has 'resolution', is=>'rw', default=>3;
has 'target', is=>'rw', default=>'web';
has 'filename', is=>'rw', default=>'output.png';

=head1 NAME

Barcode::DataMatrix::PNG - Generate PNG graphical representations of Data Matrix barcodes

=head1 SYNOPSIS

    use Barcode::DataMatrix::PNG;
    my $data = Barcode::DataMatrix::PNG->new->(barcode=>'test_barcode');
	$bleh->encode();
	$data->render();

=cut

=head1 DESCRIPTION

This class is used to create graphical representations of data matrix barcodes.  It is an extension of the Barcode::DataMatrix class.  
Potential applications include graphically oriented documents such as PDF, printable web documents, invoices, packing lists, shipping labels, etc....

=head1 METHODS

=head2 new (%attributes)

Minimal initiation of a barcode object is new(barcode=>"yourtext").  Options may be added via the C<%attributes> in any order.  Default settings of web output (with header) and a resolution of 3 pixels will be used unless changed.

=cut

=head2 render ()

Render a PNG image of the created barcode.  The graphic will be rendered based on settings selected.

An exception may be thrown by foundation classes if they are unable to generate the barcode data or graphics.

=cut

=head2 echo_barcode()

Echo the barcode data stored in $this->{"barcode"}

=cut



sub encode { 
	my $self = shift;
	$self->data(new Barcode::DataMatrix->barcode($self->barcode));
}

sub render { 
	# Create PNG version of barcode 
	my $self = shift;

	my $dimension = @{$self->data->[0]}; # Width of image
	my $size = ($dimension * $self->resolution); # Size of image, pixel-resolution times width.

	my $img = new GD::Image($size,$size);
	# Render our PNG ; 
	my $white = $img->colorAllocate(255,255,255);
	my $black = $img->colorAllocate(0,0,0);
	$img->setAntiAliasedDontBlend($white);
	$img->setAntiAliasedDontBlend($black);
	# Allocate colors, Don't blend ; Use aliased colors. 
	$img->fill(0,0,$white);
	# Fill the background with white.
	my $x = 0;
	my $y = 0;

	if ($self->target =~ /web/) {
		print "content-type: text/html\n\n";
	}
	binmode STDOUT;

	foreach (@{$self->data}) {
		foreach my $tn (@{$_}) {
			if ($tn == 1) {
				$img->filledRectangle($x,$y,($x + ($self->resolution - 1)),($y + ($self->resolution - 1)),$black);
				# Fill our 1s with black at a size of 'resolution' pixels.
			}
			$x = ($x + $self->resolution);
		}
		$x = 0;
		$y = ($y + $self->resolution);
		print "\n";
	}
	if ($self->target =~ /web/) {
		print $img->png;
	} elsif ($self->target =~ /file/) {
		open(FILE, ">" . $self->filename) || die ("Unable to open " . $self->filename . "\n"); 
		print FILE $img->png;
		close(FILE);
	} else { 
		print "Unrecognized Output Format, reverting to default.\n\n";
		$self->echo_matrix();
	}
	# Dump our image to STDOUT.
}

sub echo_barcode {
	# Dump the text of the matrix.
	my $self = shift;
	print $self->barcode . " \n";
}

sub echo_matrix {
	# Dump the matrix in ascii form. 
	my $self = shift;

	my $l = @{$self->data->[0]};
	
	print "Dims: $l \n\n";

	foreach (@{$self->data}) {
		foreach my $tn (@{$_}) {
			print $tn;
		}
		print "\n";
	}
}

=head1 ATTRIBUTES

=head2 barcode

Ascii string data to be inserted into the barcode. 

=head2 resolution

The resolution (in pixels) of the barcode to be generated.   The default setting is C<3> pixels resolution.

=head2 target

C<web> or C<file> - Web output includes a standard header for the PNG format, file outputs to <filename>.   Default output is C<web>

=head2 filename

An arbitrary filename for disk output.  The default output filename is C<output.png>.


=cut

=head1 AUTHOR

Kasem Omary<< <kasemo@gmail.com> >> 

=head1 SOURCE REPOSITORY

L<https://github.com/KasemOmary/Barcode-DataMatrix-PNG>

=head1 SEE ALSO

=over 4

=item L<HTML::Barcode::DataMatrix>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014 the AUTHORs listed above.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


no Any::Moose;
1;