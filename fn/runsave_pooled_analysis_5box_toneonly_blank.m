% Run initial data analysis for Multi-Tastant task
% ---------
% Nathan VC
% ~5/2015, 1/2016

function runsave_pooled_analysis_5box_toneonly_blank(rawdatafiles_all, ActiveBoxes, MouseTags, time_params, datadir, datasavedir, figdir_pool, SessionTag, TypeTrial, NotebookTag, Notebook, matlabfile, email, timetag_ids)

numbox=length(ActiveBoxes);

for i=1:numbox
        
    % Identify mouse and box
    %-------
    Box=ActiveBoxes(i)
    MouseTag=MouseTags{Box}
    
    for session=1:length(rawdatafiles_all)
        
        load(rawdatafiles_all{session});
        timetag=timetag_ids{session};
        
        % pull out data for just one box, multiply digital channels by
        % 5, keep same order (with raw lick 3rd from end) as older data
        % (this format is for set up with 4 boxes, digital acquisition
        % for all except raw lick), box 5 has analog channels, and is
        % recorded first if included, so has to be handled separately
        
        if ismember(5,ActiveBoxes)
            if Box<5
                data_indivbox=repmat([5 5 5 5 5 5 1 5 5],length(data_rawdaq),1).*data_rawdaq(:,[(numbox+8+(i-1)*8+1):(numbox+8+(i-1)*8+6) i (numbox+8+(i-1)*8+7):(numbox+8+(i-1)*8+8)]);
            elseif Box==5 % bx 5 is analg
                data_indivbox=data_rawdaq(:,[(numbox+1):(numbox+6) i (numbox+7):(numbox+8)]);
            end
        elseif ~ismember(5,ActiveBoxes)
            data_indivbox=repmat([5 5 5 5 5 5 1 5 5],length(data_rawdaq),1).*data_rawdaq(:,[(numbox+(i-1)*8+1):(numbox+(i-1)*8+6) i (numbox+(i-1)*8+7):(numbox+(i-1)*8+8)]);
        end
        
        data=data_indivbox;
        SessionBox(session)=Box;
        
        %-- this info is all in the raw data file, but I relied on this
        % for earlier analysis so keeping it here
        % save data for this mouse individually
        % datafile=[timetag '_Mouse_' MouseTag '_Session_' num2str(session) '_' SessionTag];
        % save([datadir datafile],'pulser','data', 'MouseTag', 'Box', 'session', 'numsessions', 'timestamp', 'timetag', 'MouseTags', 'ActiveBoxes');
        
        % Perform post-hoc processing on this trial for this mouse
        %---------
        dataproc=dataproc_timeout_format_rev_info(data,pulser,2,timetag,MouseTag,rawdatafiles_all{session},time_params);
        
        % Make structure of data for this box across all sessions
        %---------
        dp_pool{session}=dataproc;
    end
    
    % concatenate data for all sessions into one structure
    dp_cat=concat_sess(dp_pool);
    datafile2=[timetag '_Mouse_' MouseTag '_poolsessions_' SessionTag '_blank'];
    
    % save pooled and processed data for each mouse
    save([datasavedir datafile2],'dp_pool','dp_cat','SessionBox');
    attchdata=[datadir datafile2];
    
    %-------------------
    % Generate and Save Pooled Plots
    %--------------------
    % Count number of types of initiated trials, if higher than one,
    % generate pooled plots (otherwise, no trials were really initiated and
    % nothing to plot
    numtype=length(unique(find(dp_cat.trialtype_tones~=8)));
    
    if numtype>0
        
        % Plot and save lick rate heat maps
        lFig=figure;
        set(lFig, 'Position', [0 0 1800 1200])
        plot_lickrate_poolplot_onlineproc_tn(dp_cat,timetag(1:10),'det_lick')
        
        figfile_lr1=[TypeTrial '_' MouseTag '_day_' timetag '_multiplot_detlick_regen'];
        saveas(lFig,[figdir_pool figfile_lr1],'fig')
        print(lFig,'-djpeg','-r200', [figdir_pool figfile_lr1])
        
        % Plot and save changes in lick rate
        kFig=figure;
        set(kFig, 'Position', [0 0 1800 1200])
        lickrate_learning_barplot_format(dp_cat)
        
        figfile_lr2=[TypeTrial '_' MouseTag '_day_' timetag '_ratebarplot_regen'];
        saveas(kFig,[figdir_pool figfile_lr2],'fig');
        print(kFig,'-djpeg','-r200', [figdir_pool figfile_lr2]);
        
        if email==1
            NoteTitle2=['PooledPlots, Mouse ' MouseTag ', ' NotebookTag]
            % Notebook='TastantTask';
            Tags='data analysis';
            Text=[['Matlab file: ' matlabfile] 10 ...
                timetag(1:10) 10 ...
                [figdir_pool figfile_lr1] 10 ...
                [figdir_pool figfile_lr2] 10 ...
                ['Box ' num2str(Box)] 10 ...
                ['Mouse ' MouseTag] 10 ...
                'Figures for lick rate centered at light on, based on licks detected at arduino, rate calculated over nonoverlapping .2 sec blocks, ' 10 ...
                'Aligned to light on, tone on, and tastant switch' 10 ...
                'Trials with no tone are aligned to end at tone on' 10 ...
                'With timeout' 10 ...
                ['Trial Count = ' num2str(dp_cat.numtrials)] 10 ...
                TypeTrial ];
            
            attchfile_lr{1}=[figdir_pool figfile_lr1 '.jpg'];
            attchfile_lr{2}=[figdir_pool figfile_lr2 '.jpg'];
            send_evernote_append(NoteTitle2, Notebook, Tags, Text, attchfile_lr)
            
        end
        
    end
    
    clear SessionBox data datafile2 attchdata dp_cat dp_pool
    
end

end




