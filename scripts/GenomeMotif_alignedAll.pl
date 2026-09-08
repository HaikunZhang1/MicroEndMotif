#!/usr/bin/perl
use strict;
use warnings;

# this script used to calculate the frequency of 4-mer for each genome
# until the last four bases, the number of 4-mer motifs: length(sequences)-3

open (BED,"$ARGV[0]");         # aligned genome .bed file
open (IN,"$ARGV[1]");          # genome .fna file
open (OUT,">$ARGV[4]");        # GenomeMotif_freq.txt

my ($l, @l, $line, $fragsCounts, %alignedGenome_count, %alignedGenome_freq);

sub RC {                       # reverse complement
	my ($str) = @_;
	$str = uc $str;            # lower and upper case
	$str = reverse $str;
	$str =~ tr/ACGT/TGCA/;
	return $str;
}

# get aligned reference name: for microbes, read pair may align to multiple reference (both are correct), so here only use the alignedreference of R1
while ($l = <BED>) {
	chomp($l);
	$l =~ s/\r//g;
	@l = split("\t", $l);
	next if ($l[3] =~ /\/2$/);
	$fragsCounts++;
	$alignedGenome_count{$l[0]}++;
}
# calculate the fraction of fragments aligned to each reference
foreach my $key (sort { $a cmp $b } keys %alignedGenome_count) {
	$alignedGenome_freq{$key} = $alignedGenome_count{$key}/$fragsCounts;
}

# get motif of the aligend references (watson + crick)
$/ = ">";                # setting the default record separator "\n" to ">" to get the sequence of each reference 
my ($motif, %motif, %motif_count, %motif_freq, %motif_wFreq);
my $genomeName = $ARGV[2];

while (my $line = <IN>) {
	chomp($line);
	if ($line =~ /([^\n]*$genomeName[^\n]*)\n(.*)/is){                  # matching the first "\n"; before first "\n" is the reference name; after first "\n" is the sequences 
		if (exists $alignedGenome_freq{$1}){
			my $ref_name = $1;
			my $seq = $2;
			$seq =~ s/\n//g;
			my $seq_crick = RC($seq);
			for (my $i = 0; $i < length($seq)-($ARGV[3]-1); $i++){    
				$motif = substr($seq, $i, $ARGV[3]);
				next if($motif =~ /[^ATCG]/);
				$motif{$ref_name}{$motif}++;
				$motif_count{$ref_name}++;
			}
			for (my $i = 0; $i <length($seq_crick)-($ARGV[3]-1); $i++){
				$motif = substr($seq_crick, $i, $ARGV[3]);
				next if($motif =~ /[^ATCG]/);
				$motif{$ref_name}{$motif}++;
				$motif_count{$ref_name}++;
			}
		}
	}
}

# calculate the motif frequencies of aligned references
foreach my $key1 (sort { $a cmp $b } keys %motif) {
	foreach my $key2 (sort { $a cmp $b } keys %{$motif{$key1}}) {
		$motif_freq{$key1}{$key2} = $motif{$key1}{$key2}/$motif_count{$key1};
	}
}

# weighted average
foreach my $key1 (sort { $a cmp $b } keys %motif_freq) {
	foreach my $key2 (sort { $a cmp $b } keys %{$motif_freq{$key1}}) {
		$motif_wFreq{$key2} += $alignedGenome_freq{$key1}*$motif_freq{$key1}{$key2};
	}
}

# output
print OUT "GenomeName\tMotif\tFragsCount\twFreq\n";
foreach my $key (sort { $a cmp $b } keys %motif_wFreq) {
	print OUT "$genomeName\t$key\t$fragsCounts\t$motif_wFreq{$key}\n";
}

close (BED);
close (IN);
close (OUT);
