#!/usr/bin/env bash

sort -k1,1  $id2tax > $id2taxs
source activate qiime2-2017.11

suffix="NF"
otuCounts=${suffix}_otuCounts.tsv
id2tax=~/software/entrez_qiime/accessionList_accession_taxonomy_20171223115349.txt
blastdb=$HOME/ncbi_nt_database/nt
blastmat=$HOME/ncbi_blast_matrix
assignin=${suffix}_otuCounts.tsv
prefix=${otuCounts%.*}
fasta=${prefix}.fa

samples=$(head -n1 $otuCounts | cut -f3-)

id2taxs=${id2tax}.sorted

tail -n+2 $otuCounts | cut -f 1,2 | awk '{print ">"$1;print $2}'  > $fasta

BLASTMAT=$blastmat assign_taxonomy.py -m blast -b $blastdb -t  $id2tax -i $fasta -o $prefix

cat <(echo -e "accession\ttaxonomy\totu\tevalue\tsequence\t$samples") <(join -t $'\t' -1 1 -2 3 $id2taxs <(join -t $'\t' -1 1 -2 1 <(cat ${prefix}/${prefix}_tax_assignments.txt | tr '|' '\t' | cut -f 1,3,7 | sort -k1,1) <(sort -k1,1 $otuCounts) | sort -k3,3)) > ${prefix}_assigned.tsv
