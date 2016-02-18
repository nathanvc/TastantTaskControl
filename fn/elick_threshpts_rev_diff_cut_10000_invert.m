% threshold the lick detection signal on the difference, which is what the
% arduino does for trials in August/Sept 2014 of tastant task
%----------

function [elick_pts]=elick_threshpts_rev_diff_cut_10000_invert(signal,Sfreq)

%signal_lowpass=fftlowpass(signal,Sfreq,300,310);
%elick_pts=thresh_crossing(signal_lowpass,.1);

diff_elick=-diff(signal);
% analysis of revised data before 9/1 used this threshold o v0.03 volts, but it misses
% some of what the arduino catches
%elick_pts=thresh_crossing(diff_elick,0.03);
% Matches the ardunio lick detection of diff of 9 units at sampling
% frequency of 9600
elick_pts=thresh_crossing(diff_elick,(9600/10000)*(.2932));

% Matches the ardunio lick detection of diff of 4 units at sampling
% frequency of 9600
%elick_pts=thresh_crossing(diff_elick,0.0094);


% remove licks closer than 50ms (definitely artifact, and arduino does not
% reward any of these)
%candidate licks to cut -- less than 50ms worth of time from each other
%based on Sfreq -- add one to id spike after the gap that may be too soon

%while ~isempty(find(diff(elick_pts)<Sfreq*(50/1000), 1))

poss_cut=find(diff(elick_pts)<Sfreq*(50/1000))+1;

run_ind=0;

if ~isempty(poss_cut)
    run_ind=0;
end

while run_ind<1
    elick_pts=trim_pts(elick_pts,Sfreq);
    poss_cut=find(diff(elick_pts)<Sfreq*(50/1000))+1;
    if length(poss_cut)<2
        run_ind=1;
    end
end

function [trim_pts]=trim_pts(elick_pts,Sfreq)

poss_cut=find(diff(elick_pts)<Sfreq*(50/1000))+1;
if length(poss_cut)>1
    poss_keep=poss_cut(find(diff(poss_cut)==1)+1);
    cut_inds=poss_cut(~ismember(poss_cut,poss_keep));
    elick_pts(cut_inds)=[];
end
trim_pts=elick_pts;





