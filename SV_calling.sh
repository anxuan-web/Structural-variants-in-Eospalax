#Long-read sequencing data (ONT)
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


#Short-read sequencing data