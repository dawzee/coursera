#!/bin/perl
$|++;
use strict;
use warnings;

sub HammingDistance;
sub ApproximatePatternMatching;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp($data[0]);
chomp($data[1]);

printf("%s\n",join(" ",&ApproximatePatternMatching($data[0],$data[1],$data[2])));

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

sub ApproximatePatternMatching
{
    my $pattern = $_[0];
    my $text = $_[1];
    my $d = $_[2];
    my $index;
    my @start_points = ();

    for($index=0;$index<=length($text)-length($pattern);$index++)
    {
        if(&HammingDistance($pattern,substr($text,$index,length($pattern))) <= $d)
        {
            push(@start_points,$index);
        }
    }
    @start_points;
}
