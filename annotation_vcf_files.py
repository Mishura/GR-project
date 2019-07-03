import os
from Bio.SeqFeature import FeatureLocation
from Bio import SeqIO
import Bio.Data.CodonTable
import argparse
import sys


def effect(codon1, alt_codon):
	standard_table = Bio.Data.CodonTable.standard_dna_table
	all = standard_table.forward_table
	all['TAA']='Stop'
	all['TGA']='Stop'
	all['TAG']='Stop'
	all['ATG']='M'
	try:
		acid = all[str(codon1)]
		if all[str(codon1)]==all[str(alt_codon)]:
			effect = "Syn"
		else:
			effect = "Nonsyn"
		acid +="/"+all[str(alt_codon)]
	except:
		effect, acid = 'unk','unk'
	return effect, acid


def alt_complement(alt):
	s=""
	if alt=='C':
		s='G'
	elif alt=='G':
		s='C'
	elif alt=='T':
		s='A'
	elif alt=='A':
		s='T'
	return s

def codons_def(seq, pos, start,end, alt, strand):
	#print seq, pos, start,end, alt, strand
	standard_table = Bio.Data.CodonTable.standard_dna_table
	all = standard_table.forward_table
	all['TAA']='Stop'
	all['TGA']='Stop'
	all['TAG']='Stop'
	all['ATG']='M'

	if strand==1:
		#print (pos-start)%3
		if (pos-start)%3 == 0:
			codon1 = str(seq[pos-start:pos-start+3])
			#print codon1
			codon2 = alt+codon1[1]+codon1[2]
		elif (pos-start)%3 == 1:
			codon1 = str(seq[pos-start-1:pos-start+2])
			#print codon1, pos-start-1, pos-start+2
			try:
				codon2 = codon1[0]+alt+codon1[2]
			except:
				codon2 = codon1[0]+alt
				print (pos-start)%3,codon1,seq, pos, pos-start, start-end,'[',start,end,']',alt, strand
		elif (pos-start)%3 == 2:
			codon1 = str(seq[pos-start-2:pos-start+1])
			codon2 = codon1[0]+codon1[1]+alt
	elif strand==-1:
		var1 = alt_complement(alt)
		rev_seq = seq.reverse_complement()
		acid = rev_seq.translate(table=11, to_stop=True)
		codon_no =  int(round((end-pos-1)/3+0.5))
		if (end-pos-1)%3 == 0:
			codon1 = str(rev_seq[end-pos-1:end-pos+2])
			#print codon1,seq, pos, end-pos, start-end,'[',start,end,']', alt, strand
			try:
				codon2 = var1+str(rev_seq[end-pos])+str(rev_seq[end-pos+1])
			except:
				codon2 = var1
		elif (end-pos-1)%3 == 1:
			codon1 = str(rev_seq[end-pos-2:end-pos+1])
			#print codon1,seq, pos, end-pos, start-end,'[',start,end,']', alt, strand
			codon2 = str(rev_seq[end-pos-2])+var1+str(rev_seq[end-pos])
		elif (end-pos-1)%3 == 2:
			codon1 = str(rev_seq[end-pos-3:end-pos])
			#print codon1,seq, pos, end-pos, start-end,'[',start,end,']',alt, strand
			codon2 = str(rev_seq[end-pos-3])+str(rev_seq[end-pos-2])+var1
		#print end-pos, codon_no, rev_seq[end-pos-5:end-pos-1],rev_seq[end-pos-1],rev_seq[end-pos:end-pos+5], codon_no,codon1, all[codon1], acid[codon_no-1], all[codon1] == acid[codon_no-1]
		#print 'NEW AMIN = ' + all[codon2], codon2
	return codon1,codon2

def annotate(line,gb):
	row = line.split('\t')
	pos,ref_raw,alt_raw = int(row[1])-1,row[3].split(','),row[4].split(',')

	for j in ref_raw:
		if j!='*':
			ref = j
	for j in alt_raw:
		if j!='*':
			alt = j

	flag = 0
	for ind, feature in enumerate(gb.features):
		start = feature.location.nofuzzy_start 
		end = feature.location.nofuzzy_end
		strand = feature.location.strand
		codon1,codon2,codon_number,eff,acid,pos_in_gene,locus_tag,gene = None,None,None,None,None,None,None,None
		if start<=pos and pos<end and feature.type!='source' and feature.type!='gene':
			flag =1
			sliced_sequense = gb.seq[start:end]
			second_check = sliced_sequense[pos-start:pos-start+len(ref)]==ref
			codon_number = int(round((pos-start)/3+0.5))
			pos_in_gene = pos-start
			for key in feature.qualifiers.keys():
				if key == 'locus_tag':
					locus_tag = feature.qualifiers[key][0]
				elif key == 'gene':
					gene = feature.qualifiers[key][0].replace("'", "")
			if len(alt) == 1 and len(ref)==1:
				codon1,codon2 = codons_def(sliced_sequense, pos, start,end, alt, strand)
				eff, acid = effect(codon1, codon2)
			else:
				codon1,codon2 = ('.','.')
				eff, acid = ('.','.')
			if strand == -1:
				codon_number = int(round((end-pos-1)/3+0.5))
				pos_in_gene = end-pos-1
			return (line, codon1+'/'+codon2,codon_number,eff,acid,pos_in_gene, strand, gene, locus_tag)
	if flag == 0:
		return (line,None,None,None,None,None,None,None,'intergenic')



if __name__ == '__main__':
	parser=argparse.ArgumentParser()
	parser.add_argument("-i", type=str, help="path to vcf files", required=True)
	parser.add_argument("-ref", type=str, help="path to reference .genbank", required=True)
	parser.add_argument("-o",type=str, help="Output folder", required=True)
	try:
		args = parser.parse_args()
	except:
		parser.print_help()
		raise SystemExit(0)

	genbank = SeqIO.parse(open(args.ref,"r"), "genbank")
	for g in genbank:
		gb = g
	files = [j for j in os.listdir(args.i) if j.endswith('.vcf')]
	if not os.path.exists(args.o): os.makedirs(args.o)
	for f_ind in files:
		print f_ind
		with open(args.i+'/'+f_ind) as f, open(args.o+'/'+f_ind, 'w+') as f2:
			c = 0
			for line in f:
				if line[0]!='#':
					if c == 0:
						f2.write('#codon_change\tcodon_number\teffect\tacid_change\tposition_in_gene\tstrand\tgene_name\tlocus_tag\n')
					c+=1
					result = annotate(line,gb)
					f2.write("\t".join(map(str,result)).replace('\n','').replace('\r','')+'\n')
				else:
					f2.write(line)
