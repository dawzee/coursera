#!/bin/perl
$|++;
use strict;
use warnings;
no warnings 'recursion';
use Data::Dumper;

use constant INDEL_PENALTY => 1;
use constant MISMATCH_PENALTY => 1;

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
my $max_row = 0;
my $max_col = 0;
&LCSBacktrack();

my $out_str1;
my $out_str2;
&OutputLCS($max_row,$max_col);
printf("%d\n",$longest[$max_row][$max_col]);
printf("%s\n",$out_str1);
printf("%s\n",$out_str2);

sub OutputLCS # in_str1_idx, in_str2_idx
{
    my ($in_str1_idx,$in_str2_idx) = @_;
    if($in_str1_idx <= 0 && $in_str2_idx <= 0)
    {
        return;
    }

    if($backtrack[$in_str1_idx][$in_str2_idx] eq 'f')
    {
        return;
    }
    
    if($backtrack[$in_str1_idx][$in_str2_idx] eq 'd')
    {
        &OutputLCS($in_str1_idx-1,$in_str2_idx);
        $out_str1 .= substr($in_str1,$in_str1_idx-1,1);
        $out_str2 .= '-';
    }
    elsif($backtrack[$in_str1_idx][$in_str2_idx] eq 'i')
    {
        &OutputLCS($in_str1_idx,$in_str2_idx-1);
        $out_str2 .= substr($in_str2,$in_str2_idx-1,1);
        $out_str1 .= '-';
    }
    else
    {
        # match or mismatch
        &OutputLCS($in_str1_idx-1,$in_str2_idx-1);
        $out_str1 .= substr($in_str1,$in_str1_idx-1,1);
        $out_str2 .= substr($in_str2,$in_str2_idx-1,1);
    }
}

sub LCSBacktrack
{
    $longest[0][0] = 0;
    $backtrack[0][0] = 'u';
    
    # calculate first column
    for(my $row_index = 1; $row_index <= length($in_str1); $row_index++)
    {
        $longest[$row_index][0] = 0;
        $backtrack[$row_index][0] = 'f';
    }
    # calculate first row
    for(my $col_index = 1; $col_index <= length($in_str2); $col_index++)
    {
        $longest[0][$col_index] = $longest[0][$col_index-1] - INDEL_PENALTY;
        $backtrack[0][$col_index] = 'i';
    }
    # complete rest of grid
    for(my $row_index = 1; $row_index <= length($in_str1); $row_index++)
    {
        for(my $col_index = 1; $col_index <= length($in_str2); $col_index++)
        {
            if(($longest[$row_index][$col_index-1] - INDEL_PENALTY) > ($longest[$row_index-1][$col_index] - INDEL_PENALTY))
            {
                # insertion!
                $longest[$row_index][$col_index] = $longest[$row_index][$col_index-1] - INDEL_PENALTY;
                $backtrack[$row_index][$col_index] = 'i';
            }
            else
            {
                # deletion
                $longest[$row_index][$col_index] = $longest[$row_index-1][$col_index] - INDEL_PENALTY;
                $backtrack[$row_index][$col_index] = 'd';
            }
            
            # check match or mismatch score
            if(substr($in_str1,$row_index-1,1) eq substr($in_str2,$col_index-1,1))
            {
                if(($longest[$row_index-1][$col_index-1] + 1) > $longest[$row_index][$col_index])
                {
                    $longest[$row_index][$col_index] = ($longest[$row_index-1][$col_index-1] + 1);
                    $backtrack[$row_index][$col_index] = 'm';
                }
            }
            else
            {
                if(($longest[$row_index-1][$col_index-1] - MISMATCH_PENALTY) > $longest[$row_index][$col_index])
                {
                    $longest[$row_index][$col_index] = ($longest[$row_index-1][$col_index-1] - MISMATCH_PENALTY);
                    $backtrack[$row_index][$col_index] = 'M';
                }
            }
            
            # keep track of max score position
            if(($col_index == length($in_str2)) && ($longest[$row_index][$col_index] > $longest[$max_row][$max_col]))
            {
                $max_row = $row_index;
                $max_col = $col_index;
            }
            
        }
    }
#    &PrintMatrix(\@longest);
#    &PrintMatrix(\@backtrack);
#    printf("max row=%d, max col=%d\n",$max_row,$max_col);
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
    printf("\n");
}
