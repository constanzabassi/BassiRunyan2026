%wilcoxon significance test
function [p_opto,p_ctrl,h_opto,h_ctrl]=wilk_sign_rank(aligned_data_opto, aligned_data_ctrl,stim_frame, frames_before_stim,frames_after_stim)
frame2comp_before = stim_frame - frames_before_stim;
frame2comp_after = stim_frame + frames_after_stim;
stim_avg=[(mean(aligned_data_opto(:,stim_frame+1:frame2comp_after),2)),(mean(aligned_data_opto(:,frame2comp_before:stim_frame-1),2))];
ctrl_avg=[(mean(aligned_data_ctrl(:,stim_frame+1:frame2comp_after),2)),(mean(aligned_data_ctrl(:,frame2comp_before:stim_frame-1),2))];

[p_opto, h_opto] = signrank(stim_avg(:,1),stim_avg(:,2),'Alpha', 0.05/2); %h logical whether significant or not, p is p value
[p_ctrl, h_ctrl] = signrank(ctrl_avg(:,1),ctrl_avg(:,2),'Alpha', 0.05/2); %h logical whether significant or not, p is p value

