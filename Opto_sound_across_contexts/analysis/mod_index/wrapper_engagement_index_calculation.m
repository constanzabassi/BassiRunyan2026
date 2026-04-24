function [results, sig_mod_boot, mod_indexm] = wrapper_engagement_index_calculation(info, neural_structure, response_range, mod_type, mode, stim_trials_context, ctrl_trials_context,nShuffles,  savepath, varargin)
% wrapper_mod_index_calculation serves as a wrapper to loop across datasets/contexts,
% compute modulation indices and bootstrapped significance (with balancing done inside each CV repeat),
% and save the results.
%
%   Inputs:
%     info               - Structure containing dataset information (e.g., info.mouse_date).
%     neural_structure   - Structure array with neural data for each dataset.
%                          Each element should have fields 'stim' and 'ctrl'
%                          (each a 3D array: trials x neurons x frames).
%     response_range     - Cell array of frame indices over which to average the response.
%                          For example: {62:92} or {post_frames, pre_frames} if using 'prepost'.
%     mod_type           - String specifying the modulation index type, e.g. 'ctrl', 'influence', or 'prepost' or ''prepost_sound'.
%     mode               - String: 'pooled' (default) or 'separate'. In 'pooled' mode, left and right trials
%                          are combined; in 'separate' mode, they are computed independently and then the maximum
%                          (in absolute value) is chosen. 'Simple' means
%                          that whatever trials are given are used (so no
%                          balancing). 'Selectivity' means we are only
%                          using control trials and ignoring all stim
%                          trials.
%     stim_trials_context- Cell array of stimulation trial indices for each dataset and context.
%                          For dataset i and context j, use: stim_trials_context{1,i}{1,j}.
%     ctrl_trials_context- Cell array of control trial indices for each dataset and context.
%                          For dataset i and context j, use: ctrl_trials_context{1,i}{1,j}.
%     nShuffles          - for bootstrapping - if set to zero no bootrapping
%     savepath           - (Optional) Directory where results should be saved. If empty, no saving is done.
%     varargin           - (OPTIONAL) arrays of specific trials to use
%
%   Output:
%     results - Structure array containing the computed modulation indices and bootstrap p-values.
%               For each dataset (indexed by current_dataset) and each context,
%               results(current_dataset).context contains the fields:
%                  .cv_mod_index           - 1 x nNeurons vector of final cross‑validated modulation indices.
%                                             (In "separate" mode, this equals the index from the side with the larger absolute value.)
%                  .cv_mod_index_separate  - (If mode is 'separate') A structure with fields:
%                                             .left, .right, .max, and .side.
%                                             In "pooled" mode, returned as empty.
%                  .bootstrapResults       - A structure containing bootstrap results (p‑values).
%                                             If nShuffles == 0, this is empty.
%   Example usage:
%     results = wrapper_mod_index_calculation(info, neural_structure, {62:92}, 'influence', 'pooled', ...
%                     stim_trials_context, ctrl_trials_context, 'C:\savepath');
%
% CB 02/11/2025

% Load trial information (adjust paths as needed) -virmen trial info left turns/sound condition/is stim
load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat');
passive_all_trial_info_sounds = load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat').all_trial_info_sounds;
% load('V:\Connie\results\opto_2024\context\data_info\all_trial_info_passive.mat');
% load('V:\Connie\results\opto_2024\context\data_info\all_trial_info.mat');

% Set parameters for bootstrap shuffles and CV repeats
nRepeats = 10;

% Preallocate the results structure.
results = struct();

%get data type (dff or deconv)
data_type = info.data_type;

% Total contexts - 3 for photostim (active (1),passive(2),spont(3)// 2 for
% sounds(active (1),passive(2))
nContexts = 2
% Loop through datasets.
for current_dataset = 1: length(info.mouse_date)
    fprintf('Processing dataset %d/%d...\n', current_dataset, length(info.mouse_date));

        % Get condition labels from trial info 
%                 current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.condition,all_trial_info_sounds(current_dataset).sound_only.condition];
        %get active trials first
        current_conditions = [all_trial_info_sounds(current_dataset).opto.condition];
        current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.condition];

%                 current_conditions_ctrl = [passive_all_trial_info_sounds(current_dataset).ctrl.condition,passive_all_trial_info_sounds(current_dataset).sound_only.condition];

        current_conditions_pass = [passive_all_trial_info_sounds(current_dataset).opto.condition];
        current_conditions_ctrl_pass = [passive_all_trial_info_sounds(current_dataset).ctrl.condition];

        %concatenate conditions across contexts
        current_conditions_active = [current_conditions,current_conditions_ctrl];
        current_conditions_passive = [current_conditions_pass,current_conditions_ctrl_pass];


        % Get trial indices for the current context. (CHANGING STIM_TRIALS
        % TO ACTIVE, AND CONTROL TO PASSIVE FOR EASY USE OF CODE)
        context = 1;
        active_trials = [1:length(ctrl_trials_context{1, current_dataset}{1, context})+length(stim_trials_context{1, current_dataset}{1, context})];
        context = 2;
        passive_trials =  [1:length(ctrl_trials_context{1, current_dataset}{1, context})+length(stim_trials_context{1, current_dataset}{1, context})];%[stim_trials_context{1, current_dataset}{1, context},ctrl_trials_context{1, current_dataset}{1, context}];

        % Extract neural data for the current dataset.
        active_data = [neural_structure{1,current_dataset}.stim(stim_trials_context{1, current_dataset}{1, 1},:,:);neural_structure{1,current_dataset}.ctrl(ctrl_trials_context{1, current_dataset}{1, 1},:,:)];  % [trials x neurons x frames]
        passive_data = [neural_structure{1,current_dataset}.stim(stim_trials_context{1, current_dataset}{1, 2},:,:);neural_structure{1,current_dataset}.ctrl(ctrl_trials_context{1, current_dataset}{1, 2},:,:)];  % [trials x neurons x frames]


        % Call the main modulation index function.
        if ~strcmp(mode,'simple') %do balancing etc OR use all trials included
            % Note: calc_mod_index_cv now performs the trial balancing inside each CV repeat.
            [cv_mod_index, cv_mod_index_separate, bootstrapResults] = calc_mod_index_cv(...
                active_data, passive_data, active_trials, passive_trials, current_conditions, current_conditions_ctrl, ...
                response_range, mod_type, mode, nRepeats, nShuffles,data_type);
        else
            if context == 1 %only necessary when selecting specific trials from virmen (like correct vs incorrect)
                current_conditions = current_conditions(active_trials);
                current_conditions_ctrl = current_conditions_ctrl(passive_trials);
            end

            [~, ~, ~, ~, ~, ~, left_active_all, left_passive_all,  right_active_all, right_passive_all] = ...
                find_sound_trials_single(active_trials, passive_trials, current_conditions_active, current_conditions_passive);
            if nargin > 9
                stim_to_match = varargin{1,1}{1, current_dataset}{1, context};
                ctrl_to_match = varargin{1,2}{1, current_dataset}{1, context};
                 [left_active_all, left_passive_all,  right_active_all, right_passive_all] = find_overlap_trials (left_active_all, left_passive_all,  right_active_all, right_passive_all, stim_to_match,ctrl_to_match);
            end
            active_data_left = active_data(left_active_all,:,:);% trials x neurons x frames using trials for current context
            passive_data_left = passive_data(left_passive_all,:,:);% trials x neurons x frames using trials for current context
    
            active_data_right = active_data(right_active_all,:,:);% trials x neurons x frames using trials for current context
            passive_data_right = passive_data(right_passive_all,:,:);% trials x neurons x frames using trials for current context


%         %use below if wanting to use all trials
%             stim_data = stim_data(stim_trials,:,:);% trials x neurons x frames using trials for current context
%              ctrl_data = ctrl_data(ctrl_trials,:,:);% trials x neurons x frames using trials for current context
            [cv_mod_left, ~, bootstrapResults_left] = calc_mod_index_cv(...
                active_data_left, passive_data_left, active_trials, passive_trials, current_conditions, current_conditions_ctrl, ...
                response_range, mod_type, mode, nRepeats, nShuffles,data_type);

            [cv_mod_right, ~, bootstrapResults_right] = calc_mod_index_cv(...
                active_data_right, passive_data_right, active_trials, passive_trials, current_conditions, current_conditions_ctrl, ...
                response_range, mod_type, mode, nRepeats, nShuffles,data_type);

            nNeurons = size(active_data,2);
            % Select max side and prepare output;
                [cv_mod_index, cv_mod_index_separate,side] = select_max_side(...
                    cv_mod_left, cv_mod_right, nNeurons);
            bootstrapResults = handle_separate_BootstrapResults(bootstrapResults_left.pVals,bootstrapResults_right.pVals,side,nNeurons);
        end

        % Save outputs for this dataset and context.
        results(current_dataset).context.cv_mod_index = cv_mod_index;
        results(current_dataset).context.cv_mod_index_separate = cv_mod_index_separate;
        results(current_dataset).context.bootstrapResults = bootstrapResults;

        %save results per dataset in cells similar to before
        mod_indexm{current_dataset} = cv_mod_index;
        mod_index_separate{current_dataset} = cv_mod_index_separate;

        % test bootstrapped p vals for significance
        sig_neurons = find(bootstrapResults.pVals <= 0.05);
        sig_mod_boot{current_dataset} = sig_neurons;
        results(current_dataset).context.sig_neurons = sig_neurons;
end

% Save the results if a save path is provided.
if ~isempty(savepath)
    outdir = savepath;
    if ~exist(outdir, 'dir')
        mkdir(outdir);
    end
    
    cd(outdir);
    save('sig_mod_boot','sig_mod_boot');
    save('mod_indexm','mod_indexm');
    save('mod_index_separate','mod_index_separate')
    save(fullfile(outdir, 'mod_index_results.mat'), 'results');
end
end