#!/bin/perl
$|++;
use strict;
use warnings;
use List::Util qw( max );
use List::MoreUtils qw( uniq );

sub PatternToNumber;
sub NumberToPattern;
sub ComputingFrequencies;
sub ClumpFinding; #(Genome, k, t, L)

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp($data[0]);
#my @params = split(" ",$data[1]);

#printf("%s\n",join(' ',&FrequentWords($data[0],$data[1])));

#printf("%d\n",&PatternToNumber("TTAGAGCCTCAATGAAAT"));
#printf("%s\n",&NumberToPattern(7276,11));
#printf("%s\n",join(' ',&ComputingFrequencies($data[0],$data[1])));

#printf("%s\n",join(" ",&ClumpFinding($data[0],$params[0],$params[2],$params[1])));
printf("%s\n",join(" ",&ClumpFinding($data[0],9,3,500)));



sub PatternToNumber
{
    my @chars = split("",$_[0]);
    my $output;
    my $element;
    my $multiplier=1;
    my %lookup = ( A => 0, C => 1, G => 2, T => 3 );
    foreach $element (reverse @chars) {
        $output += $lookup{$element} * $multiplier;
        $multiplier *= 4; 
    }
    $output;
}

sub NumberToPattern
{
    my $number = $_[0];
    my $base = $_[1];
    my $multiplier = 4 ** ($base-1);
    my $output = "";
    #printf("%d %d\n",$multiplier,$number);
    for(;$base>0;$base--)
    {
        if($multiplier * 3 <= $number)
        {
            $output .= "T";
            $number -= $multiplier * 3;
        }
        elsif($multiplier * 2 <= $number)
        {
            $output .= "G";
            $number -= $multiplier * 2;
        }
        elsif($multiplier <= $number)
        {
            $output .= "C";
            $number -= $multiplier;
        }
        else
        {
            $output .= "A";
        }
        $multiplier = $multiplier / 4;
        #printf("(%d)[%d]",$number,$multiplier);
    }
    $output;
}

sub ComputingFrequencies #(Text , k)
{
    my $text = $_[0];
    my $k = $_[1];
    #my @frequency_array = (0) x (4 ** $k);
    my %frequency_hash = ();
    my $count;
    my $number;
    for($count=0;$count<length($text)-$k;$count++)
    {
        $number = &PatternToNumber(substr($text,$count,$k));
        #$frequency_array[$number] = $frequency_array[$number] + 1;
        if($frequency_hash{$number})
        {
            $frequency_hash{$number} = $frequency_hash{$number} + 1;
        }
        else
        {
            $frequency_hash{$number} = 1;
        }
    }
    #@frequency_array;
    %frequency_hash;
}

sub ClumpFinding #(Genome, k, t, L)
{
    my $genome = $_[0];
    my $k = $_[1];
    my $t = $_[2];
    my $L = $_[3];
    my @frequent_patterns;
    #my @clump = (0) x (4 ** $k);
    #my @frequency_array;
    my %frequency_hash = ();
    #my %clump_hash = ();
    my $count;
    my $count2;

    #printf("ClumpFinding gen=%s len=%d k=%d t=%d L=%d\n",$genome, length($genome), $k, $t, $L);
    
    for($count=0;$count<(length($genome) - $L);$count++)
    {
        #printf("%d ",$count);
        #@frequency_array = &ComputingFrequencies(substr($genome,$count,$L),$k);
        %frequency_hash = &ComputingFrequencies(substr($genome,$count,$L),$k);
        #printf("%s\n",join(" ",@frequency_array));
        #for($count2=0; $count2<(4**$k); $count2++)
        for $count2 ( keys %frequency_hash )
        {
            #if($frequency_array[$count2] >= $t)
            if($frequency_hash{$count2} >= $t)
            {
                #printf("clump $frequency_array[$count2] \@ $count2\n");
                #$clump[$count2] = 1;
                #$clump_hash{$count2} = 1;
                push(@frequent_patterns,&NumberToPattern($count2,$k));
            }
        }
    }
#     for($count2=0;$count2<(4**$k);$count2++)
#     {
#         if($clump[$count2] == 1)
#         {
#             push(@frequent_patterns,&NumberToPattern($count2,$k));
#         }
#     }
    uniq(@frequent_patterns);
}
