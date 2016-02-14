#!/bin/perl
$|++;
use strict;
use warnings;
no warnings 'recursion';
use Data::Dumper;

use constant INDEL_PENALTY => 5;


sub LoadScoringMatrix;
sub OutputLCS; # in_str1_idx, in_str2_idx
sub LCSBacktrack;
sub PrintMatrix; # matrix
sub max ($$) { $_[$_[0] < $_[1]] }

my %matrix_idx;  # map of letters to index
my @matrix_data; # 2 dimensional array of scores
&LoadScoringMatrix();

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

# read in the two strings
my $in_str1 = $data[0];
my $in_str2 = $data[1];

# and convert to arrays of indexes
my @in_str1_idx = map{ $matrix_idx{$_} } split("",$in_str1);
my @in_str2_idx = map{ $matrix_idx{$_} } split("",$in_str2);

my @longest;
my @backtrack;
&LCSBacktrack();

my $out_str1;
my $out_str2;
&OutputLCS(length($in_str1),length($in_str2));
printf("%d\n",$longest[length($in_str1)][length($in_str2)]);
printf("%s\n",$out_str1);
printf("%s\n",$out_str2);

sub LoadScoringMatrix
{
    open(my $fh, "<BLOSUM62.txt" ) || die "Can't open BLOSUM62.txt: $!";
    my @raw = <$fh>;
    close($fh);
    
    chomp(@raw);
    
    # split the first line into an array and create a lookup table from it
    my @idx_array = split(" ",$raw[0]);
    @matrix_idx{@idx_array} = (0 .. $#idx_array);

    for(my $idx=1; $idx <= $#raw; $idx++)
    {
        $matrix_data[$idx-1] = [split(" ",substr($raw[$idx],2))];
    }
}

sub OutputLCS # in_str1_idx, in_str2_idx
{
    my ($in_str1_idx,$in_str2_idx) = @_;
    if($in_str1_idx <= 0 && $in_str2_idx <= 0)
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
    for(my $row_index = 1; $row_index <= $#in_str1_idx+1; $row_index++)
    {
        $longest[$row_index][0] = $longest[$row_index-1][0] - INDEL_PENALTY;
        $backtrack[$row_index][0] = 'd';
    }
    # calculate first row
    for(my $col_index = 1; $col_index <= $#in_str2_idx+1; $col_index++)
    {
        $longest[0][$col_index] = $longest[0][$col_index-1] - INDEL_PENALTY;
        $backtrack[0][$col_index] = 'i';
    }
    # complete rest of grid
    for(my $row_index = 1; $row_index <= $#in_str1_idx+1; $row_index++)
    {
        for(my $col_index = 1; $col_index <= $#in_str2_idx+1; $col_index++)
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
            if(($longest[$row_index-1][$col_index-1] + 
                $matrix_data[$in_str1_idx[$row_index-1]][$in_str2_idx[$col_index-1]]) > $longest[$row_index][$col_index])
            {
                $longest[$row_index][$col_index] = ($longest[$row_index-1][$col_index-1] + 
                                                    $matrix_data[$in_str1_idx[$row_index-1]][$in_str2_idx[$col_index-1]]);
                $backtrack[$row_index][$col_index] = 'm';
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
