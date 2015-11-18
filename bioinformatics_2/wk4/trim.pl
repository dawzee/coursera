#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(sum max);

sub Trim; # Leaderboard, Spectrum, N
sub LinearSpectrum; # peptide
sub LinearScore; # peptide, spectrum

open(my $input_fh, "<", "integer_mass_table.txt" ) || die "Can't open integer_mass_table.txt: $!";
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

# convert list of peptides to masses
my @leaderboard = ();
foreach my $peptide (split(" ",$data[0]))
{
    my @mass_array = ();
    for(my $char=0;$char<length($peptide);$char++)
    {
        push(@mass_array,$integer_mass_table{substr($peptide,$char,1)});
    }
    push(@leaderboard,\@mass_array);
}

printf("%s -> \n",$data[0]);
print Dumper @leaderboard;

my @spectrum = split(" ",$data[1]);

# trim list
&Trim(\@leaderboard,\@spectrum,$data[2]);

print Dumper @leaderboard;

sub Trim # Leaderboard, Spectrum, N
{
    my ($leaderboard_ref,$spectrum_ref,$n) = @_;
    my @scores;
    
    foreach my $peptide_ref (@{$leaderboard_ref})
    {
        my $score = &LinearScore($peptide_ref,$spectrum_ref);
        push (@scores,[$score,$peptide_ref]);
    }

    # sort Leaderboard according to the decreasing order of scores in LinearScores
    @scores = sort { $b->[0] <=> $a->[0] } @scores;
 
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

sub LinearSpectrum # peptide-ref
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
