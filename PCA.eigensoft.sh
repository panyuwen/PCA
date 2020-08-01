#!/bin/bash

## Require bplink file as the standard input
## Require sample info file sample info, format: <sample ID> <sample ID> <pop ID> in each line
## Require plink1.9 and convertf (from eigensoft)

## BY panyuwen
## Contact: panyuwen@picb.ac.cn

prefix=$1   ## prefix of bplink files
infofile=$2 ## sample information file
output=$3   ## prefix for output files

## prune
plink1.9 --bfile ${prefix} --bp-space 50000 --maf 0.00001 --make-bed --out ${output}
## For X chromosome:  plink1.9 --bfile ${prefix} --split-x b37 <--set-hh-missing> --bp-space 1000 --make-bed --out ${output}
## X chromosome is encoded as 23. Also, Y is encoded as 24, mtDNA is encoded as 90, and XY is encoded as 25.

## convert format
awk 'BEGIN{OFS="\t"}{if($1==25) $1=91; print $0}' ${output}.bim > ${output}.pedsnp
awk 'BEGIN{OFS=" "}NR==FNR{sample[$1]=$3}NR>FNR{$6=sample[$2];print $0}' ${infofile} ${output}.fam > ${output}.pedind

echo  genotypename: ${output}.bed > ${output}.par
echo snpname: ${output}.pedsnp >> ${output}.par
echo indivname: ${output}.pedind >> ${output}.par
echo outputformat: EIGENSTRAT >> ${output}.par
echo genotypeoutname: ${output}.geno >> ${output}.par
echo snpoutname: ${output}.snp >> ${output}.par
echo indivoutname: ${output}.ind >> ${output}.par
echo familynames: NO >> ${output}.par
echo noxdata: NO >> ${output}.par
echo nomalexhet: YES >> ${output}.par
convertf -p ${output}.par   ## check the website of Eigensoft for more details

## main
i=${output}
sample_number=`cat ${i}.ind | wc -l`

smartpca.perl -i ${i}.geno -a ${i}.snp -b ${i}.ind -k $sample_number -o ${i}.pca -e ${i}.eval -p ${i}.plot -l ${i}.log -m 0
## k denotes the number of eigen value and eigen vactor to be output.
## m denotes the number of outliers to be removed

## manage output
awk 'BEGIN{OFS="\t";print "ID\tPC1\tPC2\tPC3\tPC4\tgroup"}NR==FNR{sample[$1]=$3}NR>FNR && FNR>1{$6=sample[$1];print $1,$2,$3,$4,$5,$6}' ${infofile} ${output}.pca.evec > ${output}.evec

## Then plot, using ${output}.evec & ${output}.eval
echo "Done"
echo "Use ${output}.evec & ${output}.eval for plot"
echo "Have a nice day!"
