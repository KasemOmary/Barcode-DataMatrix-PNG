#!/usr/bin/perl
use GD;
use Barcode::DataMatrix;

#my $img = new GD::Image(100,100);
$data = "";
if ($ENV{QUERY_STRING}=~/\w/) {
        $data = $ENV{QUERY_STRING};
        $data =~ s/\W//g;
} else {
        $data = "This is a test barcode This is a test barcode This is a test barcode.";
}

my $code = new Barcode::DataMatrix->barcode($data);

$l = @{$code->[0]};

$size = 3 * $l;
#print "Size: $size x $size\n\n";

my $img = new GD::Image($size,$size);
$white = $img->colorAllocate(255,255,255);
$black = $img->colorAllocate(0,0,0);
$img->setAntiAliasedDontBlend($white);
$img->setAntiAliasedDontBlend($black);

$img->fill(0,0,$white);

# $img->filledRectangle(10,10,20,20,$black);

binmode STDOUT;

print "content-type: image/png\n\n";
#print $img->png;

$x = 0;
$y = 0;

foreach $arr (@$code) {
        foreach $block(@$arr) {
 #               print "$block";
                                if ($block == 1) {
                                        $img->filledRectangle($x,$y,($x+2),($y+2),$black);
                                }
#                print "$x,$y," . ($x+3) . "," . ($y+3) . "--";
                $x += 3;
        }
        $x = 0;
#        print "\n";
        $y += 3;
}

print $img->png;
