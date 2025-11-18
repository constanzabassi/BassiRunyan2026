function [all_celltypes, dff_st, deconv_st, stim_info, ...
          mouse_context_tr, deconv_st_interp, alignment_frames_all] = ...
    pool_activity_more_events(mouse_date, server, path_string, multiple_contexts, before_after_frames)
% This function pools neural activity data from multiple mice/datasets.
% It loads various datasets, processes deconvolved and dF/F signals,
% aligns activity to experimental conditions, and categorizes cells
% based on types. It also ensures consistency in cell numbers across datasets.

    % Initialize outputs
    [dff_st, deconv_st, deconv_st_interp , stim_info, alignment_frames_all] = initialize_outputs(mouse_date);
    
    % Process each dataset
    for dataset_id = 1:length(mouse_date) % Use parallel processing if available
        fprintf('Processing dataset %s...\n', mouse_date{dataset_id});
        % Load dataset
        [data,context_tr,imaging,alignment_info] = load_experimental_data(server{dataset_id}, mouse_date{dataset_id}, path_string, multiple_contexts,1);
        
        % Process context data
        % has the trials relative to bad frames and stim/ctrl for each context
        % Store context trials
        if multiple_contexts
            mouse_context_tr{dataset_id} = context_tr;
        end

        % Store stimulus info
        stim_info(dataset_id,:) = {data.bad_frames, data.exp, data.nonexp};
        
        % Align and process neural data (dff/deconv)
        [alignment_frames, dff_st_current_dataset, deconv_st_current_dataset, deconv_st_interp_current_dataset] = process_neural_data_more_events(data, before_after_frames,imaging,alignment_info);
        alignment_frames_all{dataset_id} = alignment_frames;
        
        % Store processed data
        dff_st{dataset_id} = struct('stim', dff_st_current_dataset.stim, 'ctrl', dff_st_current_dataset.ctrl, 'z_stim', dff_st_current_dataset.z_stim, 'z_ctrl', dff_st_current_dataset.z_ctrl);
        deconv_st{dataset_id} = struct('stim', deconv_st_current_dataset.stim, 'ctrl', deconv_st_current_dataset.ctrl);
        deconv_st_interp{dataset_id} = struct('stim', deconv_st_interp_current_dataset.stim, 'ctrl', deconv_st_interp_current_dataset.ctrl);
    end
    
    % Process cell types
    all_celltypes = process_cell_types(mouse_date, server, deconv_st, dff_st);
end

function [dff_st, deconv_st, deconv_st_interp , stim_info, alignment_frames_all] = initialize_outputs(mouse_date)
    % Initialize empty output variables for data processing
    
    n_datasets = length(mouse_date);
    dff_st = cell(1, n_datasets);
    deconv_st = cell(1, n_datasets);
    deconv_st_interp = cell(1, n_datasets);
    stim_info = cell(n_datasets, 3);
    alignment_frames_all = cell(1, n_datasets);
end