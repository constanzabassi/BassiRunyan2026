%finding where stim occurs in waverusrfer signal
function [led, stim_list, ctrl_list] = finding_led(sync_base_path, LED_channel,alignment_info,bad_frames,varargin)
base1=sync_base_path; %['\\136.142.49.216\runyan2\connie\2p_results\' mousename '\wavesurfer\' date '\'];
cd(base1)
%%%%%loop through each wavesurfer file, load it
LED_channel_number = LED_channel; %LED in channel 5
sync_dir = dir(strcat(sync_base_path, '*.abf'));
num_acqs = length(sync_dir);
file_ind = 0;
wavesurfer_rate = 10000; %%in hertz
last_it_num = 0;
previous_frames=[]; stim_list =[]; interval_list = [];ctrl_list =[];
for acq_number = 1:num_acqs
index_list =[];    
[sync_data,sync_sampling_interval,~] = abfload(strcat(sync_base_path,sync_dir(acq_number).name));
led_signal = sync_data(:,LED_channel_number);
norm_led = led_signal./max(led_signal);

%finding where peaks are to determine LED in wavesurfer time
[~, locs] = findpeaks(double(abs(diff(led_signal))), 'MinPeakHeight',0.05); %min height might need to be adjusted 
if nargin > 4
    [~, locs] = findpeaks(double(abs(diff(led_signal))), 'MinPeakHeight',varargin{1,1}); %min height might need to be adjusted 
end
figure(1111);clf;
plot(double(abs(diff(led_signal))));
pause(.5);
led_values = led_signal(locs);
led_times = locs;

led(acq_number).values = led_values;
led(acq_number).times = led_times;

interval_start = find(diff(led_times) < 2000);
previous_frames_temp=[];
if acq_number == 1
    previous_frames_temp = 0;
else
    previous_frames_temp = length(alignment_info(acq_number-1).frame_times);
end
previous_frames = [previous_frames,previous_frames_temp];
previous_frames_sum = sum(previous_frames);
for i = 1:length(interval_start)
    [~, index] = min(abs( alignment_info(acq_number).frame_times- led(acq_number).times(interval_start(i)))); 
    index = index + previous_frames_sum; 
    index_list = [index_list,index];
    interval_list = cat(2, interval_list, index);
end
led(acq_number).frame_times = index_list;
end
%asigning bad_frames as stim
[val, index2] = min(abs(bad_frames(:,1) - interval_list)); %comparing to the start frame
stim_list = [stim_list,index2(find(val<5))]; %asumes bad_frames will be within 1-2 frames
stim_list = unique(stim_list);
all_index = 1:length(bad_frames);
ctrl_list = setdiff(all_index,stim_list);
end

% %FIND CLOSEST WAVESURFER FRAME TO LED VALUE
% %[c index] = min(abs(N-V(1))) This finds the value in N which is closest to the V value
% for in = 1:length(locs)
% [c index] = min(abs( locs(in) - led(file_ind).frame_times))
% end