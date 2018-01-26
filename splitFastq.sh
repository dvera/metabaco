#!/bin/bash

mkdir -p split

for i in $(ls *_R1.fastq); do j=$(echo $i | sed 's/_R1\.f/_R2\.f/g') ;
  while read name s1 s2; do
    echo "paste <(cat $i | paste - - - -) <(cat $j | paste - - - -)  | awk -F '\t' -v n=$name -v s1=$s1 -v s2=$s2 'BEGIN{s3=substr(s1,2,14);s4=substr(s2,2,14);}{start1=substr("'$2'",1,15);start2=substr("'$2'",2,14);if(start1==s1 || start1==s3 || start2==s2 || start2==s4){a=\$1'\n'\$2'\n'\$3'\n'\$4;b=\$5'\n'\$6'\n'\$7'\n'\$8;print a > \"split/${i%_R1.f*}_${name}_R1.fastq\";print b > \"split/${j%_R2.f*}_${name}_R2.fastq\" }}'"
   done < primers ; done  | parallel
