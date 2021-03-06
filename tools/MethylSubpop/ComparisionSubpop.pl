#!/usr/bin/perl

#start with ./ComparisionSubpop.pl <directory with input files> <region of interests>
#region of interests in the format: TNR=1 CHR=chr1 START=156627319 END=156627608 FIRST=156627352	LAST=156627575

use strict;
use warnings;
use List::MoreUtils qw(uniq);
use Switch; # sudo apt-get install libswitch-perl or cpan; install Switch
use List::MoreUtils qw(uniq);
use File::Basename;

#input director -> SAM-Files
my $dir = $ARGV[0];
my @samples;
my $sample=0;
my $eachline;
my @samfields;
my @targets;
my $modified;

#read in regions of interest
open (my $regions, "<", $ARGV[1]) or die ("no such file!");
while(defined($eachline=<$regions>))
	{
		chomp $eachline;	
		push @targets, { split /[\s+=]/, $eachline } if ($eachline!~/^$/);
	}
close($regions);

my @headerarray = ();
foreach my $i ( 0 .. scalar @targets-1 ) {
	my $j = $i+1;
	push @{ $headerarray[$i] }, ("Target $j; $targets[$j-1]{CHR}; $targets[$j-1]{START}-$targets[$j-1]{END}; $targets[$j-1]{FIRST}-$targets[$j-1]{LAST}");	
}

#read in all samfiles, filter & extract matching reads
my @array2 = ();
foreach my $file (glob("$dir*.sam")) {
	push @samples, basename($file);
	#printf "%s\n", $file;
	open my $fh, "<", $file or die "can't read open '$file'";
	while (<$fh>) {
		#printf "  %s", $_;
			unless ($_=~/^@.*/) #
			{
				#$reads++;
				@samfields = split("\t", $_);
				chomp($samfields[0]);  # remove whitespaces
				next if ((length($samfields[9]) < 25) || ($samfields[1] == 16));
				my $entry = {chro => $samfields[2], start => $samfields[3], leng => length($samfields[9])};
				  foreach my $elem(@targets){
				    if(testMatch($entry, $elem)){
					$modified = cigar($samfields[5],$samfields[13]);
					my $length = ($elem->{LAST})-($elem->{FIRST})+1;
					my $start = ($elem->{FIRST} - $samfields[3]);
					next if (length($modified) <= $start );
					my $modified2 = substr $modified,$start,$length;
					my $interest = $entry->{start} . "\t" . $elem->{FIRST} . "\t" . $elem->{LAST} . "\t" . $start . "\t" . $length . "\t" . length($samfields[9]) . "\t" . $modified2;
					push @{$array2[($elem->{TNR})-1][$sample]}, $modified2 if (length($modified2) >= ($elem->{LAST}-$elem->{FIRST}+1)); #($start, $length,$modified2);#$modified;#samfields[13];
					}
  				}
			}
	
	}
	$sample++;	
	close $fh or die "can't read close '$file'";
	}

#printing output file
foreach my $i ( 0 .. scalar @targets-1 )
{
	print "@{ $headerarray[$i] } \n";
	$" = "\t";
	print "@samples\tMethylation Pattern\n";
 	my @uniq_reads;
	foreach my $j ( 0 .. scalar @samples-1 )
	{
		my @samplearray = uniq  @{ $array2[$i][$j] };
		#print "@samplearray \n";
		push @uniq_reads, uniq  @{ $array2[$i][$j] }; 
	}
	my $nr2 = scalar (uniq @uniq_reads);
	foreach my $match (uniq @uniq_reads)
	{
		foreach my $j ( 0 .. scalar @samples-1 )
		{
			my $matched = grep $_ eq $match, @{ $array2[$i][$j] }; 
			print "$matched \t";
		}
		print "$match\n";
	}
	print"\n";
}


#check whether read matches with target and cover first and last methylation pattern
sub testMatch
{
  my $elem  = shift;
  my $range = shift;
	 return    $elem->{chro}  eq $range->{CHR}
         && $elem->{start} <= $range->{FIRST} 
         && ($elem->{start} + $elem->{leng})  >= $range->{LAST} 
}

#considering indels
sub cigar
{
	my $command = shift;
	my $input   = shift;
	my $output = "";

	$input =~ s/XM:Z://;
	$input =~ s/[hHxXuU]/./g;

	while ($command =~ m/(\d+)([MID])/g) {
	    my $value = $1;
	    my $code  = $2;

	    switch($code) {
		case ('D') {
		    $output .= '.' x $value;
		}
		case ('I') {
		    $input = substr($input, $value);
		}
		case ('M') {
		    $output .= substr($input, 0, $value);
		    $input = substr($input, $value);
		}
	    }
	}
	return $output;
}


