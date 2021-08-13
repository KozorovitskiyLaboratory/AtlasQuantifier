%Close preexisting figures and variables
close all
clearvars -except ano


load('CrameriColourMaps7.0.mat')

if exist('ano','var')==0;
%Read in the 3D Atlas
atlas3Dsize=[528 320 456];
fid=fopen('P56_Mouse_annotation/annotation.raw','r','l');
ano=fread(fid,prod(atlas3Dsize),'uint32');
fclose(fid);
ano=reshape(ano,atlas3Dsize);
end

%The code below here opens a prompt asking you to choose the matlab file
%with your information... depending on how your data is outputted, you will
%need to change this
[datafilename,datafolder]=uigetfile('*.mat','Select the analyzed data for heat mapping.');
fulldataFileName=fullfile(datafolder,datafilename);
load(fulldataFileName);

%backing up the variable in case something goes wrong later
backuppercentageSignalPerRegion=percentageSignalPerRegion;

%Remove 'gray' so that you use the full dynamic range
percentageSignalPerRegion(2,1)=0;

%The code below is done ahead of the for loop so your heat map is produced
%over the entire brain, not for each slice

%Find the max and min, use to set color limits
signalMax=max(percentageSignalPerRegion);
signalMin=min(percentageSignalPerRegion);
climits=[signalMin signalMax];

%The loop below specifies the first allen brain atlas coordinate, the
%interval, and the last allen brain atlas coordinate, that you want to
%generate images of
for k=140:10:480
labelAtlas=squeeze(ano(k,:,:));

%Find every atlas ID used in the allen brain atlas
AtlasIDs=unique(labelAtlas,'sorted');
numberOfRegions=size(AtlasIDs,1);
x=size(labelAtlas,1);
y=size(labelAtlas,2);

%Initializing some variables
heatAtlas=labelAtlas;
z=size(percentageSignalPerRegion,1);
numberIDs=zeros(z,1);


%%%Use the code below to get the numeric values out of the cell
%%%array
for i=1:z
    numberIDs(i)=AtlasOntology{i,1};
end


%Use the code below to construct a heat map. Note! Currently do not know if
%starting at 2 works for all atlases
for i=2:numberOfRegions
    j=AtlasIDs(i,1);
    n=find(numberIDs==j);
    if j==8
        heatAtlas(heatAtlas==j)=-inf;
    else
    heatAtlas(heatAtlas==j)=percentageSignalPerRegion(n,1);
    end
    indgrey=find(heatAtlas==-inf);
    indout=find(labelAtlas==0);
end

newmap=colormap(bilbao(25:end,:));

figure;imagesc(heatAtlas,climits);colormap(newmap);

%To specify the color of a specific value (modified from https://www.mathworks.com/matlabcentral/answers/95848-how-do-i-set-a-specific-color-for-a-intensity-value-in-an-image-in-matlab-7-8-r2009a
%The indexes defined above are for this as well
map=colormap;close(gcf)

heatAtlas_copy=heatAtlas; 
heatAtlas=floor((heatAtlas./signalMax)*length(map));
%Note! The line of code below sets Nan to black. If you use a colormap that
%doesn't start at black, you may want to change this
heatAtlas(isnan(heatAtlas))=0;
heatAtlas_copy=ind2rgb(heatAtlas,map);
[a,b]=ind2sub(size(heatAtlas_copy),indgrey);
for inda=1:length(a)
heatAtlas_copy(a(inda),b(inda),:)=[(225/255) (236/255) (239/255)];
end

[c,d]=ind2sub(size(heatAtlas_copy),indout);
for indc=1:length(c)
    heatAtlas_copy(c(indc),d(indc),:)=[1 1 1];
end

%Plot the image and save the figure. You can remove or include the colorbar
%by commenting out the 'hold on; colorbar' portion below
figure;image(heatAtlas_copy);axis off; colormap(newmap);%hold on; colorbar
savefilename=strcat('heatAtlas',num2str(k));
fullsavefilename=fullfile(datafolder,savefilename);

saveas(gcf,fullsavefilename,'png');
end