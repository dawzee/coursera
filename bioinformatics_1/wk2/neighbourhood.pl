#!/bin/perl
$|++;
use strict;
use warnings;
use List::MoreUtils qw( uniq );

sub NumberToPattern;
sub HammingDistance;
sub Neighbourhood;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp($data[0]);

printf("%d\n",&Neighbourhood($data[0],$data[1]));

sub NumberToPattern
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

sub Neighbourhood
{
    my $pattern = $_[0];
    my $d = $_[1];
    my $index;
    my $test;
    my @set = ();
    my $count = 0;
    
    for($index=0;$index<=4**length($pattern);$index++)
    {
        $test = &NumberToPattern($index,length($pattern));
        if(&HammingDistance($pattern,$test) <= $d)
        {
            push(@set,$test);
        }
    }
    scalar uniq(@set);
}
