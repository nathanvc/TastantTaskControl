% function to reformat clock into string with same number of characters
% Nathan V-C
% ~5/2015
% -------

function[timestamp,timetag]=betterclock
timestamp = clock;
timetag=sprintf('%i-%02i-%02i-%02i-%02i-%02i',timestamp(1), timestamp(2), timestamp(3), timestamp(4), timestamp(5), round(timestamp(6)));