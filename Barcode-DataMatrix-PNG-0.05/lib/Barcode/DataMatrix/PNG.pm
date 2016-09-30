#!/usr/bin/perl

package Barcode::DataMatrix::PNG;

use GD;
use Moose;
use Barcode::DataMatrix;
use Carp;

our $VERSION = '0.05';   # petercj@cpan.org

has 'barcode', is=>'rw', default=>undef;
has 'data', is=>'rw', default=>undef;
has 'resolution', is=>'rw', default=>3;
has 'target', is=>'rw', default=>'stdout';

# v0.05: allow passing in the Barcode::DataMatrix %attributes; must be set before the ->encode
has 'size', is=>'rw', default=>undef;				# requires Barcode::DataMatrix::VERSION >= 0.09
has 'encoding_mode', is=>'rw', default => undef;	# requires Barcode::DataMatrix::VERSION >= 0.01
has 'process_tilde', is=>'rw', default => undef;	# requires Barcode::DataMatrix::VERSION >= 0.01

=head1 NAME

Barcode::DataMatrix::PNG - Generate PNG graphical representations of Data Matrix barcodes

=head1 SYNOPSIS

    use Barcode::DataMatrix::PNG;
    my $data = Barcode::DataMatrix::PNG->new(barcode=>'test_barcode');
                                            # Minimal call for a new object.
    $data->encode();                        # Encode the Barcode data.
    $data->render();                        # Default:  Render the image to <STDOUT>

    $data->target('pass');                  # Alternate: set to return() image on ->render(), instead
    my $barcode = $data->render();          # Return a PNG representation of a DataMatrix Barcode.
    my $my_barcode = $data->echo_barcode(); # Return a human-readable string of the encoded data.

    $data->barcode("A new barcode.");       # To render a new barcode with the same object.
    $data->target('stdout');                # return to default rendering
    $data->encode();
    $data->render();                        # etc.

    $data->barcode('Rectangles Rule!');
    $data->size('16x48');                   # pass 'size' attribute to Barcode::DataMatrix->new() (Barcode::DataMatrix v0.09 or above)
    $data->encode();                        # requires re-encoding
    $data->resolution(4);                   # change to 4x4 pixels per bit
    $data->render();                        # results in 16x48 * 4px/bit => 64px x 192px image


=cut

=head1 DESCRIPTION

This class is used to create graphical representations of data matrix barcodes.  It is an extension of the Barcode::DataMatrix class.
Potential applications include graphically oriented documents such as PDF, printable web documents, invoices, packing lists, shipping labels, etc....

=head1 METHODS

=head2 new (%attributes)

Minimal initiation of a barcode object is new(barcode=>"yourtext").  Options may be added via the C<%attributes> in any order.

Default settings of output to C<STDOUT> with a resolution of 3 pixels will be used unless changed.

=cut

=head2 encode ()

Encode the barcode string into DataMatrix format.  An C<encode()> must be completed prior to rendering a barcode.

=cut

=head2 render ()

Render a PNG image of the created barcode.  The graphic will be rendered based on settings selected.

An exception may be thrown by foundation classes if they are unable to generate the barcode data or graphics.

=cut

=head2 echo_barcode()

Echo a human-readable representation of the barcode data stored in $this->{"barcode"}

=cut

=head2 size()

The size of each module for the data matrix; if defined, this value is passed to C<Barcode::DataMatrix::new()>.

Only available with C<$Barcode::DataMatrix::VERSION ge '0.09'>.  If the available L<Barcode::DataMatrix> version is older
than v0.09, this parameter will be ignored, and the square that best fits the data will be automatically selected (which is
also what happens if this parameter is not defined).

See L<Barcode::DataMatrix> for list of allowable sizes.

=cut

=head2 encoding_mode()

The encoding mode for the data matrix; if defined, this value is passed to C<Barcode::DataMatrix::new()>.

See L<Barcode::DataMatrix> for list of allowable modes.

=cut

=head2 process_tilde()

If true, the tilde character "~" will be used to indicate special characters; if defined, this value is passed to C<Barcode::DataMatrix::new()>.

See L<Barcode::DataMatrix> and L<http://www.idautomation.com/datamatrixfaq.html> for more information.

=cut


sub encode {
	my $self = shift;

	unless (defined $self->barcode) {
		croak("Barcode::DataMatrix::PNG : Barcode data string \$PNGobj->barcode is undefined.  Barcode contains no data.  Set \$PNGobj->barcode prior to \$PNGobj->encode().");
	}

    my %opts;
    $opts{size} = $self->size                       if defined $self->size && $Barcode::DataMatrix::VERSION ge '0.09';
    $opts{encoding_mode} = $self->encoding_mode     if defined $self->encoding_mode;
    $opts{process_tilde} = $self->process_tilde     if defined $self->process_tilde;

	#$self->data(new Barcode::DataMatrix->barcode($self->barcode));
	$self->data(Barcode::DataMatrix->new(%opts)->barcode($self->barcode));
}

sub render {
	# Create PNG version of barcode
	my $self = shift;

	unless (defined $self->data) {
		croak("Barcode::DataMatrix::PNG : Barcode matrix data \$PNGobj->data is undefined, barcode must \$PNGobj->encode() prior to \$PNGobj->render().");
	}

    # v0.05: petercj@cpan.org = split $dimension and $size into $dimw,$dimh and $sizw,$sizh to allow for rectangular barcodes (added in Barcode::DataMatrix 0.09, 2016-May-18)
	my $dimw = @{$self->data->[0]}; # Width of image
    my $dimh = @{$self->data};      # Height of image   # v0.05: petercj@cpan.org
	my $sizw = ($dimw * $self->resolution); # width of image in pixels = pixel-resolution times width.
	my $sizh = ($dimh * $self->resolution); # height of image in pixels = pixel-resolution times height.    # v0.05: petercj@cpan.org

	my $img = new GD::Image($sizw,$sizh);   # v0.05: petercj@cpan.org
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

	unless ($self->target =~ /pass/i) {
		binmode STDOUT;
	}

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
	}
	if ($self->target =~ /pass/i) {
		# Return the png image.
		return ($img->png);
	} else {
		# Dump our image to STDOUT.
		print $img->png;
		return 1;
	}
}

sub echo_barcode {
	# Dump the text of the matrix.
	my $self = shift;
	return $self->barcode;
	# Useful for Human-readable string.
}

=head1 ATTRIBUTES

=head2 barcode

Ascii string data to be inserted into the barcode.

=head2 resolution

The resolution (in pixels) of the barcode to be generated.   The default setting is C<3> pixels resolution.

=head2 target

Default output is C<stdout>.  Options are C<stdout> or C<pass>.  Pass will C<return()> the barcode PNG data for use.

=cut

=head1 AUTHOR

Kasem Omary<< <kasemo@cpan.org> >>

v0.05 updates by Peter C. Jones<< <petercj@cpan.org> >>

=head1 SOURCE REPOSITORY

L<https://github.com/KasemOmary/Barcode-DataMatrix-PNG>

=head1 SEE ALSO

=over 4

=item L<HTML::Barcode::DataMatrix>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2014-2016 the AUTHORs listed above.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


no Any::Moose;
1;
