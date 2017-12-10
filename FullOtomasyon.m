clc
clearvars -except maks MI b

obj1 = instrfind('Type', 'serial', 'Port', 'COM6', 'Tag', '');
time=datestr(now,'mm-dd-yyyy HH'); %SHOULD AVOID RUNNING IT AT HH:00
fid=fopen(time,'a');
if isempty(obj1)
    obj1 = serial('COM6')
else
    fclose(obj1);
    obj1 = obj1(1);
end
fclose(obj1);
fopen(obj1);

% READ THE CODE BELOW FROM THE DOCUMENTATION, DO NOT MESS WITH IT EXCEPT FOR cam.Timing.Exposure.Set()

NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480dotNet.dll');
cam=uc480.Camera;
cam.Init(1);
cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);
cam.PixelFormat.Set(uc480.Defines.ColorMode.RGBA8Packed);
cam.Trigger.Set(uc480.Defines.TriggerMode.Software);
cam.Timing.Exposure.Set(8)             %HARD THRESHOLD ALERT
[~,MemId] = cam.Memory.Allocate(true);
[~,Width,Height,Bits,~]=cam.Memory.Inquire(MemId);
cam.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
[~, tmp]=cam.Memory.CopyToArray(MemId);
Data= reshape(uint8(tmp), [Bits/8, Width, Height]);
Data = Data(1:3 , 1:Width, 1:Height);
Data=permute(Data, [3,2,1]);
%imtool(Data);
cam.Exit;

%THE IMAGE IS TAKEN AS A MATRIX IN Data

%TO FIND THE MIDDLE POINT OF THE SCANLINE, PIXEL LOCATIONS WITH VALUES ABOVE 10 ARE FOUND
[rowtest, coltest]=find(Data>10);
%THE LINE CUTTING THROUGH THE SCANLINE HORIZONTALLY IS ENOUGH, THE LINE IS VERTICAL ANYWAY
ROW_MIDDLE=mean(rowtest);

%FIND THE BRIGHTEST SET OF POINTS ABOVE THE MIDDLE LINE, CONSIDER THAT THE INDICES AND THE ACTUAL IMAGE IS REVERSED
mtop=max(max(Data(1:round(ROW_MIDDLE),1:1200)));
[rowtop, coltop]=find(Data==mtop);
rowtop=rowtop(rowtop<ceil(ROW_MIDDLE)+1 & rowtop>1);
coltop=coltop(coltop<1200 & coltop>1);
coltop=coltop(1);
rowtop=rowtop(1);

%FIND THE BRIGHTEST SET OF POINTS BELOW THE MIDDLE LINE, CONSIDER THAT THE INDICES AND THE ACTUAL IMAGE IS REVERSED
mbot=max(max(Data(round(ROW_MIDDLE):1024,1:1200)));
[rowbot, colbot]=find(Data==mbot);
rowbot=rowbot(rowbot<1024 & rowbot>floor(ROW_MIDDLE)-1);
colbot=colbot(colbot<1200 & colbot>1);
colbot=colbot(1);
rowbot=rowbot(1);

distance=sqrt((max(rowtop)-min(rowbot)).^2 + (max(coltop)-min(colbot)).^2)
fprintf(fid,num2str(distance));
fprintf(fid,'\n');
fclose(fid);
