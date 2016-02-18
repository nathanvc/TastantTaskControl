% Multi-Tastant Task
% Nathan V-C  7/2015
% -----------------------
% This file is for recovering pooled analysis for days where there was 
% an error and pooled analysis did not run automatically 
%-------------------------
% Only works with the 4 or 5 box digital data acquisition, prior files will need
% individual attention (prior to about 6/2015)
% --command line entries must EXACTLY match original acquisition
%-------------------------

close all
clear all

% do not email regenerated figure results
% (can change this if running same day, otherwise will send figs out of
% order to evernote notebooks)
email=1;

display('For which date do you need to reprocess pooled data?')
DateTag=input('(format YYYY-MM-DD, including a zero in 1st digit for M/D if needed) : ', 's');
SessionTag=input('Enter SessionTag for original data acquisition : ', 's');
TypeTrial=input('Enter TypeTrial for original data acquisition : ', 's');
matlabfile=mfilename; %Note that this stamps the fact that files are regenerated in the pooled plot data structure

DataVersion=0;
DataVersion=input('Enter 1 for data collected v9-11, 0 for after ("4box" code prior to 7/15/15) : ');

display('Enter tags for all mice who ran in a group of four, all mice must have run the same sessions, and numbers must be entered exactly as in original acquisition : ')
MouseTag1=input('Enter MouseTag for Box 1 (0 for no mouse) : ', 's');
MouseTag2=input('Enter MouseTag for Box 2 (0 for no mouse) : ', 's');
MouseTag3=input('Enter MouseTag for Box 3 (0 for no mouse) : ', 's');
MouseTag4=input('Enter MouseTag for Box 4 (0 for no mouse) : ', 's');
MouseTag5=input('Enter MouseTag for Box 5 (0 for no mouse) : ', 's');

sess_start=input('Enter number of starting session : ');
numsess=input('Enter number of ending session : ');

% enter 1 for each box to actually run analysis for, if enter zero, skips
% that box/mouse
run_analysis=[1 1 0 1 1];

MouseTags={MouseTag1 MouseTag2 MouseTag3 MouseTag4 MouseTag5};
% Boxes that were actually run
ActiveBoxes=find(~strcmp(MouseTags,'0')==1);
% cell containing which mice are actually running
ActiveTags=MouseTags(ActiveBoxes);
% Tag numbers in a string for saving files that apply to all mice
ActiveTagsStr=strjoin(MouseTags,'_');

% These need to be chosen to match the arduino code, they control when
% "false" data points are chosen on water only trials -- times in seconds
% [these may not be needed anymore for the update with information channel
% ...Update, NVC 1/17/16]
%---------------
time_params.int_range=[.4 1];  % time between tone and tastant
time_params.wat_range=[2 3.5];  % time that water was on, prior to tone
time_params.tast_range=[1.5 3]; % tastant time period

% data directory for running on lab machine
%----------
datadir=['C:/Users/coreuser/Documents/NathanData/Tastant_Learning/' DateTag '/'];

% data directory for running on Nathan's data drive
%----------
%datadir=['/Volumes/DATAPROC-3/TastantTask/NathanData/LickData/' DateTag '/'];

% designate where to save data when regenerating analysis (can just be data
% dir, but change if want to examine this data separately)
%-------
datasavedir=datadir;
%datasavedir=['/Volumes/DATAPROC-3/TastantTask/NathanData/TempData/' DateTag '/'];

% Figure directory for pooled files
%----------
% if saving on lab machine for plots that never ran
figdir_pool=['C:/Users/coreuser/Documents/NathanData/Tastant_Learning/Figures/' DateTag '/poolplots/'];
% running temp files on Nathan's drive
% figdir_pool=['/Volumes/DATAPROC-3/TastantTask/NathanData/TempFigs/' DateTag '/pooledplots/'];

if exist(datasavedir,'dir')==0
    mkdir(datasavedir)
    display(['creating figure directory at' datasavedir])
end

if exist(figdir_pool,'dir')==0
    mkdir(figdir_pool)
    display(['creating figure directory at' figdir_pool])
end

%-----------------
% find filenames for raw data
%   - there MUST be only one file for each session
%   - all session numbers must exist
%   - a file must exist for each box in order to reload
%   - all mice must be entered in exactly the same boxes
%-----------------

if DataVersion==0;
    errorcount=0;
    filelist=dir(datadir);
    filelist={filelist.name};
    % loop through sessions, note sessions must start from 1, and all must
    % be present in order for the analysis to run
    k=1;
    for missingsess=sess_start:numsess
        %findfile_temp={filelist{strmatch(['_AllBoxesRawData_Session_' num2str(missingsess) '_' ActiveTagsStr '_' SessionTag],filelist)}};
        findfile_temp=filelist(find(~cellfun(@isempty,regexp(filelist,['_AllBoxesRawData_Session_' num2str(sess_start+k-1) '_' ActiveTagsStr '_' SessionTag]))==1));
        if length(findfile_temp)==1
            % Possible this is wrong format for concatenating this path name
            rawdatafiles_all{k}=[datadir findfile_temp{1}];
        elseif isempty(findfile_temp)
            errorcount=errorcount+1;
            display(['No file detected for session ' num2str(missingsess) ', cannot run pooled analysis']);
        elseif length(findfile_temp)>1
            errorcount=errorcount+1;
            display(['More than one file detected for session ' num2str(missingsess) ', cannot run pooled analysis' ]);
        end
        timetag_ids{k}=findfile_temp{1}(1:19);
        k=k+1;
    end
    display(rawdatafiles_all)
    if errorcount>0
        error([num2str(errorcount) ' errors were detected while loading pooled analysis files, cannot run pooled analysis'])
    end
end

% For data collection version 8(?)-11 and earlier
% (whatever the first 4 box was, but before saved raw files with mouse tag numbers (v13)) 
if DataVersion==1;
    errorcount=0;
    filelist=dir(datadir);
    filelist={filelist.name};
    % find timetag numbers for individual raw sessions, by looking at
    % sessions numbers for mouse in box 
    for missingsess=1:numsess
        % mousefile_temp={filelist{strmatch(['Mouse_' num2str(ActiveTags{1}) '_Session_' num2str(missingsess)],filelist)}};
        mousefile_temp=filelist(find(~cellfun(@isempty,regexp(filelist,['Mouse_' num2str(ActiveTags{1}) '_Session_' num2str(missingsess)]))==1));
        if length(mousefile_temp)==1
            % Possible this is wrong format for concatenating this path name
            timetag_ids{k}=mousefile_temp{1}(1:19);
        elseif isempty(mousefile_temp)
            errorcount=errorcount+1;
            display(['No indiv mouse file file detected for session ' num2str(missingsess) ', cannot run pooled analysis']);
        elseif length(mousefile_temp)>1
            errorcount=errorcount+1;
            display(['More than one indiv mouse file detected for session ' num2str(missingsess) ', cannot run pooled analysis' ]);
        end
    end
    display(timetag_ids')
    if errorcount>0
        error([num2str(errorcount) ' errors were detected while indentifying time tags for raw data files, cannot run pooled analysis'])
    end
   
    % Once correct file ids are located,loop through sessions identifying raw data file names, note sessions must start from 1, and all must
    % be present in order for the analysis to run
    
    for missingsess=1:length(timetag_ids)
        findfile_temp={filelist{strmatch([timetag_ids{missingsess} '_AllBoxesRawData_Session_' num2str(missingsess)],filelist)}};
        if length(findfile_temp)==1
            % Possible this is wrong format for concatenating this path name
            rawdatafiles_all{missingsess}=[datadir findfile_temp{1}];
        elseif isempty(findfile_temp)
            errorcount=errorcount+1;
            display(['No file detected for session ' num2str(missingsess) ', cannot run pooled analysis']);
        elseif length(findfile_temp)>1
            errorcount=errorcount+1;
            display(['More than one file detected for session ' num2str(missingsess) ', cannot run pooled analysis' ]);
        end
    end
    rawdatafiles_all'
    if errorcount>0
        error([num2str(errorcount) ' errors were detected while loading pooled analysis files, cannot run pooled analysis'])
    end
end

% Run and save preliminary data analysis, and generate pooled plots over sessions 
% This version no longer saves an individual file for each box/session
% this information is contained in the pooled session, and can be extracted
% from the full rawdata file if needed.
% This script is located in TastantTask/fn
%---------------------------------------
runsave_pooled_analysis_5box_toneonly_blank_regen(rawdatafiles_all, ActiveBoxes, MouseTags, time_params, datadir, datasavedir, figdir_pool, SessionTag, TypeTrial, [], [], [], email, timetag_ids,run_analysis)

