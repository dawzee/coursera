#!/bin/perl
$|++;
use strict;
use warnings;

sub DeBruijnGraphFromKmers; # pattern

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

my %graph = &DeBruijnGraphFromKmers(\@data);

#printf("text is %d\n",length($data[1]));

foreach (sort keys %graph) {
    printf "$_ -> $graph{$_}\n";
}

sub DeBruijnGraphFromKmers # pattern
{
    my $pattern_ref = $_[0];
    my %debruijn_graph;
    
    foreach my $pattern_string (@{$pattern_ref})
    {
        my $prefix = substr($pattern_string,0,length($pattern_string)-1);
        my $suffix = substr($pattern_string,1,length($pattern_string)-1);
        
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
