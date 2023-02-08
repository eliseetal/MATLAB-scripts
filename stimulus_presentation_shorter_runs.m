%% Vocal Allometry v3.0
%{
Elise Kanber
20/07/22
Vocal Allometry  

USEFUL COMMANDS: 
CMD + 0 = navigate to command window (useful if your cursor is in the
editor window during the script running)
CTRL + C = stop the script running 
sca = screen close all (close all screens :)) 
deviceReader = audioDeviceReader; % View all audio devices
devices = getAudioDevices(deviceReader)

Requirements: 
PsychToolbox 
%}

tic

%% Define Structs: 
clear all

% Add psychtoolbox to path
addpath(genpath('/Users/Shared/toolbox/Psychtoolbox')) 

% global data 

% Defaults 
data.codeVers        = 1.0;
data.when_start      = datestr(now,0);
[v, d] = version;
data.MATLAB_Version  = v;
data.MATLAB_Date     = d;  % Gives the date of release of that version


%% Inputs
scanner = input('Are you at the scanner?    (y/n)   ', 's');
ppid = input('What is the participant id?     ', 's'); 
% miniblock = input('Which miniblock is it?        ', 's'); % Might not
% need this. 
run = input('Which run (1, 2, 3)?       ', 's'); 
machine = input('Which machine are you on? (elise/clare/imac)         ', 's'); 


% speakdur = 2; % Duration of the time window during which to wait for participant speech 
Fs= 44100;
nBit = 16;
nChannels = 2;  %2
ID =  -1; %-1

% screen settings for PsychToolbox display
    if scanner == 'y'
    screendim = [];
    screen = 1;
    recording = audiorecorder(Fs,nBit,nChannels, ID); % Change this to the right ID for the scanner microphone. 
    elseif scanner == 'n'
    screendim = [0 0 640 480]; % [0 0 640 480];
    screen = 0; % 0 for de-bugging, 1 for scanner projector
    recording = audiorecorder(Fs,nBit,nChannels, ID);
    else 
        disp('Error: please provide a valid response for "scanner" variable (y/n)')
        return
    end 

%% 

text = {
    'BEAD \n (sound small)'
    'BEAD \n (sound big)'
    'BEAD \n (speak naturally)'
    'BARD \n (sound small)'
    'BARD \n (sound big)';
    'BARD \n (speak naturally)'  % drawformattedtext(text{i})
    'BOOD \n (sound small)'
    'BOOD \n (sound big)'
    'BOOD \n (speak naturally)'
    'BAD \n (sound small)'
    'BAD \n (sound big)'
    'BAD \n (speak naturally)'
    'BIRD \n  (sound small)'
    'BIRD \n (sound big)'
    'BIRD \n (speak naturally)'
    };

names = {
'BEAD-HIGH'
'BEAD-LOW'
'BEAD-NORM'
'BARD-HIGH'
'BARD-LOW'
'BARD-NORM'
'BOOD-HIGH'
'BOOD-LOW'
'BOOD-NORM'
'BAD-HIGH'
'BAD-LOW'
'BAD-NORM'
'BIRD-HIGH'
'BIRD-LOW'
'BIRD-NORM'
    }';


rest = 'Time for a break!';  

%% Directory specification: 

if strcmp(machine, 'elise')
    slash = '/';
    basedir = '/Users/carolynmcgettigan/Documents/rtMRI';
    datadir = ['/Users/carolynmcgettigan/Documents/rtMRI/data/', ppid, slash, run, slash];
    logdir = ['/Users/carolynmcgettigan/Documents/rtMRI/log/', ppid, slash]; % , run, slash
    
%     for c = 1:length(names) 
%     condition(c) = [datadir, slash, 'Condition_', c, slash];
%     mkdir(condition(c))
%     end
    
elseif strcmp(machine, 'clare') 
    slash = '/';
    basedir = '';
    datadir = [basedir, '/data/', ppid, slash, run, slash];
    logdir = [basedir, '/log/', ppid, slash]; % , run, slash
    
    
elseif strcmp(machine, 'imac')
    slash = '/';
    basedir = '/Users/e.kanber/Documents/postdoc/rtMRI';
    datadir = [basedir,'/data/', ppid, slash, run, slash];
    logdir = [basedir,'/log/', ppid, slash]; % , run, slash
    
end 

% move into our working directory 

cd(basedir) 




%% Randomisation 
%Trial type set up and randomised here
rand('twister', sum(100*clock));
WaitSecs(0.02);
mixed1 = randperm(15)';  % Create a random permutation of the numbers 1:15 (to represent the 15 conditions  5 words x 5 repetitions)                                                  %10 conditions %mixed1 = [randperm(18) randperm(18)]';
ttype = [];
for k = 1:3  
    ttype = [ttype (mixed1)];
end
    

%Prepare the final running order turn the matrix into a single row vector
final_ttype = [];
for j = 1:15
    final_ttype = [final_ttype ttype(j,:)];
end

%% Preparing to collect results: 

%Create dir
if ~exist(datadir,'dir')
    mkdir(datadir);
end
if ~exist(logdir,'dir')
    mkdir(logdir);
end

% Creating a log 

disp('creating logs')

datafile = sprintf(['data/%s/%s_rtMRI_ExpLog_run%s.mat'],ppid,ppid,num2str(run));

lognm = [logdir '/' ppid '_run' run '.log']; % Name of log file - will be a .txt file that can be opened in Excel. 
if exist(lognm,'file')
    fprintf(['\n\nA file with this subject and session',...
        ' number already exists!\nIs this correct?   Either change the relevant variables or type dbcont & enter return to proceed.\n']);
    keyboard; % allows you to change your variables if needed 
else
end 
logfid = fopen(lognm,'a'); % open or create file for writing; append data to end of file.
fprintf(logfid, '\n%-s\t%-s\t%-s\n\n%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\t%-s\n\n', ...    % Write formatted data to text file.
    ppid, date, run, ...
    'Trial' , 'Condition', 'TrialType', 'Cue Start', 'Cue End', 'Speak Start', 'Speak End', 'End of miniblock - Start', 'End of miniblock - End');


% Logging onsets:
for x = 1:length(names)
    cueonsets{x} = [];
    speakonsets{x} = [];
    endminiblockonsets{x} = [];
    
end

% Logging durations of sound stimuli:
for x = 1:length(names)
    cuedurations{x} = [];
    speakdurations{x} = [];
    endminiblockdurations{x} = [];
end

    
%% Initiate PsychToolbox Window

instructions    = ['You''ll now see some words on screen, \n' ...
                 'with an instruction on how to produce each word \n' ...
                 'When the word turns GREEN, please try \n' ...
                 'to produce the word on screen, following the instruction']; % Edit these instructions...

StartExperiment = input('Experimenter: press ENTER' ,'s');

escKey    = KbName('ESCAPE');


AssertOpenGL % Break and send an error message if the installed PTB is not based on OpenGL or Screen() is not working properly 
Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.1, 15); 
Screen('Preference', 'SkipSyncTests', 1); % If you get a synchronisation
% error 
Screen('Preference', 'ConserveVRAM'); 
Screen('Preference', 'Verbosity', 1); % Whether to print error messages and how extensive to be 


[windowPtr, rect] = Screen('OpenWindow', screen, [0 0 0], screendim); % screen = which screen to use (0 is your personal laptop, 1 is the scanner projector). 
wdw_pointer = windowPtr; 
Screen('FillRect', windowPtr, [0,0,0]);
Screen('TextFont',windowPtr, 'Arial');
Screen('TextSize',windowPtr, 35);
Screen('TextStyle', windowPtr, 1); 
if run == '1'
DrawFormattedText(windowPtr, instructions, 'center', 'center', [255, 255, 255]); 
end
% Screen('DrawText', windowPtr, 'Press SPACE to start', 200, 700, [255, 255, 255]);
Screen('Flip',windowPtr);
WaitSecs(5)  % change this to longer. 


wdw_pointer = windowPtr; 
Screen('FillRect', windowPtr, [0,0,0]);
Screen('TextFont',windowPtr, 'Arial');
Screen('TextSize',windowPtr, 100);
Screen('TextStyle', windowPtr, 1); 
DrawFormattedText(windowPtr, 'Get Ready', 'center', 'center', [255, 255, 255]); 
Screen('Flip',windowPtr);
input('EXPERIMENTER: Press ENTER when scanner starts', 's')

exptime = GetSecs; % Start timing from here - start the TTL pulse here 

input('EXPERIMENTER: Press ENTER when you are ready to begin', 's')
Screen('FillRect', windowPtr, [0,0,0]);
Screen('TextFont',windowPtr, 'Arial');
Screen('TextSize',windowPtr, 100);
Screen('TextStyle', windowPtr, 1); 
DrawFormattedText(windowPtr, 'Ready...', 'center', 'center', [255, 255, 255]); 
Screen('Flip',windowPtr);
WaitSecs(1.5)


Screen('FillRect', windowPtr, [0,0,0]);
Screen('TextFont',windowPtr, 'Arial');
Screen('TextSize',windowPtr, 100);
Screen('TextStyle', windowPtr, 1); 
DrawFormattedText(windowPtr, 'Set...', 'center', 'center', [255, 255, 255]); 
Screen('Flip',windowPtr);
WaitSecs(1.5)

Screen('FillRect', windowPtr, [0,0,0]);
Screen('TextFont',windowPtr, 'Arial');
Screen('TextSize',windowPtr, 100);
Screen('TextStyle', windowPtr, 1); 
DrawFormattedText(windowPtr, 'Go!', 'center', 'center', [255, 255, 255]); 
Screen('Flip',windowPtr);
WaitSecs(1.5)

% HideCursor; 
%% Main loop 

for i = 1:45
    start_of_loop = GetSecs-exptime; % time
    sprintf('start of trial %d',i)
    
    if mod(i,3) == 0 
        
        % 2s pause at end of miniblock
        % cue
        Screen('TextSize', wdw_pointer, 100);
        Screen('FillRect', wdw_pointer, [0 0 0]);
        DrawFormattedText(wdw_pointer, [' \n' text{final_ttype(i)}], 'center', 'center', [255, 255, 255]);
        Screen('Flip', wdw_pointer)
        cuestart = GetSecs - exptime; 
        WaitSecs(1)
        cueend = GetSecs - exptime; 
        cueduration = cueend - cuestart; % should always be 1s, just a useful sanity check 
        
        % speak
        
        Screen('TextSize', wdw_pointer, 100);
        Screen('FillRect', wdw_pointer, [0 0 0]);
        DrawFormattedText(wdw_pointer, [' \n' text{final_ttype(i)}], 'center', 'center', [0,128,0]);
        Screen('Flip', wdw_pointer)
        speakstart = GetSecs - exptime; 
        WaitSecs(2)
        speakend = GetSecs - exptime; 
        speakduration = speakend - speakstart; 
    %Save file:
%        audiowrite([datadir,'Condition_',num2str(final_ttype(i)),'_',names{final_ttype(i)},'_rec_', num2str(i),'.wav'],y,44100);


        if i < length(final_ttype)
        % next up
        Screen('TextSize', wdw_pointer, 100);
        Screen('FillRect', wdw_pointer, [0 0 0]);
        DrawFormattedText(wdw_pointer, ['    Next up:   \n' text{final_ttype(i + 1)}], 'center', 'center', [255, 255, 255]);
        Screen('Flip', wdw_pointer)
        endminiblockSTART = GetSecs - exptime;
        WaitSecs(2)
        endminiblockEND = GetSecs - exptime; 
        endminiblockduration = endminiblockEND - endminiblockSTART; 
        
        data.miniblockend.start(i) = endminiblockSTART;
        data.miniblockend.end(i) = endminiblockEND; 
        data.miniblockend.duration(i) = endminiblockduration;
        
        else 
            
            Screen('TextSize', wdw_pointer, 100);
        Screen('FillRect', wdw_pointer, [0 0 0]);
        DrawFormattedText(wdw_pointer, 'That''s the end of the task \n Thank you!', 'center', 'center', [255, 255, 255]);
        Screen('Flip', wdw_pointer)
        endminiblockSTART = GetSecs - exptime;
        WaitSecs(10)
        endminiblockEND = GetSecs - exptime; 
        endminiblockduration = endminiblockEND - endminiblockSTART; 
        
        data.miniblockend.start(i) = endminiblockSTART;
        data.miniblockend.end(i) = endminiblockEND; 
        data.miniblockend.duration(i) = endminiblockduration; 
        
        end
    
    else
        
        Screen('TextSize', wdw_pointer, 100);
        Screen('FillRect', wdw_pointer, [0 0 0]);
        DrawFormattedText(wdw_pointer, [' \n' text{final_ttype(i)}], 'center', 'center', [255, 255, 255]);
        Screen('Flip', wdw_pointer)
        cuestart = GetSecs - exptime; 
        WaitSecs(1)
        cueend = GetSecs - exptime; 
        cueduration = cueend - cuestart; 
         
        Screen('TextSize', wdw_pointer, 100);
        Screen('FillRect', wdw_pointer, [0 0 0]);
        DrawFormattedText(wdw_pointer, [' \n' text{final_ttype(i)}], 'center', 'center', [0,128,0]);
        Screen('Flip', wdw_pointer)
        speakstart = GetSecs - exptime; 
        WaitSecs(2)
        speakend = GetSecs - exptime; 
        speakduration = speakend - speakstart; 
        endminiblockSTART = [];
        endminiblockEND = [];
        endminiblockduration = []; 

    %Save file:
%    audiowrite([datadir,'Condition_',num2str(final_ttype(i)),'_',names{final_ttype(i)},'_rec_', num2str(i),'.wav'],y,44100);

    end
    

% log
    % On every trial, a new line will be printed that includes the trial
    % number (i), the condition on that trial (ttype(i)), stimulus name
    % etc. etc. 
    
        fprintf(logfid, '%-d\t%-s\t%-d\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\t%-.4f\n', ...
            i, names{final_ttype(i)}, final_ttype(i), cuestart, cueend, speakstart, speakend, endminiblockSTART, endminiblockEND);
        
  % %-d\t%-d\t%-s\t%-s\t%-d\t%-d\t%-d\n    
   
        
  
% Create cell variables containing durations and onsets (more rows get filled in per trial): 

cuedurations{final_ttype(i)} = [cuedurations{final_ttype(i)} cueduration];
speakdurations{final_ttype(i)} = [speakdurations{final_ttype(i)} speakduration];
endminiblockdurations{final_ttype(i)} = [endminiblockdurations{final_ttype(i)} endminiblockduration]; % durations logged on every trial
% trialdurations{final_ttype(i)} = [trialdurations{final_ttype(i)} trialduration];


cueonsets{final_ttype(i)} = [cueonsets{final_ttype(i)} cuestart];
speakonsets{final_ttype(i)} = [speakonsets{final_ttype(i)} speakstart];
endminiblockonsets{final_ttype(i)} = [endminiblockonsets{final_ttype(i)} endminiblockSTART]; % onsets logged on every trial

data.cue.start(i) = cuestart;
data.cue.end(i) = cueend; 
data.cue.duration(i) = cueduration;
data.speak.start(i) = speakstart; 
data.speak.end(i) = speakend;
data.speak.duration(i) = speakduration;
end
  
save([logdir '/' ppid '_onsets_run_' run],'cueonsets', 'speakonsets', 'endminiblockonsets','names', 'cuedurations', 'speakdurations', 'endminiblockdurations');
fclose(logfid); % close the log

data.names = names; 
data.total_elapsed_time = toc;
data.dur_exp_min = data.total_elapsed_time / 60;                           %How long run lasted in min
save(datafile,'data');

ShowCursor;
Screen('CloseAll')

toc