% Initial data processing for 3 tastant task
%-------------
% Nathan V-C
% 6/2014, 11/2014, 11/2015, 1/2016
% This is processing to be run directly after task
% This version is for the "timeout" version of the 3-tastant task in which
% trial type and timing is selected on the independent arduino box, 
% -----
% This version of the task has no vac, but I am leaving the vac vector in
% (set to zero) b/c later tasks may include vac, and because some other
% plotting code relies on the vac vector
%--------------
% For format_tag=1, Assumes that the data coming in has the following indices:
%--------------
% data(:,1) = detected licks on arduino
% data(:,2) = delivered licks on arduino
% data(:,3) = difficulty of a given trial (width of pulse divided by 50ms is # of licks
% skipped between deliveries, selected at start of each trial)
% data(:,4) = time light on (in original, fluid-on window)
% data(:,5) = time tastant 1 (sucrose) available
% data(:,6) = time tastant 2 (quinine) available
% data(:,7) = analog electric lick signal
% data(:,8) = tone 1 on or raw tone played
% data(:,9) = tone 2 on

% format_tag=0 --> data before multiple boxes set-up (prior to 11/2014)
% format_tag=1 --> data with multiple boxes after 11/2014
% format_tag=2 --> data after 10/30, the difficulty channel also contains
% trial timing information

% time params is structure containing min and max lenght of time for
% pre-tone, learning and post-switch phases of a trial, used to select
% fictional timepoints for the water-only trials, not actually needed for
% format_tag 2, but not yet removed

function dp = dataproc_timeout_format_rev_info(data,pulser,format_tag,timetag,mousetag,rawdatafile,time_params)

% set random number generator seed, so that same random numbers generated
% in same order every time this analysis is run:
rng(mod(str2num(timetag)*str2num(mousetag),2^30));

% step sizes for each data point
%----------------------------------
dp.rawdatafile = rawdatafile;
dp.time_params = time_params;
dp.timetag = timetag;
dp.mousetag = mousetag;
dp.Sfreq = pulser.ni.rate;
dp.step_ms = 1000/pulser.ni.rate;  % timestep in ms
dp.step_s = 1/pulser.ni.rate;  %timestep in secs (1 sec over samples per sec)%
dp.timevect = 0:dp.step_s:(length(data)-1)*dp.step_s; %timevector for total run in seconds
dp.sess_length = length(data);

if format_tag>0;
    dp.data.det_lick=data(:,1);
    dp.data.del_lick=data(:,2);
    dp.data.difficulty=data(:,3);
    dp.data.tr_type_wins_raw=data(:,4:6);
    dp.data.raw_lick=data(:,7);
    if size(data,2)==9
        dp.data.tonesig=data(:,8)+data(:,9);
        dp.data.tonesig_spec=data(:,8:9);
    elseif size(data,2)==8
        dp.data.tonesig=data(:,8);
        dp.data.tonesig_spec=[data(:,8) data(:,8)];
    end
    
% reshape data collected for cohort C5 and before into new format (before 11/14)
else if format_tag==0
        dp.data.det_lick=data(:,10);
        dp.data.del_lick=sum(data(:,[4 5 9]),2);
        dp.data.difficulty=data(:,11);
        dp.data.tr_type_wins_raw=data(:,1:3);
        dp.data.raw_lick=data(:,7);
        dp.data.tonesig=data(:,8);
    end
end

% make discretized version of liquid/tast1/tast2 windows
tr_type_wins=(dp.data.tr_type_wins_raw>2);

% redefine first column of tr_type_wins to be liquid start stop for tone
% only trials -- remember some blank trials for format 3 will not actually
% have liquid delivered though
tr_type_wins(:,1)=sum(tr_type_wins(:,1:3),2)>0.5;

% make vector that indicates what window is active at each timepoint of data
% collection -- sum across when windows are open with indicator 1 for
% trial, 2 for tast1, 4 for tast 2 -- then sum
%---------
% 1 in column 1 but not column 2 & 3 --> water, sum=1
% 1 in column 1 and 2 in column 2 --> tastant 1 (sucrose), sum=3
% 1 in column 1 and 4 in column 3 --> tastant 2 (quinine), sum=5
% if sum is 2 or 4, then only tastant is on and not the liquid window, and that means nothing is
%delivered
%zeros in all columns or entry in only tastant column -->no tastant, sum=0,
%then replace 2 & 4's with zeros
%---------
win_ind_temp=sum(repmat([1 2 4],dp.sess_length,1).*tr_type_wins,2);
win_ind_temp=ismember(win_ind_temp,[1 3 5]).*win_ind_temp;

% Handle timepoints where vac was on, if any
%---
% works for vac on at varying times, provided it runs with no delay -- set
% to 1 when vac is off and 0 when vac is on
% Here, set to 1 because no vac in task, but keep in case need to run vac
% in later version of the task:
%------
vac_ind=ones(size(win_ind_temp));

% Add one to everything, times when vac is on have index of zero -- multiply this to remove
% elements when vac is on (0=vac, 1=timeout, 2=water, 4=tast1, 6=tast2)
dp.fluid_win_ind=(win_ind_temp+1).*vac_ind;

%-----------------------------------------
% indices for when trial starts and stops -- named "liquid on" but remember
% some blank trials will not actually have liquid for format 3 (see
% redefinition below)
%-----------------------------------------

dp.liquid_off_ind=find(diff(tr_type_wins(:,1))==-1);
dp.liquid_on_ind=find(diff(tr_type_wins(:,1))==1);
% if the first liquid on window starts before recording, remove the first
% element of liquid_off_ind
if dp.liquid_off_ind(1)<dp.liquid_on_ind(1)
    dp.liquid_off_ind=dp.liquid_off_ind(2:end);
end
dp.tast1_on_ind=find(diff(tr_type_wins(:,2))==1);
dp.tast2_on_ind=find(diff(tr_type_wins(:,3))==1);
dp.numtrials=length(dp.liquid_off_ind);

%-----------
% Count licks required for delivery
%-----------
% reverse difficulty signal so that we can count falling edge in case rising edge not perfectly aligned with light
% on

% pull out timepoints from the information/difficulty channel
% at trial onset 200ms pulse
% at tone on turns high and turns off at valve switch
% back on at trial end for 50ms*skiplicks
if format_tag==2
    % when is info pulse high?
    dp.info.thresh=(dp.data.difficulty>2);
    % time pulse goes on/off
    dp.info.on_ind=find(diff(dp.info.thresh)==1);
    dp.info.off_ind=find(diff(dp.info.thresh)==-1);

    % on 11/21/15 had a session where box 3 did not fully complete the
    % final info_off, set this last pulse at the last data point available
    if (length(dp.info.on_ind)==length(dp.info.off_ind)+1 && strcmp(timetag,'2015-11-21-16-13-47'))
        dp.info.off_ind(end+1)=length(data);
    end

    % length of each pulse
    dp.info.pulsetime=dp.step_ms.*(dp.info.off_ind-dp.info.on_ind);
    %-------
    % trial starts are the short pulses at start (shortest other possible
    % pulse is 250 for 5 lick skips, so if that ever gets shorter, this
    % will need fixing,
    % index is in the vector of "info" pulses, length of this is number of
    % trials
    dp.info.pulse_trial_st=find(dp.info.pulsetime<230);
    
    % index of trial start in the original data vector
    dp.info.index_trial_start=dp.info.on_ind(dp.info.pulse_trial_st); % this is like "liquid_on_ind"
    % index in vector of "info" pulses for the ending pulse -- pulses right
    % before start pulses
    dp.info.pulse_trial_end=[(dp.info.pulse_trial_st(2:end)-1)' length(dp.info.pulsetime)]';
    % index of trial end in the original data vector
    dp.info.index_trial_end=dp.info.on_ind(dp.info.pulse_trial_end); % this is like "liquid_off_ind"
    %--------
    % difficulty of trial (skiplick cnt) is length of "ending" pulse
    % divided by 50ms
    dp.info.skiplick_cnt=round(dp.info.pulsetime(dp.info.pulse_trial_end)/50); % this is like dp.skiplick_cnt
    % fix final count on last trial session 3, box 3, 11/21/2015
    if strcmp(timetag,'2015-11-21-16-13-47')
        dp.info.skiplick_cnt(57)=20;
    end
    
    %--------
    % active trials will have difference of two between index of start and
    % index of end in the info vector, passive trials will have difference
    % of one, so if subtract 1, 0 indicates passive and 1 indicates active,
    % this vector has length of number of trials
    dp.info.active=dp.info.pulse_trial_end-dp.info.pulse_trial_st-1;
    dp.info.passive=1-dp.info.active;
    % in trial index, this vector gives zero for passive trials and info
    % pulse index for active trials
    dp.info.learning_ind=dp.info.active.*(dp.info.pulse_trial_st+1);
    % in trial index, this gives the starting index for passive 
    % vector with length number of trials that gives tone_on for active
    % trials and zero for passive
    dp.info.index_toneon_active=zeros(size(dp.info.learning_ind));
    %dp.info.index_toneon_active(dp.info.learning_ind>0)=dp.info.on_ind(dp.info.learning_ind>0);
    dp.info.index_toneon_active(dp.info.learning_ind>0)=dp.info.on_ind(dp.info.learning_ind(dp.info.learning_ind>0));
    % vector with length number of trials that gives valve switch for
    % active trials and zero for passive
    dp.info.index_switch_active=zeros(size(dp.info.learning_ind));
    dp.info.index_switch_active(dp.info.learning_ind>0)=dp.info.off_ind(dp.info.learning_ind(dp.info.learning_ind>0));
    %-----------
    % in trial index, this gives the starting index for passive 
    % vector with length number of trials that gives tone_on for active
    % trials and zero for passive
    dp.info.index_toneon_passive=zeros(size(dp.info.learning_ind));
    dp.info.index_toneon_passive(dp.info.passive>0)=dp.info.on_ind(dp.info.pulse_trial_st(dp.info.passive>0));
    dp.info.index_switch_passive=dp.info.index_toneon_passive;
    %-----------
    % combine active and passive trials into same vector
    dp.info.index_toneon=dp.info.index_toneon_active+dp.info.index_toneon_passive; % this is like dp.tone_start
    dp.info.index_switch=dp.info.index_switch_active+dp.info.index_switch_passive; % this is like dp.valve_switch
    %------------
    % save difficulty index to the dp structure
    %------------
    dp.skiplick_cnt=dp.info.skiplick_cnt';
    % Redefine trial start/stop to include blank trials (remember, liquid
    % really means trial start/stop
    dp.liquid_on_ind=dp.info.index_trial_start;
    dp.liquid_off_ind=dp.info.index_trial_end;
    dp.numtrials=length(dp.liquid_off_ind);
    dp.tone_start=dp.info.index_toneon;
    dp.valve_switch=dp.info.index_switch;
    
% "new" format skipped licks are multiples of 50ms 
else if format_tag==1
    if ~isempty(dp.liquid_on_ind)
        for i=1:dp.numtrials-1
            %dp.skiplick_cnt(i)=round(dp.step_ms*length(find(dp.data.difficulty(dp.liquid_off_ind(i):min(dp.liquid_off_ind(i)+round(2/dp.step_s),end))>2))/50);
            dp.skiplick_cnt(i)=round(dp.step_ms*length(find(dp.data.difficulty(dp.liquid_on_ind(i):dp.liquid_on_ind(i+1))>2))/50);
        end
        dp.skiplick_cnt(dp.numtrials)=round(dp.step_ms*length(find(dp.data.difficulty(dp.liquid_on_ind(dp.numtrials):end)>2))/50);
    end
    
% Old format count pulses
elseif format_tag==0;
    if ~isempty(dp.liquid_on_ind)
        rev_sig=5-dp.data.difficulty;
        for i=1:dp.numtrials
            dp.skiplick_cnt(i)=length(thresh_crossing(rev_sig(dp.liquid_on_ind(i):dp.liquid_off_ind(i)),2));
        end
        clear rev_sig
        
    end
    end

end

% %------------
% % find indices of licks detected by the arduino, licks for which delivery
% % was made, and licks & deliveries for each tastant delivery state
% %------------
dp.det_lick_inds.all=thresh_crossing(dp.data.det_lick,2);
dp.del_lick_inds.all=thresh_crossing(dp.data.del_lick,2);

% trial type for detected and delivered lick
% (0=vac,2=water, 4=tast1, 6=tast2)
dp.det_lick_inds.type=dp.fluid_win_ind(dp.det_lick_inds.all);
dp.del_lick_inds.type=dp.fluid_win_ind(dp.del_lick_inds.all);

% detected and delivered licks for water
dp.det_lick_inds.wat=dp.det_lick_inds.all(dp.det_lick_inds.type==2);
dp.del_lick_inds.wat=dp.del_lick_inds.all(dp.del_lick_inds.type==2);

% detected and delivered licks for tast1
dp.det_lick_inds.tast1=dp.det_lick_inds.all(dp.det_lick_inds.type==4);
dp.del_lick_inds.tast1=dp.del_lick_inds.all(dp.del_lick_inds.type==4);

% detected and delivered licks for tast2
dp.det_lick_inds.tast2=dp.det_lick_inds.all(dp.det_lick_inds.type==6);
dp.del_lick_inds.tast2=dp.del_lick_inds.all(dp.del_lick_inds.type==6);

% detected and delivered licks for timeout (no tastant, no light) **or blank
% trials**
dp.det_lick_inds.to=dp.det_lick_inds.all(dp.det_lick_inds.type==1);
dp.del_lick_inds.to=dp.del_lick_inds.all(dp.del_lick_inds.type==1);


%-----------
% count deliveries of each tastant in each trial, total deliveries, and
% total detected (by the arduino) licks for each individual trial
%-----------
for i=1:dp.numtrials
    
    dp.det_lick_count.all(i) = length(find(dp.det_lick_inds.all>dp.liquid_on_ind(i) & dp.det_lick_inds.all<dp.liquid_off_ind(i)==1));
    dp.del_lick_count.all(i) = length(find(dp.del_lick_inds.all>dp.liquid_on_ind(i) & dp.del_lick_inds.all<dp.liquid_off_ind(i)==1));
    
    dp.det_lick_count.wat(i) = length(find(dp.det_lick_inds.wat>dp.liquid_on_ind(i) & dp.det_lick_inds.wat<dp.liquid_off_ind(i)==1));
    dp.del_lick_count.wat(i) = length(find(dp.del_lick_inds.wat>dp.liquid_on_ind(i) & dp.del_lick_inds.wat<dp.liquid_off_ind(i)==1));
    
    dp.det_lick_count.tast1(i) = length(find(dp.det_lick_inds.tast1>dp.liquid_on_ind(i) & dp.det_lick_inds.tast1<dp.liquid_off_ind(i)==1));
    dp.del_lick_count.tast1(i) = length(find(dp.del_lick_inds.tast1>dp.liquid_on_ind(i) & dp.del_lick_inds.tast1<dp.liquid_off_ind(i)==1));
    
    dp.det_lick_count.tast2(i) = length(find(dp.det_lick_inds.tast2>dp.liquid_on_ind(i) & dp.det_lick_inds.tast2<dp.liquid_off_ind(i)==1));
    dp.del_lick_count.tast2(i) = length(find(dp.del_lick_inds.tast2>dp.liquid_on_ind(i) & dp.del_lick_inds.tast2<dp.liquid_off_ind(i)==1));
    
    % licks not during fluid delivery (del_lick had better be zero!)
    dp.det_lick_count.blank(i) = length(find(dp.det_lick_inds.to>dp.liquid_on_ind(i) & dp.det_lick_inds.to<dp.liquid_off_ind(i)==1));
    dp.del_lick_count.blank(i) = length(find(dp.del_lick_inds.to>dp.liquid_on_ind(i) & dp.del_lick_inds.to<dp.liquid_off_ind(i)==1));    
    
    % for liquid off period just after a given trial -- this is most
    % relevant to the trial that comes right before (mice have to stop
    % licking before, but might keep licking after) -- del_lick had better
    % be zero!
    if i<dp.numtrials
        dp.det_lick_count.to(i) = length(find(dp.det_lick_inds.to>dp.liquid_off_ind(i) & dp.det_lick_inds.to<dp.liquid_on_ind(i+1)==1));
        dp.del_lick_count.to(i) = length(find(dp.del_lick_inds.to>dp.liquid_off_ind(i) & dp.del_lick_inds.to<dp.liquid_on_ind(i+1)==1));
        
    else if i==dp.numtrials
            dp.det_lick_count.to(i) = length(find(dp.det_lick_inds.to>dp.liquid_off_ind(i)==1));
            dp.del_lick_count.to(i) = length(find(dp.del_lick_inds.to>dp.liquid_off_ind(i)==1));
        end
    end
    
end


%Total Time in seconds for liquid, tastant 1, tastant 2, water only
%available (not including any vac time)
%--------------------
dp.timeavail.liquid=(length(find(dp.fluid_win_ind>1)))*dp.step_s;
dp.timeavail.tast1=(length(find(dp.fluid_win_ind==4)))*dp.step_s;
dp.timeavail.tast2=(length(find(dp.fluid_win_ind==6)))*dp.step_s;
dp.timeavail.water=(length(find(dp.fluid_win_ind==2)))*dp.step_s;
dp.timeavail.noliquid=(length(find(dp.fluid_win_ind==1)))*dp.step_s;

%---------------------
% Posthoc Elick processing -- in case lick detection on arduino is off --
% can change threshold to get better lick rates (but reward delivery will
% be shifted) -- timing for lick start will also be more accurate
%---------------------

% indices for start of a lick, measured from electrical signal (diff
% threshold of 4 on the arduino)
if format_tag>0
    dp.elick_ind.all=elick_threshpts_rev_diff_cut_10000_invert(dp.data.raw_lick,dp.Sfreq)';
    else if format_tag==0
        %dp.elick_ind.all=elick_threshpts_rev_diff_cut_lower(dp.data.raw_lick,dp.Sfreq)';
        dp.elick_ind.all=elick_threshpts_rev_thresh_superlow(dp.data.raw_lick,dp.Sfreq)';
    end
end

% multiply by vector of lick type (with zero when vac is active)
dp.elick_ind.type=dp.fluid_win_ind(dp.elick_ind.all);

%------
%------

% posthoc elicks for water
dp.elick_ind.wat=dp.elick_ind.all(dp.elick_ind.type==2);

% posthoc elicks for tast1
dp.elick_ind.tast1=dp.elick_ind.all(dp.elick_ind.type==4);

% posthoc elicks for tast2
dp.elick_ind.tast2=dp.elick_ind.all(dp.elick_ind.type==6);

% posthoc elicks for timeout (no tastant, no light)
dp.elick_ind.to=dp.elick_ind.all(dp.elick_ind.type==1);

%-----------
% count posthoc elick inds for each tastant in each trial, total deliveries, and
% total detected (by the arduino) licks for each individual trial
%-----------
for i=1:dp.numtrials
    dp.elick_count.all(i) = length(find(dp.elick_ind.all>dp.liquid_on_ind(i) & dp.elick_ind.all<dp.liquid_off_ind(i)==1));
    dp.elick_count.wat(i) = length(find(dp.elick_ind.wat>dp.liquid_on_ind(i) & dp.elick_ind.wat<dp.liquid_off_ind(i)==1));
    dp.elick_count.tast1(i) = length(find(dp.elick_ind.tast1>dp.liquid_on_ind(i) & dp.elick_ind.tast1<dp.liquid_off_ind(i)==1));
    dp.elick_count.tast2(i) = length(find(dp.elick_ind.tast2>dp.liquid_on_ind(i) & dp.elick_ind.tast2<dp.liquid_off_ind(i)==1));
    dp.elick_count.tast2(i) = length(find(dp.elick_ind.tast2>dp.liquid_on_ind(i) & dp.elick_ind.tast2<dp.liquid_off_ind(i)==1));
    dp.elick_count.blank(i) = length(find(dp.elick_ind.to>dp.liquid_on_ind(i) & dp.elick_ind.to<dp.liquid_off_ind(i)==1));
    
    % timeout is licks in "off" period *after* a given trial
    if i<dp.numtrials
        dp.elick_count.to(i) = length(find(dp.elick_ind.to>dp.liquid_off_ind(i) & dp.elick_ind.to<dp.liquid_on_ind(i+1)==1));
    else if i==dp.numtrials
            dp.elick_count.to(i) = length(find(dp.elick_ind.to>dp.liquid_on_ind(i)==1));
        end
    end
    
end

%-------
%-------

%calculate average elick rate in each window type, over full time tastant
%is available
dp.elickrate_avg.liquid=length(find(dp.elick_ind.type>1))/dp.timeavail.liquid;
dp.elickrate_avg.tast1=length(find(dp.elick_ind.type==4))/dp.timeavail.tast1;
dp.elickrate_avg.tast2=length(find(dp.elick_ind.type==6))/dp.timeavail.tast2;
dp.elickrate_avg.water=length(find(dp.elick_ind.type==2))/dp.timeavail.water;
dp.elickrate_avg.noliquid=length(find(dp.elick_ind.type==1))/dp.timeavail.noliquid;

%--------------------------
% Trial type and cue timing
%--------------------------
% type of trial (2=water (no tone), 4=sucrose, 6=quinine, 1=blank)
% back up a bit from end of trial when tone is definitely on -- right at
% end is the start of data kicked out due to vac
trialtype_tast=dp.fluid_win_ind(dp.liquid_off_ind-5);

% trial type matrix for active vs passive task, if 2 near start active, if
% 1, 4 or 6 then passive (1 is blank)
trialtype_actpass=dp.fluid_win_ind(dp.liquid_on_ind+5);

% time for light on (additional "trialtime" entries below, after defining
% cue and switch timing)
dp.trialtime.total=(dp.liquid_off_ind-dp.liquid_on_ind)*dp.step_s;

%----------
% Redefine trial types based on which tone is playing
%----------
if ~isempty(dp.liquid_on_ind)
    if format_tag==0
        % Find trials with tone_on & determine tone pitch
        trial_tone_inds=repmat(dp.liquid_off_ind-100,1,100)+repmat(1:100',length(dp.liquid_off_ind),1);
        for i=1:length(dp.liquid_off_ind)
            % diff tone = 6 --> tone 1 (lower pitch, orig paired with suc)
            % diff tone = 2 --> tone 2 (higher pitch, orig paired with quin)
            diff_tone(i)=floor(mean(diff(thresh_crossing(dp.data.tonesig(trial_tone_inds(i,:)),.5))));
        end
        diff_tone(isnan(diff_tone))=0;
    end
    
    if format_tag>0
        trial_tone_inds=repmat(dp.liquid_off_ind-1000,1,1000)+repmat(1:1000',length(dp.liquid_off_ind),1);
        for i=1:length(dp.liquid_off_ind)
            dt_1=mean(dp.data.tonesig_spec(trial_tone_inds(i,:),1));
            dt_2=mean(dp.data.tonesig_spec(trial_tone_inds(i,:),2));
            if dt_1>2 && dt_2<2
                diff_tone(i) = 6;
            elseif dt_1<2 && dt_2>2
                diff_tone(i) = 2;
            elseif dt_1<2 && dt_2<2
                diff_tone(i)=0;
            end
        end
    end
    
    dp.trialtype_tones=trialtype_tast;
    
    % for original trial type with water first, then tone, then tastant (active):
    %------------
    % water only (no tone)
    dp.trialtype_tones(trialtype_tast==2 & diff_tone'==0 & dp.trialtime.total>=1.2 & trialtype_actpass==2)=1;
    % sucrose/tast1 with tone 1
    dp.trialtype_tones(trialtype_tast==4 & diff_tone'==6 & trialtype_actpass==2)=2;
    % quinine/tast2 with tone 2
    dp.trialtype_tones(trialtype_tast==6 & diff_tone'==2 & trialtype_actpass==2)=3;
    % sucrose/tast1 with tone 2
    dp.trialtype_tones(trialtype_tast==4 & diff_tone'==2 & trialtype_actpass==2)=4;
    % quinine/tast2 with tone 1
    dp.trialtype_tones(trialtype_tast==6 & diff_tone'==6 & trialtype_actpass==2)=5;
    % water with tone 1
    dp.trialtype_tones(trialtype_tast==2 & diff_tone'==6 & trialtype_actpass==2)=6;
    % water with tone 2
    dp.trialtype_tones(trialtype_tast==2 & diff_tone'==2 & trialtype_actpass==2)=7;
    % water only, not a real trial (no lick before 1 second) -- really
    % should be <1 second, but boost up to avoid accidentally counting
    % trials off by a data step or two
    dp.trialtype_tones(trialtype_tast==2 & diff_tone'==0 & dp.trialtime.total<1.2 & trialtype_actpass==2)=8;
    
    % for passive trial type, where tone on and tastant available from
    % trial onset
    %-----------
    % sucrose/tast1 with tone 1
    dp.trialtype_tones(trialtype_tast==4 & diff_tone'==6 & trialtype_actpass>2)=9;
    % quinine/tast2 with tone 2
    dp.trialtype_tones(trialtype_tast==6 & diff_tone'==2 & trialtype_actpass>2)=10;
    % sucrose/tast1 with tone 2
    dp.trialtype_tones(trialtype_tast==4 & diff_tone'==2 & trialtype_actpass>2)=11;
    % quinine/tast2 with tone 1
    dp.trialtype_tones(trialtype_tast==6 & diff_tone'==6 & trialtype_actpass>2)=12;
    % blank passive trial, no tastant delivered (not even water), no tone
    % played
    dp.trialtype_tones(trialtype_tast==1 & diff_tone'==0 & trialtype_actpass==1)=13;
    
    % -------
    if format_tag < 2
        
        % time of tastant switch to sugar or quinine
        %-------
        % for non-initiated trials (1 sec of water only), set valve switch to
        % trial end time (light off)
        % for water only trials with no switch, select a fake tone time
        % incremented ahead of either the real (in the case of tone extinction
        % trials) or "fake" tone on (for water only with no tone) -- need to be
        % careful to pick the fake time consistent with the actual length of
        % the trial
        
        % valve switch time for tastant 1 active trials
        if ~isempty(dp.tast1_on_ind)
            dp.valve_switch(dp.trialtype_tones==2 | dp.trialtype_tones==4 | dp.trialtype_tones==9 | dp.trialtype_tones==11)=dp.tast1_on_ind;
        end
        
        % valve switch time for tastant 2 active trials
        if ~isempty(dp.tast2_on_ind)
            dp.valve_switch(dp.trialtype_tones==3 | dp.trialtype_tones==5 | dp.trialtype_tones==10 | dp.trialtype_tones==12 )=dp.tast2_on_ind;
        end
        
        % for water only active trials, if format 0 or 1, without timing info in the
        % "difficulty channel, then randomly pick times
        if format_tag<2
            % Choose random valve switch time for water only trials
            wat_inds=find(dp.trialtype_tones==1); % time for trial type 6 & 7 needs to be defined *after* tone_start
            for j=1:length(wat_inds)
                tr=wat_inds(j);
                tr_length=round(1000*dp.trialtime.total(tr));
                [r_t1(j), r_t2(j),~]=wateronly_tp(tr_length,time_params);
                dp.valve_switch(tr)=dp.liquid_on_ind(tr)+round(r_t2(j)/dp.step_ms);
            end
        end
        
        %    % for water only active trials and for blank passive trials
        %    if format_tag==2
        %         % Choose random valve switch time for water only trials
        %         dp.valve_switch(dp.trialtype_tones==1 | dp.trialtype_tones==13) = ...
        %             dp.info.index_switch(dp.trialtype_tones==1 | dp.trialtype_tones==13);
        %    end
        
        % Define valve switch as trial end for non-initiated trials
        dp.valve_switch(dp.trialtype_tones==8)=dp.liquid_off_ind(dp.trialtype_tones==8);
        
        % Dimensions are annoyingly wrong later
        if size(dp.valve_switch,1)<size(dp.valve_switch,2)
            dp.valve_switch=dp.valve_switch';
        end
        
        % Identify tone start time (by pulling out big gaps in the tone signal)
        %------
        % For trials where there is a tone, the tone start is the real tone start
        % For catch trials with only water, the "tone start" is set to a random
        % index with the proper timing (defined by time_params)
        % for trials that are not truly initiated (water only, <1 sec, no
        % detected licks) set "tone start" to "light off" trial end time
        
        tone_sig_temp=thresh_crossing(dp.data.tonesig,1);
        tone_sig_bigdiff_temp=find(diff(tone_sig_temp)>100);
        
        % tone start time, all trials that are not active water trials (1), no
        % trial (0), or non-initiated active trials (8) or blank trials (13) This should define
        % tone-on for passive trials also
        if numel(tone_sig_temp)>0
            dp.tone_start(dp.trialtype_tones~=1 & dp.trialtype_tones~=0 & dp.trialtype_tones~=8 & dp.trialtype_tones~=13)=[tone_sig_temp(1),tone_sig_temp(tone_sig_bigdiff_temp+1)'];
        end
        
        % tone start time for water only trials
        if format_tag==0
            faketime_learn=time_params.int_range(1)+(time_params.int_range(2)-time_params.int_range(1)).*rand(size(find(dp.trialtype_tones==1)));
            dp.tone_start(dp.trialtype_tones==1)=dp.valve_switch(dp.trialtype_tones==1)-round(faketime_learn./dp.step_s);
        elseif format_tag==1
            if ~isempty(wat_inds)
                dp.tone_start(dp.trialtype_tones==1)=dp.liquid_on_ind(dp.trialtype_tones==1)+round(r_t1'./dp.step_ms);
            end
            %     elseif format_tag==2
            %         dp.tone_start(dp.trialtype_tones==1 | dp.trialtype_tones==13) = ...
            %             dp.info.index_toneon(dp.trialtype_tones==1 | dp.trialtype_tones==13);
        end
        
        % set tone start to trial end for non-initiated trials
        dp.tone_start(dp.trialtype_tones==8)=dp.liquid_off_ind(dp.trialtype_tones==8);
        
        % dimensions are annoyingly wrong later on...
        if size(dp.tone_start,1)<size(dp.tone_start,2)
            dp.tone_start=dp.tone_start';
        end
        
        % Now define the fake valve timing for water & tone trials
        % (extinction for active case)
        if format_tag==0
            faketime_learn2=time_params.int_range(1)+(time_params.int_range(2)-time_params.int_range(1)).*rand(size(find(dp.trialtype_tones==6 | dp.trialtype_tones==7)));
            dp.valve_switch(dp.trialtype_tones==6 | dp.trialtype_tones==7)=dp.tone_start(dp.trialtype_tones==6 | dp.trialtype_tones==7)+round(faketime_learn2./dp.step_s);
        elseif format_tag==1
            faketime_learn2=time_params.int_range(1)+(time_params.int_range(2)-time_params.int_range(1)).*rand(size(find(dp.trialtype_tones==6 | dp.trialtype_tones==7)));
            dp.valve_switch(dp.trialtype_tones==6 | dp.trialtype_tones==7)=dp.tone_start(dp.trialtype_tones==6 | dp.trialtype_tones==7)+round(faketime_learn2./dp.step_s);
            %     elseif format_tag==2
            %         dp.valve_switch(dp.trialtype_tones==6 | dp.trialtype_tones==7)=dp.info.index_switch(dp.trialtype_tones==6 | dp.trialtype_tones==7);
        end
        
        clear tone_sig_temp tone_sig_bigdiff
        
    end

    %dp.trialtime.total=(dp.liquid_off_ind-dp.liquid_on_ind)*dp.step_s;
    dp.trialtime.pretone=(dp.tone_start-dp.liquid_on_ind)*dp.step_s;
    dp.trialtime.learning=(dp.valve_switch-dp.tone_start)*dp.step_s;
    dp.trialtime.tastant=(dp.liquid_off_ind-dp.valve_switch)*dp.step_s;
    % time is for timeout period *after* the trial
    dp.trialtime.to=(dp.liquid_on_ind(2:end)-dp.liquid_off_ind(1:(end-1)))*dp.step_s;
    dp.trialtime.to(dp.numtrials)=(dp.sess_length-dp.liquid_off_ind(end))*dp.step_s;
    dp.trialtime.baseline=dp.liquid_on_ind(1)*dp.step_s; %amount of time before first trial
end

%-----------
% Calculate lick rates in each trial
%-----------
for i=1:dp.numtrials
    
    %-----------
    % Calculate lick rate in each trial time window, full time period,
    % arduino detected licks
    %-----------
    
    dp.trial_det_lick_rate.pretone(i) = length(find(dp.det_lick_inds.all>dp.liquid_on_ind(i) & dp.det_lick_inds.all<dp.tone_start(i)==1))/dp.trialtime.pretone(i);
    dp.trial_det_lick_rate.learning(i) = length(find(dp.det_lick_inds.all>dp.tone_start(i) & dp.det_lick_inds.all<dp.valve_switch(i)==1))/dp.trialtime.learning(i);
    dp.trial_det_lick_rate.tastant(i) = length(find(dp.det_lick_inds.all>dp.valve_switch(i) & dp.det_lick_inds.all<dp.liquid_off_ind(i)==1))/dp.trialtime.tastant(i);
    if i<dp.numtrials
        dp.trial_det_lick_rate.to(i) = length(find(dp.det_lick_inds.all>dp.liquid_off_ind(i) & dp.det_lick_inds.all<dp.liquid_on_ind(i+1)==1))/dp.trialtime.to(i);
    elseif i==dp.numtrials
        dp.trial_det_lick_rate.to(i) = length(find(dp.det_lick_inds.all>dp.liquid_off_ind(i)))/dp.trialtime.to(i);
    end
    dp.trial_det_lick_rate.pretone_1sec(i)=length(find(dp.det_lick_inds.all>(dp.tone_start(i)-dp.Sfreq) & dp.det_lick_inds.all<dp.tone_start(i)==1));
    dp.trial_det_lick_rate.tastant_1sec(i)=length(find(dp.det_lick_inds.all>dp.valve_switch(i) & dp.det_lick_inds.all<(dp.valve_switch(i)+dp.Sfreq)==1));
    
    %-----------
    % Calculate lick rate in each trial time window, full time period,
    % post-hoc detected lick
    %-----------
    
    dp.trial_elick_rate.pretone(i) = length(find(dp.elick_ind.all>dp.liquid_on_ind(i) & dp.elick_ind.all<dp.tone_start(i)==1))/dp.trialtime.pretone(i);
    dp.trial_elick_rate.learning(i) = length(find(dp.elick_ind.all>dp.tone_start(i) & dp.elick_ind.all<dp.valve_switch(i)==1))/dp.trialtime.learning(i);
    dp.trial_elick_rate.tastant(i) = length(find(dp.elick_ind.all>dp.valve_switch(i) & dp.elick_ind.all<dp.liquid_off_ind(i)==1))/dp.trialtime.tastant(i);
    if i<dp.numtrials
        dp.trial_elick_rate.to(i) = length(find(dp.elick_ind.all>dp.liquid_off_ind(i) & dp.elick_ind.all<dp.liquid_on_ind(i+1)==1))/dp.trialtime.to(i);
    elseif i==dp.numtrials
        dp.trial_elick_rate.to(i) = length(find(dp.elick_ind.all>dp.liquid_off_ind(i)))/dp.trialtime.to(i);
    end
    dp.trial_elick_rate.pretone_1sec(i)=length(find(dp.elick_ind.all>(dp.tone_start(i)-dp.Sfreq) & dp.elick_ind.all<dp.tone_start(i)==1));
    dp.trial_elick_rate.tastant_1sec(i)=length(find(dp.elick_ind.all>dp.valve_switch(i) & dp.elick_ind.all<(dp.valve_switch(i)+dp.Sfreq)==1));
    
end

%-----------------
% Over all trials, calculate index for each event after light on
% for that trial
%-----------------

dp.shift_ind.tone_start=dp.tone_start-dp.liquid_on_ind;
dp.shift_ind.valve_switch=dp.valve_switch-dp.liquid_on_ind;
dp.shift_ind.liquid_off_ind=dp.liquid_off_ind-dp.liquid_on_ind;

for i=1:dp.numtrials
    if i==dp.numtrials
        dp.shift_ind.det_lick{i} = dp.det_lick_inds.all(find(dp.det_lick_inds.all>=dp.liquid_on_ind(i) == 1))-dp.liquid_on_ind(i);
        dp.shift_ind.elick{i} = dp.elick_ind.all(find(dp.elick_ind.all>=dp.liquid_on_ind(i) == 1))-dp.liquid_on_ind(i);
        dp.shift_ind.del_lick{i} = dp.del_lick_inds.all(find(dp.del_lick_inds.all>=dp.liquid_on_ind(i) == 1))-dp.liquid_on_ind(i);
    else
        dp.shift_ind.det_lick{i} = dp.det_lick_inds.all(find(dp.det_lick_inds.all>=dp.liquid_on_ind(i) & dp.det_lick_inds.all<dp.liquid_on_ind(i+1) == 1))-dp.liquid_on_ind(i);
        dp.shift_ind.elick{i} = dp.elick_ind.all(find(dp.elick_ind.all>=dp.liquid_on_ind(i) & dp.elick_ind.all<dp.liquid_on_ind(i+1) == 1))-dp.liquid_on_ind(i);
        dp.shift_ind.del_lick{i} = dp.del_lick_inds.all(find(dp.del_lick_inds.all>=dp.liquid_on_ind(i) & dp.del_lick_inds.all<dp.liquid_on_ind(i+1) == 1))-dp.liquid_on_ind(i);
    end
end


