% Script to enter external data for tastant task
% This is anything the experimentalist knows, but not the data collection
% For the most part, this is data that is written down on our check sheet
% This data entry automatically mails the basics to evernote where
% additional notes can be added if needed
% ----------------

function [ExtData, Text] = ExternalDataEntry_DuringTask(matlabfile,dp_cat,MouseTags);

skipheader = 0;
email = 0;

% Make directory to save
extdatadir=['/Volumes/DATAPROC-3/TastantTask/ExternalData/' Cohort '/'];
extdatafile = [Cohort '_Day_' CohortDay '_extdata'];

if exist(extdatadir,'dir')==0
    mkdir(extdatadir)
    display(['creating directory at' extdatadir])
    display('-----')
end

if exist([extdatadir extdatafile])==2
    load([extdatadir extdatafile],'ExtData', 'Text', 'MouseTags_gps', ...
        'Cohort','CohortDay','PhaseDay','PhaseTitle','PhaseType',...
        'Experimentalist','Date')
    skipheader = 1;
end

if skipheader == 0
    Cohort=input('Enter Cohort identity for these mice: ', 's');
    Experimentalist=input('Enter experimentalist initials: ', 's');
    % matlabfile = input('Enter matlab file for this day: ', 's');
    CohortDay=input('Enter total day count for these mice: ', 's');
    PhaseDay=input('Enter phase day count for these mice: ', 's');
    Date = dp_cat.timetag{1}(1:10);
    % Titles depending on phase
    % -----
    PossTitles{1} = 'Water Shaping Easy';
    PossTitles{2} = 'Water Shaping';
    PossTitles{3} = 'Active Passive with Injections';
    PossTitles{4} = 'Active Passive with Control Injections';
    PossTitles{5} = 'Reversal with Control Injections';
    
    display('-----')
    display('Enter 1 for water shaping easy, Enter 2 for water shaping');
    display('Enter 3 for full task with drugs, Enter 4 for full task post-drug');
    PhaseType=input('Enter 5 for reversal: ');
    PhaseTitle=PossTitles{PhaseType};
    
end

Grp=input('Which group number was this for today?');

lastind = input ('Is this the last group for the day? (enter y/n)','s');

% Enter Pre calibration info
% -----
if lastind == 'y'
    
    email = 1; % only email to evernote once have all data for this cohort
    
    display('-----')
    display('ENTER CALIBRATION INFORMATION (enter zeros if not run)')
    display('-----')
    
    for i=1:5
        ExtData.Calibration.(['Box' num2str(i)]).pre.wat = ...
            input(['Water Pre-calibration for Box ' num2str(i) ': '], 's');
        ExtData.Calibration.(['Box' num2str(i)]).pre.sug = ...
            input(['Sugar Pre-calibration for Box ' num2str(i) ': '], 's');
        ExtData.Calibration.(['Box' num2str(i)]).pre.quin = ...
            input(['Quinine Pre-calibration for Box ' num2str(i) ': '], 's');
        display('-----')
    end
    
    % Enter Post calibration
    for i=1:5
        ExtData.Calibration.(['Box' num2str(i)]).post.wat = ...
            input(['Water Post-calibration for Box ' num2str(i) ': '], 's');
        ExtData.Calibration.(['Box' num2str(i)]).post.sug = ...
            input(['Sugar Post-calibration for Box ' num2str(i) ': '], 's');
        ExtData.Calibration.(['Box' num2str(i)]).post.quin = ...
            input(['Quinine Post-calibration for Box ' num2str(i) ': '], 's');
        display('----')
    end
end

for gp = Grp
    
    Group = gp;
    
    display('-----')
    display(['ENTER GROUP INFORMATION FOR GROUP ' num2str(gp)])
    display('-----')
    
%     MouseTag1=input('Enter MouseTag for Box 1 (0 for no mouse) : ', 's');
%     MouseTag2=input('Enter MouseTag for Box 2 (0 for no mouse) : ', 's');
%     MouseTag3=input('Enter MouseTag for Box 3 (0 for no mouse) : ', 's');
%     MouseTag4=input('Enter MouseTag for Box 4 (0 for no mouse) : ', 's');
%     MouseTag5=input('Enter MouseTag for Box 5 (0 for no mouse) : ', 's');
%     display('-----')
%     
%     % cell containing all mouse tags
%     MouseTags={MouseTag1 MouseTag2 MouseTag3 MouseTag4 MouseTag5};
    
    % Vectors indicating which boxes are currently running mice
    ActiveBoxes=find(~strcmp(MouseTags,'0')==1);
    
    % Enter any special notes
    SpNotesAllBoxes = input('Enter any special notes that apply to all boxes: ', 's');
    for i=ActiveBoxes
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).spnotes.allboxes = SpNotesAllBoxes;
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).spnotes.thisbox = ...
            input(['Enter any special notes for box ' num2str(i) ' mouse (tag : ' MouseTags{i} '): '], 's');
    end
    display('-----')
    
    % Enter injection time information
    display('Were all injection times (within 5 mins) the same for this group?')
    InjDiff = input('Enter y/n: ','s');
    if (InjDiff == 'y' || InjDiff == '')
        InjTime = input('Enter injection time (HH:MM, military) : ', 's');
        for i=ActiveBoxes
            ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).injtime = InjTime;
        end
        display('-----')
    elseif InjDiff == 'n'
        for i=ActiveBoxes
            ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).injtime = ...
                input(['Enter injection time (HH:MM, military) for box ' num2str(i) ' mouse (tag : ' MouseTags{i} '): '], 's');
        end
        display('-----')
    end
    
    display('Were all run start times the same for this group and started at session 1?')
    RunDiff = input('Enter y/n: ','s');
    
    if (InjDiff == 'y' || InjDiff == '')
        InjTime = [dp_cat.timetag{1}(12:13) ':' dp_cat.timetag{1}(14:15)];
        for i=ActiveBoxes
            ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).starttime = InjTime;
        end
        display('-----')
    elseif InjDiff == 'n'
        for i=ActiveBoxes
            st_sess = input(['Which session was first for box ' num2str(i) ' mouse (tag : ' MouseTags{i} ')?: ']);
            ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).starttime = ...
                [dp_cat.timetag{st_sess}(12:13) ':' dp_cat.timetag{st_sess}(14:15)];
        end
        display('-----')
    end
        
    % Enter pre-weight data
    for i=ActiveBoxes
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).mousetag = MouseTags{i};
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).weight.pre = ...
            input(['pre-weight for box ' num2str(i) ' mouse (tag : ' MouseTags{i} '): '], 's');
    end
    display('-----')
    
    % Enter post-weight data
    for i=ActiveBoxes
        MTag = ['M' MouseTags{i}];
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).weight.post = ...
            input(['post-weight for box ' num2str(i) ' mouse (tag : ' MouseTags{i} '): '], 's');
    end
    display('-----')
    
    % Enter injection amount (microliters)
    for i=ActiveBoxes
        MTag = ['M' MouseTags{i}];
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).injamt = ...
            input(['injection amt (microliters) for box ' num2str(i) ' mouse (tag : ' MouseTags{i} '): '], 's');
    end
    display('-----')
    
    % Enter injection type
    InjTypes{1} = 'Control';
    InjTypes{2} = 'Low Hal';
    InjTypes{3} = 'High Hal';
        
    display('Enter 1 for Control, Enter 2 for Low Hal, Enter 3 for High Hal:');
    PhaseTitle=PossTitles{PhaseType};
    for i=ActiveBoxes
        MTag = ['M' MouseTags{i}];
        injind = input(['Enter injection type for box ' num2str(i) ' mouse (tag : ' MouseTags{i} '): ']);
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).injtype = ...
            InjTypes{injind};
    end
    display('-----')
    
    % Enter water delivered (mL)
    for i=ActiveBoxes
        MTag = ['M' MouseTags{i}];
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).delivered.wat = ...
            input(['Water delivered (mL) for box ' num2str(i) ': '], 's');
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).delivered.sug = ...
            input(['Sugar delivered (mL) for box ' num2str(i) ': '], 's');
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).delivered.quin = ...
            input(['Quinine delivered (mL) for box ' num2str(i) ': '], 's');
        ExtData.(['Grp' num2str(Group)]).(['Box' num2str(i)]).delivered.supp = ...
            input(['Supplement delivered (mL) for box ' num2str(i) ' mouse (tag : ' MouseTags{i} '): '], 's');
        display('-----')
    end
    
    MouseTags_gps{gp}=MouseTags;
    ActiveBoxes_gps{gp}=ActiveBoxes;
    
end

Text = []; % empty text for first groups

% Sub function that generates the text block to email to evernote, only
% runs after all groups have run for the day (as indicated by lastind)

if email==1
    NoteTitle=['Cohort ' Cohort ', ' PhaseTitle ', Day ' CohortDay ' Phase Day ' PhaseDay];
    Notebook='TastantTask';
    Tags='';
    % Generate Text
    Text = GenText(ExtData, Date, Experimentalist, MouseTags_gps, Groups);
    % Send to Evernote to generate today's data note
    send_evernote_append(NoteTitle, Notebook, Tags, Text, [])    
end

    function Text = GenText(ExtData, Date, Experimentalist, MouseTags_gps, Groups);
        
        TextHeader = [Date 10 ...
            Experimentalist 10 ...
            ['Matlab script: ' matlabfile]];
        
        for i = 1:5
            CalibText{i} = [['Box ' num2str(i) ' Calibration:'] 10 ...
                ['Pre: Water: ' ExtData.Calibration.(['Box' num2str(i)]).pre.wat ' mL, Sugar: ' ExtData.Calibration.(['Box' num2str(i)]).pre.sug ' mL, Quinine: ' ExtData.Calibration.(['Box' num2str(i)]).pre.quin ' mL'] 10 ...
                ['Post: Water: ' ExtData.Calibration.(['Box' num2str(i)]).post.wat ' mL, Sugar: ' ExtData.Calibration.(['Box' num2str(i)]).post.sug ' mL, Quinine: ' ExtData.Calibration.(['Box' num2str(i)]).post.quin ' mL']];
        end
        
        
        
        for gp = 1:Groups
            MouseTags = MouseTags_gps{gp}
            SpNotes_ab{gp} = [['Group ' num2str(gp) ' Notes: '] 10 ...
                ExtData.(['Grp' num2str(gp)]).Box1.spnotes.allboxes];
            
            for i = ActiveBoxes_gps{gp}
                if MouseTags{i} == '0'
                    SpNotes{gp}{i} = [];
                else
                    SpNotes{gp}{i} = [['Box ' num2str(i) ' Notes: '] 10 ...
                        ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).spnotes.thisbox];
                end
            end
        end
        
        for gp = 1:Groups
            MouseTags = MouseTags_gps{gp};
            for i = 1:5
                if MouseTags{i} == '0'
                    TextBox{gp}{i} = [['BOX ' num2str(i)] 10 ...
                        'Box not run'];
                else
                    TextBox{gp}{i} = [['BOX ' num2str(i)] 10 ...
                        ['Mouse ' MouseTags{i}] 10 ...
                        ['Injection Time: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).injtime] 10 ...
                        ['Start Time: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).starttime] 10 ...
                        ['Injection Amt: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).injamt ' microliters'] 10 ...
                        ['Injection Type: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).injtype] 10 ...
                        ['Pre Weight: '  ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).weight.pre ' g, Post Weight: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).weight.pre ' g'] 10 ...
                        ['Water: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).delivered.wat ' mL, Sugar: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).delivered.sug ' mL, Quinine: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).delivered.quin ' mL'] 10 ...
                        ['Supplement: ' ExtData.(['Grp' num2str(gp)]).(['Box' num2str(i)]).delivered.supp  ' mL']];
                end
            end
        end
        
        % Compile all text into a single block
        % --------------
        Text = [TextHeader 10 10];
        
        % Add calibration text
        for i = 1:5
            Text = [Text CalibText{i} 10];
        end
        Text = [Text 10];
        
        Text = [Text 'SPECIAL NOTES' 10];
        for gp = 1:Groups
            Text = [Text SpNotes_ab{gp} 10];
            for i=ActiveBoxes_gps{gp}
                if ~isempty(SpNotes{gp}{i})
                    Text = [Text SpNotes{gp}{i} 10];
                end
            end
        end
        Text = [Text 10]; % add an extra line
        
        % Add specific mouse information for each group
        for gp = 1:Groups
            Text = [Text ['GROUP ' num2str(gp)] 10 10];
            for i=1:5
                Text = [Text TextBox{gp}{i} 10 10];
            end
        end
        
    end

save([extdatadir extdatafile], 'ExtData', 'Text', 'MouseTags_gps', 'Cohort','CohortDay','PhaseDay','PhaseTitle','PhaseType','Experimentalist','Date')
clear('ExtData', 'Text', 'MouseTags_gps', 'Cohort','CohortDay','PhaseDay','PhaseTitle','PhaseType','Experimentalist','Date')

end
   