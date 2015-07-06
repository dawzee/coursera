#!/bin/perl
$|++;
use strict;
use warnings;

sub NumberToPattern; #(number, base)
sub HammingDistance; #(string1, string2)
sub DistanceBetweenPatternAndStrings; #(Pattern, Dna)
sub MedianString; #(Dna, k)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

my @dna = @data[ 1 .. $#data ];

printf("%s\n",join("\n",&MedianString(\@dna,$data[0])));

sub NumberToPattern #(number, base)
{
    my $number = $_[0];
    my $base = $_[1];
    my $multiplier = 4 ** ($base-1);
    my $output = "";
    #printf("%d %d\n",$multiplier,$number);
    for(;$base>0;$base--)
    {
        if($multiplier * 3 <= $number)
        {
            $output .= "T";
            $number -= $multiplier * 3;
        }
        elsif($multiplier * 2 <= $number)
        {
            $output .= "G";
            $number -= $multiplier * 2;
        }
        elsif($multiplier <= $number)
        {
            $output .= "C";
            $number -= $multiplier;
        }
        else
        {
            $output .= "A";
        }
        $multiplier = $multiplier / 4;
        #printf("(%d)[%d]",$number,$multiplier);
    }
    $output;
}

sub HammingDistance #(string1, string2)
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

sub DistanceBetweenPatternAndStrings #(Pattern, Dna)
{
    my($pattern,$dna) = @_;
    my $k = length($pattern);
    my $distance;
    
    #printf("DistanceBetweenPatternAndString pattern=%s dna=(%s)\n",$pattern,join(":",@{dna}),$k);
    
    foreach my $string (@{$dna})
    {
        my $min_hamming_distance = 9**9**9;
        for(my $index=0;$index<=length($string)-$k;$index++)
        {
            my $hamming_distance = &HammingDistance($pattern,substr($string,$index,$k));
            if($min_hamming_distance > $hamming_distance)
            {
                $min_hamming_distance = $hamming_distance;
            }
        }
        $distance += $min_hamming_distance;
    }
    $distance;
}

sub MedianString #(Dna, k)
{
    my($dna,$k) = @_;
    my $distance = 9**9**9;
    my @median = ();
    
    #printf("MedianString dna=(%s) k=%d\n",join(":",@{dna}),$k);
    
    for(my $index=0;$index<(4**$k);$index++)
    {
        my $pattern = &NumberToPattern($index,$k);
        my $pattern_distance = &DistanceBetweenPatternAndStrings($pattern, $dna);
        if($distance>$pattern_distance)
        {
            $distance = $pattern_distance;
            @median = ();
            push(@median,$pattern);
        }
        elsif($distance==$pattern_distance)
        {
            push(@median,$pattern);
        }
    }
    @median;
}
