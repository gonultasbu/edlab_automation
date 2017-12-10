%THIS FILE SWEEPS THE FREQUENCY AND CALLS THE DETECTION ALGORITHM
for b= maks-20:1:maks+20
    obj1 = instrfind('Type', 'serial', 'Port', 'COM6', 'Tag', '');
    if isempty(obj1)
      obj1 = serial('COM6');
    else
      fclose(obj1);
      obj1 = obj1(1);
end

h=strcat('WMF0000',num2str(b),'00+0x0a');

fclose(obj1);
fopen(obj1);
fprintf(obj1, 'WMW00+ 0x0a');
fprintf(obj1, 'WMA17.0+ 0x0a');
fprintf(obj1, h);
FullOtomasyon
fclose(obj1);
delete(obj1);
end;

time=datestr(now,'mm-dd-yyyy HH');
C=textread(time,'%f');
MI=find(C == max(C(:)));
maks=maks-21+MI;
k=strcat(time,'--',num2str(maks(1)),'Hz')
movefile(time, k);
z=strcat('WMF0000',num2str(maks(1)),'00+0x0a');
obj1 = instrfind('Type', 'serial', 'Port', 'COM6', 'Tag', '');

if isempty(obj1)
    obj1 = serial('COM6');  
else
    fclose(obj1);
    obj1 = obj1(1);
end

fopen(obj1);
fprintf(obj1,z);
