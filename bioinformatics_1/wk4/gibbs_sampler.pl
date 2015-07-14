#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(sum);

sub MotifToProfile;        #(motif)
sub RandomProfile;         #(profile)
sub ProfileRandomProbable; #(text,k,profile)
sub Score;                 #(motif)
sub GibbsSampler;          #(Dna, k, t, N)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
my @params = split(" ",$data[0]);
my @dna = @data[ 1 .. $#data ];
local $/ = "\r\n";
chomp(@dna);

my @best_gibbs_motif = ();
my $best_gibbs_score = 9**9**9;

for my $gibbs_count (1..20)
{
    my @gibbs_motif = &GibbsSampler(\@dna,$params[0],$params[1],$params[2]);
    my $gibbs_score = &Score(@gibbs_motif);
    
    if($gibbs_score < $best_gibbs_score)
    {
        @best_gibbs_motif = @gibbs_motif;
        $best_gibbs_score = $gibbs_score;
    }
}

printf("%s\n",join("\n",@best_gibbs_motif));

sub MotifToProfile #(motif)
{
    my @motif = @_;
    my %lookup = ( 'A' => 0, 'C' => 1, 'G' => 2, 'T' => 3);
    my ($char,$total);
    my @profile; # = map [(0) x length($motif[0])], 0..3;
    my $num_motifs = @motif;
    my $string_length = length($motif[0]);
    
    # initialise profile to 0 for normal GreedyMotifSearch
    # initialise profile to 1 for GreedyMotifSearch with pseudocounts
    push @profile, [(1)x$string_length] for (0..3);

    for(my $string=0;$string<$num_motifs;$string++)
    {
        # convert text string of chars ACGT into array of indexes 0123 
        my @text_array = map{ $lookup{$_} } split("",$motif[$string]);
        
        for($char=0;$char<$string_length;$char++)
        {
            $profile[$text_array[$char]][$char]++;
        }
    }
    
    for($char=0;$char<$string_length;$char++)
    {
        $total = $profile[0][$char] + $profile[1][$char] + $profile[2][$char] + $profile[3][$char];
        $profile[0][$char] = $profile[0][$char] / $total;
        $profile[1][$char] = $profile[1][$char] / $total;
        $profile[2][$char] = $profile[2][$char] / $total;
        $profile[3][$char] = $profile[3][$char] / $total;
    }
    \@profile;
}

sub RandomProfile #(profile)
{
    my @profile = @_;
    my $sum = sum(@profile);
    my $rand = rand($sum);
    my $accumilator = 0;

    for(my $index=0;$index<@profile;$index++)
    {
        $accumilator += $profile[$index];
        if($rand<=$accumilator)
        {
            return($index);
        }
    }
}

sub ProfileRandomProbable #(text,k,profile)
{
    my($text,$k,$profile_ref) = @_;

    # convert text string of chars ACGT into array of indexes 0123 
    my %lookup = ( 'A' => 0, 'C' => 1, 'G' => 2, 'T' => 3);
    my @text_array = map{ $lookup{$_} } split("",$text);
    my @probability_profile = ();

    # for each k-mer in string
    for(my $index=0;$index<=length($text)-$k;$index++)
    {
        # take probability of first char
        my $probability = $profile_ref->[$text_array[$index]][0];
        for(my $char=1;$char<$k;$char++)
        {
            # multiply by each subsequent char
            $probability *= $profile_ref->[$text_array[$index+$char]][$char];
        }
        
        $probability_profile[$index] = $probability;

    }
    
    return substr($text,&RandomProfile(@probability_profile),$k);
}

sub Score #(motif)
{
    my @motif = @_;
    my $num_motifs = @motif;
    my $string_length = length($motif[0]);
    my $score = 0;
    my @counts;
    push @counts, [(0)x$string_length] for (0..3);
    my %lookup = ( 'A' => 0, 'C' => 1, 'G' => 2, 'T' => 3);

    # for each string in the motif count the occurances of each letter
    for(my $string=0;$string<$num_motifs;$string++)
    {
        my @text_array = map{ $lookup{$_} } split("",$motif[$string]);
        
        for(my $char=0;$char<$string_length;$char++)
        {
            $counts[$text_array[$char]][$char]++;
        }
    }

    for(my $char=0;$char<$string_length;$char++)
    {
        # find the max count
        my $max_count = 0;
        for(my $letter=0;$letter<4;$letter++)
        {
            if($counts[$letter][$char] > $max_count)
            {
                $max_count = $counts[$letter][$char];
            }
        }
        # subtract max count from number of strings and add to score
        $score += ($num_motifs-$max_count);
    }
    
    $score;
}

sub GibbsSampler #(Dna, k, t, N)
{
    my($dna_ref,$k,$t,$N) = @_;
    my @motifs = ();

    # randomly select k-mers Motifs = (Motif1, …, Motift) in each string from Dna
    foreach my $dna_string (@{$dna_ref})
    {
        push(@motifs,substr($dna_string,int(rand(length($dna_string)-$k)),$k));
    }
    
    my @best_motifs = @motifs;
    my $best_motif_score = &Score(@best_motifs);

    for my $i (1..$N)
    {
        my $random_index = int(rand($t));

        # Profile ← profile matrix constructed from all strings in Motifs except for Motifi
        my @motifs_subset = @motifs;
        splice(@motifs_subset,$random_index,1);
        my $profile_ref = &MotifToProfile(@motifs_subset);
        
        # Motifi ← Profile-randomly generated k-mer in the i-th sequence
        $motifs[$random_index] = &ProfileRandomProbable($dna_ref->[$random_index],$k,$profile_ref);

        my $motif_score = &Score(@motifs);
        if($motif_score < $best_motif_score)
        {
            @best_motifs = @motifs;
            $best_motif_score = $motif_score;
        }
    }
    @best_motifs;
}
