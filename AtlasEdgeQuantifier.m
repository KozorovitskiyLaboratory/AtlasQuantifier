%Written by Michael F. Priest at Northwestern University ~2017

close all
clearvars -except AlignmentInputs ano totMask

if exist('ano','var')==0;
%Read in the 3D Atlas
atlas3Dsize=[528 320 456];
fid=fopen('P56_Mouse_annotation/annotation.raw','r','l');
ano=fread(fid,prod(atlas3Dsize),'uint32');
fclose(fid);
ano=reshape(ano,atlas3Dsize);
end

if exist('AlignmentInputs','var')==0;
%Read in parameter values for all files, if it doesn't already exist
[parameterfilename, parameterfolder]=uigetfile('*.xlsx','Select the parameter file for your data.');
fullparameterFileName=fullfile(parameterfolder,parameterfilename);
AlignmentInputs=xlsread(fullparameterFileName);
end



%Read in your raw data file (be sure to choose the correct channel!)
[datafilename, datafolder]=uigetfile('*.tif', 'Select the raw tiff file of your data.');
fulldataFileName=fullfile(datafolder,datafilename);
rawdataVSI=imread(fulldataFileName);
[savefilepath,savefilename,savefileext]=fileparts(fulldataFileName);
fullsavename=fullfile(savefilepath,strcat(savefilename,'.mat'));


%Read in your parameter values
rawdatavalueprompt={'Enter excel row from parameter file, minus one:'};
dlg_title='Slice to run';
num_lines=1;
ParameterRow=inputdlg(rawdatavalueprompt,dlg_title,num_lines);
ParameterRow=str2double(ParameterRow{1,1});

%Edge find using canny to get your signal out
thresholdedVSI=edge(rawdataVSI,'Canny');

%Get that labelatlas!
k=AlignmentInputs(ParameterRow,7);
labelAtlas=squeeze(ano(k,:,:));
%Change the labelatlas so it matches up!
rotateAtlas=imrotate(labelAtlas,AlignmentInputs(ParameterRow,11));
resizeAtlas=imresize(rotateAtlas,[round(AlignmentInputs(ParameterRow,10)) round(AlignmentInputs(ParameterRow,9))],'nearest');
%pad it so that it lines up in x y dimension properly, and so the arrays
%are the same size. Will add some code (if then statements on whether the
%things are negative positive (atlas versus raw smaller))
pre_horz_padding=round(AlignmentInputs(ParameterRow,14)-AlignmentInputs(ParameterRow,12));
post_vert_padding=round(AlignmentInputs(ParameterRow,15)-AlignmentInputs(ParameterRow,13));
horizontal_padding=size(rawdataVSI,2)-size(resizeAtlas,2);
vertical_padding=size(rawdataVSI,1)-size(resizeAtlas,1);
post_horz_padding=horizontal_padding-pre_horz_padding;
pre_vert_padding=vertical_padding-post_vert_padding;

%This code is to initialize variables so the if/then statements below work
%properly regardless of which is chosen
padded_resizeAtlas=resizeAtlas;
padded_thresholdedVSI=thresholdedVSI;

%This code is to make sure the arrays become translated to each other
%appopriately regardless of which is larger or smaller in which dimension.
%Note that this is based on Inkscape coordinates, which work with the lower
%left as (0,0)
if pre_horz_padding>0
    padded_resizeAtlas=padarray(padded_resizeAtlas, [0 pre_horz_padding],'pre');
else
    padded_thresholdedVSI=padarray(padded_thresholdedVSI,[0 abs(pre_horz_padding)],'pre');
end

if post_horz_padding>0
    padded_resizeAtlas=padarray(padded_resizeAtlas, [0 post_horz_padding],'post');
else
    padded_thresholdedVSI=padarray(padded_thresholdedVSI, [0 abs(post_horz_padding)],'post');
end

if post_vert_padding>0
    padded_resizeAtlas=padarray(padded_resizeAtlas, [post_vert_padding 0],'post');
else
    padded_thresholdedVSI=padarray(padded_thresholdedVSI, [abs(post_vert_padding) 0], 'post');
end

if pre_vert_padding>0
    padded_resizeAtlas=padarray(padded_resizeAtlas, [pre_vert_padding 0],'pre');
else
    padded_thresholdedVSI=padarray(padded_thresholdedVSI,[abs(pre_vert_padding) 0],'pre');
end

%The code below isn't necessary, but can be run to confirm that your
%alignment works, you have to make it tiny or it will crash your computer
%because the arrays are too large
tinyAtlas=imresize(padded_resizeAtlas,.05,'nearest');
tinyVSI=imresize(padded_thresholdedVSI,.05,'nearest');
figure;imshowpair(tinyVSI,tinyAtlas);
disp('Click mouse to accept alignment. End the script to try again.')
%msgbox('Click mouse to accept alignment. End the script to try again.', 'Alignment Verification')
w=waitforbuttonpress;
if w==0
    close all
end

%From https://stackoverflow.com/questions/23463516/draw-multiple-regions-on-an-image-imfreehand
%Select areas to remove from analysis (remove noise), when done click on
%screen to complete
x=size(padded_thresholdedVSI,1);
y=size(padded_thresholdedVSI,2);
totMask=false(x,y);

figure;imshow(padded_thresholdedVSI);
h=imfreehand;
BW=createMask(h);
while sum(BW(:))>10
    totMask=totMask | BW;
    h=imfreehand;
    BW=createMask(h);
end
totMask=~totMask;
save(fullsavename, 'totMask','padded_thresholdedVSI','resizeAtlas','labelAtlas','fullsavename','-v7.3');
close;
backuppadded_thresholdedVSI=padded_thresholdedVSI;
padded_thresholdedVSI=padded_thresholdedVSI&totMask;

%It seems like sorted is somehow faster than stable, which is surprising to
%me... below works very quickly (although will require slower consolidation
%on the far side)

AtlasIDs=unique(labelAtlas,'sorted');
numberOfRegions=size(AtlasIDs,1);
regionData=zeros(numberOfRegions,3);
for i=1:numberOfRegions
    j=AtlasIDs(i,1);
    regionData(i,1)=j;
    region_resizeAtlas=(padded_resizeAtlas==j);
    regionData(i,2)=sum(sum(region_resizeAtlas));
    regionData(i,3)=sum(sum(padded_thresholdedVSI&(region_resizeAtlas)));
end

save(fullsavename, 'regionData','-append');
