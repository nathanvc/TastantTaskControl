% input cell array of processed data for each session, output data
% concatenated into full day's data for that mout
% Nathan V-C  1/2015
% Included data has to be data that can be considered trial-by-trial, not
% indexed data

function dp_cat=concat_sess(dp_pool)

dp_cat.mousetag=dp_pool{1}.mousetag;
dp_cat.Sfreq=dp_pool{1}.Sfreq;
dp_cat.step_ms=dp_pool{1}.step_ms;
dp_cat.step_s=dp_pool{1}.step_s;
dp_cat.rawdatafile{1}=dp_pool{1}.rawdatafile;
dp_cat.timetag{1}=dp_pool{1}.timetag;
dp_cat.numsessions=length(dp_pool);

%initialize for concatenating
dp_cat.numtrials=dp_pool{1}.numtrials;
dp_cat.session_numtrials=dp_pool{1}.numtrials;
dp_cat.skiplick_cnt=dp_pool{1}.skiplick_cnt;
dp_cat.trialtype_tones=dp_pool{1}.trialtype_tones';
dp_cat.shift_ind.tone_start=dp_pool{1}.shift_ind.tone_start';
dp_cat.shift_ind.valve_switch=dp_pool{1}.shift_ind.valve_switch';
dp_cat.shift_ind.liquid_off_ind=dp_pool{1}.shift_ind.liquid_off_ind';

% define fieldnames for count of delivered licks
% define fieldnames for the timing structure
fnames_del=fieldnames(dp_pool{1}.del_lick_count);

% initialize trialtime for concatenation
for f=1:length(fnames_del)
    fname=fnames_del{f};
    dp_cat.del_lick_count.(fname)=dp_pool{1}.del_lick_count.(fname);
end

% define fieldnames for the timing structure
fnames_tm=fieldnames(dp_pool{1}.trialtime);

% initialize trialtime for concatenation
for f=1:length(fnames_tm)
    fname=fnames_tm{f};
    dp_cat.trialtime.(fname)=dp_pool{1}.trialtime.(fname)';
end

%define fieldnames for the structures that include rate information
fnames_rt=fieldnames(dp_pool{1}.trial_det_lick_rate);

% initialize rates for concatenation
for f=1:length(fnames_rt)
    fname=fnames_rt{f};
    dp_cat.trial_det_lick_rate.(fname)=dp_pool{1}.trial_det_lick_rate.(fname);
    dp_cat.trial_elick_rate.(fname)=dp_pool{1}.trial_elick_rate.(fname);
end

% define fieldnames for the shifted lick times
fnames_shift=fieldnames(dp_pool{1}.shift_ind);

% initialize shifted lick times -- note only loop through field names that
% are cells here (the ones that include a variable number of lick times)
for f=4:length(fnames_shift)
    fname=fnames_shift{f};
    dp_cat.shift_ind.(fname)=dp_pool{1}.shift_ind.(fname);
    dp_cat.shift_ind.(fname)=dp_pool{1}.shift_ind.(fname);
end

% Initialize field that includes number of trials for each session

for i=2:length(dp_pool)
    dp_cat.rawdatafile{i}=dp_pool{i}.rawdatafile;
    dp_cat.timetag{i}=dp_pool{i}.timetag;
    %dp_cat.liquid_on_ind=cat(2,dp_cat.liquid_on_ind,dp_pool{i}.liquid_on_ind');
    %dp_cat.liquid_off_ind=cat(2,dp_cat.liquid_off_ind,dp_pool{i}.liquid_off_ind');
    dp_cat.numtrials=sum([dp_cat.numtrials dp_pool{i}.numtrials]);
    dp_cat.skiplick_cnt=cat(2,dp_cat.skiplick_cnt,dp_pool{i}.skiplick_cnt);
    dp_cat.trialtype_tones=cat(2,dp_cat.trialtype_tones,dp_pool{i}.trialtype_tones');
    
    dp_cat.shift_ind.tone_start=cat(2, dp_cat.shift_ind.tone_start,dp_pool{i}.shift_ind.tone_start');
    dp_cat.shift_ind.valve_switch=cat(2, dp_cat.shift_ind.valve_switch,dp_pool{i}.shift_ind.valve_switch');
    dp_cat.shift_ind.liquid_off_ind=cat(2, dp_cat.shift_ind.liquid_off_ind,dp_pool{i}.shift_ind.liquid_off_ind');
    
    dp_cat.session_numtrials=[dp_cat.session_numtrials dp_pool{i}.numtrials];
    
    for f=1:length(fnames_del)
        fname=fnames_del{f};
        dp_cat.del_lick_count.(fname)=cat(2, dp_cat.del_lick_count.(fname), dp_pool{i}.del_lick_count.(fname));
    end
    
    
    for f=1:length(fnames_tm)
        fname=fnames_tm{f};
        dp_cat.trialtime.(fname)=cat(2, dp_cat.trialtime.(fname), dp_pool{i}.trialtime.(fname)');
    end
    
    for f=1:length(fnames_rt)
        fname=fnames_rt{f};
        dp_cat.trial_det_lick_rate.(fname)=cat(2, dp_cat.trial_det_lick_rate.(fname), dp_pool{i}.trial_det_lick_rate.(fname));
        dp_cat.trial_elick_rate.(fname)=cat(2, dp_cat.trial_elick_rate.(fname), dp_pool{i}.trial_elick_rate.(fname));
    end
    
    for f=4:length(fnames_shift)
        fname=fnames_shift{f};
        dp_cat.shift_ind.(fname)=[dp_cat.shift_ind.(fname) dp_pool{i}.shift_ind.(fname)];
    end
    
end
    