#!/usr/bin/python
'''
Mol2 Substrucuture Builder - mol2_substruct.py
    
	Author: James Peerless
			Yingling Group
			NC State University

	Date Created:	Mar 05, 2017

	Date Modified:	Apr 10, 2017

	Purpose:	Rebuild the SUBSTRUCTURE section of a Tripos Mol2 format
				molecular structure file. Requires that residue info is still
				contained in ATOM section.
    
	Usage:		mol2_substruct.py [-h] -i input [-o output]
	
				input:	string with Mol2 filename with missing substructure
						info.
				
				output:	string for output filename. (Optional - default = 
						'substruct_out.mol2')

	Notes/Bugs: Resid's renumbered so that they are sequential (no skipping).
				This is necessary for tLeap, but will change resid's.
				
				Atom section is no longer fixed-width. (Does not affect AMBER
				or VMD, but may affect others.)
				
				NOT SPEED OPTIMIZED - iterators used a lot. Bench mark is
				1-2 seconds for 130,000 atoms.
'''
##############################################################################
#        Initialization                                                      #
##############################################################################

# Import necessary packages
import time
import argparse
import numpy as np

# Start the clock
t_start = time.time()
update = 1

# Inputs
parser = argparse.ArgumentParser(description='This script repopulates missing'\
								' SUBSTRUCTURE sections of Mol2 format '\
								' structure files. \nWritten by James Peerless')
parser.add_argument('-i','--input',help='Input Mol2 file',required=True)
parser.add_argument('-o','--output',default='substruct_out.mol2', \
					help='Output Mol2 file name (default = '\
					'substruct_out.mol2',required=False)
args = parser.parse_args()

# DEBUG ONLY
#args.input = 'HA_stripped.mol2'
#args.output = 'substruct_out.mol2'

ifname = str(args.input)
ofname = str(args.output)

##############################################################################
#        Get Mol Info                                                        #
##############################################################################
mol_hln = -9999

print('Reading', ifname, '...')

# Save all line info from original file
with open(ifname) as infile:
	lines = infile.readlines()

# Extract header positions and number of atoms
for line in lines:
	if '@<TRIPOS>MOLECULE' in line:
		mol_hln = lines.index(line)
	if lines.index(line) == (mol_hln+2):
		num_atms = int(line.split()[0])
	if '@<TRIPOS>ATOM' in line:
		atm_hln = lines.index(line)
		break

##############################################################################
#        Output data into outfile											 #
##############################################################################
# Remove last line
lines = lines[:-1]
# Correct residue numbers so that they are sequential (also split atom lines
#	to use in condtructing SUBSTRUCTURE section
old_res_num = 0
n = 0
split_atm_lines = []
for line_n in range(atm_hln+1,(atm_hln+num_atms+1)):
	atm_line = lines[line_n].split()
	res_num = int(atm_line[6])
	if res_num != old_res_num:
		n = n + 1
		old_res_num = res_num
	atm_line[6] = str(n)
	split_atm_lines.append(atm_line)
	atm_line.append('\n')
	lines[line_n] = '  '.join(atm_line)
# Set info line w/correct n_res
n_res = n
mol_info_ln = lines[mol_hln+2].split()
lines[mol_hln+2] = mol_info_ln[0]+' '+mol_info_ln[1]+' '+str(n_res)\
					+'     0     0 \n'

# Construct array from ATOM section
atoms         = np.asarray(split_atm_lines)
atoms_subinfo = atoms[:, (0,6,7)]

# Construct SUBSTRUCTURE array
nres          = np.shape(np.unique(atoms_subinfo[:,1]))[0]
subinfo_resid = []
junk_tail     = np.reshape(np.asarray(np.repeat('****               0 ****  ****', nres)), (nres,1))

for i in range(1, nres + 1):
	subinfo_resid.append(np.where(atoms_subinfo[:,1] == str(i))[0][0])

subinfo   = atoms[subinfo_resid,:]
subinfo   = subinfo[:, (6,7,0)]
subinfo   = np.hstack((subinfo, junk_tail))

# Convert to list and change resid's and atom id's to fixed-width strings
subinfo_list = subinfo.tolist()
for i in subinfo_list:
	i[0] = '{0:>7}'.format(str(i[0]))
	i[2] = '{0:>13}'.format(str(i[2]))

# Append new SUBSTRUCTURE section to "lines"
for subinfo_line in subinfo_list:
	lines.append(' '.join(subinfo_line)+'\n')

# Print out all lines from header, modified ATOM stection
print('Writing', ofname, '...')
with open(ofname, 'w') as outfile:
	outfile.write(''.join(lines))				

##############################################################################
#        Denoument                                                           #
##############################################################################
total_time = time.time() - t_start
print('Success!')
print('Excecution time: %.2f min for %i atoms' % (total_time/60, num_atms))
