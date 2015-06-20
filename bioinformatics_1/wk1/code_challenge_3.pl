#!/bin/perl
use strict;
use warnings;

sub ReverseCompliment;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
#open( my $output_fh, ">output.txt");

my @data = <$input_fh>;

chomp($data[0]);

printf("%s\n",&ReverseCompliment($data[0]));


sub ReverseCompliment
{
    my $element;
    my @output = split("",reverse($_[0]));
    my %replace = ( A => 'T', C => 'G', G => 'C', T => 'A' );
    foreach $element (@output) {
        $element = $replace{$element};
    }
    return join("",@output);
}
