function [xticks_in,xticks_lab]  = x_axis_sec_aligned(stim_frame,length_frames,interval)
% stim_frame: frame number where the stimulus event occurs
% length_frames: total number of frames
% interval: optional argument (e.g., 1 for every second, 2 for every other second, 3 for every third second, etc.)
if nargin < 3
    interval = 1; % Default to every second if no interval is provided
end
frame_rate = 30; % Imaging frame rate (30 Hz)
frames_before = length(1:stim_frame-1); % Number of frames before the event
frames_after = length(stim_frame:length_frames); % Number of frames after the event
% Create the time axis relative to the stim_frame
time_before = (-frames_before:0) / frame_rate; % Time for frames before the event
time_after = (1:frames_after) / frame_rate;   % Time for frames after the event
time_axis = [time_before, time_after];        % Full time axis
frame_indices = (stim_frame - frames_before):(stim_frame + frames_after); % Corresponding frame indices
% Define the desired x-tick values (integer seconds only) at the specified interval
x_tick_seconds = unique(floor(time_axis)); % Round down to the nearest second and get
% Define the desired x-tick values (integer seconds only)
x_tick_seconds = x_tick_seconds(mod(x_tick_seconds, interval) == 0); % Select ticks based on the interval
% Find the indices of these seconds in the time_axis
[valid_id, x_tick_indices] = ismember(x_tick_seconds, time_axis);
% Verify validity of indices
x_tick_indices = x_tick_indices(valid_id);
x_tick_seconds = x_tick_seconds(valid_id);
% Set the x-ticks and labels
xticks_in = frame_indices(x_tick_indices); % Set ticks at the corresponding frame indices
xticks_lab = arrayfun(@num2str, x_tick_seconds, 'UniformOutput', false); % Set labels as integers
end
