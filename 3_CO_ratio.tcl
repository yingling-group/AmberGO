# ------------------------------------------------------------------------------
# Title: Graphene Oxide C:O Ratio and Oxidation Rate Calculator
# ------------------------------------------------------------------------------
# Purpose:
#   This script analyzes a graphene oxide (GO) structure in VMD to determine:
#       1) The total number of Carbon (C) and Oxygen (O/O1) atoms
#       2) The atomic C:O ratio (scaled to C:1)
#       3) The oxidation rate defined as (O/C) × 100
#
# Description:
#   This script validates the effective oxidation rate obtained from HierGO
#   functionalization by comparing the number of oxygen atoms added relative
#   to the total number of carbon atoms. It reports both the C:O ratio and
#   the percent oxygen content per carbon atom (%O/C), matching HierGO’s
#   internal convention for oxidation level.
#
# Usage:
#   1) Load your GO structure (.mol2) in VMD.
#   2) In the Tk Console, run:
#          source 3_C:O_ratio.tcl
#
# Notes:
#   - Oxidation rate = (N_O / N_C) × 100
#   - The result directly corresponds to HierGO’s “--percento” target.
#   - Provides optional oxygen breakdown by residue (GRA, OH, EPX) to verify
#     that functionalization is spatially consistent.
#
# Author: Merve Fedai
# Date: 12/24/2024
# Last Update Date: 10/28/2025
# ------------------------------------------------------------------------------

# ----------------------------------------------------------------
# STEP 0: Pick the Current Molecule
# ----------------------------------------------------------------
if {[molinfo num] == 0} {
    puts "No molecules loaded."
    return
}
set mol [molinfo top]

# ----------------------------------------------------------------
# STEP 1: Select Total Carbon Atoms
# ----------------------------------------------------------------
# Select all carbon atoms named "C"
set selC  [atomselect $mol "name C"]
set nC [$selC num]

# ----------------------------------------------------------------
# STEP 2: Select Total Oxygen Atoms (robust to naming)
# ----------------------------------------------------------------
# Prefer O1 (pipeline convention); fallback to element O
set selO1 [atomselect $mol "name O1"]
if {[$selO1 num] > 0} {
    set selO $selO1
} else {
    set selO [atomselect $mol "element O"]
}
set nO [$selO num]

# ----------------------------------------------------------------
# STEP 3: Calculate C:O Ratio and Oxidation Percentage (O/C)
# ----------------------------------------------------------------
if {$nC == 0} {
    puts "No carbon atoms found — cannot compute oxidation ratio."
    $selC delete
    $selO delete
    return
}

# C:O ratio scaled to 'C:1' (prints as C:O = X:1)
set ratioCO [expr {($nO > 0) ? double($nC)/double($nO) : "Inf"}]

# Oxidation rate defined as atomic ratio of O/C × 100
set percO   [expr {100.0 * double($nO) / double($nC)}]

# ----------------------------------------------------------------
# STEP 4: Print Summary
# ----------------------------------------------------------------
puts "Total Carbon atoms (C): $nC"
puts "Total Oxygen atoms (O): $nO"
if {$nO > 0} {
    puts [format "C:O Ratio (scaled): %.4g:1" $ratioCO]
} else {
    puts "C:O Ratio (scaled): ∞:1 (no oxygens found)"
}
puts [format "Oxidation Rate (O/C × 100): %.3f%%" $percO]

# ----------------------------------------------------------------
# STEP 5: Optional Oxygen Breakdown by Residue (GRA/OH/EPX)
# ----------------------------------------------------------------
# These only print if at least one atom matches; harmless otherwise.
set selO_OH  [atomselect $mol "resname OH and (name O1 or element O)"]
set selO_EPX [atomselect $mol "resname EPX and (name O1 or element O)"]
set nO_OH  [$selO_OH num]
set nO_EPX [$selO_EPX num]
if {$nO_OH > 0 || $nO_EPX > 0} {
    puts "Oxygens by residue: OH=$nO_OH, EPX=$nO_EPX, Other=[expr {$nO - $nO_OH - $nO_EPX}]"
}

# ----------------------------------------------------------------
# STEP 6: Cleanup
# ----------------------------------------------------------------
$selC delete
$selO delete
$selO_OH delete
$selO_EPX delete

# ----------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------
