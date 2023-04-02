#Hic-pro v3.1.0
bowtie2-build ref.fasta ref
./HiC-Pro-3.1.0/bin/utils/digest_genome.py -r ^GATC -o ref.bed ref.fasta
samtools faidx ref.fasta
awk '{print $1 "\t" $2 }' ref.fasta.fai > ref.sizes
./HiC-Pro-3.1.0/bin/HiC-Pro  -i ./HIC/ref/rawdata -o ./HIC/ref/result -c config-hicpro.txt

#Construct matrix
for i in {150000,40000,20000};
do
python sparseToDense.py -b zz_'$i'_abs.bed  zz_'$i'_iced.matrix --perchr
done

#Bins mapping according to this pipelines
https://github.com/YinYuan-001/muntjac_code/blob/main/Hi-C_analysis/01.bins_mapping/work.sh

#Identifying compartment type using cworld-dekker v1.0
python runchangematrix.insulation.py -i hjf_150000_iced_hjf_LG01_dense.matrix -g hjf -c chr1 -o hjftohjf -s 150000
perl matrix2compartment.pl -i hjf_150000_iced_hjf_LG01_dense.matrix.insulation.matrix -o 1 --et
python matrix2EigenVectors.py -i 4.zScore.matrix.gz -r EVM.out.cor.gff3.bed -v

#Identifying TAD boundary using cworld-dekker v1.0
python runchangematrix.insulation.py -i hjf_40000_iced_hjf_LG01_dense.matrix -g hjf -c LG01 -o hjftohjf -s 40000
perl -I /project/software/cworld-dekker-master/lib/ matrix2insulation.pl -i hjm_LG01_40000.insulation.matrix --is 1000000 --ids 240000

#Identifying significant interactions by fithic v1.13
python hicpro2fithic.py -i hjf_20000.matrix -b hjf_20000_abs.bed -s hjf_20000_iced.matrix.biases
fithic -f fithic.fragmentMappability.gz -i fithic.interactionCounts.gz -t fithic.biases.gz -o fithic -l hjf -v -x All -r 20000
python runfilterpvalue.qvalue.count.py hjf.spline_pass1.res20000.significances.txt.gz hjf.spline_pass1.res20000.significances.txt.bed
