#!/bin/perl
$|++;
use strict;
use warnings;
#use Data::Dumper;

sub EulerianCycle; # adjacent list

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

# load the adjacent list into a 2 dimensional array
my @adjacent_list = ();
foreach my $line (@data)
{
    my ($index,$adjacent_string) = split(" -> ",$line);
    my @adjacent_array = split(",",$adjacent_string);
    $adjacent_list[$index] = \@adjacent_array;
}
printf("%s\n",join("->",&EulerianCycle(@adjacent_list)));

sub EulerianCycle # adjacent list
{
    my @in_list = @_;
    my @cycle = ();       # store the running cycle
    my $first_index = 0;  # remember where we started each cycle
    my $done = 0;         # flag that we're complete
    my @spare_paths = (); # remember spare paths to use later
    
    # start at position 0
    my $next_index = $first_index;
    
    do {
#        printf("at $next_index : %d\n",(scalar @{$in_list[$next_index]}));

        # if there are other paths available at this node (and we're not at the start) then store it
        if($next_index != $first_index && scalar(@{$in_list[$next_index]}) > 1)
        {
#            printf("spare paths found @ position %d\n",scalar(@cycle));
            push(@spare_paths,scalar(@cycle));
        }

        # store the node in the cycle and get next
        push(@cycle,$next_index);
        $next_index = shift($in_list[$next_index]);
        
        if(!defined($next_index))
        {
            # whoops, this shouldn't have happened. protect against infinite loop
            printf("ERROR! next index is null!\n");
            $done=1;
        }

        # check if we're at the end of the cycle
        if($next_index == $first_index && scalar(@{$in_list[$next_index]}) == 0)
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
                } while(defined $next_spare_path_location && (scalar @{$in_list[$cycle[$next_spare_path_location]]}) == 0);
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
                    if($x<0) { $x += $#in_list; }
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
