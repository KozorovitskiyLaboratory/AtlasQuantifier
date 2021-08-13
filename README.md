# AtlasQuantifier
Code for quantifying projections throughout the brain against Allen Brain Atlas regions

This code was developed using tiffs converted from .vsi tile-scan images. These tiffs are of a single fluorescent channel containing anterograde projection signal.

To perform whole brain mapping, perform the following steps. 
1) Manually align atlas against slices, recording parameters in the attached spreadsheet
2) Obtain the P56_mouse_annotation 'annotation.raw' file encoding the Allen Brain Atlas (~290 MB, so it could not be uploaded). Place the file in the matlab folder/directory. It may be necessary to add it to the path.
3) Run 'AtlasEdgeQuantifier' to quantify from a single individual
4) Run 'AtlasGroupCompilation' to compile data from multiple individuals
5) Add CrameriColourMaps to the path, if desired. Run 'AtlasMapColor' for visualization, changing the color map as desired.
