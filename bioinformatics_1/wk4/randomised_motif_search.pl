#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub MotifToProfile;        #(motif)
sub ProfileMostProbable;   #(text,k,profile)
sub Motifs;                #(Profile, k, Dna)
sub Score;                 #(motif)
sub RandomisedMotifSearch; #(Dna, k, t)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
my @params = split(" ",$data[0]);
my @dna = @data[ 1 .. $#data ];
local $/ = "\r\n";
chomp(@dna);

#print Dumper @dna;

printf("%s\n",join("\n",&RandomisedMotifSearch(\@dna,$params[0],$params[1])));

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

    #print Dumper $profile_ref;
    
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

sub Motifs #(Profile, k, Dna)
{
    my($profile_ref,$k,$dna_ref) = @_;
    my @motifs;
    
    foreach my $dna_string (@{$dna_ref})
    {
        push(@motifs,&ProfileMostProbable($dna_string,$k,$profile_ref));
    }
    @motifs;
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

sub RandomisedMotifSearch #(Dna, k, t)
{
    my($dna_ref,$k,$t) = @_;
    my @motifs = ();

    # randomly select k-mers Motifs = (Motif1, …, Motift) in each string from Dna
    foreach my $dna_string (@{$dna_ref})
    {
        push(@motifs,substr($dna_string,int(rand(length($dna_string)-$k)),$k));
    }
    
    my @best_motifs = @motifs;
    my $best_motif_score = &Score(@best_motifs);
    #printf("%d ", $best_motif_score);

    for my $i (0..999)
    #while(1)
    {
        # Profile ← Profile(Motifs)
        my $profile_ref = &MotifToProfile(@motifs);
        
        # Motifs ← Motifs(Profile, Dna)
        @motifs = &Motifs($profile_ref,$k,$dna_ref);
        
        my $motif_score = &Score(@motifs);
        if($motif_score < $best_motif_score)
        {
            @best_motifs = @motifs;
            $best_motif_score = $motif_score;
            #printf("%d ", $best_motif_score);
        }
        #else
        #{
        #    return @best_motifs;
        #}
    }
    @best_motifs;
}
