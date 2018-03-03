% A ONE SIZE FITS ALL APPROACH FOR DATA TAKEN FROM THE SCANNER


%myFolder is the FILE DIRECTORY example myFolder = 'O:\MEMS5'; For windows
function [SCANLINES, FREQUENCIES, QFS ]= MASTERCODE(myFolder,suppress)

clearvars -except myFolder suppress
%hold on;
z=0;

% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*'); 
theFiles = dir(filePattern);
SCANLINES=zeros(length(theFiles)-2,1);
FREQUENCIES=zeros(length(theFiles)-2,1);
QFS=zeros(length(theFiles)-2,1);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  % Now do whatever you want with this file name,
  % such as reading it in as an image array with imread()
  c=fopen(fullFileName,'r')
  if c>0
     FILE_VALUES=dlmread(fullFileName);
     SCANLINES(z+1)=max(FILE_VALUES);
     PARSE_STORAGE=fullFileName(length(fullFileName)-4:length(fullFileName)-2);
     PARSE_STORAGE(strfind(PARSE_STORAGE, '-')) = [];
     PARSE_STORAGE=str2double(PARSE_STORAGE);
     FREQUENCIES(z+1)=PARSE_STORAGE;
     
     [MAX_VAL,MAX_INDEX]=max(FILE_VALUES);
     
     
     %OPTIONAL OUTLIER FILTERING
     %FILE_VALUES=FILE_VALUES-50;          %NOT USEFUL   
     %FILE_VALUES=smooth(FILE_VALUES);     %SUPRESSES THE PEAKVALS
     %FILE_VALUES=medfilt1(FILE_VALUES,3); %SUPRESSES THE PEAKVALS
     
     PLOT_INTERVAL=PARSE_STORAGE-(MAX_INDEX-1):PARSE_STORAGE-(MAX_INDEX-1)+40;
     UPSAMPLED_PLOT_INTERVAL=PARSE_STORAGE-(MAX_INDEX-1):0.00001:PARSE_STORAGE-(MAX_INDEX-1)+40;
     SPLINED_VALS=spline(PLOT_INTERVAL,FILE_VALUES...
         ,UPSAMPLED_PLOT_INTERVAL);
     
     %f = fit(PLOT_INTERVAL',FILE_VALUES,'gauss2');
     %plot(f,PLOT_INTERVAL,FILE_VALUES');
     %plot(UPSAMPLED_PLOT_INTERVAL,SPLINED_VALS);
     
     QF_LIMIT=(1/sqrt(2)) * MAX_VAL;
     [QF_CORRESPONDING_SPLINED_X_VALS]=find(SPLINED_VALS < QF_LIMIT+0.005 & SPLINED_VALS > QF_LIMIT-0.005);
     %SPLINED_VALS consists of 4e6+1 elements but +1 is ignored for 
     %simplicity
     [SPLINE_ROW,SPLINE_COL]=size(SPLINED_VALS);
     delta_f=40*((max(QF_CORRESPONDING_SPLINED_X_VALS)-min(QF_CORRESPONDING_SPLINED_X_VALS))/(SPLINE_COL));
     QF=PARSE_STORAGE/delta_f
     QFS(z+1)=QF
     z=z+1;
 end
  fclose('all');
end


%FOR MEMS 10&11 ONLY

if (strcmp(myFolder,'/Volumes/mems/MEMS11/') )
    SCANLINES=SCANLINES.*2; %HARD THRESHOLD ALERT, MEMS11 bandaid fix
end

if (strcmp(myFolder,'/Volumes/mems/MEMS10/') )
    SCANLINES=SCANLINES.*(400/242); %HARD THRESHOLD ALERT, MEMS10 bandaid fix
end

if (suppress==0)
plot(1:length(SCANLINES),SCANLINES')
xlabel('TimeinHours')
ylabel('ScanlineLengthinPixels')
figure;
plot(1:length(FREQUENCIES),FREQUENCIES')
xlabel('TimeinHours')
ylabel('ResonantFrequencyinHertz')
figure;
plot(1:length(QFS),QFS')
xlabel('TimeinHours')
ylabel('QualityFactor')
figure;
histogram(FREQUENCIES)
title('FREQUENCY DIST')
figure;
histogram(QFS)
title('Q FACTOR DIST')
figure;
histogram(SCANLINES)
title('SCANLINE DIST')
end
std_SCANLINES=std(SCANLINES)
mean_SCANLINES=mean(SCANLINES)

std_FREQUENCIES=std(FREQUENCIES)
mean_FREQUENCIES=mean(FREQUENCIES)

std_QFS=std(QFS)
mean_QFS=mean(QFS)
end
