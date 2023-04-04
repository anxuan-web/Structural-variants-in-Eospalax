#Raw data quality control
trim_galore -q 25 --phred33 --stringency 3 --length 36  --paired sample_R1.fastq.gz sample_R2.fastq.gz --gzip -o 01.trim
fastqc 01.trim/sample_R1_val_1.fq.gz 01.trim/sample_R2_val_2.fq.gz -o 02.fastqc -t 4
#Reads align using hista2
hisat2-build -p 8 ref.fasta ref
hisat2 -x 03.hista/ref -p 8 -1 01.trim/sample_R1_val_1.fq.gz -2 01.trim/sample_R2_val_2.fq.gz -S sam/sample.sam
samtools view -@ 16 -b -S sample.sam -o sample.bam
samtools sort sample.bam > sample.sort.bam
samtools index sample.sort.bam
#RNA-seq data assembly
./stringtie/stringtie-1.3.3b.Linux_x86_64/stringtie -G ./ref.gtf -o sample.gtf -e -B  -A sample.gene.tab sample.sort.bam
python prepDE.py -i . -l 150
#Identifying DEGs using DESeq2
https://bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html#differential-expression-analysis
