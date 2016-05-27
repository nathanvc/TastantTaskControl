% Plot raw data from the multitastant task
% Divided out by individual boxes in the 5 box rig
% ------------
% Nathan V-C
% ~5/2015
% ------------

function plot_rawdata_background(MouseTags, ActiveTags, data_rawdaq, timetag, session, SessionTag, Notebook, NotebookTag, TypeTrial, matlabfile, pulser, figdir_rawdata, email)

ActiveBoxes=find(~strcmp(MouseTags,'0')==1);
ActiveTagsStr=strjoin(MouseTags,'_');
numbox=length(ActiveTags);

%------
%Plot raw data for each box for this session in a single plot
%-------
hFig=figure;
set(hFig, 'Position', [0 0 1000 1000])
figfile=[timetag '_rawdataplots_allboxes_Session_' num2str(session) '_' ActiveTagsStr '_' SessionTag];

for i=1:numbox
    
    MouseTag=ActiveTags{i};
    Box=ActiveBoxes(i);
    
    % pull out data for just one box, multiply digital channels by
    % 5, keep same order (with raw lick 3rd from end) as older data
    % (this format is for set up with 4 boxes, digital acquisition
    % for all except raw lick), Note if box 5 is active, all box 5
    % channels are analog and collected first in the data acquisition
    % order, so need to be accounted for
    
    if ismember(5,ActiveBoxes)
        if Box<5
            data_indivbox=repmat([5 5 5 5 5 5 1 5 5],length(data_rawdaq),1).*data_rawdaq(:,[(numbox+8+(i-1)*8+1):(numbox+8+(i-1)*8+6) i (numbox+8+(i-1)*8+7):(numbox+8+(i-1)*8+8)]);
        elseif Box==5 % bx 5 is analg
            data_indivbox=data_rawdaq(:,[(numbox+1):(numbox+6) i (numbox+7):(numbox+8)]);
        end
    elseif ~ismember(5,ActiveBoxes)
        data_indivbox=repmat([5 5 5 5 5 5 1 5 5],length(data_rawdaq),1).*data_rawdaq(:,[(numbox+(i-1)*8+1):(numbox+(i-1)*8+6) i (numbox+(i-1)*8+7):(numbox+(i-1)*8+8)]);
    end
   
    %Plot raw data
    %---------
    subfigtitle=[timetag '_Mouse_' MouseTag '_Session_' num2str(session) '_Box_' num2str(Box) '_' SessionTag];
    subplot(5,1,Box)
    plotrawdata_detlick_nodataproc(data_indivbox,pulser.ni.rate);
    title(subfigtitle,'fontsize',12,'interpreter','none')
    
end

%Save raw data figure
saveas(hFig,[figdir_rawdata,figfile])
print(hFig,'-djpeg','-r200', [figdir_rawdata figfile])
attchfile=[figdir_rawdata figfile '.jpg'];

% email raw figures to evernnote if email turned on
if email==1
    NoteTitle_raw=[NotebookTag ', RawDataPlots, all boxes']
    Tags='data analysis';
    Text=[['Matlab file: ' matlabfile] 10 ...
        timetag 10 ...
        [figdir_rawdata figfile] 10 ...
        ['Box 1: ' MouseTags{1} ' Box 2: ' MouseTags{2} ' Box 3: ' MouseTags{3} ' Box 4: ' MouseTags{4} ' Box 5: ' MouseTags{5}]  10 ...
        'Raw data figure' 10 ...
        TypeTrial ];
    
    attchfile=[figdir_rawdata figfile '.jpg'];
    send_evernote_append(NoteTitle_raw, Notebook, Tags, Text, attchfile)
end