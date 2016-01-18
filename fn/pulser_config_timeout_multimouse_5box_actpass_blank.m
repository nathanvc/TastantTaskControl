% Pulser Configuration File
% --------------
% 3 tastant task
% For session where trial type is generated on arduino itself
% Generates an analog signal that cues trial type when read into the
% arduino
% Nathan V-C 4/2014, 7/2014, 11/2014

% input a vector that indicates active boxes
% e.g. if 1 & 3 are running: [1 3] (max boxes right now is 5)
% input a cell with string indicating session type for each mouse, must be
% as long as number of mice run
%-------------------
% Proportions of trials are hard-coded
%-------------------
% No tastant
%-------------
% 'Shape' -- all water, no tones, with requirement for lick before 1000ms
% to keep trial
% 'Shape_easy' - do not have to lick before 1000ms
% 'notrial' -- no voltage input, no trials are initiated, need this for
% when running multiple mice, and one mouse stops before others
%--------------------
% 2-tastant:
%------------
% '2tast_orig' -- tone1 with sucrose, tone 2 with quin
% '2tast_pair_cb' -- tone 2 with sucrose, tone 1 with quin, for reversal or for counterbalancing original exposure
% '2tast_ext' -- 2 tones, but both paired with water for extinction
%------------
% 1-tastant:
%------------
% 'Sonly_orig' -- tone 1 paired with sucrose only
% 'Qonly_orig' -- tone 2 paired with quinine only
% 'Sonly_cb' -- tone 2 paired with sucrose only
% 'Qonly_cb' -- tone 1 paired with quinine only
% 'Tone1_ext -- tone 1 with water
% 'Tone2_ext -- tone 2 with water
%------------
% Tone only task (no light, tone A or B paired with tastant A or B)
%--------------
% 'Toneonly_orig' -- tone 1 paired with sucrose, tone 2 paired with
% quinine, no light
% 'Toneonly_cb' -- tone 2 paired with sucrose, tone 1 paired with
% quinine, no light
%-----------
% 'activepassive' -- combined active and passive, with blank trials for
%  some passive trials (tone pairing 1=sugar, 2=quin)
% 'actpass_cb' -- combined active and passive, with blank trials for
%  some passive trials, but counterbalanced tones (1=quin, 2=sugar)
%-----------
% Adapted from pulser configuration example file by Chris Deister, 2015
% -----------

function [pulser]=pulser_config_timeout_multimouse_5box_actpass_blank(ActiveBoxes, session_type, sess_dur)

% Set overall session parameters
%--------------
pulser.ni.rate = 2000;
pulser.ni.daqToggle=1; % 0 means no daqs, 1 means use daqs (debug purposes, you probably want 1 here)
pulser.ni.useTrig=0;
pulser.ni.trialDuration=sess_dur;

% Set length of time each value is held in the analog output in seconds
% (not more than 6 seconds (min timeout + min trial length) or might force two trials in row of same length)
%----------------
pulser.ni.aOut.rs_timestep=3;
% Time set to zero before starting randstep waveforms
pulser.ni.aOut.rs_time_pre=1;
% time to set to zero at end of session -- this prevents starting a trial
% that will not be recorded in full due to the session ending
pulser.ni.aOut.rs_time_post=10;

% Proportion of each trial type -- proportions must add up to 1 -- These
% are set based on the trial type indicated for each mouse
%-------------------

for m=1:length(ActiveBoxes);
    
    if  strcmp(session_type{m},'notrial')
        % Proportion water only
        p_wat=0;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif  strcmp(session_type{m},'Shape')
        % Proportion water only
        p_wat=1;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
        
    elseif  strcmp(session_type{m},'Shape_easy')
        % Proportion water only
        p_wat=0;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=1;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
        
    elseif strcmp(session_type{m},'2tast_orig')
        % Proportion water only
        p_wat=0.2;
        % Original tone/tastant pairings
        p_suc_tone1=.4;
        p_quin_tone2=.4;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'2tast_cb')
        % Proportion water only
        p_wat=0.2;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=.4;
        p_quin_tone1=.4;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'2tast_ext')
        % Proportion water only
        p_wat=0.2;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=.4;
        p_ext_tone2=.4;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'Sonly_orig')
        % Proportion water only
        p_wat=0.5;
        % Original tone/tastant pairings
        p_suc_tone1=0.5;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
        
    elseif strcmp(session_type{m},'Qonly_orig')
        % Proportion water only
        p_wat=0.5;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0.5;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'Sonly_cb')
        % Proportion water only
        p_wat=0.5;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0.5;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'Qonly_cb')
        % Proportion water only
        p_wat=0.5;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0.5;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'Tone1_ext')
        % Proportion water only
        p_wat=0.5;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0.5;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'Tone2_ext')
        % Proportion water only
        p_wat=0.5;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0.5;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
        
    elseif strcmp(session_type{m},'QW_tone_orig')
        % Proportion water only
        p_wat=0.2;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0.4;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0.4;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'QW_tone_cb')
        % Proportion water only
        p_wat=0.2;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0.4;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0.4;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0;
        
    elseif strcmp(session_type{m},'Toneonly_orig')
        % Proportion water only
        p_wat=0;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0.4;
        p_to_quin_tone2=0.4;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0.2;
        
    elseif strcmp(session_type{m},'Toneonly_cb')
        % Proportion water only
        p_wat=0;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0.4;
        p_to_quin_tone1=0.4;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0.2;
        
        
    elseif strcmp(session_type{m},'activepassive')
        % Proportion water only
        p_wat=.1;
        % Original tone/tastant pairings
        p_suc_tone1=.25;
        p_quin_tone2=.25;
        % Reversal tone/tastant pairings:
        p_suc_tone2=0;
        p_quin_tone1=0;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0.15;
        p_to_quin_tone2=0.15;
        p_to_suc_tone2=0;
        p_to_quin_tone1=0;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0.1;
        
    elseif strcmp(session_type{m},'actpass_cb')
        % Proportion water only
        p_wat=.1;
        % Original tone/tastant pairings
        p_suc_tone1=0;
        p_quin_tone2=0;
        % Reversal tone/tastant pairings:
        p_suc_tone2=.25;
        p_quin_tone1=.25;
        % Extinction tones only (with water whole time):
        p_ext_tone1=0;
        p_ext_tone2=0;
        % Easy water trials (only for shaping)
        p_wat_easy=0;
        % Tone only trials (no light)
        p_to_suc_tone1=0;
        p_to_quin_tone2=0;
        p_to_suc_tone2=0.15;
        p_to_quin_tone1=0.15;
        % tone C trials, active
        p_suc_tone3=0;
        p_quin_tone3=0;
        p_wat_tone3=0;
        % tone C passive
        p_to_suc_tone3=0;
        p_to_quin_tone3=0;
        % total blank trial, passive (catch)
        p_to_blank=0.1;
        
    end
    
    % Indicator vector of proportions for each trial type -- this can be
    % different for each mouse based on trial type
    % If another channel is added later has a different wave form, this cell will need an
    % empty entry in order to reference the right spot for the channel that
    % is randstep
    pulser.ni.aOut.trains.rs_prop_trials{m}=[p_wat p_suc_tone1 p_quin_tone2 p_suc_tone2 p_quin_tone1 p_ext_tone1 p_ext_tone2 ...
        p_wat_easy p_to_suc_tone1 p_to_quin_tone2 p_to_suc_tone2 p_to_quin_tone1 p_suc_tone3 p_quin_tone3 p_wat_tone3 ...
        p_to_suc_tone3 p_to_quin_tone3 p_to_blank];
    
end

% This is the voltage value output to set for each trial type -- what trial is run
% is determined by the arduino when it reads in the value
%--------------
% // 1) water & no tone set output to 0.5v      102.3 units     arduino read between 52-153
% // 2) tone 1 & tast 1 (suc) set to 1v         204.6           arduino read between 154 and 255
% // 3) tone 2 & tast 2 (quin) set to 1.5 v     306.9           arduino read between 256 and 358
% // 4) tone 2 & tast 1 (suc) set to 2 v        409.2           arduino read between 359 and 460
% // 5) tone 1 & tast 2 (quin) set to 2.5 v     511.5           arduino read between 461 and 562
% // 6) tone 1 & water set to 3 v               613.8           arduino read between 563 and 664
% // 7) tone 2 & water set to 3.5v              716.1           arduino read between 665 and 767
% *** Passive trials missing, need to add these in ***** Nathan VC 1/2016
%--------------

pulser.ni.aOut.trains.rs_trial_vals=[0.5 1 1.5 2 2.5 3 3.5 0.25 4 4.2 4.4 4.6 1.25 2.25 3.25 3.8 4.8 0.75];

%-----------------
% Analog Out
%-----------------
% Generates an independent voltage out for each mouse box -- this code works for up to 5 mice

% If all five boxes are active, these are the analog out channels and wave
% forms
%---------------
allposs_out_devIDs={'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev2'};
allposs_out_names={'M1' 'M2' 'M3' 'M4' 'M5'};
allposs_out_chans=[0 1 2 3 0];
allposs_out_wavetype={'randstep' 'randstep' 'randstep' 'randstep' 'randstep'};

% But we only include the active boxes
%---------------
pulser.ni.aOut.devIDs=allposs_out_devIDs(ActiveBoxes);
pulser.ni.aOut.names=allposs_out_names(ActiveBoxes);
pulser.ni.aOut.channels=allposs_out_chans(ActiveBoxes);
pulser.ni.aOut.trains.types=allposs_out_wavetype(ActiveBoxes);

%-----------
% Digital In
%-----------
% Collect general channel info for each mouse that will be run separately
% Collecting separately first to make it easier to change later if needed
pulser.params.M1.devIDs={'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1'};
pulser.params.M2.devIDs={'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1'};
pulser.params.M3.devIDs={'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1'};
pulser.params.M4.devIDs={'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1'};

pulser.params.M1.channels={'Port0/Line0' 'Port0/Line1' 'Port0/Line2' 'Port0/Line3' 'Port0/Line4' 'Port0/Line5' 'Port0/Line6' 'Port0/Line7'};
pulser.params.M2.channels={'Port0/Line8' 'Port0/Line9' 'Port0/Line10' 'Port0/Line11' 'Port0/Line12' 'Port0/Line13' 'Port0/Line14' 'Port0/Line15'};
pulser.params.M3.channels={'Port0/Line16' 'Port0/Line17' 'Port0/Line18' 'Port0/Line19' 'Port0/Line20' 'Port0/Line21' 'Port0/Line22' 'Port0/Line23'};
pulser.params.M4.channels={'Port0/Line24' 'Port0/Line25' 'Port0/Line26' 'Port0/Line27' 'Port0/Line28' 'Port0/Line29' 'Port0/Line30' 'Port0/Line31'};

gen_chan_names={'det_lick' 'del_lick' 'difficulty' 'liq_win' 'tast1_win' 'tast2_win' 'toneA' 'toneB'};

% collect into cell of all channels if all mice active:
allposs_in_devIDs={pulser.params.M1.devIDs pulser.params.M2.devIDs pulser.params.M3.devIDs pulser.params.M4.devIDs};
allposs_in_channels={pulser.params.M1.channels pulser.params.M2.channels pulser.params.M3.channels pulser.params.M4.channels};

% Concatenate only the channel specifications for the active boxes
pulser.ni.dIn.devIDs=[allposs_in_devIDs{intersect(1:4,ActiveBoxes)}];
pulser.ni.dIn.channels=[allposs_in_channels{intersect(1:4,ActiveBoxes)}];
pulser.ni.dIn.names=repmat(gen_chan_names,1,length(intersect(1:4,ActiveBoxes)));

%----------------
% Analog input channels -- Raw lick signal only
%----------------
allposs_in_devIDs={'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1'};
allposs_in_names={'M1lick' 'M2lick' 'M3lick' 'M4lick' 'M5lick'};
allposs_in_chans=[0 1 2 3 4];
allposs_in_range=[10 10 10 10 10];

%----------------
% Analog input channels -- Box 5 channels
%----------------
allposs_in_devIDs_m5={'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1' 'Dev1'};
allposs_in_names_m5={'det_lick' 'del_lick' 'difficulty' 'liq_win' 'tast1_win' 'tast2_win' 'toneA' 'toneB'};
allposs_in_chans_m5=[16 17 18 19 20 21 22 23];
allposs_in_range_m5=[10 10 10 10 10 10 10 10];

%---------------
% But we only include the active boxes
%---------------
% if there is no box 5
if ~ismember(5, ActiveBoxes)
    pulser.ni.aIn.devIDs=allposs_in_devIDs(ActiveBoxes);
    pulser.ni.aIn.names=allposs_in_names(ActiveBoxes);
    pulser.ni.aIn.channels=allposs_in_chans(ActiveBoxes);
    pulser.ni.aIn.range=allposs_in_range(ActiveBoxes);
    
elseif ismember(5, ActiveBoxes)
    pulser.ni.aIn.devIDs=[allposs_in_devIDs(ActiveBoxes) allposs_in_devIDs_m5];
    pulser.ni.aIn.names=[allposs_in_names(ActiveBoxes) allposs_in_names_m5];
    pulser.ni.aIn.channels=[allposs_in_chans(ActiveBoxes) allposs_in_chans_m5];
    pulser.ni.aIn.range=[allposs_in_range(ActiveBoxes) allposs_in_range_m5];
    
end

% Set external trigger timeout
%-------------------
pulser.ni.triggertimeout=90;

% ----- Quadrature Encoding (Not used here), carryover from pulser...
%
pulser.ni.counter.devIDs={};
pulser.ni.counter.channels=[];
pulser.ni.counter.type={};  %Choose Position or EdgeCount
pulser.ni.counter.names={};

end