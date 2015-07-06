#!/bin/perl
$|++;
use strict;
use warnings;
#use List::MoreUtils qw( uniq );

sub HammingDistance;
sub Neighbourhood;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp($data[0]);

printf("%s\n",join("\n",&Neighbourhood($data[0],$data[1])));


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
    my @neighbourhood = ();
    my @suffix_neighbours = ();
    my $text;
    
    if($d == 0)
    {
        return $pattern;
    }
    if(length($pattern) == 1)
    {
       return ('A', 'T', 'G', 'C');
    }
    @suffix_neighbours = &Neighbourhood(substr($pattern,1,length($pattern)-1),$d);
    foreach $text (@suffix_neighbours)
    {
        if(&HammingDistance(substr($pattern,1,length($pattern)-1),$text) < $d)
        {
            push(@neighbourhood,'A'.$text);
            push(@neighbourhood,'T'.$text);
            push(@neighbourhood,'C'.$text);
            push(@neighbourhood,'G'.$text);
        }
        else
        {
            push(@neighbourhood,substr($pattern,0,1).$text);
        }
    }
    @neighbourhood;
}
