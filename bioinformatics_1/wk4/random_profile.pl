#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(sum);

sub RandomProfile; #(profile)

my @profile = (0.1, 0.3, 0.02, 0.8);

printf("o/p = %d\n",&RandomProfile(@profile));


sub RandomProfile #(profile)
{
    my @profile = @_;
    my $sum = sum(@profile);
    my $rand = rand($sum);
    my $accumilator = 0;

    for(my $index=0;$index<@profile;$index++)
    {
        $accumilator += $profile[$index];
        if($rand<=$accumilator)
        {
            return($index);
        }
    }
}
