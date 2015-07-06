#!/bin/perl
$|++;
use strict;
use warnings;
use List::MoreUtils qw( uniq );

sub HammingDistance;  #(string1, string2)
sub Neighbourhood;    #(pattern, d)
sub PatternCount;     #(text, pattern, d)
sub MotifEnumeration; #(Dna, k, d)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
my @params = split(" ",$data[0]);
my @dna = @data[ 1 .. $#data ];
chomp(@dna);

printf("%s\n",join(" ",&MotifEnumeration(\@dna,$params[0],$params[1])));


sub HammingDistance #(string1, string2)
{
    my @string1 = split("",$_[0]);
    my @string2 = split("",$_[1]);
    my $count;
    my $mismatch = 0;

    for($count=0;$count<length($_[0]);$count++)
    {
        if($string1[$count] ne $string2[$count])
        {
            $mismatch++;
        }
    }
    $mismatch;
}

sub Neighbourhood #(pattern, d)
{
    my $pattern = $_[0];
    my $d = $_[1];
    my @neighbourhood = ();
    my @suffix_neighbours = ();
    my $text;
    
    if($d == 0)
    {
        return $pattern;
    }
    if(length($pattern) == 1)
    {
       return ('A', 'T', 'G', 'C');
    }
    @suffix_neighbours = &Neighbourhood(substr($pattern,1,length($pattern)-1),$d);
    foreach $text (@suffix_neighbours)
    {
        if(&HammingDistance(substr($pattern,1,length($pattern)-1),$text) < $d)
        {
            push(@neighbourhood,'A'.$text);
            push(@neighbourhood,'T'.$text);
            push(@neighbourhood,'C'.$text);
            push(@neighbourhood,'G'.$text);
        }
        else
        {
            push(@neighbourhood,substr($pattern,0,1).$text);
        }
    }
    @neighbourhood;
}

sub PatternCount #(text, pattern, d)
{
    my $text = $_[0];
    my $pattern = $_[1];
    my $d = $_[2];
    my $index = 0;
    my $count = 0;

    for($index=0;$index<=length($text)-length($pattern);$index++)
    {
        if(&HammingDistance($pattern,substr($text,$index,length($pattern))) <= $d)
        {
            $count++;
        }
    }
    $count;
}

sub MotifEnumeration #(Dna, k, d)
{
    my($dna, $k, $d) = @_;
    my @patterns = ();
    
    #printf("dna=(%s) k=%d d=%d\n",join(":",@{dna}),$k,$d);
    
    #for each k-mer Pattern in Dna
    foreach my $dna_string (@{$dna})
    {
        for(my $dna_index=0;$dna_index<length($dna_string)-$k;$dna_index++)
        {
            #for each k-mer Pattern’ differing from Pattern by at most d mismatches
            foreach my $dna_neighbourhood_string (&Neighbourhood(substr($dna_string,$dna_index,$k),$d))
            {
                my $in_every_string = 1;
                
                #if Pattern' appears in each string from Dna with at most d mismatches
                foreach (@{$dna})
                {
                    if(&PatternCount($_,$dna_neighbourhood_string,$d) < 1)
                    {
                        $in_every_string = 0;
                    }
                }
                
                if($in_every_string)
                {
                    #add Pattern' to Patterns
                    push(@patterns,$dna_neighbourhood_string);
                }
            }
        }
    }    
    #remove duplicates from Patterns
    uniq(@patterns);
    #return Patterns
}
