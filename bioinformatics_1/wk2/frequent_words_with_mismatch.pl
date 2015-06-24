#!/bin/perl
use strict;
use warnings;
use List::Util qw( max );
use List::MoreUtils qw( uniq );

sub HammingDistance;
sub PatternCount;
sub FrequentWordsWithMismatch; #(text, k, d)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;

my @params = split(" ",$data[1]);

printf("%s\n",join(' ',&FrequentWordsWithMismatch($data[0],$params[0],$params[1])));

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

sub PatternCount
{
    my $text = $_[0];
    my $pattern = $_[1];
    my $d = $_[2];
    my $index = 0;
    my $count = 0;

    chomp($text);
    chomp($pattern);

    for($index=0;$index<=length($text)-length($pattern);$index++)
    {
        if(&HammingDistance($pattern,substr($text,$index,length($pattern))) <= $d)
        {
            $count++;
        }
    }
    $count;
}

sub FrequentWordsWithMismatch #(Text, k, d)
{
    my $text = $_[0];
    my $k = $_[1];
    my $d = $_[2];
    chomp($text);
    my @frequent_patterns;
    my $index;
    my $pattern;
    my @count;
    my $max_count=0;
    
    for($index=0;$index<=(4**$k);$index++)
    {
        $pattern = &NumberToPattern($index,$k);
        $count[$index] = &PatternCount($text,$pattern,$d);
    }
    $max_count = max(@count);
    for($index=0;$index<=(4**$k);$index++)
    {
        if($count[$index] == $max_count)
        {
            push(@frequent_patterns,&NumberToPattern($index,$k));
        }
    }
    uniq(@frequent_patterns);
}
