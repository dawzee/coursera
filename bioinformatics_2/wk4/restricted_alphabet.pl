#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub RestrictedAlphabet; # m, spectrum

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

my @spectrum = split(" ",$data[1]);

printf("%s\n",join(" ",&RestrictedAlphabet($data[0],\@spectrum)));

sub RestrictedAlphabet # m, spectrum
{
    my ($m,$spectrum_ref) = @_;
    my %occurances;
    my @alphabet;
    
    foreach my $omass (@{$spectrum_ref})
    {
        foreach my $imass (@{$spectrum_ref})
        {
            if(($omass-$imass)>0)
            {
                $occurances{($omass-$imass)}++;
            }
        }
    }
    
    my $cutoff;
    foreach my $mass (sort { $occurances{$b} <=> $occurances{$a} } keys %occurances)
    {
        if($mass<57 || $mass>200)
        {
            next;
        }
        
        $m--;
        if($m==0)
        {
            $cutoff = $occurances{$mass};
        }
        elsif($m<0 && $cutoff != $occurances{$mass})
        {
            last;
        }
        
        push(@alphabet,$mass);
    }
    @alphabet;
}
