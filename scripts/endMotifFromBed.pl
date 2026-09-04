#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max min);

#####  this script used to extract the fragment end motif from .bed file (fragment genomic position output: .bed format)  #####

open (INBED,"$ARGV[0]");            # .seq.bed file with sequences
open (OUTR1,">$ARGV[3]");           # endMotifR1.txt
open (OUTR2,">$ARGV[4]");           # endMotifR2.txt
open (OUTR1R2,">$ARGV[5]");         # endMotifR1R2.txt

sub ReverseComplement {
	my ($str) = @_;
	$str = uc $str;            # lowercase converting into uppercase
	$str = reverse $str;
	$str =~ tr/ACGT/TGCA/;
	return $str;
}

my ($line, @line, $endMotif_R1, $endMotif_R2, %motif_R1, %motif_R2, %motif_R1R2); 
my $genomeName = $ARGV[1];
my $count_R1 = 0;
my $count_R2 = 0;
my $count_R1R2 = 0;

while ($line = <INBED>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t", $line);
	if ($line =~ /([^\n]*$genomeName[^\n]*)/i) {       # i: ignore case
		my $readName = $line[3];
		my $strand = $line[5];
		my $seq = $line[6];
		$seq =~ s/\n//g;
		$seq = uc $seq;                                # lowercase converting into uppercase 
		
		$endMotif_R1 = undef;
		$endMotif_R2 = undef;
		if ($readName =~ /\/1$/) {
			$endMotif_R1 = ($strand eq "+") ? substr($seq, 0, $ARGV[2]) : ReverseComplement(substr($seq, -$ARGV[2]));
			$count_R1++;
			$motif_R1{$endMotif_R1}++;
			$motif_R1R2{$endMotif_R1}++;
			# print "$count_R1\t$endMotif_R1\n";
		}
		if ($readName =~ /\/2$/) {
			$endMotif_R2 = ($strand eq "+") ? substr($seq, 0, $ARGV[2]) : ReverseComplement(substr($seq, -$ARGV[2]));
			$count_R2++;
			$motif_R2{$endMotif_R2}++;
			$motif_R1R2{$endMotif_R2}++;
			# print "$count_R2\t$endMotif_R2\n";
		}

		$count_R1R2++;
	}
}

foreach my $k (sort{ $a cmp $b } keys %motif_R1) {
	my $endMotifFreq = $motif_R1{$k}/$count_R1;
	print OUTR1 "$genomeName\t$k\t$motif_R1{$k}\t$endMotifFreq\n";
}
foreach my $k (sort{ $a cmp $b } keys %motif_R2) {
	my $endMotifFreq = $motif_R2{$k}/$count_R2;
	print OUTR2 "$genomeName\t$k\t$motif_R2{$k}\t$endMotifFreq\n";
}

foreach my $k (sort{ $a cmp $b } keys %motif_R1R2) {
	my $endMotifFreq = $motif_R1R2{$k}/$count_R1R2;
	print OUTR1R2 "$genomeName\t$k\t$motif_R1R2{$k}\t$endMotifFreq\n";
}

close (INBED);
close (OUTR1);
close (OUTR2);
close (OUTR1R2);
