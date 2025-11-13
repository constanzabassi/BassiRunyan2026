function X = get_X (aligned_data, mdl_param,current_frame)
%%% INPUTS: aligned_data (trials,cells,time)
%%% timepoints: bins inside each trials
%%% param: extra info (sum or not depending on deconvolved)

%%%OUTPUT: normalized X! (normc)

cells_ids = mdl_param.mdl_cells; %which cell type to use
event_onset =  mdl_param.event_onset; %starting point
bin = mdl_param.bin; %bin size in terms of frames

if strcmp(mdl_param.data_type,'dff')
    X = squeeze(mean(aligned_data(:,cells_ids,event_onset+current_frame:event_onset+current_frame+bin),3)); %mean across frames
elseif strcmp(mdl_param.data_type,'deconv')
    X = sum(squeeze(aligned_data(:,cells_ids,event_onset+current_frame:event_onset+current_frame+bin)),3); %sum across frames
end
X = normc(X); %normalize columns (features/neurons)
% X = zscore(X);

