#!/usr/bin/env perl
use strict;
use warnings;

my $in=shift or die "perl $0 genscan_output\n";

my %exon_type = ('Sngl', 'Single Exon',
		 'Init', 'Initial Exon',
		 'Intr', 'Internal Exon',
		 'Term', 'Terminal Exon');

my %gff;
my $chr="NA";
open (IN, "$in");
while (<IN>) {
    chomp;
    s/^\s+//;
    
    $chr=$1 if (/^\s*Sequence\s+(\S+)\s*:\s*\d+\s*bp/);
	
    if ($_=~/^(\d+)\.(\d+)\s+(Intr|Term|Init|Sngl)\s+(\+|\-)\s+(\d+)\s+(\d+)\s+/){
	my ($geneid,$exonnum,$type,$strand,$start,$end)=($1,$2,$3,$4,$5,$6);
	($start,$end)=sort{$a<=>$b} ($start,$end);
	my $genestart=$start;
	my $geneend=$end;
	if (! exists $gff{$geneid}{start}){
	    $gff{$geneid}{start}=$genestart;
	    $gff{$geneid}{end}=$geneend;
	}else{
	    $gff{$geneid}{start}=$genestart if $genestart < $gff{$geneid}{start};
	    $gff{$geneid}{end}=$geneend if $geneend>$gff{$geneid}{end};
	}
	$gff{$geneid}{cds}{$start}=$end;
	$gff{$geneid}{strand}=$strand;
	$gff{$geneid}{len} += $end-$start+1;
    }
}
close IN;

die "$in\n" if $chr eq 'NA';

for my $k1 (sort{$a <=> $b} keys %gff){
    my $cdslen=$gff{$k1}{len};
    my $genes=$gff{$k1}{start};
    my $genee=$gff{$k1}{end};
    my $strand=$gff{$k1}{strand};
    next if $cdslen<150;
    next if $cdslen%3;
    print "$chr\tgenscan\tgene\t$genes\t$genee\t1\t$strand\t.\tID=genscan_g$k1\n";
    print "$chr\tgenscan\tmRNA\t$genes\t$genee\t.\t$strand\t.\tID=genscan_g$k1.t1;Parent=genscan_g$k1\n";
    my @cdss=sort{$a<=>$b} keys %{$gff{$k1}{cds}};
    @cdss=reverse @cdss if $strand eq '-';
    my $len=0;
    for (my $i=0;$i<@cdss;$i++){
	my $codon=$len%3;
	my ($cdss,$cdse)=($cdss[$i],$gff{$k1}{cds}{$cdss[$i]});
	print "$chr\tgenscan\tCDS\t$cdss\t$cdse\t.\t$strand\t$codon\tID=cds.genscan_g$k1.t1;Parent=genscan_g$k1.t1\n";
	$len += $cdse-$cdss+1;
    }
}
	
