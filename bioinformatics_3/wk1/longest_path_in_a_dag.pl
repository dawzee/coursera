#!/bin/perl
$|++;
use strict;
use warnings;
no warnings 'recursion';
use Data::Dumper;

sub CalcLongest; # element
sub PrintLongest; # sink

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

my $in_source = $data[0];
my $in_sink = $data[1];
my @edge_list;

# first generate an edge list, indexed by start node with a list of end points and weight
for(my $index_edge = 2; $index_edge <= $#data; $index_edge++)
{
    my @elements = split(/(->|:)/,$data[$index_edge]);
    if(defined($edge_list[$elements[0]]))
    {
        push($edge_list[$elements[0]]->{out_links},{end=>$elements[2],weight=>$elements[4]});
    }
    else
    {
        $edge_list[$elements[0]] = {out_links=>[{end=>$elements[2],weight=>$elements[4]}],longest=>0};
    }
    
}

# travese the edge list starting at the source, calculating the longest path to get to that point
&CalcLongest($in_source);

# travese the edge list starting at the sink, printing the longest path
printf("%d\n",$edge_list[$in_sink]->{longest});
&PrintLongest($in_sink);
printf("\n");


sub CalcLongest # source
{
    my $start = $_[0];
    
    if($start == $in_sink)
    {
        return;
    }
    
    # loop through each out link at this node
    foreach my $out (@{$edge_list[$start]->{out_links}})
    {
        # if the end of the link has not been visited before, or the cost of getting these at 
        # least matches the previous visit....
        if(!defined($edge_list[$out->{end}]->{longest}) ||
           $edge_list[$out->{end}]->{longest} <= ($edge_list[$start]->{longest} + $out->{weight}))
        {
            # record the in link, if it's the new longest record then record it. if it matches then
            # add to the list
            if(defined($edge_list[$out->{end}]->{in_links}) &&
               $edge_list[$out->{end}]->{longest} == ($edge_list[$start]->{longest} + $out->{weight}))
            {
                push(@{$edge_list[$out->{end}]->{in_links}}, $start);
            }
            else
            {
                $edge_list[$out->{end}]->{in_links} = [$start];
            }
            # update the longest record
            $edge_list[$out->{end}]->{longest} = ($edge_list[$start]->{longest} + $out->{weight});
            
            # traverse from this point
            &CalcLongest($out->{end});
        }
    }
}

sub PrintLongest # sink
{
    my $end = $_[0];
    
    if($end == $in_source)
    {
        printf("%d",$end);
        return;
    }
    
    &PrintLongest($edge_list[$end]->{in_links}->[0]);
    printf("->%d",$end);
}
