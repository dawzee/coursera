#!/bin/perl
$|++;
use strict;
use warnings;
no warnings 'recursion';
use Data::Dumper;

use constant INDEL_PENALTY => 5;


sub OutputLCS; # i, j
sub LCSBacktrack;
sub PrintMatrix; # matrix
sub max ($$) { $_[$_[0] < $_[1]] }

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

# read in the two strings
my $in_str1 = $data[0];
my $in_str2 = $data[1];

my @longest;
my @backtrack;
&LCSBacktrack();

printf("%d\n",$longest[length($in_str1)][length($in_str2)]);


sub LCSBacktrack
{
    $longest[0][0] = 0;
    $backtrack[0][0] = 'u';
    
    # calculate first column
    for(my $row_index = 1; $row_index <= length($in_str1)+1; $row_index++)
    {
        $longest[$row_index][0] = $longest[$row_index-1][0] + 1;
        $backtrack[$row_index][0] = 'd';
    }
    # calculate first row
    for(my $col_index = 1; $col_index <= length($in_str2)+1; $col_index++)
    {
        $longest[0][$col_index] = $longest[0][$col_index-1] + 1;
        $backtrack[0][$col_index] = 'i';
    }
    # complete rest of grid
    for(my $row_index = 1; $row_index <= length($in_str1)+1; $row_index++)
    {
        for(my $col_index = 1; $col_index <= length($in_str2)+1; $col_index++)
        {
            if(($longest[$row_index][$col_index-1] + 1) < ($longest[$row_index-1][$col_index] + 1))
            {
                # insertion!
                $longest[$row_index][$col_index] = $longest[$row_index][$col_index-1] + 1;
                $backtrack[$row_index][$col_index] = 'i';
            }
            else
            {
                # deletion
                $longest[$row_index][$col_index] = $longest[$row_index-1][$col_index] + 1;
                $backtrack[$row_index][$col_index] = 'd';
            }
            
            # check match for match
            if(substr($in_str1,$row_index-1,1) eq substr($in_str2,$col_index-1,1))
            {
                $longest[$row_index][$col_index] = $longest[$row_index-1][$col_index-1];
                $backtrack[$row_index][$col_index] = 'm';
            }
            elsif(($longest[$row_index-1][$col_index-1] + 1) < ($longest[$row_index][$col_index]))
            {
                $longest[$row_index][$col_index] = $longest[$row_index-1][$col_index-1] + 1;
                $backtrack[$row_index][$col_index] = 'M';
            }
            
        }
    }
#    &PrintMatrix(\@longest);
#    &PrintMatrix(\@backtrack);
}

sub PrintMatrix # matrix
{
    my $matrix_ref = $_[0];
    
    for(my $col=0;$col<=$#{$matrix_ref};$col++)
    {
        for(my $row=0;$row<=$#{$matrix_ref->[$col]};$row++)
        {
            if(defined($matrix_ref->[$col][$row]))
            {
                printf("%3s ",$matrix_ref->[$col][$row]);
            }
            else
            {
                printf("  u ");
            }
        }
        printf("\n");
    }
    
}
