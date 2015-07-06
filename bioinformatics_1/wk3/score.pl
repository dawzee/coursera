#!/bin/perl
$|++;
use strict;
use warnings;

sub Score; #(motif)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @motif = <$input_fh>;
chomp(@motif);

printf("%d\n",&Score(@motif));

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
