a=200; %Frequency value in Hz 

    obj1 = instrfind('Type', 'serial', 'Port', 'COM6', 'Tag', '');
    if isempty(obj1)
      obj1 = serial('COM6');
    else
      fclose(obj1);
      obj1 = obj1(1);


h=strcat('WMF0000',num2str(a),'00+0x0a');

fclose(obj1);
fopen(obj1);
fprintf(obj1, 'WMW00+ 0x0a'); %Waveform sine
fprintf(obj1, 'WMA17.0+ 0x0a'); %Amplitude value in V
fprintf(obj1, h);
FullOtomasyon
fclose(obj1);
delete(obj1);
