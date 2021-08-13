# AtlasQuantifier
Code for quantifying projections throughout the brain against coronal Allen Brain Atlas regions. Please cite https://www.biorxiv.org/content/10.1101/2021.08.05.455317v1 or published manuscript.

This code was developed using tiffs converted from .vsi tile-scan images. These tiffs are of a single fluorescent channel containing anterograde projection signal. It is not designed to find or quantify cell bodies.

To perform whole brain mapping, perform the following steps. 
1) Obtain the P56_mouse_annotation 'annotation.raw' file encoding the Allen Brain Atlas. Place the file in the matlab folder/directory. It may be necessary to add it to the path. Unzip the Atlas files for subsequent registration into a file folder location of your choosing. This step should only need to be performed once. 
2) Manually align atlas against slices, recording parameters in the attached spreadsheet.
  a. Pick the atlas slice that looks the most like your brain section/slice. Add this value to the 7th column.
  b. Import the image of your brain section/slice using link and blocky options into Inkscape or similar. Put it in layer   1 and lock it
  c. Make a second layer, open up the related .png coronal atlas wire diagram.
  d. Alter the atlas file so the atlas is aligned to the slice, keeping track of rotation.
  e. Write down x,y,w, and h for the atlas, as well as x and y for the brain section image, and the rotation, in the       AtlasQuantifierParameters file. (See the Atlas QuantifierParameters_Example file for an example of how this can be       filled in.) Columns with titles in bold must be filled in.
3) Run 'AtlasEdgeQuantifier' to quantify from a single individual.
4) Copy the workspaces generated for each individual into a single folder. Run 'AtlasGroupCompilation', selecting that folder when prompted, to compile data from multiple individuals.
5) Add CrameriColourMaps to the path, if desired. Run 'AtlasMapColor' for visualization, changing the color map as desired.
