#!/usr/bin/perl
use Barcode::DataMatrix::PNG;

my $bleh = new Barcode::DataMatrix::PNG(barcode=>"This is a test barcode This is a test barcode This is a test barcode.", resoultion=>3, target=>'stdout');

$bleh->encode();
$bleh->render();

$bleh->barcode('Rectangles Rule');
$bleh->size('16x48');
$bleh->target('pass');
$bleh->encode();
open my $fh, '>', 'barcode1648.png' or die "cannot write to file";
binmode $fh;
print $fh $bleh->render();
close $fh;