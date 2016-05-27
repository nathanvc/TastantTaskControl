% CrashRecovery.m
%-----------------
% NathanVC
% 1/2016
%-----------------
% Run after "RunPlotSave" in cases where code runs an entire nidaq session
% but gets hung up before data is able to save
% This presents as a frozen unresponsive system but no "red" error text
%-----------------
% Pulled from RunPlotSave_revactpass_v18_back
% May need to be updated when/if RunPlotSave is updated
%-----------------

% closes the log file and deletes the listening object from the daq session
%------------------
delete(lh);
fclose(fid1);

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
% Plot raw data for that mouse after session saves
% Saving all data in one raw file, data will be reformatted when pooled
% analysis is run
%---------------
data_rawdaq=data';
rawdatafile=[timetag '_AllBoxesRawData_Session_' num2str(session) '_' ActiveTagsStr '_' SessionTag];
save([datadir rawdatafile],'pulser', 'data_rawdaq', 'session', 'numsessions', 'timestamp', 'timetag', 'MouseTags', 'ActiveBoxes','Trial_Type_all');

% Plot raw data and email it to evernote
%---------------------------------------
plot_rawdata_background(MouseTags, ActiveTags, data_rawdaq, timetag, session, SessionTag, Notebook, NotebookTag, TypeTrial, matlabfile, pulser, figdir_rawdata, email)

% stop the cameras now that everything has run
%-----------------
for j=1:length(VideoBox)
    %box=camboxes(j);
    stop(VideoBox{j});
end

clear data
delete('log.bin')