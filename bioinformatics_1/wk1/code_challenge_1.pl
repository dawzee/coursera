#!/bin/perl
use strict;
use warnings;

sub PatternCount;

open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

my @data = <$input_fh>;

printf("%d matches\n",&PatternCount($data[0],$data[1]));


sub PatternCount
{

    my $indx = 0;
    my $count = 0;
    my $text = $_[0];
    my $pattern = $_[1];

    chomp($text);
    chomp($pattern);

    #printf("text = %s\n", $text);
    #printf("pattern = %s\n", $pattern);

    for($indx=0;$indx<=length($text)-length($pattern);$indx++)
    #for($indx=0;$indx<2;$indx++)
    {

        #printf("%s:%s\n",$pattern,substr($text,$indx,length($pattern)));
        if($pattern eq substr($text,$indx,length($pattern)))
        {
            $count++;
        }
    }
    $count;
}
