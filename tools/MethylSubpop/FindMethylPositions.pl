#!/usr/bin/perl

#Run with perl FindMethylpositions.pl <Output of MethylPattern.pl>
#extract first and last methylated positions of each target and print it in a space-delimited text file

use strict;
use warnings;
use List::MoreUtils qw(uniq);

my $eachline; 
my $start;	#start position of each target
my $end;	#end position of each target
my @firsthit;
my @lasthit;
my $counter=-1;

open (my $input, "<", $ARGV[0]) or die ("no such file!");
while(defined($eachline=<$input>))
	{
		if($eachline=~/chr.*;\s(\d+)-(\d+)$/) #count the iterations, print results & reset the parameters to zero after each iteration
			{
				print "FIRST=0\tLAST=0\n" if ((!@firsthit)	&& ($start));		#in case of empty target
				$counter++;				
				#print "$counter first: @firsthit last:@lasthit \n" if(@firsthit);
				#print "@firsthit \t @lasthit \n";	
				printpositions() if(@firsthit);
				@firsthit=();
				@lasthit=();				
				$start = $1;
				$end = $2;				
			}
		elsif($eachline=~/\d*\s*([\*\.zZ]*)/) #(\d*\s*)(\.|z|Z|\*)/) #(\d*\s*)
			{
				$eachline=$1;
				#print "$eachline \n";
				#$eachline =~ s/\d//;
				#$eachline =~ s/\t//g;
				push @firsthit, (index(lc $eachline, "z")+1) if ($eachline =~ m/[zZ]/);	#index+1 for distinguishing empty reads and first position		#http://www.misc-perl-info.com/perl-index.html; 
				push @firsthit, "0" if ($eachline !~ m/[zZ]/);
				push @lasthit, (rindex(lc $eachline, "z")+1) if (($eachline =~ m/[zZ]/)&&(rindex(lc $eachline, "z")+$start <= $end)); 
				push @lasthit, "0" if ($eachline !~ m/[zZ]/);
			}		
	}
close($input);

#for the last target
#print "$counter first: @firsthit last:@lasthit" if(@firsthit);
printpositions() if(@firsthit);
print "FIRST=0\tLAST=0\n" if ((!@firsthit) && ($start));

sub printpositions
{
	count_unique(\@firsthit, 1);
	count_unique(reverse (\@lasthit), 2);
}

#returns first and last methylation position (first and last postion for at least 50% of all reads)
sub count_unique {
	my ($array, $case) = @_;
	my %count;
	$count{$_}++ for @$array;
	my $i;
	
	if  ($case eq 1 )	
		{
		for (sort {$a <=> $b} keys %count)
			{
				if ((!$i)&&(${count{$_}}/(scalar (@$array)) >= 0.050)&&($_ != 0))
					{					
						$i=1;
						print "FIRST=", $_+$start-1," "; 
					}
			}
		print "FIRST=0\t" if (!$i);		
		}
	else 
		{for (sort {$b <=> $a} keys %count)
			{
				if ((!$i)&&(${count{$_}}/(scalar (@$array)) >= 0.050)&&($_ != 0))
					{
						$i=1;
						#if ($_ != 0)
						print "LAST=", $_+$start-1, "\n";
						#else
						#{print "LAST=", $_, "\n";}
					}	
			}
		print "LAST=0\n" if (!$i);
		}
}
