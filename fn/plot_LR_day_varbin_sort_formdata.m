% Nathan V-C
% 1/15-1/16
%-----------
% plot_LR_day_varbin_sort_formdata.m
%-----------
% Plot aligned lick rate for single day of multi-tastant task
% SORTED by the input vector sort_vect
% use this to sort by difficulty, lick rate, any parameter that can be
% ordered on a trial-by-trial basis
% Can also indicate (using cut_ind) whether to cut trials with very low
% lick rate
%-----------
% Day and mouse need to be specified in the inputs (i.e. time_start_tr is
% probably time_start_tr{day}{mouse} (which is then a cell containing
% session information)


function plot_LR_day_varbin_sort_formdata(lick_shift_all,time_start_tr,time_end_tr,Sfreq,b_width,extramarker,sortvect,cut_ind)

[~, sorted_index]=sort(sortvect);

% find longest and shortest trial times per session and over whole day (necessary b/c
% timing is random
day_st=min(time_start_tr);
day_end=max(time_end_tr);

k=1;
centers=(floor(day_st)+.5*b_width):b_width:(ceil(day_end)-0.5*b_width);

% Amount of time for each index step, calculated from sampling
% frequency
step_s=1/Sfreq;

sp_count_trial=cellfun(@length,lick_shift_all);
% Trials to cut for low spike rate, if indicator is 1 in command line
if cut_ind==1
    trial_keep= sp_count_trial>5;
    lick_shift_all_cut=lick_shift_all(trial_keep);
    time_start_tr=time_start_tr(trial_keep);
    time_end_tr=time_end_tr(trial_keep);
    extramarker=extramarker(trial_keep);
    sorted_index=sorted_index(trial_keep);
    
    % rename so everything below runs
    lick_shift_all=lick_shift_all_cut;
    
    [~, sorted_index]=sort(sortvect(trial_keep));
end
    
%******
% Reorder inputs based on sorted vector, only the trials that are kept
%******

lick_shift_all_reord=lick_shift_all(sorted_index);
time_start_tr=time_start_tr(sorted_index);
time_end_tr=time_end_tr(sorted_index);
extramarker=extramarker(sorted_index);

% rename so everything below runs
lick_shift_all=lick_shift_all_reord;

    for trial=1:length(sorted_index)
        clear lick_trial type_trial
        % convert to times in secs
        lick_trial=step_s*lick_shift_all{trial};
        
        % lick rate in bin in Hz (note first bin after start and
        % last before end for that trial will have artificially low
        % rates -- this is written to center exactly at the
        % alignment time -- one bin on each side of the line
        [bin_lick(k,:),xout]=hist(lick_trial,centers);
        
        k=k+1;
    end

         
%calculate lick rate
bin_lick_rate=1/b_width*bin_lick;

%--------
%Plot lick rate heat mat
%--------
%make heat map, colorbar in Hz
imagesc(xout,1:k-1,bin_lick_rate,[0 15])
% set y direction so trial 1 is at bottom
set(gca,'YDir','normal')
%colorbar('location','southoutside')

% Loop through each trial, 
% using patch to block out parts that are not that trial
%------------------
k=1;
    for trial=1:length(lick_shift_all)
        if iscell(time_start_tr)
            st_patch=time_start_tr(trial);
            end_patch=time_end_tr(trial);
        else
            st_patch=time_start_tr(trial);
            end_patch=time_end_tr(trial);
        end
        if ~isempty(extramarker)
            markerpt=extramarker(trial);
        else markerpt=[];
        end
        l_patch=floor(day_st);
        r_patch=ceil(day_end);
        patch([l_patch l_patch st_patch st_patch],[k-.5 k+.5 k+.5 k-.5],[1 1 1],'edgecolor',[1 1 1])
        patch([r_patch r_patch end_patch end_patch],[k-.5 k+.5 k+.5 k-.5],[1 1 1],'edgecolor',[1 1 1])
        if ~isempty(markerpt)
            line([markerpt markerpt],[k-.5 k+.5],'color','magenta','linewidth',2)
        end
        k=k+1;
    end


line([0 0],[0 k+.5],'color','black','linewidth',1)
        