function [stim_avg,ctrl_avg] = difference_2event (aligned_data_opto, aligned_data_ctrl,stim_frame, frames_before_stim,frames_after_stim)
frame2comp_before = stim_frame - frames_before_stim;
frame2comp_after = stim_frame + frames_after_stim;
stim_avg=[(mean(aligned_data_opto(:,stim_frame+1:frame2comp_after),2))-(mean(aligned_data_opto(:,frame2comp_before:stim_frame-1),2))];
if exist('aligned_data_ctrl')
    ctrl_avg=[(mean(aligned_data_ctrl(:,stim_frame+1:frame2comp_after),2))-(mean(aligned_data_ctrl(:,frame2comp_before:stim_frame-1),2))];
else
    ctrl_avg=[];
end

