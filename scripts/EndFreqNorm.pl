#!/usr/bin/perl
use strict;
use warnings;

# this script used to normalize fragment end motif frequency by background genome motif

open (ENDFREQ,"$ARGV[0]");             # fragment end motif frequency file
open (GENOMEFREQ,"$ARGV[1]");          # genome motif frequency file
open (OUT,">$ARGV[2]");                # normalization file

my ($line, @line, $endFreqNorm, %endFreq, %genomeFreq);

while ($line = <ENDFREQ>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t", $line);
	$endFreq{$line[0]}{$line[1]} = $line[3];
}

print OUT "GenomeName\tMotif\tEndFreq\tGenomeFreq\tEndFreqNorm\n";

while ($line = <GENOMEFREQ>) {
	chomp($line);
	$line =~ s/\r//;
	@line = split("\t", $line);
	next if ($line =~ /GenomeName/);
	if (exists $endFreq{$line[0]}{$line[1]}) {
		$endFreqNorm = $endFreq{$line[0]}{$line[1]}/$line[3];
		print OUT "$line[0]\t$line[1]\t$endFreq{$line[0]}{$line[1]}\t$line[3]\t$endFreqNorm\n";
	} else {
		print OUT "$line[0]\t$line[1]\tNA\t$line[3]\tNA\n"
	}
}

close (ENDFREQ);
close (GENOMEFREQ);
close (OUT);
