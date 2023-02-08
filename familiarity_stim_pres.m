%% Familiarity_task.m 
%{ 
 24 August, 2022
 Elise Kanber, elise.kanber@ucl.ac.uk
 
 Runs a voice recognition task with button presses
 Requirements: 
- PsychToolbox
- .Mat files containing a list of the stimuli 
- excel files with randomisations to be read in. 

%}

tic
%% Clear workspace
clear all 
close all 
addpath(genpath('/Users/Shared/toolbox/Psychtoolbox/'));
[id, name] = GetKeyboardIndices; % gives names and indices for all connected keyboards.
devices = PsychHID('devices');
keynames = KbName('keynames');

%% Get inputs

ppid          = input('What is the participant ID?         ', 's');
partnerid     = input('What is the partner''s ID? (DIAPIX ID)      ', 's'); 
pfname        = input('What is the name of the participant''s friend/partner?       ', 's');
pfsex         = input('What is the sex of participant''s friend/partner? (m/f)       ', 's');
ppnum         = input('What is the participant number?        '); 
run           = input('What run is this?                    ');
scanner       = input('Are you at the scanner? (1 = Y, 0 = N)      '); 

pf_text =       pfname;   
f_text = 'Alex';
uf_text = 'Charlie';


labels          = {pf_text, f_text, uf_text};
order           = randperm(3);
button_text     = labels(order);
triggercode = "t";

keylist(1:256)          = 0; % set all to 0
keylist(23)             = 1; % set 23 to 1 for scanner trigger (t)
button_list(1:256)      = 0; % set all to 0
button_list(34:38)      = 1; % RH: (35:39), LH: (30:34) - 56789 (RH), 01234(LH)
keynames                = KbName('keynames');


%% Set-up for scanner: 

if scanner == 1 % yes I am at the scanner 
    button_device = id(2); % 1 should always be mac keyboard. 2 or 3 would be the trigger and button device.
    trigger_device = id(3);  % 3
    screendim = [];
    screen = 1; % 1 for scanner projector  Might be better to mirror screens - think about this.
    info_wait = 5; % change this to 5 when actually scanning 
else 
    button_device = id(1); % id(1) for keyboard
    trigger_device = id(2); % id(2) for the Arduino (to send in the triggers).
    screendim = [100 100 1000 600]; % [0 0 640 480]; 100 100 1000 600
    screen = 0;
    info_wait = 5; 
    
end 


% Flush events when starting script again. 
KbEventFlush
KbQueueCreate
KbQueueFlush
KbQueueRelease
disp('flushed events') 

%% Set up directories: 

basedir             = '/Users/carolynmcgettigan/Documents/familiarity/';
ppdir               = [basedir ppid];
stimdir             = [basedir 'sounds/'];
logdir              = [basedir ppid '/log/'];

if ~ exist (basedir) % if the base directory or log directory don't exist, create them.
    mkdir (basedir)
end

if ~ exist (logdir)
    mkdir (logdir)
end

cd(ppdir)
% load audio files & image files: 
% load([stimdir ppid '_stims.mat']); 


xls         = readtable([basedir partnerid '_stims.csv']);
PFstims     = xls.Filename(1:8);
Fstims      = xls.Filename(9:16); 
UFstims     = xls.Filename(17:24);

% target = imread([basedir 'button.png']); 
InitializePsychSound;
commandwindow

cd(basedir) % change directory to base directory
load([stimdir 'silence.mat']);
%% Randomisations: 

disp('Reading in randomisations')

% read in condition order (ttype) and stimulus order(randvec_a):
if run == 1 % Run 1
    ttype           = xlsread('trialtype_run1.xlsx', ppnum, 'A2:FX2');
    randvec_a{1}    = xlsread('stimulus_order_run1_PF.xlsx', ppnum, 'A2:AD2');
    randvec_a{2}    = xlsread('stimulus_order_run1_F.xlsx', ppnum, 'A2:AD2');
    randvec_a{3}    = xlsread('stimulus_order_run1_UF.xlsx', ppnum, 'A2:AD2');

elseif run == 2 % Run 2 
    ttype           = xlsread('trialtype_run2.xlsx', ppnum, 'A2:FX2');
    randvec_a{1}    = xlsread('stimulus_order_run2_PF.xlsx', ppnum, 'A2:AD2');
    randvec_a{2}    = xlsread('stimulus_order_run2_F.xlsx', ppnum, 'A2:AD2');
    randvec_a{3}    = xlsread('stimulus_order_run2_UF.xlsx', ppnum, 'A2:AD2');

elseif run == 3 % Run 3 
    ttype           = xlsread('trialtype_run3.xlsx', ppnum, 'A2:FX2');
    randvec_a{1}    = xlsread('stimulus_order_run3_PF.xlsx', ppnum, 'A2:AD2');
    randvec_a{2}    = xlsread('stimulus_order_run3_F.xlsx', ppnum, 'A2:AD2');
    randvec_a{3}    = xlsread('stimulus_order_run3_UF.xlsx', ppnum, 'A2:AD2');
    
elseif run == 4 % Run 4 
    ttype           = xlsread('trialtype_run4.xlsx', ppnum, 'A2:FX2'); 
    randvec_a{1}    = xlsread('stimulus_order_run4_PF.xlsx', ppnum, 'A2:AD2'); 
    randvec_a{2}    = xlsread('stimulus_order_run4_F.xlsx', ppnum, 'A2:AD2'); 
    randvec_a{3}    = xlsread('stimulus_order_run4_UF.xlsx', ppnum, 'A2:AD2'); 
    
end 

              
disp('randomisations complete!');

%% Logging onsets: 

disp('creating logs');
lognm = [logdir '/' ppid '.log']; % log file name. Will be saved as a text file that can be opened in Excel.
logfid = fopen(lognm,'a'); % open or create file for writing; append data to end of file.
fprintf(logfid, '\n%-s\t%-s\t%-d\t%-d\n\n%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\n\n', ...    % Write formatted data to text file.
    ppid, date, ppnum, run, ...
    'Trial' , 'TrialType', 'Item', 'Jitter voice 1 start', 'jitter voice 1 end', 'jitter baseline 1 start', 'jitter baseline 1 end', 'Voiceclip Start', 'Voiceclip End', 'jitter voice 2 start', 'jitter voice 2 end', 'jitter baseline 2 start', 'jitter baseline 2 end', 'Question Start', 'Keypressed', 'Time of keypress', 'Question End', 'Answer', 'Response', 'Correct');

names = {
    'Personally familiar'
    'Lab-trained'
    'Unfamiliar' 
    'Baseline'
%     'No Keypress'
    };
    

% Logging onsets:
for x = 1:length(names)
    voiceonsets{x} = [];
    questiononsets{x} = [];
    trialonsets{x} = [];
end

% Logging durations of sound stimuli:
for x = 1:length(names)
    voicedurations{x} = [];
    questiondurations{x} = [];
    trialdurations{x} = [];
end

%% PSYCHTOOLBOX: 
%% Initialise the screen 

%initialize the screen
Screen('Preference','SyncTestSettings' , 0.01, 50, 0.1,15); 
% Screen('Preference', 'SkipSyncTests', 1); % If synchronisation error 
Screen('Preference', 'ConserveVRAM');
Screen('Preference', 'Verbosity', 1); % whether to print error messages and how extensive to be
PsychPortAudio('Verbosity',0);
[windowPtr, rect] = Screen('OpenWindow', screen, [0 0 0], screendim); %change here to something for second display, second arg = screen number. [0 0 640 480]   1 = correct screen for scanner                                                               % if   this argument is removed, should default to full screen. If not, use set resolution.                                        
% , [0 0 640 480]
% [0, 0, 2048, 1152] is full screen for my iMac. 
wdw_pointer = windowPtr;

% centre of screen
hor_cen=rect(3)/2;
ver_cen= rect(4)/2;

% centre 
[xCentre, yCentre] = RectCenter(rect); 

% define coordinates for boxes and text on screen

boxlength               = rect(3)/4;
gaplength               = (rect(3)/4)/4;
boxheight               = rect(4)/4;

% x coordinates
box1_TL                 = rect(3) - 3*boxlength - 3*gaplength; %90
box1_BR                 = rect(3) - 2*boxlength - 3*gaplength; %450
box2_TL                 = rect(3) - 2*boxlength - 2*gaplength; %540
box2_BR                 = rect(3) - boxlength - 2*gaplength; %900
box3_TL                 = rect(3) - boxlength - gaplength; %990
box3_BR                 = rect(3) - gaplength; %1350
text1_x                 = (box1_TL + box1_BR)/3;
text2_x                 = (box2_TL + box2_BR)/3;
text3_x                 = (box3_TL + box3_BR)/3;

% y coordinates
box_BR                  = rect(4) - boxheight;
box_TL                  = rect(4) - 2*boxheight;
text_y                  = ((box_BR + box_TL)/2) + 25;


% Define the coordinates for each of the three boxes
box1                    = [(box1_TL) (box_TL) (box1_BR) (box_BR)]';
box2                    = [(box2_TL) (box_TL) (box2_BR) (box_BR)]';
box3                    = [(box3_TL) (box_TL) (box3_BR) (box_BR)]';
rectangle               = [box1, box2, box3];



HideCursor;

% escKey = KbName('ESCAPE');

%% Instructions for participants: 

instructions = ['Welcome! \n\n In this task, you will hear three speakers. \n' ...
    'On each trial, you will hear one of these speakers, \n' ...
    'and it is your job to decide who is speaking. \n'];

button_instruct = ['Below is the order that the buttons will appear in  \n' ...
    'during the task. Please ensure you press the button \n' ...
    ' that corresponds with the name of the speaker you \n' ... 
    'think you hear on each trial.'];

DisableKeysForKbCheck(40);


if run == 1
Screen('FillRect', wdw_pointer, [0 0 0]);
Screen('TextSize',wdw_pointer, 35);
Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
Screen('TextStyle', wdw_pointer, 1);
DrawFormattedText(wdw_pointer, instructions, 'center', 'center', [255, 255, 255]);
Screen('Flip',wdw_pointer);
WaitSecs(info_wait)  
end 


Screen('FillRect', wdw_pointer, [0 0 0]);
Screen('FrameRect', wdw_pointer, [255 255 255], rectangle); 
Screen('TextSize', wdw_pointer, 35);
% Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
DrawFormattedText(wdw_pointer, button_instruct, 'center', yCentre-200, [255 255 255])
Screen('TextSize', wdw_pointer, 60);
Screen('TextFont', wdw_pointer, 'Arial');
DrawFormattedText(wdw_pointer, button_text{1}, box1_TL +20, text_y, [255 255 255]);
DrawFormattedText(wdw_pointer, button_text{2}, box2_TL +20, text_y, [255 255 255]);
DrawFormattedText(wdw_pointer, button_text{3}, box3_TL +20, text_y, [255 255 255]);
Screen('Flip', wdw_pointer); 
WaitSecs(info_wait)

%% Dummy scans - 5 of them

Screen('FillRect', wdw_pointer, [0 0 0]);
Screen('TextSize',wdw_pointer, 60);
Screen('TextStyle', wdw_pointer, 1);
Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
DrawFormattedText(wdw_pointer, 'Get ready!', 'center', 'center', [255, 255, 255]);
Screen('Flip',wdw_pointer);
% WaitSecs(); 
input('EXPERIMENTER: Press ''enter'' when ready to begin          ')

KbName('UnifyKeyNames');
DisableKeysForKbCheck(40); % return key is a 'stuck' key. Disable it.
trigger_count = 0;
disp('Waiting for trigger')

KbQueueCreate(trigger_device, keylist)
KbQueueStart(trigger_device)
  
   while 1
        [waitcmd, ~, ~, keypressed] = KbQueueCheck(trigger_device);
        if waitcmd
            keypressed = string(KbName(keypressed));
            
            if keypressed == triggercode
                WaitSecs(0.1);
                KbQueueFlush(trigger_device);
                trigger_count = trigger_count+1;
                disp(strcat("Dummy:",string(trigger_count)))
                
                if trigger_count == 5
                    break
                end
                
            end
        end
   end
    

    
   KbQueueStop(trigger_device)
   KbQueueFlush(trigger_device)
   KbQueueRelease(trigger_device)
   
   
   
   % Logging onsets:
for x = 1:length(names)
    voiceonsets{x} = [];
    questiononsets{x} = [];
    trialonsets{x} = [];
end

% Logging durations of sound stimuli:
for x = 1:length(names)
    voicedurations{x} = [];
    questiondurations{x} = [];
    trialdurations{x} = [];
end
         

disp('end of dummy scans')

exptime = GetSecs; % Start timings from here - discard dummy volumes 
c1 = 1; c2 = 1; c3 = 1; jitter_v1_n = 0; jitter_v2_n = 0; jitter_b1_n = 0; jitter_b2_n = 0; 
%% Main Loop 

for i = 1: length(ttype)
    
    DisableKeysForKbCheck([]); % enable all keys so that trigger can be recognised
    DisableKeysForKbCheck(40); % disable 'stuck' key
    
    KbQueueCreate(trigger_device, keylist)
    KbQueueStart(trigger_device)
    while 1
        [waitcmd, ~, ~, keypressed] = KbQueueCheck(trigger_device);
        if waitcmd
            keyname = string(KbName(keypressed));
            
            if keyname == triggercode
                
                break   % if waitcmd = 1 (i.e. a button has been pressed),
                % then it'll store the name of the key pressed as keyname.
                % If the keyname is the trigger code (i.e. 't'),
                % then it'll break out of the while loop and
                % continue on with the script. If the keyname isn't
                % trigger code or there is no keypress, it'll keep
                % looping until the break condition is met.
            end
            
        end
    end
    
    KbQueueStop(trigger_device)
    KbQueueFlush(trigger_device)
    KbQueueRelease(trigger_device)
    
    sprintf('start of trial %d',i) 
 
    
    
    if ttype(i) == 1                                % Personally familiar stimuli 
        stimName = [PFstims{randvec_a{1}(c1)}];
        c1 = c1+1;
        jitter_v1_n = jitter_v1_n +1;
        jitter_v2_n = jitter_v2_n +1; 
        answer = pf_text;
    elseif ttype(i) == 2                            % Lab-trained stimuli
        stimName = [Fstims{randvec_a{2}(c2)}];
        c2 = c2+1;
        jitter_v1_n = jitter_v1_n +1;
        jitter_v2_n = jitter_v2_n +1;
        answer = f_text;
    elseif ttype(i) == 3                            % Unfamiliar stimuli 
        stimName = [UFstims{randvec_a{3}(c3)}];
        c3 = c3+1;
        jitter_v1_n = jitter_v1_n +1;
        jitter_v2_n = jitter_v2_n +1;
        answer = uf_text;
    elseif ttype(i) == 4                            % Rest/Baseline trial
        stimName = Silence{1};
        jitter_b1_n = jitter_b1_n +1;
        jitter_b2_n = jitter_b2_n +1; 
        answer = [];
    else
        error('check ttype')
        
    end
    
cwav = [stimdir stimName];                            % The name of the wav file for the current trial 

                                                      % jittering
% jitter start - voice trials:                                                     
m = 0.375; 
std = 0.1250;
rng(6,'twister')
jitter_voice1 = std.*randn(72,1) + m;
rng('shuffle')
jitter_voice1 = jitter_voice1(randperm(length(jitter_voice1)));
 

% jitter middle - voice trials:
m = 0.5; 
std = 0.25;
rng(7,'twister')
jitter_voice2 = std.*randn(72,1) + m; 
rng('shuffle')
jitter_voice2 = jitter_voice2(randperm(length(jitter_voice2))); 
 
% jitter start - baseline:
m = 0.375;
std = 0.1250;
rng(1,'twister')
jitter_baseline1 = std.*randn(24,1) + m;
rng('shuffle')
jitter_baseline1 = jitter_baseline1(randperm(length(jitter_baseline1)));

% jitter middle - baseline: 
m = 0.5; 
std = 0.25;
rng(5,'twister')
jitter_baseline2 = std.*randn(24,1) + m; 
rng('shuffle')
jitter_baseline2 = jitter_baseline2(randperm(length(jitter_baseline2))); 
questduration = 1.5;

if ttype(i) ~= 4                                                      % Present fixation on screen

Screen('TextSize', wdw_pointer, 100); 
Screen('FillRect', wdw_pointer, [0 0 0]);
DrawFormattedText(wdw_pointer, '+', 'center', 'center', [255 255 255]); % hor_cen-40, ver_cen-80,
Screen('Flip', wdw_pointer);
trialstart = GetSecs - exptime;
jitter_v1_start = GetSecs - exptime; 
WaitSecs(jitter_voice1(jitter_v1_n)); 
jitter_v1_end = GetSecs - exptime; 
jitter_v1_dur = jitter_v1_end - jitter_v1_start; 

                                                      % play the sound
Screen('TextSize', wdw_pointer, 100);
DrawFormattedText(wdw_pointer, '+', 'center', 'center', [0,128,0]); % , hor_cen-40, ver_cen-80
Screen('Flip', wdw_pointer);
% Wait for a random delay of between 0.05 and 0.5s.
% WaitSecs(sound_delay) % 0.5-0.05  (rand(1,1)*(0.12-0.02)+0.02)
eventstart = GetSecs-exptime;
playsound(cwav)
eventend = GetSecs-exptime;
WaitSecs(0.01)
voiceduration = eventend - eventstart;

Screen('TextSize', wdw_pointer, 100);                                       % fixation between audio and response question
Screen('FillRect', wdw_pointer, [0 0 0]);
DrawFormattedText(wdw_pointer, '+', 'center', 'center', [255 255 255]); % hor_cen-40, ver_cen-80,
Screen('Flip', wdw_pointer);
jitter_v2_start = GetSecs - exptime;
WaitSecs(jitter_voice2(jitter_v2_n))
jitter_v2_end = GetSecs - exptime; 
jitter_v2_dur = jitter_v2_end - jitter_v2_start; 


pressed = 0;
Screen('FillRect', wdw_pointer, [0 0 0]);
Screen('FrameRect', wdw_pointer, [255 255 255], rectangle);
% Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
Screen('TextSize', wdw_pointer, 50); 
DrawFormattedText(wdw_pointer, 'Whose voice did you hear?', 'center', yCentre-200, [255 255 255])
DrawFormattedText(wdw_pointer, button_text{1}, box1_TL +20, text_y, [255 255 255]);
DrawFormattedText(wdw_pointer, button_text{2}, box2_TL +20, text_y, [255 255 255]);
DrawFormattedText(wdw_pointer, button_text{3}, box3_TL +20, text_y, [255 255 255]);
KbQueueCreate(button_device, button_list)
KbQueueStart(button_device)
% WaitSecs((rand(1,1)*(0.5-0.05)+0.05));
Screen('Flip', wdw_pointer);
responseStart = GetSecs - exptime;  % onset of target starting 
% WaitSecs(target_delay);  % target_delay
time=GetSecs;


% % Screen('TextSize', wdw_pointer, 100);
% Screen('FillRect', wdw_pointer, [0 0 0]);
% % DrawFormattedText(wdw_pointer, '+', 'center', 'center', [0 0 0]); % hor_cen-40, ver_cen-80,
% Screen('Flip', wdw_pointer);

%Wait for a button press or until 1.5 seconds have passed
while time + 1.5 >= GetSecs && pressed ~=1
    [pressed, keypressed] = KbQueueCheck(button_device);% change device index for button box 
    
    if pressed == 1  %if pressed or not is 1, then get the name of the key they pressed
        proceed = 1; % proceed with playing the audio y/n 
        t_keypressed = keypressed(keypressed > 0); % keypressed is an array. this finds the point in the array where the keypressed value is larger than 0 (i.e. 1).
        t_keypressed = t_keypressed - exptime; % time of keypress - important!
        
        keypressed = KbName(keypressed); % Name of the key that was pressed
        keypressed = keypressed(end);% and then move on
        
        responseEnd = GetSecs - exptime;  % Time for end of target
        responseDuration = responseEnd - responseStart; %Duration of target
        trialduration = responseEnd - trialstart;
        break
        
    else 
        proceed = 0; % proceed to the extra time period  - I gave my participants slightly longer to make a button press, but this was not visible to them. 
        responseEnd = GetSecs - exptime;
        responseDuration = responseEnd - responseStart;
    end
end 

t_aftertarget = GetSecs;

Screen('FillRect', wdw_pointer, [0 0 0]);
Screen('Flip', wdw_pointer);


while t_aftertarget + 0.5  >= GetSecs && proceed == 0 
    [pressed, keypressed] = KbQueueCheck(button_device);
    if pressed == 1
        t_keypressed = keypressed(keypressed > 0); % keypressed is an array. this finds the point in the array where the keypressed value is larger than 0 (i.e. 1).
        t_keypressed = t_keypressed - exptime; % time of keypress - important
        
        keypressed = KbName(keypressed);
        keypressed = keypressed(end);  % the last key pressed 
        
        break
       
    else 
         pressed = '0'; % if pressed or not is 0, i.e. they don't make a button press in time
        % mark the key pressed as [] and don't play a sound
        keypressed= [];
        t_keypressed = [];
        responseEnd = GetSecs - exptime;
        responseDuration = responseEnd - responseStart;
%         ttype(i) = 5; % Mark these trials as condition 5. 
        trialduration = responseEnd - trialstart;
        
    end 
end 


% sprintf('key %s was pressed', keypressed)
if keypressed == '^'
    response = button_text{1};
elseif keypressed == '&'
    response = button_text{2};
elseif keypressed == '*'
    response = button_text{3}; 
else 
    response = [];
end 

KbQueueStop(button_device)
KbQueueFlush(button_device)
KbQueueRelease(button_device)
jitter_b1_start = [];
jitter_b1_end = [];
jitter_b2_start = [];
jitter_b2_end = [];
jitter_b1_dur = [];
jitter_b2_dur = [];

else
    
    
Screen('TextSize', wdw_pointer, 100); 
Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
Screen('FillRect', wdw_pointer, [0 0 0]);
DrawFormattedText(wdw_pointer, '+', 'center', 'center', [255 255 255]); % hor_cen-40, ver_cen-80,
Screen('Flip', wdw_pointer);
trialstart = GetSecs - exptime;
jitter_b1_start = GetSecs - exptime; 
WaitSecs(jitter_baseline1(jitter_b1_n)); 
jitter_b1_end = GetSecs - exptime; 
jitter_b1_dur = jitter_b1_start - jitter_b1_end; 

                                                      % play the sound
Screen('TextSize', wdw_pointer, 100);
Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
DrawFormattedText(wdw_pointer, '+', 'center', 'center', [0,128,0]); % , hor_cen-40, ver_cen-80
Screen('Flip', wdw_pointer);
% Wait for a random delay of between 0.05 and 0.5s.
% WaitSecs(sound_delay) % 0.5-0.05  (rand(1,1)*(0.12-0.02)+0.02)
eventstart = GetSecs-exptime;
playsound(cwav)
eventend = GetSecs-exptime;
WaitSecs(0.01)
voiceduration = eventend - eventstart;

% fixation between audio and response question
Screen('TextSize', wdw_pointer, 100);   
Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
Screen('FillRect', wdw_pointer, [0 0 0]);
DrawFormattedText(wdw_pointer, '+', 'center', 'center', [255 255 255]); % hor_cen-40, ver_cen-80,
Screen('Flip', wdw_pointer);
jitter_b2_start = GetSecs - exptime; 
WaitSecs(jitter_baseline2(jitter_b2_n))
jitter_b2_end = GetSecs - exptime; 
jitter_b2_dur = jitter_b2_end - jitter_b2_start; 
responseStart = [];
keypressed= [];
t_keypressed = [];
responseEnd = [];
responseDuration = [];
jitter_v1_start = [];
jitter_v2_start = [];
jitter_v1_end = [];
jitter_v2_end = [];
jitter_v1_dur = [];
jitter_v2_dur = [];
trialduration = jitter_b2_end - trialstart;
response = [];

end
    
if strcmp(answer, response) == 1
    correct = 1;
else 
    correct = 0; 
end 


% log
    % On every trial, a new line will be printed that includes the trial
    % number (i), the condition on that trial (ttype(i)), stimulus name
    % etc. etc. 
    
        fprintf(logfid, '%-d\t%-d\t%-s\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-s\t%-.4f\t%-.4f\t%-s\t%-s\t%-d\n', ...
            i, ttype(i), stimName, jitter_v1_start, jitter_v1_end, jitter_b1_start, jitter_b1_end, eventstart, eventend, jitter_v2_start, jitter_v2_end, jitter_b2_start, jitter_b2_end, responseStart, keypressed, t_keypressed, responseEnd, answer, response, correct);
        
        
       
       

% Create cell variables containing durations and onsets (more rows get filled in per trial): 

voicedurations{ttype(i)} = [voicedurations{ttype(i)} voiceduration];
questiondurations{ttype(i)} = [questiondurations{ttype(i)} responseDuration];
trialdurations{ttype(i)} = [trialdurations{ttype(i)} trialduration];


voiceonsets{ttype(i)} = [voiceonsets{ttype(i)} eventstart];
questiononsets{ttype(i)} = [questiononsets{ttype(i)} responseStart];
trialonsets{ttype(i)} = [trialonsets{ttype(i)} trialstart]; % onsets logged on every trial


KbQueueCreate(trigger_device, keylist)
KbQueueStart(trigger_device)


KbQueueStop(trigger_device)
KbQueueFlush(trigger_device)
KbQueueRelease(trigger_device)

end

%% onsets.mat

if run == 1
	save([logdir '/' ppid '_onsets1'],'voiceonsets', 'questiononsets', 'trialonsets','names', 'voicedurations', 'questiondurations','trialdurations', 'trialdurations'); % saves onsets as mat file
elseif run == 2
    save([logdir '/' ppid '_onsets2'], 'voiceonsets', 'questiononsets', 'trialonsets','names', 'voicedurations', 'questiondurations','trialdurations', 'trialdurations');        
elseif run == 3
    save([logdir '/' ppid '_onsets3'],'voiceonsets', 'questiononsets', 'trialonsets','names', 'voicedurations', 'questiondurations','trialdurations', 'trialdurations');
elseif run == 4
    save([logdir '/' ppid '_onsets4'], 'voiceonsets', 'questiononsets', 'trialonsets','names', 'voicedurations', 'questiondurations','trialdurations', 'trialdurations'); 
end

fclose(logfid); % close the log

%% Create a rest period at the end of the run
Screen('FillRect', wdw_pointer, [0 0 0]);
Screen('TextSize',wdw_pointer, 100);
Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
Screen('TextStyle', wdw_pointer, 1);
DrawFormattedText(wdw_pointer, '+', 'center', 'center', [255, 255, 255]);
Screen('Flip',wdw_pointer); 

KbName('UnifyKeyNames');
DisableKeysForKbCheck(40); % return key is a 'stuck' key. Disable it.
trigger_count = 0;
disp('Waiting for 10 triggers')

% keylist(1:256) = 0;
% keylist(23) = 1;
% button_list(1:256) = 0;
% button_list([39 30:33]) = 1; % for right hand: 34:38

        KbQueueCreate(trigger_device, keylist)
        KbQueueStart(trigger_device)
   rest_start = GetSecs - exptime; 
   while 1
        [waitcmd, ~, ~, keypressed] = KbQueueCheck(trigger_device);
        if waitcmd
            keypressed = string(KbName(keypressed));
            
            if keypressed == triggercode
                WaitSecs(0.1);
                KbQueueFlush(trigger_device);
                trigger_count = trigger_count+1;
                disp(strcat("Dummy:",string(trigger_count)))
                
                if trigger_count == 10
                    rest_end = GetSecs - exptime;
                    rest_duration = rest_end - rest_start;
                    break
                end
                
            end
        end
    end
    
         KbQueueStop(trigger_device)
         KbQueueFlush(trigger_device)
         KbQueueRelease(trigger_device)
  
  cd(stimdir)
  save ([ppid 'rest_trailing'], 'rest_start', 'rest_end', 'rest_duration'); 



% end screen here - for last run only
if run ~= 4
    endtext = ['That''s the end of the block!'];
    Screen('FillRect', wdw_pointer, [0 0 0]);
    Screen('TextSize',wdw_pointer, 35);
    Screen('TextStyle', wdw_pointer, 1);
    Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
    DrawFormattedText(wdw_pointer, endtext, 'center', 'center', [255, 255, 255]);
    Screen('Flip',wdw_pointer);
    WaitSecs(3)
else
    endtext = ['That''s the end of the experiment! \n\n Thank you for taking part.'];
    Screen('FillRect', wdw_pointer, [0 0 0]);
    Screen('TextSize',wdw_pointer, 35);
    Screen('TextStyle', wdw_pointer, 1);
    Screen('TextFont',wdw_pointer, 'Courier'); %Set Font Type
    DrawFormattedText(wdw_pointer, endtext, 'center', 'center', [255, 255, 255]);
    Screen('Flip',wdw_pointer);
    WaitSecs(3)
end

Screen('CloseAll')
toc

%% Audio playback subfunction: playing audio

function playsound(wavfilename)

 

[y,fs] = audioread(wavfilename);

audio_info = audioinfo(wavfilename); 

audio_duration = audio_info.Duration;
wavedata = y';
nrchannels = audio_info.NumChannels; 
freq = fs; 


pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels); 

PsychPortAudio('FillBuffer', pahandle, wavedata); 


startTime = PsychPortAudio('Start', pahandle); 



PsychPortAudio('Stop', pahandle, 1); 

PsychPortAudio('Close', pahandle); 

end

         
        


