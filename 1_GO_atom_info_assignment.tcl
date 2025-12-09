# ------------------------------------------------------------------------------
# Title: Graphene Oxide Atom Info Assignment Script (3 Residue Approach)
# ------------------------------------------------------------------------------
# Purpose:
#   This script processes a large graphene oxide (GO) sheet in VMD by assigning
#   atoms to three residues:
#       1) GRA - all unmodified carbons (and anything else not in OH or EPX)
#       2) OH  - all hydroxyl-modified carbons, oxygens, and hydrogens
#       3) EPX - all epoxy-modified carbons and oxygens
#
# Usage:
#   1) Load your GO structure in VMD.
#   2) Run this script in the VMD console or with: `vmd -dispdev text -e this_script.tcl`.
#
# Output:
#   "GO_modified.mol2" with three residues (GRA, OH, EPX).
#
# Author: Merve Fedai
# Date: 12/24/24
# ------------------------------------------------------------------------------
# Notes:
# - Atom types and partial charges come from gaff logic:
#     c3, ca, ho, oh, os
# - Adjust distance cutoffs/criteria if needed.
# - This script assumes:
#     - "name C" for carbons
#     - "name O" for oxygens
#     - "name H" for hydrogens
#     - "resname UNL" for the original graphene base (if any).
# ------------------------------------------------------------------------------

# ----------------------------------------------------------------
# STEP 0: RESET ALL RESIDS
# ----------------------------------------------------------------
# 1) Set all residue IDs to 0 so we start from a clean slate
set allAtoms [atomselect top "all"]
$allAtoms set resid 0
$allAtoms delete

# ----------------------------------------------------------------
# STEP 1: ASSIGN DEFAULT RESID=1, RESNAME=GRA
# ----------------------------------------------------------------
# Everything (including all carbons, oxygens, hydrogens) becomes resid=1, GRA initially.
set defaultAll [atomselect top "all"]
$defaultAll set resid 1
$defaultAll set resname GRA
$defaultAll delete

# Now set sp² carbons to 'ca' as a baseline (unmodified GO).
# (We can override them later for epoxy/hydroxyl.)
set ca_carbons [atomselect top "name C"]
$ca_carbons set type ca
$ca_carbons delete

# ----------------------------------------------------------------
# STEP 2: ASSIGN HYDROXYL (OH) GROUPS TO RESID=2
# ----------------------------------------------------------------
# We'll identify:
#   - Hydroxyl carbons: "name C and within 2.0 of name O"
#   - Hydroxyl oxygens: "name O" (but you might refine to "within 2.0 of name C" or similar)
#   - Hydroxyl hydrogens: "name H" (optionally within 2.0 or 1.5 of those oxygens)
#
# Then we override (resid=2, resname=OH) and set partial charges / types.

# 2A. Hydroxyl carbons
set hydroxyl_carbons [atomselect top "name C and within 2.0 of name O"]
$hydroxyl_carbons set resid 2
$hydroxyl_carbons set resname OH
$hydroxyl_carbons set type c3
$hydroxyl_carbons set charge 0.16
$hydroxyl_carbons delete

# 2B. Hydroxyl oxygens
set hydroxyl_oxygens [atomselect top "name O"]
$hydroxyl_oxygens set resid 2
$hydroxyl_oxygens set resname OH
$hydroxyl_oxygens set type oh
$hydroxyl_oxygens set charge -0.57
$hydroxyl_oxygens delete

# 2C. Hydroxyl hydrogens
set hydroxyl_hydrogens [atomselect top "name H"]
$hydroxyl_hydrogens set resid 2
$hydroxyl_hydrogens set resname OH
$hydroxyl_hydrogens set type ho
$hydroxyl_hydrogens set charge 0.41
$hydroxyl_hydrogens set name H1
$hydroxyl_hydrogens delete

# ----------------------------------------------------------------
# STEP 3: ASSIGN EPOXY (EPX) GROUPS TO RESID=3
# ----------------------------------------------------------------
# Identify epoxy carbons and oxygens (ringsize 3 from name C/O).
# Then override to resid=3, resname=EPX.

# 3A. Epoxy carbons
set epoxy_carbons [atomselect top "ringsize 3 from name C"]
$epoxy_carbons set resid 3
$epoxy_carbons set resname EPX
$epoxy_carbons set type c3
$epoxy_carbons set charge 0.16
$epoxy_carbons delete

# 3B. Epoxy oxygens
set epoxy_oxygens [atomselect top "ringsize 3 from name O"]
$epoxy_oxygens set resid 3
$epoxy_oxygens set resname EPX
$epoxy_oxygens set type os
$epoxy_oxygens set charge -0.32
$epoxy_oxygens delete

# ----------------------------------------------------------------
# STEP 4: RENAME OXYGENS TO O1
# ----------------------------------------------------------------
# Just for consistent naming in the output
set oxygens [atomselect top "name O"]
$oxygens set name O1
$oxygens delete

# ----------------------------------------------------------------
# STEP 5: CHECK FOR STRUCTURAL ARTIFACTS
# ----------------------------------------------------------------

# Note: Make further improvement to the script including;
# 1- Determine the resname of the defected carbon
# 2- Based on the resname determine which atoms to remove. For example, if the atom is EPX remove the hydroxyl based attached atoms.
# 3- Determine atoms' indeces that are causing the defect. And save the structure exluding these indeces.

# Check for c3 atoms meeting specific criteria and warn users if any are found
set epoxy_hydroxy [atomselect top "type c3 and (within 2 of type os) and (within 2 of type oh)"]
set double_hydroxy [atomselect top "type c3 and (within 2 of type oh) and (within 2 of z \"-1.700000.*\") and (within 2 of z 1.700000)"]
set double_epoxy [atomselect top "type c3 and (within 2 of type oh) and (within 2 of z 1.283000) and (within 2 of z \"-1.283000.*\")"]

if {[$epoxy_hydroxy num] > 0} {
    set epoxy_hydroxy_ids [$epoxy_hydroxy list]
    puts "WARNING: Structural artifact detected! C3 atom with epoxy and hydroxyl groups on the same carbon. Atom IDs: $epoxy_hydroxy_ids"
}
if {[$double_hydroxy num] > 0} {
    set double_hydroxy_ids [$double_hydroxy list]
    puts "WARNING: Structural artifact detected! C3 atom with double hydroxyl addition on opposite sides of same carbon. Atom IDs: $double_hydroxy_ids"
}
if {[$double_epoxy num] > 0} {
    set double_epoxy_ids [$double_epoxy list]
    puts "WARNING: Structural artifact detected! C3 atom with double epoxy addition on opposite sides of same carbon. Atom IDs: $double_epoxy_ids"
}

if {([$epoxy_hydroxy num] == 0) && ([$double_hydroxy num] == 0) && ([$double_epoxy num] == 0)} {
    puts "No structural artifacts detected. Your structure is clean."
}

$epoxy_hydroxy delete
$double_hydroxy delete
$double_epoxy delete

#~ # Specify the molecule ID (usually 0 if only one molecule is loaded)
#~ set mol 0

#~ # Specify the indices of atoms to exclude
#~ set excluded_indices {21393 25977}

#~ # Select all atoms except those in the excluded_indices
#~ set selection [atomselect $mol "all not index [join $excluded_indices " "]"]

#~ # Save the selected atoms to a new MOL2 file
#~ set outfile "modified_structure.mol2"
#~ $selection writemol2 $outfile

# ----------------------------------------------------------------
# STEP 6: SAVE THE FINAL MOL2 FILE
# ----------------------------------------------------------------
set all_final [atomselect top "all"]
$all_final writemol2 "GO_modified.mol2"
$all_final delete

puts "Done! Your GO sheet now has three residues: GRA, OH, and EPX."
