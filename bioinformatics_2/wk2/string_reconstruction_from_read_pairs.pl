#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub StringReconstructionReadPairs; # k, d, pattern
sub EulerianPath; # adjacent list
sub EulerianCycle; # adjacent list

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);
my ($k,$d) = split(" ",$data[0]);
my @pattern = @data[ 1 .. $#data ];

printf("%s\n",&StringReconstructionReadPairs($k,$d,\@pattern));

sub StringReconstructionReadPairs # k, d, pattern
{
    my ($k,$d,$pattern_ref) = @_;
    my %debruijn_graph;

    foreach my $pattern_string (@{$pattern_ref})
    {
        my $prefix = substr($pattern_string,0,$k-1).substr($pattern_string,$k+1,$k-1);
        my $suffix = substr($pattern_string,1,$k-1).substr($pattern_string,$k+2,$k-1);
        
        if($debruijn_graph{$prefix})
        {
            # we already have this prefix, so push on the suffix
            push(@{$debruijn_graph{$prefix}}, $suffix);
        }
        else
        {
            # new prefix
            my @new_array = ($suffix);
            $debruijn_graph{$prefix} = \@new_array;
        }
    }

#    print Dumper %debruijn_graph;
    # find the eulerian path
    my @path = &EulerianPath(%debruijn_graph);
 
#    printf("%s\n",join("->",@path));
    
    # build string by taking the first element then adding last character of subsequent elements
    my $prefix_string = substr($path[0],0,$k-1);
    my $suffix_string = substr($path[0],$k-1,$k-1);
    foreach my $index (1..$#path)
    {
        $prefix_string .= substr($path[$index],$k-2,1);
        $suffix_string .= substr($path[$index],(2*$k)-3,1);
    }
    
    my $overlap = length($prefix_string)-$k-$d;
    my $reconstructed_string;
    if(substr($prefix_string,$k+$d,$overlap) eq substr($suffix_string,0,$overlap))
    {
        #printf("MATCH!\n");
        $reconstructed_string = $prefix_string.substr($suffix_string,$overlap,length($suffix_string)-$overlap);
    }
    else
    {
        $reconstructed_string = "NO MATCH!";
    }
    $reconstructed_string;
}


sub EulerianPath # adjacent list
{
    my %adjacent_list = @_;
    my %in_count  = ();
    my %out_count = ();

    # count ins and outs to find unbalanced edge
    foreach my $index (keys(%adjacent_list))
    {
        $out_count{$index} = @{$adjacent_list{$index}};
        foreach my $out_link (@{$adjacent_list{$index}})
        {
            $in_count{$out_link}++;
        }
    }

    my $unbalanced_from;
    my $unbalanced_to;
    foreach my $index (keys(%in_count),keys(%out_count))
    {
        if(!defined($in_count{$index}))  { $in_count{$index} = 0;  }
        if(!defined($out_count{$index})) { $out_count{$index} = 0; }
        if($in_count{$index} < $out_count{$index})
        {
            $unbalanced_from = $index;
#            printf("from - $index\n");
        }
        elsif($in_count{$index} > $out_count{$index})
        {
            $unbalanced_to = $index;
#            printf("to - $index\n");
        }
    }
    
    # add the extra edge to balance
    if(defined($adjacent_list{$unbalanced_to}))
    {
        push(@{$adjacent_list{$unbalanced_to}}, $unbalanced_from);
    }
    else
    {
        my @new_array = ($unbalanced_from);
        $adjacent_list{$unbalanced_to} = \@new_array;
    }

    #print Dumper %adjacent_list;

    # find the Eulerian cycle
    my @cycle = &EulerianCycle(%adjacent_list);
    
#    printf("%s\n",join("->",@cycle));
    
    # rebalance and remove extra node
    foreach my $index (0..$#cycle)
    {
        if(($cycle[$index] eq $unbalanced_to) && ($cycle[$index+1] eq $unbalanced_from))
        {
            # found it
            pop(@cycle);
            push(@cycle,splice(@cycle,0,$index+1));
            last;
        }
    }
    
    @cycle;
}

sub EulerianCycle # adjacent list
{
    my %in_list = @_;
    my @cycle = ();       # store the running cycle
    my $first_index = 0;  # remember where we started each cycle
    my $done = 0;         # flag that we're complete
    my @spare_paths = (); # remember spare paths to use later
    
    # choose a key to start at (it doesn't really matter which)
    # use 'keys' in array context assigned to a scalar to pick one
    ($first_index) = keys(%in_list);
    
#    printf("staring at $first_index\n");
    
    my $next_index = $first_index;
    
    do {
#        printf("at $next_index : %d\n",(scalar @{$in_list[$next_index]}));

        # if there are other paths available at this node (and we're not at the start) then store it
        if($next_index ne $first_index && scalar(@{$in_list{$next_index}}) > 1)
        {
#            printf("spare paths found @ position %d\n",scalar(@cycle));
            push(@spare_paths,scalar(@cycle));
        }

        # store the node in the cycle and get next
        push(@cycle,$next_index);
#        printf("%s\n",join("->",@cycle));
        $next_index = shift($in_list{$next_index});
        
        if(!defined($next_index))
        {
            # whoops, this shouldn't have happened. protect against infinite loop
            printf("ERROR! next index is null!\n");
            $done=1;
        }

        # check if we're at the end of the cycle
        if($next_index eq $first_index && scalar(@{$in_list{$next_index}}) == 0)
        {
#            printf("at the start with nowhere to go\n");
            my $next_spare_path_location = undef;
            # we're back at the start and nowhere to go, are there any paths elsewhere?
            if(@spare_paths)
            {
                # check that the spare paths are still valid, it may have been used since we stored its location
                do
                {
                    $next_spare_path_location = shift(@spare_paths);
                } while(defined $next_spare_path_location && (scalar @{$in_list{$cycle[$next_spare_path_location]}}) == 0);
            }
            
            if(defined $next_spare_path_location)
            {
#                printf("spare paths available @ position $next_spare_path_location node = $cycle[$next_spare_path_location]\n");
                # shift the cycle to put the new first index at the start
                push(@cycle,splice(@cycle,0,$next_spare_path_location));
                # the spare path locations need to be adjusted to match as well
                foreach my $x (@spare_paths)
                {
                    $x -= $next_spare_path_location;
                    if($x<0) { $x += keys(%in_list); }
                }
                # store the next index and first index
                $next_index = $first_index = $cycle[0];
            }
            else
            {
                # we're done
#                printf("complete\n");
                $done = 1;
            }
        
        }
    } while(!$done);
    
    # finally, complete the cycle
    push(@cycle,$next_index);

    @cycle;
}
