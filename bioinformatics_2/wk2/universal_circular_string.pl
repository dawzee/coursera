#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub UniversalCircularString; # k
sub StringReconstruction; # k, pattern
sub EulerianCycle; # adjacent list

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

printf("%s\n",&UniversalCircularString($data[0]));

sub UniversalCircularString # k
{
    my $k = $_[0];
    my @all_kmers = ();

    # construct list of all possible binary strings for this k-mer
    for my $value (0..(2**$k)-1)
    {
        $all_kmers[$value] = sprintf("%0${k}b",$value);
    }

    &StringReconstruction($k,\@all_kmers);
}

sub StringReconstruction # k, pattern
{
    my ($k,$pattern_ref) = @_;
    my %debruijn_graph;

    # construct DeBruijn graph for the list of strings
    foreach my $pattern_string (@{$pattern_ref})
    {
        my $prefix = substr($pattern_string,0,$k-1);
        my $suffix = substr($pattern_string,1,$k-1);
        
        if($debruijn_graph{$prefix})
        {
            # we already have this prefix, so add suffix to list 
            push(@{$debruijn_graph{$prefix}}, $suffix);
        }
        else
        {
            # new prefix
            my @new_array = ($suffix);
            $debruijn_graph{$prefix} = \@new_array;
        }
    }

    # the graph is balanced, find the eulerian cycle
    my @path = &EulerianCycle(%debruijn_graph);
     
    # build string by taking the last character of each element, skip the first element
    my $reconstructed_string = "";
    foreach my $index (1..$#path)
    {
        $reconstructed_string .= substr($path[$index],$k-2,1);
    }
    
    $reconstructed_string;
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
