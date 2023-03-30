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
