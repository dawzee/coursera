#!/bin/perl
$|++;
use strict;
use warnings;
no warnings 'recursion';
use Data::Dumper;

sub OutputLCS; # backtrack, str1, i, j
sub LCSBacktrack; # str1, str2
sub PrintMatrix; # matrix
sub max ($$) { $_[$_[0] < $_[1]] }

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

my $in_str1 = $data[0];
my $in_str2 = $data[1];

#printf("%s,%s\n",$in_str1,$in_str2);
&OutputLCS(&LCSBacktrack($in_str1,$in_str2),$in_str1,length($in_str1),length($in_str2));
printf("\n");

sub OutputLCS # backtrack, str1, i, j
{
    my ($backtrack_ref,$str1,$i,$j) = @_;

    if($i == 0 || $j == 0)
    {
        return;
    }

    if($backtrack_ref->[$i][$j] eq 'd')
    {
#        printf("d");
        &OutputLCS($backtrack_ref,$str1,$i,$j-1);
    }
    elsif($backtrack_ref->[$i][$j] eq 'i')
    {
#        printf("i");
        &OutputLCS($backtrack_ref,$str1,$i-1,$j);
    }
    else
    {
#        printf("m");
        &OutputLCS($backtrack_ref,$str1,$i-1,$j-1);
        printf("%s",substr($str1,$i-1,1));
    }
}

sub LCSBacktrack # str1, str2
{
    my ($str1, $str2) = @_;

    my @longest;
    my @backtrack;

    # calculate first column
    for(my $col_index = 0; $col_index <= length($str1); $col_index++)
    {
        $longest[$col_index][0] = 0;
    }
    # calculate first row
    for(my $row_index = 0; $row_index <= length($str2); $row_index++)
    {
        $longest[0][$row_index] = 0;
    }
    # complete rest of grid
    for(my $col_index = 1; $col_index <= length($str1); $col_index++)
    {
        for(my $row_index = 1; $row_index <= length($str2); $row_index++)
        {
            if($longest[$col_index-1][$row_index] > $longest[$col_index][$row_index-1])
            {
                # insertion!
                $longest[$col_index][$row_index] = $longest[$col_index-1][$row_index];
                $backtrack[$col_index][$row_index] = 'i';
            }
            else
            {
                # deletion
                $longest[$col_index][$row_index] = $longest[$col_index][$row_index-1];
                $backtrack[$col_index][$row_index] = 'd';
            }
            
            if(substr($str1,$col_index-1,1) eq substr($str2,$row_index-1,1))
            {
                # match
                if(($longest[$col_index-1][$row_index-1]+1) > $longest[$col_index][$row_index])
                {
                    $longest[$col_index][$row_index] = ($longest[$col_index-1][$row_index-1]+1);
                    $backtrack[$col_index][$row_index] = 'm';
                }
            }
        }
    }
#    print Dumper @longest;
#    print Dumper @backtrack;
#    &PrintMatrix(\@longest);
#    &PrintMatrix(\@backtrack);
    \@backtrack;
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
                printf("%s ",$matrix_ref->[$col][$row]);
            }
            else
            {
                printf("u ");
            }
        }
        printf("\n");
    }
    
}
