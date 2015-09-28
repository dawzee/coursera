#!/bin/perl
$|++;
use strict;
use warnings;
#use Data::Dumper;

sub TranslateRna; # rna_pattern

open( my $input_fh, "<", "RNA_codon_table_1.txt" ) || die "Can't open RNA_codon_table_1.txt: $!";
my %RNA_codon_table = ();
foreach my $codon_string (<$input_fh>)
{
    chomp($codon_string);
    $RNA_codon_table{substr($codon_string,0,3)} = substr($codon_string,4,1);
}
close($input_fh);

open( $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

printf("%s\n",&TranslateRna($data[0]));

sub TranslateRna # rna_pattern
{
    my $rna_pattern = $_[0];
    my $peptide = "";
    
    for(my $index=0; $index<length($rna_pattern); $index+=3)
    {
        my $codon = $RNA_codon_table{substr($rna_pattern,$index,3)};
        if(defined($codon)) { $peptide .= $codon; }
    }
    $peptide;
}
