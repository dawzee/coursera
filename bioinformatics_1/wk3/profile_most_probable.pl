#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub ProfileMostProbable; #(text,k,profile)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

my $text = $data[0];
my $k = $data[1];
# read profile into multi-dimensional array
my @profile = ([split(" ",$data[2])],[split(" ",$data[3])],[split(" ",$data[4])],[split(" ",$data[5])]);

printf("%s\n",&ProfileMostProbable($text,$k,\@profile));

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
