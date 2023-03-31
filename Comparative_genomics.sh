#Orthofinder v2.5.4 was used to identify orthogroups among nine species
orthofinder -f pep -S diamond -M msa -T fasttree -t 40
#Mcmctree was used to estimate divergence time
~/paml4.9j/src/mcmctree mcmctree.ctl
http://abacus.gene.ucl.ac.uk/software/pamlDOC.pdf
#cafe v4.2.1 was used to identify contracted and expanded gene families
mkdir -p reports
cafe cafetutorial_run1.sh
python  python_scripts/cafetutorial_report_analysis.py -i reports/report_run1.cafe -o reports/summary_run1
https://hahnlab.github.io/CAFE/
#Hyphy was used to identify positive selection genes
hyphy absrel --alignment gene.codon.fa --tree tree --output gene.out
