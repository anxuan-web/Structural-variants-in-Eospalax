##Identification and verification of large SVs
#Mummer v4.0.0 was used to align genome
nucmer -t 20 --mum Efon.fa Eba.fa -p out
delta-filter -i 90 -l 30000 -q out.delta > filter.out.delta
show-coords -c -r filter.out.delta > filter.out.delta.coords
#
