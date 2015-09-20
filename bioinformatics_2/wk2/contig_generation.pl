#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub DebruijnGraph; # pattern
sub GenerateContigs; # debruijn graph

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

my %debruijn_graph = &DebruijnGraph(@data);
printf("%s\n",join("\n",&GenerateContigs(%debruijn_graph)));

sub DebruijnGraph # pattern
{
    my @pattern = @_;
    my %out_graph;

    foreach my $pattern_string (@pattern)
    {
        my $k = length($pattern_string);
        my $prefix = substr($pattern_string,0,$k-1);
        my $suffix = substr($pattern_string,1,$k-1);
        
        if($out_graph{$prefix})
        {
            # we already have this prefix, so push on the suffix
            push(@{$out_graph{$prefix}}, $suffix);
        }
        else
        {
            # new prefix
            my @new_array = ($suffix);
            $out_graph{$prefix} = \@new_array;
        }
    }

    %out_graph;
}

sub GenerateContigs # debruijn graph
{
    my %debruijn_graph = @_;
    my %in_count  = ();
    my %out_count = ();
    my %not_used  = ();
    my @contigs = ();
    
    # count ins and outs of each node
    foreach my $start_node (keys(%debruijn_graph))
    {
        $not_used{$start_node} = 1;
        
        $out_count{$start_node} = @{$debruijn_graph{$start_node}};
        if(!defined($in_count{$start_node}))  { $in_count{$start_node} = 0;  }
        foreach my $end_node (@{$debruijn_graph{$start_node}})
        {
            $in_count{$end_node}++;
            if(!defined($out_count{$end_node})) { $out_count{$end_node} = 0; }
        }
    }

    # look for paths
    foreach my $start_node (keys(%debruijn_graph))
    {
        # if this is a 1-1 node or out count is 0 then skip it
        if(($in_count{$start_node} == 1 && $out_count{$start_node} == 1) || $out_count{$start_node} == 0) { next; }
        
        $not_used{$start_node} = 0;
        
        foreach my $end_node (@{$debruijn_graph{$start_node}})
        {
            $not_used{$end_node} = 0;
            my $new_path = $start_node.substr($end_node,length($end_node)-1,1);
            while($in_count{$end_node} == 1 && $out_count{$end_node} == 1)
            {
                $end_node = $debruijn_graph{$end_node}[0];
                $not_used{$end_node} = 0;
                $new_path .= substr($end_node,length($end_node)-1,1);
            }
            push(@contigs,$new_path);
        }
    }
    
    # find isolated cycles
    foreach my $start_node (keys(%debruijn_graph))
    {
        # if we've already used this node then skip it
        if(!$not_used{$start_node}) { next; }
        $not_used{$start_node} = 0;

        my $end_node = $debruijn_graph{$start_node}[0];
        
        my $new_path = $start_node.substr($end_node,length($end_node)-1,1);
        while(!$not_used{$end_node})
        {
            $not_used{$end_node} = 0;
            $end_node = $debruijn_graph{$end_node}[0];
            $new_path .= substr($end_node,length($end_node)-1,1);
        }
        push(@contigs,$new_path);
    }
    
    @contigs;
}
