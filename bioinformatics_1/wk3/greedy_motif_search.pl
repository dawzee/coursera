#!/bin/perl
$|++;
use strict;
use warnings;

use Data::Dumper;

sub MotifToProfile;      #(motif)
sub ProfileMostProbable; #(text,k,profile)
sub Score;               #(motif)
sub GreedyMotifSearch;   #(k,t,dna)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
my @params = split(" ",$data[0]);
my @dna = @data[ 1 .. $#data ];
local $/ = "\r\n";
chomp(@dna);

printf("%s\n",join("\n",&GreedyMotifSearch($params[0],$params[1],\@dna)));

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

sub ProfileMostProbable #(text,k,profile)
{
    my($text,$k,$profile_ref) = @_;

    # convert text string of chars ACGT into array of indexes 0123 
    my %lookup = ( 'A' => 0, 'C' => 1, 'G' => 2, 'T' => 3);
    my @text_array = map{ $lookup{$_} } split("",$text);
    my $max_probability = 0;
    my $max_probability_string = substr($text,0,$k);

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

        if($max_probability<$probability)
        {
            # store best probability
            $max_probability = $probability;
            $max_probability_string = substr($text,$index,$k);
        }
    }
    $max_probability_string;
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

sub GreedyMotifSearch #(k,t,dna)
{
    my($k, $t, $dna_ref) = @_;
    
    # BestMotifs ← motif matrix formed by first k-mers in each string from Dna
    my @best_motif = map{ substr($_,0,$k) } @{$dna_ref};
    
    # for each k-mer Motif in the first string from Dna
    for(my $kmer_index=0;$kmer_index<=length($dna_ref->[0])-$k;$kmer_index++)
    {
        my @motif = ();
        # Motif1 ← Motif
        push(@motif,substr($dna_ref->[0],$kmer_index,$k));
        
        # for i = 2 to t
        for(my $dna_index=1;$dna_index<$t;$dna_index++)
        {
            # form Profile from motifs Motif1, …, Motifi - 1
            my $profile_ref = &MotifToProfile(@motif);

            # Motifi ← Profile-most probable k-mer in the i-th string in Dna
            push(@motif,&ProfileMostProbable($dna_ref->[$dna_index],$k,$profile_ref));
        }
        
        if(&Score(@motif) < &Score(@best_motif))
        {
            @best_motif = @motif;
        }
        
    }
    
    @best_motif;
}
