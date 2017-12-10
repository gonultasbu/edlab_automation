clear
clc
%INITIAL CONDITIONS+START
prompt = 'INITIAL ESTIMATED FREQUENCY?';
maks=input(prompt);            %HARD THRESHOLD INPUT
ForLoop                        %TRIGGER THE FREQUENCY SWEEP

%FREQUENCY SWEEP IS OVER, SLEEP UNTIL HH:04
while(1==1)
    c=clock;
    if(c(5)==4)
        ForLoop
        pause(55)
        %FREQUENCY SWEEP SHOULDN'T END WITHIN 5 SECONDS, IT WILL MESS THINGS UP
    end
end
