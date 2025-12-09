# ------------------------------------------------------------------------------
# Title: Atom Type Counter Script for VMD
# ------------------------------------------------------------------------------
# Purpose:
# This script determines the number of atoms corresponding to specific atom types
# in a molecular structure loaded in VMD. The script uses atom selection 
# commands to filter atoms by their type and outputs the count for each 
# specified atom type.
#
# Usage:
# - Load this script in VMD after loading a molecular file (e.g., PDB or PSF).
# - Modify the list of atom types (`atom_types`) as per your requirements.
# - Run the script in the VMD Tcl console.
#
# Requirements:
# - VMD (Visual Molecular Dynamics) must be installed and the molecular file
#   should be loaded prior to running this script.
# - Atom types should be defined in the molecular file (e.g., via topology or
#   parameter files).
#
# Output:
# The script prints the count of atoms for each specified atom type to the 
# console.
#
# Author: Merve Fedai
# Date: 12/24/2024
# ------------------------------------------------------------------------------
# Define the atom types to count
# Modify this list to include the atom types relevant to your system
set atom_types [list "ca" "c3" "oh" "os" "ho"]

# Initialize a dictionary to store counts for each atom type
array set atom_counts {}

# Iterate over each atom type to count matching atoms
foreach atom_type $atom_types {
    # Select atoms matching the current atom type
    set sel [atomselect top "type $atom_type"]
    
    # Get the number of atoms in the selection
    set count [$sel num]
    
    # Store the count in the dictionary
    set atom_counts($atom_type) $count
    
    # Free the selection to release memory
    $sel delete
}

# Output the results
puts "Atom Type Counts:"
foreach atom_type $atom_types {
    puts " - $atom_type: $atom_counts($atom_type)"
}

# End of Script
# ------------------------------------------------------------------------------

