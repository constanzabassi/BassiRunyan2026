function [speed_params,speed_params_single] = get_speed_params(control_or_opto)

%define speed_params_single to plot example trials for EACH dataset
speed_params_single.abs = 0; %whether to take absolute value of velocity or not
speed_params_single.right_color = [.39,.56,1];%light blue %colors for right sound trials
speed_params_single.left_color = [.86,.15,.49];% magenta %colors for right sound trials
speed_params_single.colormap = 'RdBu';
speed_params_single.frames_before_event = 60;
speed_params_single.frames_after_event = 240;
speed_params_single.onset_frame = speed_params_single.frames_before_event + 1;
speed_params_single.right_color_active = [.3,.3,1];%dark blue %colors for right sound trials
speed_params_single.left_color_active = [.7,0,.5];% dark magenta %colors for right sound trials
speed_params_single.right_color_passive = [.5,.8,1];%light blue %colors for right sound trials
speed_params_single.left_color_passive = [.9,.5,.8];% magenta %colors for right sound trials

%define params ACROSS datasets
speed_params.frames_before_event = 60;
speed_params.frames_after_event = 60;
speed_params.only_before = 0; %important what to plot 0 is to plot the difference,2 is to plot after frames only; 1 is to plot only before frames;  (regardless of number code will still take the difference and give p values for those)
speed_params.stim_frame = speed_params.frames_before_event + 1; %based on previous alignment
speed_params.frames_before_stim = 15; %used to take the difference
speed_params.frames_after_stim = 15; %used to take the difference
speed_params.bins = [0,10,Inf]; %for plotting binned speed vs neural (also will use first bin to get trials where change in speed is small
speed_params.single_mouse_plot = 0;% plot individual mice or not
speed_params.abs = 1; %take the absolute value of the velocity difference or not
speed_params.contexts  = {'Active', 'Passive'};
speed_params.contexts_colors = [0 0 0; 0.5 0.5 0.5]; %black/ gray
speed_params.context_lineStyle = { '-', '--', '-.'};
if control_or_opto == 1
    speed_params.field_name_vel = 'both_control'; %or both_opto
    speed_params.field_name_neural = 'ctrl'; %ctrl or stim
    speed_params.right_color = [.39,.56,1];%light blue %colors for right sound trials
    speed_params.left_color = [.86,.15,.49];% magenta %colors for left sound trials

else
    speed_params.field_name_vel = 'both_opto'; %or both_opto
    speed_params.field_name_neural = 'stim'; %ctrl or stim
    
    speed_params.right_color =[0.9 0.6 0]; %yellow
    speed_params.left_color = [0.9 0.6 0]; %yellow
    
end