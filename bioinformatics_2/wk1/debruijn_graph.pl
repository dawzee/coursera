#!/bin/perl
$|++;
use strict;
use warnings;

sub DeBruijnGraph; # k, text

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

my %graph = &DeBruijnGraph($data[0],$data[1]);

#printf("text is %d\n",length($data[1]));

foreach (sort keys %graph) {
    printf "$_ -> $graph{$_}\n";
}

sub DeBruijnGraph # k, text
{
    my $k = $_[0];
    my $text = $_[1];
    my %debruijn_graph;
    
    for(my $index=0;$index<=length($text)-$k;$index++)
    {
        my $prefix = substr($text,$index,$k-1);
        my $suffix = substr($text,$index+1,$k-1);
        
        if($debruijn_graph{$prefix})
        {
            # we already have this prefix, so concatinate the suffix
            $debruijn_graph{$prefix} = $debruijn_graph{$prefix}.",".$suffix;
        }
        else
        {
            # new prefix
            $debruijn_graph{$prefix} = $suffix;
        }
        #printf("$debruijn_graph{$prefix}\n")
    }
    %debruijn_graph;
}
