close all
clearvars

%Open folder with matlab workspaces containing data for each brain
datafolder=uigetdir('C:\', 'Select the folder containing the matlab workspaces with your analyzed data');
filePattern=fullfile(datafolder,'*.mat');

%Initialize variables
theFiles=dir(filePattern);
x=length(theFiles);
AtlasOntology=AtlasOntology('AtlasOntology.csv');
y=size(AtlasOntology,1);

%Stick data from each mouse into an array
for k=1:x
    baseFileName=theFiles(k).name;
    fullFileName=fullfile(datafolder,baseFileName);
    load(fullFileName, 'percentageSignalPerRegion','signalDensityPerRegion');
    percentageSignalPerRegionFull(:,k)=percentageSignalPerRegion;
    signalDensityPerRegionFull(:,k)=signalDensityPerRegion;
end

%calculate averages and standard errors
averagePercentageSignalPerRegion(:,1)=mean(percentageSignalPerRegionFull,2);
stePercentageSignalPerRegion(:,1)=std(percentageSignalPerRegionFull,0,2)/sqrt(x);

averageSignalDensityPerRegion(:,1)=mean(signalDensityPerRegionFull,2);
steSignalDensityPerRegion(:,1)=std(signalDensityPerRegionFull,0,2)/sqrt(x);

percentageSignalPerRegion=averagePercentageSignalPerRegion;
signalDensityPerRegion=averageSignalDensityPerRegion;


%save the workspace
[savename,pathname]=uiputfile('*.mat','Save your analyzed data.');
fullsavename=fullfile(pathname,savename);
save(fullsavename,'percentageSignalPerRegionFull','signalDensityPerRegionFull','signalDensityPerRegion','percentageSignalPerRegion','stePercentageSignalPerRegion','steSignalDensityPerRegion','AtlasOntology');