##Genome assembly
nextDenovo test_data/run.cfg
https://github.com/Nextomics/NextDenovo


##Repeat sequences annotation
#Finding full-length LTR retrotranspsons in genome sequences
ltr_finder -w 2 -s tRNA_mus.fa genome.fasta 1>genome.ltr_finder
#Identifying tandem repeats sequences using TRF
trf genome.fasta 2 5 7 80 10 50 2000 -d -h
#RepeatMasker
RepeatMasker -pa 4 -species "Mus musculus" -nolow -no_is -norna -q -dir ./reptmasker genome.fasta 1>reptmasker.log.o.txt 2>reptmasker.log.e.txt
#RepeatModeler
BuildDatablase –name sample –engine ncbi genome.fasta
RepeatModeler -pa 20 -database sample > repeatmodeler.run.out
RepeatMasker -nolow -e ncbi -pa 5 -norna -dir ./repeatmasker -lib consensi.fa.classified genome.fasta
#RepeatProteinMask
RepeatProteinMask -engine ncbi -noLowSimple -pvalue 0.0001 genome.fasta

##Gene annotation
#Ab initio prediction using AUGUSTUS v3.3.1, chromosomes can be separated to improve the seed of analysis
augustus --softmasking=1 --AUGUSTUS_CONFIG_PATH=software/augustus/augustus-3.3.3/config --species=human sample.soft.Chr1.fa --UTR=off > ./out/sample.soft.Chr1.fa_out
#Ab initio prediction using genscan, the genome is divided into many 5Mb sequences
perl ConvertFormat_genescan.pl genome.soft.masked.fasta genome.soft.masked-split 5000000
genscan ./software/genscan/HumanIso.smat split.Chr1-0.fa > ./out/split.Chr1-0.fa.genscan
#The protein sequences of five species were used as templates in GeMoMa v1.6.1
java -jar -Xmx80g ./GeMoMa-1.8/GeMoMa-1.8.jar CLI GeMoMaPipeline threads=40 t=genome.fasta s=own g=ref.fasta a=ref.gff outdir=results AnnotationFinalizer.r=NO tblastn=false
Align high-quality homologous protein sequences from the UniProt database to the genome using Exonerate v2.4.0
exonerate -q fix_75.uniprot.faa -t sample.soft.Chr1.fa -Q protein -T dna --softmasktarget yes --softmaskquery no --minintron 20 --maxintron 600000 --fsmmemory 200000 --dpmemory 200000 --showvulgar no --showalignment no --showquerygff no --showtargetgff --ryo "AveragePercentIdentity: %pi\n" > ./out/sample.Chr1.fa_out
#RNA-seq data predict genes
#RNA-seq reads align
./hisat/hisat2-2.1.0/hisat2-build genome.fasta sample 1> hisat2-index.log 2>&1
./hisat/hisat2-2.1.0/hisat2 --new-summary -p2 -x sample -1 sample.1.fq -2 sample.2.fq -S sample.sam
samtools sort @ 6 -o sample.sort.bam sample.sam
#RNA-seq data assembly and merge multiple samples RNA-seq data
stringtie $bam -p 25 -o $gtf
stringtie --merge -p 15 -o merge.gtf $list
#acquire transcript
gffread -w transcript.fa -g genome.fasta merge.gtf
#Predicting coding region based on transcript sequences
./TransDecoder/TransDecoder-TransDecoder-v5.5.0/TransDecoder.LongOrfs -t transcript.fa
./TransDecoder/TransDecoder-TransDecoder-v5.5.0/TransDecoder.Predict -t sample.stri.transcript.fa
#acquire annotation file
./TransDecoder/TransDecoder-TransDecoder-v5.5.0/util/gtf_to_alignment_gff3.pl merge.gtf  >  trans.merge.gff3
./TransDecoder/bin/cdna_alignment_orf_to_genome_orf.pl transcripts.fasta.transdecoder.gff trans.merge.gff3 transcripts.fa >transcripts.fasta.transdecoder.genome.gff3
#Correcting transcriptome prediction (strigtie) results using PASApipeline
./PASApipeline/Launch_PASA_pipeline.pl  --TRANSDECODER -c align.conf -C -r -R -g sample.Chr1.fa -t sample.stri.transcript.fa --ALIGNERS blat --CPU 40 && ./PASApipeline/scripts/pasa_asmbls_to_training_set.dbi --pasa_transcripts_fasta  sample.sqlite.assemblies.fasta --pasa_transcripts_gff3 sample.sqlite.pasa_assemblies.gff3 > pasa_asmbls_to_training_set.log

##EVM v1.1.1 was used to integrate all predictions
https://github.com/EVidenceModeler/EVidenceModeler/wiki#running-evm
