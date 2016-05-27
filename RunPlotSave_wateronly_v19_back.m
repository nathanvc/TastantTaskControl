% Multi-Tastant Task
% Nathan V-C  5/2014-1/2016
% ----------------------
% Control script that runs the combined active/passive MultiTastant Task
% ----------------------
% Specific installation for Multi-Tastant Lickometry Task
% Several features (number of boxes, channels for DAQ acquisition, 
% e-mail updates for figures during acquisition) are customized to the 
% Brown Multi-Tastant rig so will not work out ofRunPlotSave_wateronly_v19_back the box in another set-up
% requires pulser
% V19 revision 1/2016, revise for github and syncing across machines
% requires pulser and some other files not included here
% ---
% V18 combined active/passive trial with blanks
% ---
% v13 is update from v11 that only saves full daq session between runs, and
% then does all preliminary data analysis at the end of the run, to save
% time and reduce potential for crashes.
% ---
% this version also can load earlier sessions for pooled analysis, provided
% all sessions prior to start_sess_tag exist, and that only one such file
% exists, and that the exact same mice are run in the exact same boxes and
% no ear tags are entered incorrectly
% ---

clear all
close all
closepreview

% Filenames and tags for saving, and sending figures to Evernote
%----------
% SessionTag='revactpass';
% matlabfile=mfilename;
% NotebookTag='Reversal Act/Pass Water Sugar Quinine'; % controls notebook saved as in evernote
% TypeTrial='RevActPass'; %used for saving figs
% Notebook='TastantTask';

% % Water only easy file tags
% %----------
% SessionTag='watereasy';
% matlabfile=mfilename;
% NotebookTag='Water Only'; % controls notebook saved as in evernote
% TypeTrial='WaterEasy'; %used for saving figs
% Notebook='TastantTask';

% Water only file tags
%----------
SessionTag='wateronly';
matlabfile=mfilename;
NotebookTag='Water Only'; % controls notebook saved as in evernote
TypeTrial='WaterOnly'; %used for saving figs
Notebook='TastantTask';

% Take time point of run (before set up) to save files without overwriting
[~,timetag]=betterclock;  % formatted timesamp (string with always same number of characters)

% Send a test e-mail to evernote to make sure email will get through
% --- NOTE -- 
% if you get an error on this line, check internet and try again
% If you still get error, set the email tag to 0,
% it just means that the internet is out, everything else will run & save fine
%------------
send_evernote_append('Test', Notebook, '', [timetag 'email test'] ,[])
email=1; % indicator to control whether to email figs to evernote (1=email, 0=don't)

% Define file where raw data will save, organizing in a folder by date
%-----------
datadir=['C:/Users/coreuser/Documents/NathanData/Tastant_Learning/' timetag(1:10) '/'];
figdir=['C:/Users/coreuser/Documents/NathanData/Tastant_Learning/Figures/' timetag(1:10) '/'];

% make figure directories
figdir_pool=[figdir '/poolplots/'];
figdir_rawdata=[figdir '/rawdataplots/'];

% make video directory
viddir=['C:/Users/coreuser/Documents/NathanData/Videos_of_Sessions/' timetag(1:10) '/'];

% create directories if needed
if exist(datadir,'dir')==0
    mkdir(datadir)
    display(['creating directory at' datadir])
end

if exist(figdir,'dir')==0
    mkdir(figdir)
    display(['creating directory at' figdir])
end

if exist(figdir_pool,'dir')==0
    mkdir(figdir_pool)
    display(['creating directory at' figdir_pool])
end

if exist(figdir_rawdata,'dir')==0
    mkdir(figdir_rawdata)
    display(['creating directory at' figdir_rawdata])
end

if exist(viddir,'dir')==0
    mkdir(viddir)
    display(['creating directory at' viddir])
end

% set default session duration (10 mins)
session_duration= 600;

% ---------------
% Input to get from command line during run
% ---------------
display(['You started ' matlabfile ',']);
display('Is this the correct script?'); 
matlab_input=input(['If yes, press enter, if no, press CTRL+C to cancel']);
MouseTag1=input('Enter MouseTag for Box 1 (0 for no mouse) : ', 's');
MouseTag2=input('Enter MouseTag for Box 2 (0 for no mouse) : ', 's');
MouseTag3=input('Enter MouseTag for Box 3 (0 for no mouse) : ', 's');
MouseTag4=input('Enter MouseTag for Box 4 (0 for no mouse) : ', 's');
MouseTag5=input('Enter MouseTag for Box 5 (0 for no mouse) : ', 's');
numsess_tag=input('Enter how many sessions to run : ', 's');
start_sess_tag=input('Enter session number to start with : ', 's'); %pooled plots will only run if start with session 1
display('Run sessions for 10 minutes (600 seconds)?');
sess_dur_input=input('(Press Enter for yes or input desired session duration in seconds) : ');
if ~isempty(sess_dur_input)
    session_duration=sess_dur_input;
end

% These need to be chosen to match the arduino code timing, they control when
% "false" data points are chosen on water only trials -- times in seconds
% ------------
% These were needed with an earlier version, but should not be needed now
% that...
% ------------
time_params.int_range=[.4 1];  % time between tone and tastant
time_params.wat_range=[2 3.5];  % time that water was on, prior to tone
time_params.tast_range=[1.5 3]; % tastant time period

% convert command line entries to numbers
numsessions=str2num(numsess_tag);
start_session=str2num(start_sess_tag);

% cell containing all mouse tags
MouseTags={MouseTag1 MouseTag2 MouseTag3 MouseTag4 MouseTag5};

% Vectors indicating which boxes are currently running mice
ActiveBoxes=find(~strcmp(MouseTags,'0')==1);
% Cell containing ear tags for mice that are actually running
ActiveTags=MouseTags(ActiveBoxes);
% Tag numbers reformatted into a string for saving files that apply to all mice
ActiveTagsStr=strjoin(MouseTags,'_');
% Number of active boxes for looping through...
numbox=length(ActiveBoxes);

% Specify the trial type for each box
% -----------------------------------
% Can set up so that each box runs different version of task, 
% but here are set up to run identical 
%--Trial options are: ----
% 'Shape' - light on paired with water only, requires lick within 1 sec
% 'Shape_easy' - light on for full trial, no required lick within 1 sec
% '2tast_orig' - tone 1 with sucrose, tone 2 paired quin, active trials
% '2tast_cb' - tone 2 with sucrose, tone 1 with quin (for reversal), active
% '2tast_ext' - 2 tones, but both paired with water for extinction, active
% 'Sonly_orig' - tone 1 paired with sucrose only, active
% 'Qonly_orig' - tone 2 paired with quinine only, active
% 'Sonly_cb' - tone 2 paired with sucrose only
% 'Qonly_cb' - tone 1 paired with quinine only
% 'Tone1_ext - tone 1 with water
% 'Tone2_ext - tone 2 with water
% 'activepassive' - tone 1 with glucose, tone 2 with quin, including
% active, passive, trials, including catch for tone-only
% 'actpass_cb' - tone 2 with glucose, tone 1 qith quin, including
% active, passive, trials, including catch for tone-only
%---------
% Tr_type='activepassive';
% Tr_type='actpass_cb';
% Tr_type='Shape_easy';
Tr_type='Shape';

% can define this cell differently for each box
for i=1:numbox
    Trial_Type_all{i}=Tr_type;
end

%---------------
% set up cameras
%---------------
% vector that indicates which camera index to call for each box
% camera ids are set when matlab starts up, so if cameras are moved between
% plugs or added/taken away, need to restart matlab, enter 0 if no camera
% for that box (each entry is the matlab id for that camera in the box of
% that index, e.g. for [1 3 2 0] -- box 1 contains camera 1, box 2 contains
% camera 3, box 3 contains camera 2, and box 4 contains no camera
camvect=[2 0 0 1 0];
% only set up video for active boxes with camera
camboxes=intersect(ActiveBoxes,find(camvect>0));

for i=1:length(camboxes)
    % create a video object for each active camera
    % Each video object is stored under VideoBox{"box number"} (inactive
    % boxes and boxes without camera will have empty "VideoBox" entry
    camind=camvect(camboxes(i));
    VideoBox{i}=videoinput('winvideo',camind,'YUY2_640x480');
    preview(VideoBox{i});
end

%ask for input once previews have started to give a chance to adjust the
%cameras
ready2begin=input('Are you ready to begin ?', 's');

% Start taking videos for this session
%----------
for j=1:length(camboxes)
    
    %uncomment next line to see all the properties of the device that you
    %can set: brightness, saturation, etc.
    %get(getselectedsource(VideoBox{j}))
    
    % webcams will grab frames at 30fps, decide which of those frames it
    % records to disk i.e. 1= every frame, 2= every other frame etc.
    % This determines framerate of the recorded video
    VideoBox{j}.FrameGrabInterval = 4;
    
    % uncomment below to specify exact number of frames/time to record
    % determine length to record based on session duration
    % frames_to_record=session_duration*(30/ VideoBox{j}.FrameGrabInterval)
    % VideoBox{j}.FramesPerTrigger = frames_to_record;
    VideoBox{j}.FramesPerTrigger = Inf;
    
    % choose whether matlab immediately records frames captured to disk or
    % keeps them in memory
    % (Changing this might help increase frame rate)
    VideoBox{j}.LoggingMode = 'disk';
    
    % initialize and name the file the recording will be saved as
    MouseTag=MouseTags{camboxes(j)};
    videofile{j}=[viddir timetag '_Mouse_' MouseTag];
    
    % this next line is where we can play with the exact way its recorded
    % (whether it's an avi or .mp4 file, whether its compressed, etc.
    logfile{j} = VideoWriter(videofile{j}, 'Motion JPEG AVI');
    VideoBox{j}.DiskLogger = logfile{j};
    % add framerate for videofile here?
    % logfile{j}.FrameRate=30;
end

%start camera recording
for j=1:length(camboxes)
    start(VideoBox{j});
end


%pause program until all videos are ready to record
%-----
while ~isrunning(VideoBox{length(VideoBox)})
    pause(.1)
end

% ----------------
% Use pulser to construct the DAQ session and waveforms
% ----------------
[pulser]=pulser_config_timeout_multimouse_5box_actpass_blank(ActiveBoxes,Trial_Type_all,session_duration);
pulser_sessionConstructor(pulser);

% Using the pulser output, make a session, but don't start it 
testOutConfigAndStart_varpulse_range_nostart;

% Generate an analog wave form for each session and box that will be run
% These are generated now to cut run time between sessions during
% experiment
for s=start_session+1:start_session+numsessions-1
    if numel(pulser.ni.aOut.channels) > 0,
        aOut{s}=zeros(pulser.ni.rate*pulser.ni.trialDuration,numel(pulser.ni.aOut.channels));
        for i=1:numel(pulser.ni.aOut.channels),
            if strcmp(pulser.ni.aOut.trains.types{i},'randstep'),
                aOut{s}(:,i) = pulser_randstep(pulser.ni.aOut.trains.rs_trial_vals, pulser.ni.aOut.trains.rs_prop_trials{i}, pulser.ni.aOut.rs_timestep, pulser.ni.aOut.rs_time_pre, pulser.ni.aOut.rs_time_post, pulser.ni.rate,pulser.ni.trialDuration);
            end
        end
    end
end

% ------------------
% NOW ACTUALLY RUN THE SESSIONS
% ------------------

% Loop through sessions
for session=start_session:start_session+numsessions-1
    
    % after first session,
    % input the analog out signals for each box into the nidaq session
    if session>start_session
        pulser_old=pulser;
        pulser.ni.aOut.aOutWrite=aOut{session};
    end
    
    disp(['Now starting session ' num2str(session)])
    
    % Take timestamp for session to use for file names, taking as close to
    % actual trial start as possible
    %------
    [timestamp,timetag]=betterclock;
    timetag_ids{session}=timetag;
    
    % Run session using pulser, runs in background 
    % (this command is in pulser_session_recent, generates 'data')
    %------
    RunSingleSession
    
    % if one session is done, then crunch, 
    % plot & save that data while the current session runs
    if session > start_session
        % plot data acquired in prior session while current one runs
        % data_rawdaq is from previous session b/c has not yet been
        % redefined in current session
        plot_rawdata_background(MouseTags, ActiveTags, data_rawdaq, timetag_ids{session-1}, session-1, SessionTag, Notebook, NotebookTag, TypeTrial, matlabfile, pulser_old, figdir_rawdata, email)
    end
    clear data_rawdaq

    % data acquisition started in background, stop after it finishes
    % pause to make sure new session is really started
    % pause(20)
    % pulser_daq_session.wait()
    
    pause(5)
    if ~pulser_daq_session.IsRunning
        pulser_daq_session.IsRunning
        pause(1)    
    elseif pulser_daq_session.IsRunning
        pulser_daq_session.IsRunning
        display('Waiting for session to complete')
        wait(pulser_daq_session)
        display('Session is complete')
    end
    
    
    
    % pulser_daq_session.stop;
    delete(lh); % delete listener inside the session
    fclose(fid1); % close the log file where data saved
   
    %---------------
    % Load data from log file
    %---------------
    fid2 = fopen('log.bin','r');
    [data_all,count]=fread(fid2,[numbox*9+1,inf],'double');
    fclose(fid2);
    time=data_all(1,:);
    data=data_all(2:end,:);
    
    clear data_all
    
    % Save data and pulser session that generated the data
    % Saving all data in one raw file, data will be reformatted when pooled
    % analysis is run
    %---------------
    data_rawdaq=data';
    rawdatafile=[timetag '_AllBoxesRawData_Session_' num2str(session) '_' ActiveTagsStr '_' SessionTag];
    save([datadir rawdatafile],'pulser', 'data_rawdaq', 'session', 'numsessions', 'timestamp', 'timetag', 'MouseTags', 'ActiveBoxes','Trial_Type_all');
    % structure that has raw file names, need later for data crunching
    rawdatafiles_all{session}=[datadir rawdatafile];
    
    delete('log.bin')
    
    clear data
    
end

% Make raw data plot for final session
plot_rawdata_background(MouseTags, ActiveTags, data_rawdaq, timetag, session, SessionTag, Notebook, NotebookTag, TypeTrial, matlabfile, pulser, figdir_rawdata, email)

% stop the cameras now that everything has run
%-----------------
for j=1:length(VideoBox)
    %box=camboxes(j);
    stop(VideoBox{j});
end

%--------
% *************
% All the raw data has been saved and sessions have been run
% Now we do some data crunching
% *************
%--------
% if sessions for this run started after 1 (likely due to prior crash same day), find filenames 
% of the earlier sessionsfiles. For this to work
%   - there MUST be only one file for each session
%   - all session numbers must exist
%   - a file must exist for each box in order to reload
%   - all mice must be loaded in exactly the same boxes
%-----------------
errorcount=0;
if start_session>1
    filelist=dir(datadir);
    filelist={filelist.name};
    for missingsess=1:start_session-1
        findfile_temp={filelist{strmatch(['_AllBoxesRawData_Session_' num2str(missingsess) '_' ActiveTagsStr '_' SessionTag],filelist)}}; 
        if length(findfile_temp)==1
           % Possible this is wrong format for concatenating this path name
            rawdatafiles_all{missingsess}=strjoin([datadir findfile_temp{1}],'');
        elseif isempty(findfile_temp)
            errorcount=errorcount+1;
            display(['No file detected for session ' num2str(missingsess) ', cannot run pooled analysis']);
        elseif length(findfile_temp)>1
            errorcount=errorcount+1;
            display(['More than one file detected for session ' num2str(missingsess) ', cannot run pooled analysis' ]);
        end
        timetag_ids{missingsess}=findfile_temp{1}(1:19);
    end
    display(rawdatafiles_all)
    if errorcount>0
        error([num2str(errorcount) ' errors were detected while loading pooled analysis files, cannot run pooled analysis'])
    end
end

% Run and save preliminary data analysis, and generate pooled plots over sessions 
% This script is located in TastantTaskControl/fn
%---------------------------------------
runsave_pooled_analysis_5box_toneonly_blank(rawdatafiles_all, ActiveBoxes, MouseTags, time_params, datadir, datadir, figdir_pool, SessionTag, TypeTrial, NotebookTag, Notebook, matlabfile, email, timetag_ids)


