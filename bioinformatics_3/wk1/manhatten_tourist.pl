#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;

sub ManhattenTourist; # n, m, down, right
sub max ($$) { $_[$_[0] < $_[1]] }

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

my ($n_in,$m_in) = split(" ",$data[0]);
my @down_in;
my @right_in;

for(my $down_index=0; $down_index<$n_in; $down_index++)
{
    $down_in[$down_index] = [ split(" ",$data[$down_index+1]) ];
}
for(my $right_index=0; $right_index<$n_in+1; $right_index++)
{
    $right_in[$right_index] = [ split(" ",$data[$right_index+1+$n_in+1]) ];
}


printf("%d\n",&ManhattenTourist($n_in,$m_in,\@down_in,\@right_in));


sub ManhattenTourist # n, m, down, right
{
    my ($n,$m,$down_ref,$right_ref) = @_;
    
    my @longest;
    $longest[0][0] = 0;
    # calculate first column
    for(my $n_index = 1; $n_index <= $n; $n_index++)
    {
        $longest[$n_index][0] = $longest[$n_index-1][0] + $down_ref->[$n_index-1][0];
    }
    # calculate first row
    for(my $m_index = 1; $m_index <= $m; $m_index++)
    {
        $longest[0][$m_index] = $longest[0][$m_index-1] + $right_ref->[0][$m_index-1];
    }
    # complete rest of grid
    for(my $m_index = 1; $m_index <= $m; $m_index++)
    {
        for(my $n_index = 1; $n_index <= $n; $n_index++)
        {
            $longest[$n_index][$m_index] = &max(($longest[$n_index-1][$m_index] + $down_ref->[$n_index-1][$m_index]),
                                                ($longest[$n_index][$m_index-1] + $right_ref->[$n_index][$m_index-1]));
        }
    }
    $longest[$n][$m];
}
