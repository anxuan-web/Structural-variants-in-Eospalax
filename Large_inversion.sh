##Identification and verification of large SVs
#Mummer v4.0.0 was used to align genome
nucmer -t 20 --mum Efon.fa Eba.fa -p out
delta-filter -i 90 -l 30000 -q out.delta > filter.out.delta
show-coords -c -r filter.out.delta > filter.out.delta.coords
#JCVI v1.2.7 was used to visualize genome alignment
python3 -m jcvi.graphics.karyotype seqids layout
https://github.com/tanghaibao/jcvi/wiki/MCscan-(Python-version)
#SyRI v1.5.6 was used to identify large inversions
nucmer --maxmatch -c 100 -b 500 -l 50 refgenome qrygenome       
delta-filter -m -i 90 -l 100 out.delta > out.filtered.delta     
show-coords -THrd out.filtered.delta > out.filtered.coords      
python3 $PATH_TO_SYRI -c out.filtered.coords -d out.filtered.delta -r refgenome -q qrygenome
python3 $PATH_TO_PLOTSR syri.out refgenome qrygenome -H 8 -W 5
https://schneebergerlab.github.io/syri/pipeline.html
#validating the large inversions using contig-level genome of E. baileyi
nucmer ref.fa contig.fa -p out
delta-filter -i 90 -l 10000 -q out.delta > filter.out.delta
show-coords -c -r filter.out.delta > filter.out.delta.coords

##Predicting telomere locations
tidk search [OPTIONS] --string <STRING> --output <OUTPUT> --dir <DIR> <FASTA>
https://github.com/tolkit/telomeric-identifier

##Identifying SDs
./sedef.sh -o <output> -j <jobs> soft.mask.genome.fa

##Identifying inverted repeats using IRF v3.05

##Identifying LOF-SNPs using SnpEff v5.1
