clc
clearvars -except maks MI b %Since the script is iterated multiple times, some variables must be preserved

%Find the serial object on COM6 serial port, define the timestamp
obj1 = instrfind('Type', 'serial', 'Port', 'COM6', 'Tag', '');
time=datestr(now,'mm-dd-yyyy HH'); %SHOULD AVOID RUNNING IT AT HH:00
%Open the text file for storing the results
fid=fopen(time,'a');
if isempty(obj1)
    obj1 = serial('COM6')
else
    fclose(obj1);
    obj1 = obj1(1);
end
fclose(obj1);
fopen(obj1);


%Import the DLL for accessing the ThorCam software, define the camera, this part is read from the ThorCam Documentation.
NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480dotNet.dll');
cam=uc480.Camera;
cam.Init(1);
cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
cam.PixelFormat.Set(uc480.Defines.ColorMode.RGBA8Packed);
cam.Trigger.Set(uc480.Defines.TriggerMode.Software);
%Define the Exposure, this is the only modifiable parameter in this section.
cam.Timing.Exposure.Set(8)             
[~,MemId] = cam.Memory.Allocate(true);
[~,Width,Height,Bits,~]=cam.Memory.Inquire(MemId);
cam.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
[~, tmp]=cam.Memory.CopyToArray(MemId);
Data= reshape(uint8(tmp), [Bits/8, Width, Height]);
Data = Data(1:3 , 1:Width, 1:Height);
Data=permute(Data, [3,2,1]);
%Uncomment imtool if you wish to check the snapshots and debug.
%imtool(Data);
cam.Exit;

%Snapshot is taken as "Data" variable.
%Weak noise filter.
[rowtest, coltest]=find(Data>10); %Hard Thresholding
%Find the middle point of the scanline.
ROW_MIDDLE=mean(rowtest);

%Find the brightest set of points above the middle line, consider that the indices and the actual image are reversed. (y,x)
mtop=max(max(Data(1:round(ROW_MIDDLE),1:1200)));
[rowtop, coltop]=find(Data==mtop);
rowtop=rowtop(rowtop<ceil(ROW_MIDDLE)+1 & rowtop>1);
coltop=coltop(coltop<1200 & coltop>1);
coltop=coltop(1);
rowtop=rowtop(1);

%Find the brightest set of points below the middle line, consider that the indices and the actual image are reversed. (y,x)
mbot=max(max(Data(round(ROW_MIDDLE):1024,1:1200)));
[rowbot, colbot]=find(Data==mbot);
rowbot=rowbot(rowbot<1024 & rowbot>floor(ROW_MIDDLE)-1);
colbot=colbot(colbot<1200 & colbot>1);
colbot=colbot(1);
rowbot=rowbot(1);

%Standard distance calculation.
distance=sqrt((max(rowtop)-min(rowbot)).^2 + (max(coltop)-min(colbot)).^2)
fprintf(fid,num2str(distance));
fprintf(fid,'\n');
fclose(fid);
