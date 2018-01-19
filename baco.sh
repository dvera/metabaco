#!/usr/bin/env bash

for i in $(ls *.fastq); do
  # count total number of reads
  l=$(cat $i | paste - - - - | wc -l)
  cat $i  | \
  paste - - - - | \
  # grab first 15 sequences of reads
  awk -F '\t'  '
    {
      a=length($2)
      print substr($2,1,15)
      print ""
    }' OFS='\t' | \
  # sort first 15 bp of reads, count unique occurrences
  sort -k1,1n | \
  uniq -c | \
  awk 'NF>1' | \
  #
  awk -v l=$l -v n="${i%.*}" '
    BEGIN{
      split(n,d,"_")
    }
    {
      $1=100*$1/l
      if($1>30){
        print d[3],$1,$2,$3
      }
    }' OFS='\t' | grep -v "^AL" | sort -k1,1 ; done | sort -k3,3 | cut -f 1,3 | awk '!seen[$2]++' | sort -k1,1 | paste - - | cut -f 1,2,4 > primers

for i in $(ls ../*.fastq); do while read name s1 s2; do echo "cat $i | paste - - - - | awk -F '\t' -v n=$name -v s1=$s1 -v s2=$s2 'BEGIN{s3=substr(s1,2,14);s4=substr(s2,2,14)} {start1=substr("'$2'",1,15);start2=substr("'$2'",2,14); if(start1==s1 || start1==s3 || start2==s2 || start2==s4){a=\$1'\n'\$2'\n'\$3'\n'\$4; print a > \"${i%.fastq}_$name.fastq\"}}'"; done < ../../primers ; done  | parallel
