#!/bin/perl
$|++;
use strict;
use warnings;

sub DpChange; # money, coins

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

printf("%d\n",&DpChange($data[0],split(",",$data[1])));

sub DpChange # money, coins
{
    my ($money, @coins) = @_;
    
    my @min_coins = ();
    
    $min_coins[0] = 0;
    for(my $money_index = 1; $money_index<=$money; $money_index++)
    {
        $min_coins[$money_index] = 999999;
        
        for(my $coin_index = 0; $coin_index < $#coins; $coin_index++)
        {
            if($money_index >= $coins[$coin_index])
            {
                if(($min_coins[$money_index - $coins[$coin_index]] + 1) < $min_coins[$money_index])
                {
                    $min_coins[$money_index] = $min_coins[$money_index - $coins[$coin_index]] + 1;
                }
            }
        }
    }
    $min_coins[$money];
}
