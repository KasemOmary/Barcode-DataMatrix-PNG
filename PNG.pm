#!/usr/bin/perl

package Barcode::DataMatrix::PNG;

use GD;
use Moose;
use Barcode::DataMatrix;

has 'barcode', is=>'rw', default=>"";
has 'data', is=>'rw', default=>"";
has 'resolution', is=>'rw', default=>3;
has 'target', is=>'rw', default=>'web';
has 'filename', is=>'rw', default=>'output.png';

=head1 NAME

Barcode::DataMatrix - Generate data for Data Matrix barcodes

=head1 SYNOPSIS

    use Barcode::DataMatrix::PNG;
    my $data = Barcode::DataMatrix::PNG->new->(barcode=>'test_barcode',size=>'3');
	my $image = $data->render();
=cut

=head1 DESCRIPTION

This class is used to create graphical representations of data matrix barcodes.  It is an extension of the Barcode::DataMatrix class.  
Potential applications include graphically oriented documents such as PDF, printable web documents, invoices, packing lists, shipping labels, etc....

=head1 METHODS

=head2 new (%attributes)



=cut

=head2 render ()

Render a PNG image of the created barcode.

This can throw an exception if it's unable to generate the barcode data.

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



=head2 length


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