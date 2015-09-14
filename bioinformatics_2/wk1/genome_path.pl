#!/bin/perl
$|++;
use strict;
use warnings;

sub GenomePath; # pattern

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

printf("%s\n",&GenomePath(\@data));

sub GenomePath # pattern
{
    my $pattern_ref = $_[0];
    my $string = substr($pattern_ref->[0],0,length($pattern_ref->[0])-1);

    foreach my $pattern_string (@{$pattern_ref})
    {
        $string .= substr($pattern_string,length($pattern_string)-1,1);
    }
    $string;
}
