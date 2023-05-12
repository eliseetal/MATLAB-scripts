### MATLAB_scripts
MATLAB scripts designed for use in functional MRI experiments: stimulus presentation, transforming data, automating data analysis pipeline for analysis of brain (fMRI) data. 


### AV_stimuli_V_delay.m
Script I created that takes in audio and video files, joins them together, and adds either a visual lag or auditory lag, and saves off these files as AVIs to be used in an experiment. 

### hu_score_calculator.m 
Script that reads in raw data, calculates unbiased hit rates using a for loop, and saves each participants' unbiased hit rates (hu scores) to separate sheets within an
excel file. 

### familiarity_stim_pres.m 
Experiment I programmed using MATLAB's PsychToolbox to be used within the MRI scanner. 
The task involves presenting voice stimuli to listeners inside the MRI scanner, and records button presses at various timepoints. 
Timings of stimulus presentation are logged within the task and saved off to a log file to be used later in the analysis alongside the fMRI data collected. 

### Randomisations_familiarity.m 
Script I wrote to create randomised condition and stimulus orders for an experimental task.  
