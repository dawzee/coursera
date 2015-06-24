#!/bin/perl
$|++;
use strict;
use warnings;

sub HammingDistance;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp($data[0]);
chomp($data[1]);

printf("%d\n",&HammingDistance($data[0],$data[1]));

sub HammingDistance
{
    my @string1 = split("",$_[0]);
    my @string2 = split("",$_[1]);
    my $count;
    my $mismatch = 0;

    for($count=0;$count<length($_[0]);$count++)
    {
        if($string1[$count] ne $string2[$count])
        {
            $mismatch++;
        }
    }
    $mismatch;
}
