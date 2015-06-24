#!/bin/perl
$|++;
use strict;
use warnings;

sub Skew;

#open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

#my @data = <$input_fh>;
#chomp($data[0]);

printf("%s\n",join(" ",&Skew("GATACACTTCCCGAGTAGGTACTG")));

sub Skew
{
    my @chars = split("",$_[0]);
    my @skew;
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
    }
    @skew;
}
