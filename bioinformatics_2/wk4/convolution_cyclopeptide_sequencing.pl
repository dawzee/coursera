#!/bin/perl
$|++;
use strict;
use warnings;
use Data::Dumper;
use List::Util qw(sum max);
#use Devel::Size qw(size total_size);

sub ConvolutionCyclopeptideSequencing; # M, N, spectrum
sub RestrictedAlphabet; # m, spectrum
sub Expand; # alphabet, peptides
sub LinearSpectrum; # peptide
sub LinearScore; # peptide, spectrum
sub CyclicSpectrum; # peptide
sub CyclicScore; # peptide, spectrum
sub Trim; # Leaderboard, Spectrum, N

open(my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";
my @data = <$input_fh>;
chomp(@data);

printf("%s\n",join("-",&ConvolutionCyclopeptideSequencing($data[0],$data[1],split(" ",$data[2]))));

sub ConvolutionCyclopeptideSequencing # M, N, spectrum
{
    my ($m, $n, @spectrum) = @_;

    my $old_peptides = ""; # a set containing only the empty peptide
    my $new_peptides;
    my $parent_mass_spectrum = max(@spectrum);
    my $max_mass_peptide_array = 0;
    
    my @leader;
    my $debug_count = 0;
    
    my @alphabet = &RestrictedAlphabet($m,\@spectrum);
    
    do
    {
        $new_peptides = "";
        &Expand(\@alphabet,\$old_peptides,\$new_peptides);
        $old_peptides = "";

        for(my $index=0;$index<length($new_peptides);$index++)
        {
            my $end_index = $index;
            while($end_index < length($new_peptides) && substr($new_peptides,$end_index,1) ne ":") { $end_index++; };
            my $peptide = substr($new_peptides,$index,$end_index-$index);
            $index = $end_index;
            
            my @peptide_array = split("-",$peptide);
            my $mass_peptide_array = sum(@peptide_array);
            
            if($mass_peptide_array > $max_mass_peptide_array)
            {
                $max_mass_peptide_array = $mass_peptide_array;
            }
            
            if($mass_peptide_array == $parent_mass_spectrum)
            { # Mass(Peptide) = ParentMass(Spectrum)
            
                if(&CyclicScore(\@peptide_array, \@spectrum) > &CyclicScore(\@leader, \@spectrum))
                {
                    @leader = @peptide_array;
                    # something is wrong with this program! let's just give up as soon as we've found a leader
                    #$old_peptides = "";
                    #last;
                }
            }            
            elsif($mass_peptide_array < $parent_mass_spectrum)
            {
                # it's still a good candidate, keep it for next time
                if(length($old_peptides)>0)
                {
                    $old_peptides .= ":".$peptide;
                }
                else
                {
                    $old_peptides = $peptide;
                }
            }
        }
        if(length($old_peptides)>0)
        {
            printf("%d",($old_peptides =~ tr/://));
            $old_peptides = &Trim($old_peptides,\@spectrum,$n);
            printf(" trimmed to %d. %d",($old_peptides =~ tr/://),($old_peptides =~ tr/-//));
            printf(" mm=%d pm=%d leader=%s\n",$max_mass_peptide_array,$parent_mass_spectrum,join("-",@leader));
        }
        
#    } while($debug_count++<10);
    } while(length($old_peptides) > 0);
    
    @leader;
}

sub RestrictedAlphabet # m, spectrum
{
    my ($m,$spectrum_ref) = @_;
    my %occurances;
    my @alphabet;
    
    foreach my $omass (@{$spectrum_ref})
    {
        foreach my $imass (@{$spectrum_ref})
        {
            if(($omass-$imass)>0)
            {
                $occurances{($omass-$imass)}++;
            }
        }
    }
    
    my $cutoff;
    foreach my $mass (sort { $occurances{$b} <=> $occurances{$a} } keys %occurances)
    {
        if($mass<57 || $mass>200)
        {
            next;
        }

        $m--;
        if($m==0)
        {
            $cutoff = $occurances{$mass};
        }
        elsif($m<0 && $cutoff != $occurances{$mass})
        {
            last;
        }
        
        printf("%d->%d ",$mass,$occurances{$mass});
        push(@alphabet,$mass);
    }
    printf("\n");
    @alphabet;
}

sub Expand # alphabet, peptides
{
    my ($alphabet_ref,$peptides_ref,$new_peptides_ref) = @_;
    #my @masses = (57, 71, 87, 97, 99, 101, 103, 113, 114, 115, 128, 129, 131, 137, 147, 156, 163, 186);
    my $peptide;
    my $mass;
    
    if(length(${$peptides_ref})>0)
    {
        foreach $peptide (split(":",${$peptides_ref}))
        {
            foreach $mass (@{$alphabet_ref})
            {
                ${$new_peptides_ref} .= ":".$peptide."-".$mass;
            }
        }
        ${$new_peptides_ref} = substr(${$new_peptides_ref},1);
    }
    else
    {
        ${$new_peptides_ref} = join(":",@{$alphabet_ref});
    }
}

sub LinearSpectrum # peptide
{
    my @peptide = @_;
    my $char_index;
    my $mass_index;

    my @prefix_mass = (0);
    for($char_index=1;$char_index<=scalar(@peptide);$char_index++)
    {
        $prefix_mass[$char_index] = $prefix_mass[$char_index-1] + $peptide[$char_index-1];
    }

    my @linear_spectrum = (0);
    for($char_index=0;$char_index<scalar(@peptide);$char_index++)
    {
        for($mass_index=$char_index+1;$mass_index<=scalar(@peptide);$mass_index++)
        {
            push(@linear_spectrum,($prefix_mass[$mass_index]-$prefix_mass[$char_index]));
        }
    }
    sort {$a <=> $b} (@linear_spectrum);
}

sub LinearScore # peptide, spectrum
{
    my ($tpeptide_ref,$espectrum_ref) = @_;

    #printf("experimental spectrum is %s\n",join(" ",@{$espectrum_ref}));

    # calculate the spectrum for the given peptide
    my @tspectrum = &LinearSpectrum(@{$tpeptide_ref});

    #printf("theoretical spectrum of %s is %s\n",join(" ",@{$tpeptide_ref}),join(" ",@tspectrum));
    
    my $score = 0;

    foreach my $emass (@{$espectrum_ref})
    {
        foreach my $tmass (@tspectrum)
        {
            if($emass == $tmass)
            {
                $score++;
                # negate the spectrum mass so we don't reuse it
                $tmass = -$tmass;
                last; # break
            }
        }
    }
    $score;
}

sub CyclicSpectrum # peptide
{
    my @peptide = @_;
    my $char_index;
    my $mass_index;

    my @prefix_mass = (0);
    for($char_index=1;$char_index<=scalar(@peptide);$char_index++)
    {
        $prefix_mass[$char_index] = $prefix_mass[$char_index-1] + $peptide[$char_index-1];
    }

    my $peptide_mass = $prefix_mass[scalar(@peptide)];
    my @cyclic_spectrum = (0);
    for($char_index=0;$char_index<scalar(@peptide);$char_index++)
    {
        for($mass_index=$char_index+1;$mass_index<=scalar(@peptide);$mass_index++)
        {
            push(@cyclic_spectrum,($prefix_mass[$mass_index]-$prefix_mass[$char_index]));
            if($char_index>0 && $mass_index<scalar(@peptide))
            {
                push(@cyclic_spectrum,
                     $peptide_mass-($prefix_mass[$mass_index]-$prefix_mass[$char_index]));                
            }
        }
    }
    sort {$a <=> $b} (@cyclic_spectrum);
}

sub CyclicScore # peptide, spectrum
{
    my ($tpeptide_ref,$espectrum_ref) = @_;

    #printf("experimental spectrum is %s\n",join(" ",@espectrum));

    # calculate the spectrum for the given peptide
    my @tspectrum = &CyclicSpectrum(@{$tpeptide_ref});
    
    #printf("theoretical spectrum of %s is %s\n",$peptide,join(" ",@tspectrum));
    
    my $score = 0;

    foreach my $emass (@{$espectrum_ref})
    {
        foreach my $tmass (@tspectrum)
        {
            if($emass == $tmass)
            {
                $score++;
                # negate the spectrum mass so we don't reuse it
                $tmass = -$tmass;
                last; # break
            }
        }
    }
    $score;
}

sub Trim # Leaderboard, Spectrum, N
{
    my ($leaderboard_string,$spectrum_ref,$n) = @_;

    my $trimmed_list;
    #my $found;
    my @scores = ();

    printf(" s ");

    foreach my $peptide (split(":",$leaderboard_string))
    {
        #$found=0;
        #foreach my $search (@scores)
        #{
        #    if($search->[1] eq $peptide)
        #    {
        #        $found=1;
        #        last;
        #    }
        #}
        #if($found)
        #{
        #    next;
        #}
        my @peptide_array = split("-",$peptide);
        my $score = &LinearScore(\@peptide_array,$spectrum_ref);
        #printf("score of %s against %s is %d\n",$peptide,join("-",@{$spectrum_ref}),$score);
        push (@scores,[$score,$peptide]);
    }

    printf(" o ");

    # sort Leaderboard according to the decreasing order of scores in LinearScores
    @scores = sort { $b->[0] <=> $a->[0] } @scores;

    printf(" t(%d) ",scalar(@scores));

    for(my $index=0;$index<scalar(@scores);$index++)
    {
        # output all peptides in the top n'th positions or ones with equal score than the n'th
        if($index<$n || $scores[$index][0] >= $scores[$n-1][0])
        {
            $trimmed_list .= $scores[$index][1].":";
        }
        else
        {
            #splice(@scores,$index);
            last;
        }
    }
    chop($trimmed_list);
    $trimmed_list;
}
