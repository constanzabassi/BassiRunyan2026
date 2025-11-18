function wrapper_mod_index_single_plots_across_contexts(info, neural_structure, stim_trials_context, ctrl_trials_context, mod_index_results, dataset_to_plot, sig_neurons_to_plot, modulation_type, save_string, plot_params)
% WRAPPER_MOD_INDEX_SINGLE_PLOTS_ACROSS_CONTEXTS computes modulation indices for each dataset/context,
% identifies significant neurons based on bootstrap results, and then plots individual neuron activity.
%
%   Inputs:
%     info                - Structure with dataset information (e.g., info.mouse_date).
%     neural_structure    - Cell array or structure array with neural data for each dataset.
%                           Each element should have fields 'stim' and 'ctrl' (3D arrays: trials x neurons x frames).
%     mod_index_results   - Structure array of modulation indices per
%                            neuron and significant neurons.
%     stim_trials_context - Cell array of stimulation trial indices for each dataset/context.
%                           For dataset i and context j, use: stim_trials_context{1,i}{1,j}.
%     ctrl_trials_context - Cell array of control trial indices for each dataset/context.
%                           For dataset i and context j, use: ctrl_trials_context{1,i}{1,j}.
%     dataset_to_plot     - Dataset indices to process.
%     context_to_plot     - Context indices to process.
%     sig_neurons_to_plot - Indices of significant neurons to plot (optional, if empty, determined from results).
%     modulation_type     - Type of modulation index to use.
%     save_string         - String to append to saved plots.
%
%   Author: CB 09/24/2025
% Set random seed for reproducibility.
rng(123);

% Load trial information (adjust paths as needed) -virmen trial info left turns/sound condition/is stim
load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat');
passive_all_trial_info_sounds = load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat').all_trial_info_sounds;
% all_trial_info_sounds = plot_params.trial_info;
% passive_all_trial_info_sounds = plot_params.pass_trial_info;

nContexts = size(stim_trials_context{1,1},2);
% Loop through datasets.
for current_dataset = dataset_to_plot
    fprintf('Processing dataset %d/%d...\n', current_dataset, length(dataset_to_plot));
    % Loop through contexts (assuming context 1: active, context 2: passive; adjust as needed).
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

        % Get example trials!
        [~, ~, ~, ~, ~, ~, left_active_all, left_passive_all,  right_active_all, right_passive_all] = ...
                find_sound_trials_single(active_trials, passive_trials, current_conditions_active, current_conditions_passive);

        % For now, use pooled indices.
        pooled_active_indices = [left_active_all(:); right_active_all(:)];
        pooled_passive_indices = [left_passive_all(:); right_passive_all(:)];
        
        % Identify significant neurons using your helper function.
        mod_index = mod_index_results(current_dataset).context(1).cv_mod_index;
        if isempty(sig_neurons_to_plot)
            sig_neurons = get_significant_mod_neurons(mod_index, mod_index_results(current_dataset).context(1).sig_neurons, modulation_type);
        else
            sig_neurons = sig_neurons_to_plot;
        end

        fprintf('sig_neurons dataset %d/%d...\n', current_dataset, length(sig_neurons));
        % Plot individual modulated neurons.
        time_vector = [1:122];
        context = [1,2];
        if ~isempty(sig_neurons)
            plot_params.plot_mode = 'both'; %make sure to plot both contexts
            plot_individual_mod_neurons(active_data(pooled_active_indices, :, :), ...
                                        passive_data(pooled_passive_indices, :, :), ...
                                        mod_index, sig_neurons, time_vector, [current_dataset, context], [length(left_active_all), length(left_passive_all)], ...
                                        fullfile(info.savepath,'individual_neuron_plots', save_string),plot_params.plot_mode,plot_params.plot_avg,plot_params);

            if isfield(plot_params,'avg_traces') && plot_params.avg_traces == 1
                %plot avg trace and trials in gray per neuron
                if strcmp(plot_params.plot_mode,'passive')
                    plot_avg_trial_traces_simple(passive_data(pooled_passive_indices, :, :),sig_neurons,mod_index,[current_dataset, context],plot_params,fullfile(info.savepath,'individual_neuron_plots_avg', save_string));
%                     plot_avg_trial_traces_simple(passive_data(left_passive_all, :, :),sig_neurons,mod_index,[current_dataset, context],plot_params,fullfile(info.savepath,'individual_neuron_plots_avg_left', save_string));
%                     plot_avg_trial_traces_simple(passive_data(right_passive_all, :, :),sig_neurons,mod_index,[current_dataset, context],plot_params,fullfile(info.savepath,'individual_neuron_plots_avg_right', save_string));
                elseif strcmp(plot_params.plot_mode,'active')
                    plot_avg_trial_traces_simple(active_data(pooled_active_indices, :, :),sig_neurons,mod_index,[current_dataset, context],plot_params,fullfile(info.savepath,'individual_neuron_plots_avg', save_string));
                else
                    plot_avg_trial_traces_simple(passive_data(pooled_passive_indices, :, :),sig_neurons,mod_index,[current_dataset, context],plot_params,fullfile(info.savepath,'individual_neuron_plots_avg', save_string),active_data(pooled_active_indices, :, :));
%                     plot_avg_trial_traces_simple(passive_data(left_passive_all, :, :),sig_neurons,mod_index,[current_dataset, context],plot_params,fullfile(info.savepath,'individual_neuron_plots_avg_left', save_string),active_data(right_passive_all, :, :));
%                     plot_avg_trial_traces_simple(passive_data(left_passive_all, :, :),sig_neurons,mod_index,[current_dataset, context],plot_params,fullfile(info.savepath,'individual_neuron_plots_avg_right', save_string),active_data(right_passive_all, :, :));

                end
            end

        end
    end
end
