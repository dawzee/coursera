#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(sum max);
use Devel::Size qw(size total_size);

sub CyclopeptideSequencing; # spectrum
sub Expand; # peptides
sub LinearSpectrum; # peptide
sub CyclicSpectrum; # peptide
sub Consistent; # peptide ref, spectrum ref

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

printf("%s\n",join(" ",&CyclopeptideSequencing(split(" ",$data[0]))));

sub CyclopeptideSequencing # spectrum
{
    my @spectrum = @_;
    my @output_peptides = ();
    my $next_peptides = ""; # a set containing only the empty peptide
    my $peptides;
    my $peptide;
    my $debug_count = 0;
    my @peptide_array;
    
    do
    {
        $peptides = "";
        &Expand(\$next_peptides,\$peptides);
        $next_peptides = "";

        for(my $index=0;$index<length($peptides);$index++)
        {
            my $end_index = $index;
            while($end_index < length($peptides) && substr($peptides,$end_index,1) ne ":") { $end_index++; };
            $peptide = substr($peptides,$index,$end_index-$index);
            $index = $end_index;
            
            @peptide_array = split("-",$peptide);

            if(sum(@peptide_array) == max(@spectrum))
            { # Mass(Peptide) = ParentMass(Spectrum)
            
                if(join("-",&CyclicSpectrum(@peptide_array)) eq join("-",@spectrum))
                {
                    push(@output_peptides,$peptide);
                }
            }            
            elsif(&Consistent(\@peptide_array,\@spectrum))
            {
                # it's still a good candidate, keep it for next time
                if(length($next_peptides)>0)
                {
                    $next_peptides .= ":".$peptide;
                }
                else
                {
                    $next_peptides = $peptide;
                }
            }
        }
    } while(length($next_peptides) > 0);
    
    @output_peptides;
}

sub Expand # peptides
{
    my ($peptides_ref,$new_peptides_ref) = @_;
    my @masses = (57, 71, 87, 97, 99, 101, 103, 113, 114, 115, 128, 129, 131, 137, 147, 156, 163, 186);
    my $peptide;
    my $mass;
    
    if(length(${$peptides_ref})>0)
    {
        foreach $peptide (split(":",${$peptides_ref}))
        {
            foreach $mass (@masses)
            {
                ${$new_peptides_ref} .= ":".$peptide."-".$mass;
            }
        }
        ${$new_peptides_ref} = substr(${$new_peptides_ref},1);
    }
    else
    {
        ${$new_peptides_ref} = join(":",@masses);
    }
}

sub LinearSpectrum # peptide
{
    my @peptide = @_;
    my $char_index;
    my $mass_index;

    my @prefix_mass = (0);
    for($char_index=1;$char_index<=scalar(@peptide);$char_index++)
    {
        $prefix_mass[$char_index] = $prefix_mass[$char_index-1] + $peptide[$char_index-1];
    }

    my @linear_spectrum = (0);
    for($char_index=0;$char_index<scalar(@peptide);$char_index++)
    {
        for($mass_index=$char_index+1;$mass_index<=scalar(@peptide);$mass_index++)
        {
            push(@linear_spectrum,($prefix_mass[$mass_index]-$prefix_mass[$char_index]));
        }
    }
    sort {$a <=> $b} (@linear_spectrum);
}

sub CyclicSpectrum # peptide
{
    my @peptide = @_;
    my $char_index;
    my $mass_index;

    my @prefix_mass = (0);
    for($char_index=1;$char_index<=scalar(@peptide);$char_index++)
    {
        $prefix_mass[$char_index] = $prefix_mass[$char_index-1] + $peptide[$char_index-1];
    }

    my $peptide_mass = $prefix_mass[scalar(@peptide)];
    my @cyclic_spectrum = (0);
    for($char_index=0;$char_index<scalar(@peptide);$char_index++)
    {
        for($mass_index=$char_index+1;$mass_index<=scalar(@peptide);$mass_index++)
        {
            push(@cyclic_spectrum,($prefix_mass[$mass_index]-$prefix_mass[$char_index]));
            if($char_index>0 && $mass_index<scalar(@peptide))
            {
                push(@cyclic_spectrum,
                     $peptide_mass-($prefix_mass[$mass_index]-$prefix_mass[$char_index]));                
            }
        }
    }
    sort {$a <=> $b} (@cyclic_spectrum);
}

sub Consistent # peptide ref, spectrum ref
{
    my ($peptide_ref,$spectrum_ref) = @_;

    # calculate the spectrum for the given peptide
    my @theoretical_spectrum = &LinearSpectrum(@{$peptide_ref});
    # take a copy of the spectrum
    my @spectrum = @{$spectrum_ref};
    
    my $consistent = 1;
    
    foreach my $mass (@theoretical_spectrum)
    {
        my $found = 0;
        foreach my $spec_mass (@spectrum)
        {
            if($mass == $spec_mass)
            {
                $found = 1;
                # negate the spectrum mass so we don't reuse it
                $spec_mass = -$spec_mass;
                last; # break
            }
            elsif($mass < $spec_mass)
            {
                # assuming that spectrum is in numerical order then there's no more chance of finding a match
                #printf("ERROR %d not found in spectrum %s\n",$mass,join("-",@spectrum));
                last;
            }
        }
        if(!$found)
        {
            #printf("ERROR %d not found in spectrum %s\n",$mass,join("-",@spectrum));
            $consistent = 0;
            last; # break
        }
    }
    $consistent;
}
