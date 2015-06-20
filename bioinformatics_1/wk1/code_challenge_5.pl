#!/bin/perl
use strict;
use warnings;
use List::Util qw( max );
use List::MoreUtils qw( uniq );

sub PatternCount;
sub FrequentWords;
sub FindClump;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;

my @params = split(" ",$data[1]);

#printf("%s\n",join(' ',&ClumpFind($data[0],$params[0],$params[1],$params[2])));
&ClumpFind($data[0],$params[0],$params[1],$params[2]);

sub PatternCount
{

    my $indx = 0;
    my $count = 0;
    my $text = $_[0];
    my $pattern = $_[1];

    chomp($text);
    chomp($pattern);

    #printf("text = %s\n", $text);
    #printf("pattern = %s\n", $pattern);

    for($indx=0;$indx<=length($text)-length($pattern);$indx++)
    #for($indx=0;$indx<2;$indx++)
    {

        #printf("%s:%s\n",$pattern,substr($text,$indx,length($pattern)));
        if($pattern eq substr($text,$indx,length($pattern)))
        {
            $count++;
        }
    }
    $count;
}

sub FrequentWords #(Text, k)
{
    my $text = $_[0];
    my $k = $_[1];
    my $t = $_[2];
    chomp($text);
    my @frequent_patterns;
    my @frequent_uniq;
    my $index;
    my $pattern;
    my @count;
    my $max_count=0;
    
    for($index=0;$index<=length($text)-$k;$index++)
    {
        $pattern = substr($text,$index,$k);
        $count[$index] = &PatternCount($text,$pattern);
    }
    $max_count = max(@count);
    #printf("max count = %d\n",$max_count);
    if($max_count >= $t)
    {
    for($index=0;$index<=length($text)-$k;$index++)
    {
        if($count[$index] == $max_count)
        {
            #printf("adding %s\n",substr($text,$index,$k));
            push(@frequent_patterns,substr($text,$index,$k));
        }
    }
    }
    @frequent_uniq = uniq(@frequent_patterns);
#@frequent_uniq;
}

sub ClumpFind #(Genome, k, L, t)
{
    my $genome = $_[0];
    my $k = $_[1];
    my $L = $_[2];
    my $t = $_[3];
    my $count;
    my @clump_patterns;
    my @clump_uniq;

    #printf("%d %d %d\n",$k, $L, $t);
    for($count=0;$count<length($genome)-$L;$count++)
    {
        push(@clump_patterns,&FrequentWords(substr($genome,$count,$L),$k,$t));
    }
    @clump_uniq = uniq(@clump_patterns);
    printf("%s\n",join(" ",@clump_uniq));
}
