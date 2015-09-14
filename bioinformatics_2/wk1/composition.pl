#!/bin/perl
$|++;
use strict;
use warnings;

sub Composition; # k, text

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;
chomp(@data);

my $k = $data[0];
my $text = $data[1];

printf("%s\n",join("\n",&Composition($data[0],$data[1])));

sub Composition # k, text
{
    my $k = $_[0];
    my $text = $_[1];
    my @composition = ();
    
    for(my $index=0;$index<=length($text)-$k;$index++)
    {
        push(@composition,substr($text,$index,$k));
    }
    @composition;
}
