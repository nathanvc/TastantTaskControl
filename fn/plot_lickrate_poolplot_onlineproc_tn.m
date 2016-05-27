% 1/2015, 1/2016
% Nathan V-C
%------------
% plot_lickrate_poolplot_onlineproc_tn
%------------
%------------
% trial by trial lick rate plots, including both 
% "active" (light) and "passive" (tone only) trials
% enter the structure dp_cat from one of the pooled tastant task data files
% daynum should be date tag or number of day in task, used for title
% licktype should be 'det_lick' or 'e_lick' and determines which lick times
% to take (detected online, or posthoc threshold analysis of raw lick
% signal)

function plot_lickrate_poolplot_onlineproc_tn(dp_cat,daynum,licktype)

% identify types of trials included, do not include the light only trials
% (1 sec)
sorttype_all=unique(dp_cat.trialtype_tones);
sorttype=sorttype_all(sorttype_all~=8);
numtype=length(sorttype);
lick_inds=dp_cat.shift_ind.(licktype);
fs=10;

if ~isempty(sorttype)
    figinds=[0:numtype-1]*5;
else
    figinds=1;
end


if numtype>0
% Plot light on only, starting at light on
subplot(numtype,5,figinds+1)
% Only include trials actually run in this plot
s_inds=find(dp_cat.trialtype_tones~=8);
for i=1:length(s_inds)
    s=s_inds(i);
    tempshift{i}=lick_inds{s};
end
plot_LR_day_varbin_formdata(tempshift,zeros(length(tempshift),1), dp_cat.trialtime.total(s_inds), dp_cat.Sfreq, 0.2, dp_cat.trialtime.pretone(s_inds))
title({[dp_cat.mousetag ', Day ' num2str(daynum) ', ' licktype]; 'Trial, align to light on'},'fontsize',fs,'interpreter','none')

clear tempshift s_inds
end

% Plot full light on and off time aligned to light off
if numtype>0
    subplot(numtype,5,figinds+2)
else
    subplot(1,5,2)
end

for i=1:dp_cat.numtrials
    tempshift{i}=lick_inds{i}-dp_cat.shift_ind.liquid_off_ind(i);
end
plot_LR_day_varbin_formdata(tempshift,-dp_cat.trialtime.total, dp_cat.trialtime.to, dp_cat.Sfreq, 0.2, -(dp_cat.trialtime.learning+dp_cat.trialtime.tastant))
title('Trial & TO, alighn to light off','fontsize',fs)

for s=1:length(sorttype)   
    
    clear temp_licks tempshift s_ind sort_inds
    
    s_ind=sorttype(s);
    
    if s_ind==1
        %title({['Mouse ' mice{mouse} ', ' dates{day}],['align to light on']},'fontsize',10)
        ylab='Water';
    elseif s_ind==2
        ylab='Sugar, Tone A';
    elseif s_ind==3
        ylab='Quinine, Tone B';
    elseif s_ind==4
        ylab='Sugar, Tone B';
    elseif s_ind==5
        ylab='Quinine, Tone A';
    elseif s_ind==6
        ylab='Ext, Tone A';
    elseif s_ind==7
        ylab='Ext, Tone B';
    elseif s_ind==9
        ylab='Sug, Tn only, A';
    elseif s_ind==10
        ylab='Quin, Tn only, B';
    elseif s_ind==11
        ylab='Sug, Tn only, B';
    elseif s_ind==12
        ylab='Quin, Tn only, A';
    elseif s_ind==13
        ylab='Catch';   
    end
    
    sort_inds=find(dp_cat.trialtype_tones==s_ind);
    temp_licks={lick_inds{sort_inds}};
    
    % shift times of licks to tone_on
    for i=1:length(temp_licks)
        tempshift{i}=temp_licks{i}-dp_cat.shift_ind.tone_start(sort_inds(i));
    end

    % Plot in order
    subplot(numtype,5,figinds(s)+3)
    plot_LR_day_varbin_formdata(tempshift,-dp_cat.trialtime.pretone(sort_inds), dp_cat.trialtime.learning(sort_inds)+dp_cat.trialtime.tastant(sort_inds), dp_cat.Sfreq, 0.2, dp_cat.trialtime.learning(sort_inds))
    ylabel(ylab,'fontsize',fs)
    if s==1
        title({'Align Tone On';'In order'},'fontsize',fs)
    end
    
    % Plot sorted by time between tone and trigger...
    subplot(numtype,5,figinds(s)+4)
    plot_LR_day_varbin_sort_formdata(tempshift,-dp_cat.trialtime.pretone(sort_inds), dp_cat.trialtime.learning(sort_inds)+dp_cat.trialtime.tastant(sort_inds), dp_cat.Sfreq, 0.2, dp_cat.trialtime.learning(sort_inds), dp_cat.trialtime.learning(sort_inds), 0)
    ylabel(ylab,'fontsize',fs)
    if s==1
        title({'Align Tone On';'Sort by learning time';'Active only'},'fontsize',fs)
    end

    % Plot sorted by lick difficulty
    subplot(numtype,5,figinds(s)+5)
    plot_LR_day_varbin_sort_formdata(tempshift,-dp_cat.trialtime.pretone(sort_inds), dp_cat.trialtime.learning(sort_inds)+dp_cat.trialtime.tastant(sort_inds), dp_cat.Sfreq, 0.2, dp_cat.trialtime.learning(sort_inds), dp_cat.skiplick_cnt(sort_inds), 0)
    ylabel(ylab)
    if s==1
        title({'Align Tone On';'Sort by diff';'Active only'},'fontsize',fs)
    end

end

