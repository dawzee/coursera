#!/bin/perl
use strict;
use warnings;

sub PatternMatch;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;

chomp($data[0]);
chomp($data[1]);

&PatternMatch($data[0],$data[1]);

sub PatternMatch
{
    my $pattern = $_[0];
    my $genome = $_[1];
    my $index;
    
    for($index=0;$index<length($genome)-length($pattern);$index++)
    {
        if(substr($genome,$index,length($pattern)) eq $pattern)
        {
             printf("%d ",$index);
        }
    }
    printf("\n");
}