##Long-read sequencing data (ONT)
#Reads alignment
ngmlr -t 6 -r reference.fa -q sample.fq -o sample.sam -x ont
#Convert to BAM file
samtools view -bS sample.sam | samtools sort > sample.sort.bam
samtools index sample.sort.bam
#SV detection used Sniffles
sniffles -m sample.sort.bam -v sample.vcf -d 50 -n -1 -s 10 -t 10 -l 50
#Merge all samples SVs and genotype each sample SVs
ls *.vcf > vcf_files_raw_calls.txt
SURVIVOR merge vcf_files_raw_calls.txt 1000 1 1 -1 -1 -1 merged_SURVIVOR_1kbpdist.vcf
sniffles -m sample.sort.bam -v sample_genotype.vcf --genotype -n -1 --Ivcf merged_SURVIVOR_1kbpdist.vcf
#Correct insertions and deletions used iris v 1.0.4
iris --keep_long_variants --also_deletions threads=30 genome_in=reference.fa vcf_in=sample_genotype.vcf vcf_out=iris/sample.iris.vcf reads_in=sample.sort.bam out_dir=iris/sample
#Merge all sample SVs
ls *.iris.vcf > iris.vcf.list
SURVIVOR merge iris.vcf.list 1000 1 1 -1 -1 -1 merged.iris.vcf
#Filter out some SVs based missing rate
vcftools --vcf merged.iris.vcf --max-missing 0.9 --recode --recode-INFO-all --out vcftools-filter


##Short-read sequencing data
#Illumina reads align
bwa mem -t 4 -R "@RG\tID:sample\tPL:illuminatLB:sample\tSM:sample" reference.fa sample.1.fq.gz sample.2.fq.gz | samtools view -Sb - > sample.bam
samtools sort -m4G -@4 -o sample.sort.bam sample.bam
gatk MarkDuplicates -I sample.sort.bam  -O sample.sort.markdup.bam -M sample.sort.markdup_metrics.txt
samtools index sample.sort.markdup.bam
#Delly v0.7.6
delly call -g $reference -o $name.bcf $name.sort.markdup.bam
delly merge -o all.sites.bcf $name1.bcf $name2.bcf $name3.bcf ...
delly call -g $reference -v all.sites.bcf -o $name1.geno.bcf $name1.sort.markdup.bam
for file in *geno.bcf; do bcftools view $file -O v > $file.vcf; done
#Lumpy v0.2.13
smoove call --outdir results-smoove/ --name $sample --fasta $reference -p 1 --genotype $name1.sort.markdup.bam

