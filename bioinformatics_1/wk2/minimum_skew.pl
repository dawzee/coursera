#!/bin/perl
$|++;
use strict;
use warnings;

sub MinimumSkew;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp($data[0]);

printf("%s\n",join(" ",&MinimumSkew($data[0])));

sub MinimumSkew
{
    my @chars = split("",$_[0]);
    my @skew;
    my @min_skew_pos = ();
    my $min_skew = 1;
    my $element;
    $skew[0] = 0;
    for $element (0 .. $#chars)
    {
        if($chars[$element] eq "G")
        {
            $skew[$element+1] = $skew[$element] + 1;
        }
        elsif($chars[$element] eq "C")
        {
            $skew[$element+1] = $skew[$element] - 1;
        }
        else
        {
            $skew[$element+1] = $skew[$element];
        }
        
        if($skew[$element+1] < $min_skew)
        {
            #new minimum skew value
            $min_skew = $skew[$element+1];
            @min_skew_pos = ();
            push(@min_skew_pos,$element+1);
        }
        elsif($skew[$element+1] == $min_skew)
        {
            #equal to minimum skew
            push(@min_skew_pos,$element+1);
        }
    }
    @min_skew_pos;
}
