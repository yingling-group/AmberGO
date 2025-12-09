# ------------------------------------------------------------------------------
# Title: VMD Display and Visualization Script for Graphene Oxide (GO)
# ------------------------------------------------------------------------------
# Purpose:
#   This script provides a standardized visual setup in VMD for graphene oxide
#   structures generated and processed through the HierGO workflow. It highlights
#   the spatial distribution of functional groups and hydrophobic regions by
#   applying distinct visual styles and colors to each residue type.
#
# Description:
#   The script configures the VMD display environment and assigns visual
#   representations for residues as follows:
#       - GRA (unmodified graphene regions): black licorice and paperchain view
#       - EPX (epoxy-modified carbons): orange
#       - OH  (hydroxyl-modified carbons): purple
#
#   In this visualization:
#       • Epoxy and hydroxyl groups are clearly distinguished by color.
#       • Unmodified carbons are shown as black frameworks.
#       • Fully unmodified rings are automatically outlined in red, visually
#         representing hydrophobic domains or pristine graphene patches.
#
# Usage:
#   1) Load your GO-modified structure in VMD.
#   2) Open the Tk Console and run:
#          source 4_snapshot.tcl
#   3) Adjust the view, zoom, or render settings as needed.
#
# Notes:
#   - This step is mainly for visualization and structural validation; it does
#     not modify coordinates.
#   - The color scheme helps confirm whether functional groups are uniformly
#     distributed or clustered.
#   - Hydrophobic patches appear as red-filled ring structures surrounded by
#     black outlines.
#
# Author: Merve Fedai
# Date: 12/24/2024
# Last Update Date: 10/28/2025
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Set Display Properties
# ------------------------------------------------------------------------------
display projection Orthographic
display rendermode GLSL
display shadows off
display ambientocclusion on
display aodirect 0.400000
color Display Background white
color Axes Labels black
axes location off
display depthcue off
scale by 1.200000

# ------------------------------------------------------------------------------
# Molecular Representation Setup
# ------------------------------------------------------------------------------

# Initial molecular representation
mol modstyle 0 0 Licorice 0.300000 82.000000 82.000000
mol modmaterial 0 0 AOChalky
mol modcolor 0 0 Chain

# Set chain color and adjust RGB for Chain X to gray
mol color Chain
color Chain X gray
color change rgb 2 gray 0.781095 0.781095 0.781095

# Update molecular representation
mol representation Licorice 0.300000 82.000000 82.000000
mol selection all
mol material AOChalky

# ------------------------------------------------------------------------------
# Add Representation for Specific Residues
# ------------------------------------------------------------------------------

# Add a new representation for selected residues
mol addrep 0
mol modselect 1 0 resname EPX OH
mol modstyle 1 0 CPK 2.000000 0.300000 82.000000 82.000000
mol modcolor 1 0 ResName
mol material AOChalky
# ------------------------------------------------------------------------------
# Representation for Residue GRA
# ------------------------------------------------------------------------------

# Licorice representation for GRA residues (overall structure)
mol addrep 0
mol modselect 2 0 resname GRA
mol modstyle 2 0 Licorice 0.500000 82.000000 82.000000
mol modcolor 2 0 ResName
mol material AOChalky
# PaperChain representation for GRA residues (highlighting specific feature)
mol representation PaperChain 1.000000 10.000000
mol selection resname GRA
mol material AOChalky
mol addrep 0
mol modstyle 3 0 PaperChain 1.000000 10.000000

# ------------------------------------------------------------------------------
# Set Colors for Specific Residues
# ------------------------------------------------------------------------------

color Resname EPX orange
color Resname OH purple
color Resname GRA black

# ------------------------------------------------------------------------------
# Render Settings and Final Output
# ------------------------------------------------------------------------------

#display rendermode Tachyon RTX RTRT
#render Tachyon /home/merve/Desktop/HierGO-master/Test/GO_all_percentages/GO5%/color_by_resname "/usr/local/lib/vmd/tachyon_LINUXAMD64" -aasamples 12 %s -format TARGA -res 3000 3000 -o %s.tga

