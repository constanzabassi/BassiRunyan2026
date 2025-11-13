function X = get_X_nooverlap (aligned_data, mdl_param,current_frame)
%%% INPUTS: aligned_data (trials,cells,time)
%%% timepoints: bins inside each trials
%%% param: extra info (sum or not depending on deconvolved)

%%%OUTPUT: normalized X! (normc)


cells_ids = mdl_param.mdl_cells; %which cell type to use
event_onset =  mdl_param.event_onset; %starting point
bin = mdl_param.bin-1; %bin size in terms of frames (-1 so it doesn't count current)
current_frame = current_frame;%+bin+1;


if strcmp(mdl_param.data_type,'dff')
    if ~ismember(size(aligned_data,3),event_onset+current_frame)
        X = squeeze(mean(aligned_data(:,cells_ids,event_onset+current_frame:event_onset+current_frame+bin),3)); %mean across frames
    else
        X = squeeze(mean(aligned_data(:,cells_ids,event_onset+current_frame:size(aligned_data,3)),3)); %mean across frames
    end

elseif strcmp(mdl_param.data_type,'deconv')
    if ~ismember(size(aligned_data,3),event_onset+current_frame)
        X = sum(squeeze(aligned_data(:,cells_ids,event_onset+current_frame:event_onset+current_frame+bin)),3); %sum across frames
    else
        X = sum(squeeze(aligned_data(:,cells_ids,event_onset+current_frame:size(aligned_data,3))),3); %sum across frames
    end
end
% X = normc(X); %normalize columns (features/neurons)
% X = zscore(X);
