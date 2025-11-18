function [avg_results, avg_results_by_dataset , avg_results_ctrl,  avg_results_by_dataset_ctrl] = wrapper_trial_averaging(info, neural_structure,stim_trials_context,ctrl_trials_context, params, savepath, varargin)
% Wrapper function to compute trial-averaged responses across datasets and contexts
%
% Inputs:
%   info            - Structure with dataset information (e.g., info.mouse_date)
%   neural_structure- Cell array of neural data for each dataset
%   trial_info      - Structure with trial information for each context
%   params         - Structure with fields:
%                    .response_window - Frames to average over
%                    .trial_types    - 'stim', 'sounds'
%                    .mode          - 'pooled' or 'separate'
%                    .savepath      - Where to save results
%
% Outputs:
%   avg_results          - Combined results across datasets
%   avg_results_by_dataset - Cell array of results for each dataset

% Initialize storage
nDatasets = length(info.mouse_date);
nContexts = 2;
if strcmpi(params.trial_type,'stim')
    nContexts = 3;
end

if nargin > 6
    context_to_run = varargin{1,1};
else
    context_to_run = 1:nContexts;
end

avg_results_by_dataset = cell(nDatasets, length(context_to_run));

% Load context-specific trial info
% Load trial information (adjust paths as needed) -virmen trial info left turns/sound condition/is stim
load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat');
passive_all_trial_info_sounds = load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat').all_trial_info_sounds;

% Loop through datasets
for current_dataset = 1:nDatasets
    fprintf('Processing dataset %d/%d...\n', current_dataset, nDatasets);
    
    % Loop through contexts
    for context = context_to_run
        fprintf('Current context %d...\n', context);
        
        % Get condition labels from trial info 
        if context == 1
            if strcmpi(params.trial_type,'sounds') %for sound alignment I included [control, sound_only trials] so I need to concatenate trial types here)
                current_conditions = [all_trial_info_sounds(current_dataset).opto.condition];
                current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.condition,all_trial_info_sounds(current_dataset).sound_only.condition];
            else
                current_conditions = [all_trial_info_sounds(current_dataset).opto.condition];
                current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.condition];
            end
        elseif context == 2
            if strcmpi(params.trial_type,'sounds')%for sound alignment I included [control, sound_only trials] so I need to concatenate trial types here)
                current_conditions = [passive_all_trial_info_sounds(current_dataset).opto.condition];
                current_conditions_ctrl = [passive_all_trial_info_sounds(current_dataset).ctrl.condition,passive_all_trial_info_sounds(current_dataset).sound_only.condition];
            else
                current_conditions = [passive_all_trial_info_sounds(current_dataset).opto.condition];
                current_conditions_ctrl = [passive_all_trial_info_sounds(current_dataset).ctrl.condition];
            end
        else %spont has no conditions
            current_conditions = [];
            current_conditions_ctrl = [];
        end
        
        % Get neural data
        % Extract neural data for the current dataset.
        stim_data = neural_structure{1,current_dataset}.stim;  % [trials x neurons x frames]
        ctrl_data = neural_structure{1,current_dataset}.ctrl;  % [trials x neurons x frames]

%         % Get trial indices for the current context.
        stim_trials = stim_trials_context{1, current_dataset}{1, context};
        ctrl_trials = ctrl_trials_context{1, current_dataset}{1, context};
        
        % Compute trial averages
        [avg_results_by_dataset{current_dataset, context},avg_results_by_dataset_ctrl{current_dataset, context}] = get_trial_averaged_response(...
            stim_data,ctrl_data,stim_trials,ctrl_trials, current_conditions, current_conditions_ctrl, params);
        
    end
end

% Combine results across datasets
avg_results = combine_dataset_averages(avg_results_by_dataset,params);
avg_results_ctrl = combine_dataset_averages(avg_results_by_dataset_ctrl,params);


% Save results
if ~isempty(savepath)
    outdir =savepath;
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end
    save(fullfile(outdir, 'trial_averaged_results.mat'), 'avg_results');
    save(fullfile(outdir, 'trial_averaged_results_by_dataset.mat'), 'avg_results_by_dataset');

    if strcmpi(params.trial_type,'stim')
        %ctrl without sounds
        save(fullfile(outdir, 'trial_averaged_results_ctrl.mat'), 'avg_results_ctrl');
        save(fullfile(outdir, 'trial_averaged_results_by_dataset_ctrl.mat'), 'avg_results_by_dataset_ctrl');
    else
        avg_results_sounds = avg_results_ctrl;
        avg_results_by_dataset_sounds = avg_results_by_dataset_ctrl;
        save(fullfile(outdir, 'trial_averaged_results_sounds.mat'), 'avg_results_sounds');
        save(fullfile(outdir, 'trial_averaged_results_by_dataset_sounds.mat'), 'avg_results_by_dataset_sounds');
    end

end

end

