function [second_ticks,second_labels] = x_axis_sec_onset(mdl_param)
% 1) mdl_param.frames_around goes forwards and backwards in time from onset
second_frames = find(rem(mdl_param.frames_around,30) == 0);
second_ticks = find(histcounts(second_frames,mdl_param.binns+mdl_param.event_onset));

% 2) get labels for the seconds!
second_labels = mdl_param.frames_around(second_frames)/30;

