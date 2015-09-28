#!/bin/perl
$|++;
use strict;
use warnings;
#use Data::Dumper;

sub FindPeptideEncoding; # dna_string, peptide
sub ReverseCompliment; # dna_pattern
sub TranscribeDna; # dna_pattern
sub TranslateRna;  # rna_pattern

#printf("ATGGCCATGGCCCCCAGAACTGAGATCAATAGTACCCGTATTAACGGGTGA -> %s\n",&TranscribeDna("ATGGCCATGGCCCCCAGAACTGAGATCAATAGTACCCGTATTAACGGGTGA"));
#exit;

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

printf("%s\n",join("\n",&FindPeptideEncoding($data[0],$data[1])));


sub FindPeptideEncoding # dna_string, peptide
{
    my ($dna_string,$peptide) = @_;
    my $substring_length = length($peptide)*3;
    
    my @matching = ();
    
    for(my $index=0; $index<=length($dna_string)-$substring_length; $index++)
    {
        my $segment = substr($dna_string,$index,$substring_length);
#        printf("pepin=%s segment=%s rna=%s pep=%s rev=%s rna=%s pep=%s\n",
#            $peptide,
#            $segment,&TranscribeDna($segment),&TranslateRna(&TranscribeDna($segment)),
#            &ReverseCompliment($segment),&TranscribeDna(&ReverseCompliment($segment)),&TranslateRna(&TranscribeDna(&ReverseCompliment($segment))));
        if((&TranslateRna(&TranscribeDna($segment)) eq $peptide) ||
           (&TranslateRna(&TranscribeDna(&ReverseCompliment($segment))) eq $peptide))
        {
#            printf("MATCH!\n");
            push(@matching,$segment);
        }
    }

    @matching;
}


sub ReverseCompliment # dna_pattern
{
    my $element;
    my @output = split("",reverse($_[0]));
    my %replace = ( A => 'T', C => 'G', G => 'C', T => 'A' );
    foreach $element (@output) {
        $element = $replace{$element};
    }
    return join("",@output);
}

sub TranscribeDna # dna_pattern
{
    my $temp = $_[0];
    $temp =~ s/T/U/g;
    $temp;
}

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
