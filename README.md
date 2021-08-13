# AtlasQuantifier
Code for quantifying projections throughout the brain against Allen Brain Atlas regions

This code was developed using tiffs converted from .vsi tile-scan images. These tiffs are of a single fluorescent channel containing anterograde projection signal.

To perform whole brain mapping, perform the following steps. 
1) Manually align atlas against slices, recording parameters in the attached spreadsheet
2) Run 'AtlasEdgeQuantifier' to quantify from a single individual
3) Run 'AtlasGroupCompilation' to compile data from multiple individuals
4) Run 'AtlasMapColor' for visualization
