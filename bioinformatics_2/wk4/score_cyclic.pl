#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(sum max);

sub CyclicSpectrum; # peptide
sub CyclicScore; # peptide, spectrum-ref

open( my $input_fh, "<", "integer_mass_table.txt" ) || die "Can't open integer_mass_table.txt: $!";
my %integer_mass_table = ();
foreach my $integer_mass_string (<$input_fh>)
{
    chomp($integer_mass_string);
    $integer_mass_table{substr($integer_mass_string,0,1)} = substr($integer_mass_string,2,3);
}
close($input_fh);

open($input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

my $peptide = $data[0];
my @spectrum = split(" ",$data[1]);

printf("%d\n",&CyclicScore($peptide,\@spectrum));

sub CyclicSpectrum # peptide
{
    my $peptide = $_[0];
    my $char_index;
    my $mass_index;

    my @prefix_mass = (0);
    for($char_index=1;$char_index<=length($peptide);$char_index++)
    {
        $prefix_mass[$char_index] = $prefix_mass[$char_index-1] + 
                                    $integer_mass_table{substr($peptide,$char_index-1,1)};
    }

    my $peptide_mass = $prefix_mass[length($peptide)];
    my @cyclic_spectrum = (0);
    for($char_index=0;$char_index<length($peptide);$char_index++)
    {
        for($mass_index=$char_index+1;$mass_index<=length($peptide);$mass_index++)
        {
            push(@cyclic_spectrum,($prefix_mass[$mass_index]-$prefix_mass[$char_index]));
            if($char_index>0 && $mass_index<length($peptide))
            {
                push(@cyclic_spectrum,
                     $peptide_mass-($prefix_mass[$mass_index]-$prefix_mass[$char_index]));                
            }
        }
    }
    sort {$a <=> $b} (@cyclic_spectrum);
}

sub CyclicScore # peptide, spectrum-ref
{
    my ($peptide,$espectrum_ref) = @_;

    # calculate the spectrum for the given peptide
    my @tspectrum = &CyclicSpectrum($peptide);
    
    my $score = 0;

    foreach my $emass (@{$espectrum_ref})
    {
        foreach my $tmass (@tspectrum)
        {
            if($emass == $tmass)
            {
                $score++;
                # negate the spectrum mass so we don't reuse it
                $tmass = -$tmass;
                last; # break
            }
        }
    }
    $score;
}
