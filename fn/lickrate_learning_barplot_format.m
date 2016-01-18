% 1/2015, 1/2016
% Nathan V-C
%------------
% lickrate_learning_barplot_format.m
%------------
% enter the structure dp_cat from one of the pooled tastant task data files
% uses online licks detected by the arduino
% Can be modified to use post-hoc detected licks if needed
% Makes graphs showing changes in lick rate during each trial time phase 
% (pre-tone, learning, post-tastant-switch)
% Plots for full time period and restricted to 1 second pre/post
% Also plots raw lick rates on trial by trial basis
% Used for assessing task output on daily basis, runs directly after task
% data acquisition
% active trials only (does not include tone-only passive trials)
%-------------

function lickrate_learning_barplot_format(dp_cat)

% identify types of trials included, do not include the light only trials
% (1 sec)
sorttype_all=unique(dp_cat.trialtype_tones);
sorttype=sorttype_all(sorttype_all<8);
numtype=length(sorttype);
fs=10; % fontsize for figure

% Join rate information for all trial timepoints into one array (
rate_join_1sec=[dp_cat.trial_det_lick_rate.pretone_1sec' dp_cat.trial_det_lick_rate.learning' dp_cat.trial_det_lick_rate.tastant_1sec'];
rate_join_full=[dp_cat.trial_det_lick_rate.pretone' dp_cat.trial_det_lick_rate.learning' dp_cat.trial_det_lick_rate.tastant'];

if numtype>0

    for i=1:numtype
        
        st=sorttype(i);
        numtr{st}=length(find(dp_cat.trialtype_tones==st));
        
        if st==1
            lab{i}='Wat';
        elseif st==2
            lab{i}='SugA';
        elseif st==3
            lab{i}='QuinB';
        elseif st==4
            lab{i}='SugB';
        elseif st==5
            lab{i}='QuinA';
        elseif st==6
            lab{i}='ExtA';
        elseif st==7
            lab{i}='ExtB';
        end
        
        % Make separate individual rate matrix for each trial type, note that
        % many will be empty
        rate_tr_1sec{st}=rate_join_1sec(find(dp_cat.trialtype_tones==st),:);
        rate_tr_full{st}=rate_join_full(find(dp_cat.trialtype_tones==st),:);
        
        % generate slightly random 'x' points so we can see more easily how
        % many points are at each rate value
        
        clear x_pt
        x_pt=[0.9+0.2*rand(numtr{st},1) 1.9+0.2*rand(numtr{st},1) 2.9+0.2*rand(numtr{st},1)];
        
        % Plot all trial lick rates, where pretone and tastant are taken only
        % over 1 second directly before tone and directly after tastant switch
        subplot(2,numtype+2,i)
        plot(x_pt',rate_tr_1sec{st}','.-','markersize',12)
        hold on
        plot(mean(rate_tr_1sec{st}),'.-','markersize',15,'color','black','linewidth',3)
        if i==1
            title({[dp_cat.mousetag ' ' dp_cat.timetag{1}(1:10)];[lab{i} ', 1sec']})
        else
            title([lab{i} ', 1 sec'])
        end
        xlim([0.5 3.5])
        set(gca,'xtick',1:3)
        set(gca,'xticklabel',{'pretn';'lrn';'tast'})
        ylim([0 15])
        
        % Plot all trial lick rates, where rate is taken over the full time
        % that tastant is available
        subplot(2,numtype+2,numtype+2+i)
        plot(x_pt',rate_tr_full{st}','.-','markersize',12)
        hold on
        plot(mean(rate_tr_full{st}),'.-','markersize',15,'color','black','linewidth',3)
        title([lab{i} ', full time'])
        xlim([0.5 3.5])
        set(gca,'xtick',1:3)
        set(gca,'xticklabel',{'pretn';'lrn';'tast'})
        ylim([0 15])
        
        % Calculate changes in rate compared to water rate prior to tone
        for j=1:3
            rate_diff_1sec{st}(:,j)=rate_tr_1sec{st}(:,j)-rate_tr_1sec{st}(:,1);
            rate_diff_full{st}(:,j)=rate_tr_full{st}(:,j)-rate_tr_full{st}(:,1);
        end
        
    end
    
    % Calculate mean and standard error values for rate changes
    
    for i=1:numtype
        st=sorttype(i);
        mean_rate_diff_1sec_learning(i)=mean(rate_diff_1sec{st}(:,2));
        mean_rate_diff_full_learning(i)=mean(rate_diff_full{st}(:,2));
        mean_rate_diff_1sec_tastant(i)=mean(rate_diff_1sec{st}(:,3));
        mean_rate_diff_full_tastant(i)=mean(rate_diff_full{st}(:,3));
        
        ste_1sec_learning(i)=std(rate_diff_1sec{st}(:,2))/sqrt(numtr{st});
        ste_full_learning(i)=std(rate_diff_full{st}(:,2))/sqrt(numtr{st});
        ste_1sec_tastant(i)=std(rate_diff_1sec{st}(:,3))/sqrt(numtr{st});
        ste_full_tastant(i)=std(rate_diff_full{st}(:,3))/sqrt(numtr{st});
        
    end
    
    % Plot change in lick rate during learning period, where baseline is taken
    % as rate one second prior to tone
    subplot(2,numtype+2,numtype+1)
    color_cell={'y','g','r'};
    for j=1:numtype
        bar(j,mean_rate_diff_1sec_learning(j),color_cell{j})
        hold on
    end
    errorbar(mean_rate_diff_1sec_learning,ste_1sec_learning,'.k')
    set(gca,'xtick',1:3)
    set(gca,'xticklabel',lab)
    ylabel('LR change, Hz')
    title('Learning, 1 sec')
    
    % Plot change in lick rate during tastant period, where baseline is taken
    % as rate one second prior to tone
    subplot(2,numtype+2,numtype+2)
    color_cell={'y','g','r'};
    for i=1:numtype
        bar(i,mean_rate_diff_1sec_tastant(i),color_cell{i})
        hold on
    end
    errorbar(mean_rate_diff_1sec_tastant,ste_1sec_tastant,'.k')
    set(gca,'xtick',1:3)
    set(gca,'xticklabel',lab)
    ylabel('LR change, Hz')
    title('Tastant, 1 sec')
    
    % Plot change in lick rate during tastant period, where baseline is taken
    % as rate over full period of water available one second prior to tone
    subplot(2,numtype+2,numtype*2+2+1)
    color_cell={'y','g','r'};
    for i=1:numtype
        bar(i,mean_rate_diff_full_learning(i),color_cell{i})
        hold on
    end
    errorbar(mean_rate_diff_full_learning,ste_full_learning,'.k')
    set(gca,'xtick',1:3)
    set(gca,'xticklabel',lab)
    ylabel('LR change, Hz')
    title('Learning, full')
    
    % Plot change in lick rate during tastant period, where baseline is taken
    % as rate over full period of water available one second prior to tone
    subplot(2,numtype+2,numtype*2+2+2)
    color_cell={'y','g','r'};
    for i=1:numtype
        bar(i,mean_rate_diff_full_tastant(i),color_cell{i})
        hold on
    end
    errorbar(mean_rate_diff_full_tastant,ste_full_tastant,'.k')
    set(gca,'xtick',1:3)
    set(gca,'xticklabel',lab)
    ylabel('LR change, Hz')
    title('Tastant, full')
    
end


