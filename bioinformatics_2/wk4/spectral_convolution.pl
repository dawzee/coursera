#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub SpectralConvolution; # spectrum

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

my @spectrum = split(" ",$data[0]);

printf("%s\n",join(" ",&SpectralConvolution(\@spectrum)));

sub SpectralConvolution # spectrum
{
    my $spectrum_ref = $_[0];
    my @convolution;
    
    foreach my $omass (@{$spectrum_ref})
    {
        foreach my $imass (@{$spectrum_ref})
        {
            if(($omass-$imass)>0)
            {
                push(@convolution,($omass-$imass));
            }
        }
    }
    @convolution;
}
