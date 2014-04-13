#!/usr/bin/perl
use Barcode::DataMatrix::PNG;

my $bleh = new Barcode::DataMatrix::PNG(barcode=>"This is a test barcode This is a test barcode This is a test barcode.", resoultion=>3, target=>'stdout');

$bleh->encode();
$bleh->render();

