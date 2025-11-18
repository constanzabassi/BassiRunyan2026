function [data,context_tr] = load_neural_data(server, dataset_path)
%load neural data (dff/deconv), stimulus onsets, and context_trials if
%multiple trials available

    base_path = fullfile(server, 'Connie', 'ProcessedData', dataset_path);
    
    % Load core files
    data.bad_frames = load_mat_file(base_path, 'bad_frames.mat');
    data.deconv = load_mat_file(fullfile(base_path, 'deconv'), 'deconv.mat');
    data.dff = load_mat_file(base_path, 'dff.mat');
    
end
