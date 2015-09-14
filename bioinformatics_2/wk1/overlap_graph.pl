#!/bin/perl
$|++;
use strict;
use warnings;

sub OverlapPath; # pattern

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

printf("%s\n",join("\n",&OverlapPath(\@data)));

sub OverlapPath # pattern
{
    my $pattern_ref = $_[0];
    my @overlaps = ();

    foreach my $pattern_string (@{$pattern_ref})
    {
        foreach my $match_string (@{$pattern_ref})
        {
            if(substr($pattern_string,1,length($pattern_string)-1) eq substr($match_string,0,length($match_string)-1))
            {
                push(@overlaps,$pattern_string." -> ".$match_string);
            }
        }
    }
    @overlaps;
}
