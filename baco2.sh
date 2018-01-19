#prepare id2tax
cut -f 2 nucl_gb.accession2taxid > accessionList
./entrez_qiime.py -L accessionList
wget -r -np -e robots=off ftp://ftp.ncbi.nlm.nih.gov/blast/matrices/

library(dada2)
library(phyloseq)
library(travis)
library(ggplot2)

suffix="D3"
fnFs <- files(paste0("*",suffix,"_R1.fastq"), full.names = TRUE)
fnRs <- files(paste0("*",suffix,"_R2.fastq"), full.names = TRUE)
sample.names <- sapply(strsplit(basename(fnFs), "_R"), `[`, 1)
outname <- paste0(suffix,"_otuCounts.tsv")

# filter and trim
filtFs <- paste0(basename(removeext(fnFs)),"_filtered.fastq.gz")
filtRs <- paste0(basename(removeext(fnRs)),"_filtered.fastq.gz")
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, maxN=0, minLen=200, maxEE=c(2,2), truncQ=2, rm.phix=TRUE, compress=TRUE, multithread=TRUE)
o=order(out[,2]/out[,1]);cbind(out,out[,2]/out[,1])[o,]

errF <- learnErrors(filtFs, multithread=TRUE)
errR <- learnErrors(filtRs, multithread=TRUE)

derepFs <- derepFastq(filtFs, verbose=TRUE)
derepRs <- derepFastq(filtRs, verbose=TRUE)

names(derepFs) <- sample.names
names(derepRs) <- sample.names

dadaFs <- dada(derepFs, err=errF, multithread=TRUE)
dadaRs <- dada(derepRs, err=errR, multithread=TRUE)

mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE)
seqtab <- makeSequenceTable(mergers)
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)

outtable <- t(seqtab.nochim)
nseqs=nrow(outtable)
newt=as.data.frame(cbind(1:nseqs,rownames(outtable),outtable))
colnames(newt)[1:2]=c("id","sequence")
write.table(newt,outname,row.names=F,col.names=T,sep="\t",quote=F)
