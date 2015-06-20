
#include <stdio.h>
#include <string.h>

unsigned long long int PatternToNumber(const char *chars);
// void NumberToPattern;
// void ComputingFrequencies;
// void ClumpFinding(const char *Genome, int k, int t, int L);

int main()
{
//   open( my $input_fh, "<", $ARGV[0] ) || die "Can't open $ARGV[0]: $!";

//   my @data = <$input_fh>;
//   chomp($data[0]);
//   my @params = split(" ",$data[1]);

//   printf("%s\n",join(' ',&FrequentWords($data[0],$data[1])));

  printf("%llu\n",PatternToNumber("TTAGAGCCTCAATGAAAT"));
//   printf("%s\n",&NumberToPattern(7276,11));
//   printf("%s\n",join(' ',&ComputingFrequencies($data[0],$data[1])));

//   printf("%s\n",join(" ",&ClumpFinding($data[0],$params[0],$params[2],$params[1])));

}

unsigned long long int PatternToNumber(const char *chars)
{
  unsigned long long int output=0;
  int element=0;
  int multiplier=1;
  int shift=0;
  printf("%s (%ld) (%d) ",chars,strlen(chars),sizeof(unsigned int));
  
  for(element=strlen(chars)-1;element>=0;element--)
  {
    printf("%c (%d - %llu - %llu) ",chars[element],shift,output,(1<<shift));
    switch(chars[element])
    {
    case 'C' :
      //output += multiplier;
      output += 1 << shift;
      break;
    case 'G' :
      //output += 2 * multiplier;
      output += 2 << shift;
      break;
    case 'T' :
      //output += 3 * multiplier;
      output += 3 << shift;
      break;
    }
    multiplier *= 4;
    shift+=2;
  }
  return output;
}

// sub NumberToPattern
// {
//     my $number = $_[0];
//     my $base = $_[1];
//     my $multiplier = 4 ** ($base-1);
//     my $output = "";
//     #printf("%d %d\n",$multiplier,$number);
//     for(;$base>0;$base--)
//     {
//         if($multiplier * 3 <= $number)
//         {
//             $output .= "T";
//             $number -= $multiplier * 3;
//         }
//         elsif($multiplier * 2 <= $number)
//         {
//             $output .= "G";
//             $number -= $multiplier * 2;
//         }
//         elsif($multiplier <= $number)
//         {
//             $output .= "C";
//             $number -= $multiplier;
//         }
//         else
//         {
//             $output .= "A";
//         }
//         $multiplier = $multiplier / 4;
//         #printf("(%d)[%d]",$number,$multiplier);
//     }
//     $output;
// }

// sub ComputingFrequencies #(Text , k)
// {
//     my $text = $_[0];
//     my $k = $_[1];
//     my @frequency_array = (0) x (4 ** $k);
//     my $count;
//     my $number;
//     for($count=0;$count<length($text)-$k;$count++)
//     {
//         $number = &PatternToNumber(substr($text,$count,$k));
//         $frequency_array[$number] = $frequency_array[$number] + 1;
//     }
//     @frequency_array;
// }

// sub ClumpFinding #(Genome, k, t, L)
// {
//     my $genome = $_[0];
//     my $k = $_[1];
//     my $t = $_[2];
//     my $L = $_[3];
//     my @frequent_patterns;
//     my @clump = (0) x (4 ** $k);
//     my @frequency_array;
//     my $count;
//     my $count2;

//     #printf("ClumpFinding gen=%s len=%d k=%d t=%d L=%d\n",$genome, length($genome), $k, $t, $L);
    
//     for($count=0;$count<(length($genome) - $L);$count++)
//     {
//         printf("%d ",$count);
//         @frequency_array = &ComputingFrequencies(substr($genome,$count,$L),$k);
//         #printf("%s\n",join(" ",@frequency_array));
//         for($count2=0; $count2<(4**$k); $count2++)
//         {
//             if($frequency_array[$count2] >= $t)
//             {
//                 #printf("clump $frequency_array[$count2] \@ $count2\n");
//                 $clump[$count2] = 1;
//             }
//         }
//     }
//     for($count2=0;$count2<(4**$k);$count2++)
//     {
//         if($clump[$count2] == 1)
//         {
//             push(@frequent_patterns,&NumberToPattern($count2,$k));
//         }
//     }
//     @frequent_patterns;
// }
