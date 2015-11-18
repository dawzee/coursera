#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(sum max);

sub LeaderboardCyclopeptideSequencing; # N, spectrum
sub Expand; # peptides
sub LinearSpectrum; # peptide
sub LinearScore; # peptide, spectrum
sub CyclicSpectrum; # peptide
sub CyclicScore; # peptide, spectrum
sub Trim; # Leaderboard, Spectrum, N

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

printf("%s\n",join("-",&LeaderboardCyclopeptideSequencing($data[0],split(" ",$data[1]))));

sub LeaderboardCyclopeptideSequencing # N, spectrum
{
    my ($n, @spectrum) = @_;

    my @old_peptides = (); # a set containing only the empty peptide
    my @new_peptides;
    my $parent_mass_spectrum = max(@spectrum);
    my $max_mass_peptide_array = 0;
    
    my @leader;
    my $debug_count = 0;
    
    do
    {
        @new_peptides = ();
        &Expand(\@old_peptides,\@new_peptides);
        @old_peptides = ();

        foreach my $peptide_ref (@new_peptides)
        {
            my $mass_peptide_array = sum(@{$peptide_ref});
            
            if($mass_peptide_array > $max_mass_peptide_array)
            {
                $max_mass_peptide_array = $mass_peptide_array;
            }
            
            if($mass_peptide_array == $parent_mass_spectrum)
            { # Mass(Peptide) = ParentMass(Spectrum)
            
                if(&CyclicScore($peptide_ref, \@spectrum) > &CyclicScore(\@leader, \@spectrum))
                {
                    @leader = @{$peptide_ref};
                }
            }            
            elsif($mass_peptide_array < $parent_mass_spectrum)
            {
                # it's still a good candidate, keep it for next time
                push(@old_peptides,$peptide_ref);
            }
        }
        if(scalar(@old_peptides)>0)
        {
            printf("%d",scalar(@old_peptides));
            &Trim(\@old_peptides,\@spectrum,$n);
            printf(" trimmed to %d.",scalar(@old_peptides));
            printf(" mm=%d pm=%d leader=%s\n",$max_mass_peptide_array,$parent_mass_spectrum,join("-",@leader));
        }
        
    } while(scalar(@old_peptides));
    
    @leader;
}

sub Expand # peptides
{
    my ($old_peptides_ref,$new_peptides_ref) = @_;
    my @masses = (57, 71, 87, 97, 99, 101, 103, 113, 114, 115, 128, 129, 131, 137, 147, 156, 163, 186);
    my $mass;
    
    if(scalar(@{$old_peptides_ref})>0)
    {
        foreach my $peptide_ref (@{$old_peptides_ref})
        {
            foreach $mass (@masses)
            {
                push(@{$new_peptides_ref},[@{$peptide_ref},$mass]);#\@new_peptide);
            }
        }
    }
    else
    {
        foreach $mass (@masses)
        {
            push(@{$new_peptides_ref},[$mass]);
        }
    }
}

sub LinearSpectrum # peptide
{
    my $peptide_ref = $_[0];
    my $char_index;
    my $mass_index;
    my $peptide_length = scalar(@{$peptide_ref});

    my @prefix_mass = (0);
    for($char_index=1;$char_index<=$peptide_length;$char_index++)
    {
        $prefix_mass[$char_index] = $prefix_mass[$char_index-1] + $peptide_ref->[$char_index-1];
    }

    my @linear_spectrum = (0);
    for($char_index=0;$char_index<$peptide_length;$char_index++)
    {
        for($mass_index=$char_index+1;$mass_index<=$peptide_length;$mass_index++)
        {
            push(@linear_spectrum,($prefix_mass[$mass_index]-$prefix_mass[$char_index]));
        }
    }
    sort {$a <=> $b} (@linear_spectrum);
}

sub LinearScore # peptide, spectrum
{
    my ($tpeptide_ref,$espectrum_ref) = @_;

    # calculate the spectrum for the given peptide
    my @tspectrum = &LinearSpectrum($tpeptide_ref);

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

sub CyclicSpectrum # peptide
{
    my $peptide_ref = $_[0];
    my $char_index;
    my $mass_index;
    my $peptide_length = scalar(@{$peptide_ref});

    my @prefix_mass = (0);
    for($char_index=1;$char_index<=$peptide_length;$char_index++)
    {
        $prefix_mass[$char_index] = $prefix_mass[$char_index-1] + $peptide_ref->[$char_index-1];
    }

    my $peptide_mass = $prefix_mass[$peptide_length];
    my @cyclic_spectrum = (0);
    for($char_index=0;$char_index<$peptide_length;$char_index++)
    {
        for($mass_index=$char_index+1;$mass_index<=$peptide_length;$mass_index++)
        {
            push(@cyclic_spectrum,($prefix_mass[$mass_index]-$prefix_mass[$char_index]));
            if($char_index>0 && $mass_index<$peptide_length)
            {
                push(@cyclic_spectrum,
                     $peptide_mass-($prefix_mass[$mass_index]-$prefix_mass[$char_index]));                
            }
        }
    }
    sort {$a <=> $b} (@cyclic_spectrum);
}

sub CyclicScore # peptide, spectrum
{
    my ($tpeptide_ref,$espectrum_ref) = @_;

    # calculate the spectrum for the given peptide
    my @tspectrum = &CyclicSpectrum($tpeptide_ref);
    
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

sub Trim # Leaderboard, Spectrum, N
{
    my ($leaderboard_ref,$spectrum_ref,$n) = @_;
    my @scores = ();

    printf(" s ");

    foreach my $peptide_ref (@{$leaderboard_ref})
    {
        my $score = &LinearScore($peptide_ref,$spectrum_ref);
        push (@scores,[$score,$peptide_ref]);
    }

    printf(" o ");

    # sort Leaderboard according to the decreasing order of scores in LinearScores
    @scores = sort { $b->[0] <=> $a->[0] } @scores;

    printf(" t ");

    @{$leaderboard_ref} = ();
    for(my $index=0;$index<scalar(@scores);$index++)
    {
        # output all peptides in the top n'th positions or ones with equal score than the n'th
        if($index<$n || $scores[$index][0] >= $scores[$n-1][0])
        {
            push(@{$leaderboard_ref},$scores[$index][1]);
        }
        else
        {
            last;
        }
    }
}
