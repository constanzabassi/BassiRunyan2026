function [divided_trials_stim, divided_trials_ctrl] = find_condition_context_trials(stim_trials_context, ctrl_trials_context, condition_type)

load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat');
passive_all_trial_info_sounds = load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat').all_trial_info_sounds;

% Initialize output cell arrays
divided_trials_stim = cell(size(1,2));
divided_trials_ctrl = cell(size(1,2));


nContexts = size(stim_trials_context{1,1},2);
nDatasets = length(stim_trials_context);

% Loop through datasets.
for current_dataset = 1: nDatasets
    for context =1: nContexts  % active context is the only have to have correct also
        % Get condition labels from trial info 
        if context == 1
            if nContexts == 2
                current_conditions = [all_trial_info_sounds(current_dataset).opto.(condition_type)];
                current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.(condition_type),all_trial_info_sounds(current_dataset).sound_only.(condition_type)];
            else
                current_conditions = [all_trial_info_sounds(current_dataset).opto.(condition_type)];
                current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.(condition_type)];
            end
        elseif context == 2
            if  nContexts == 2
                current_conditions = [passive_all_trial_info_sounds(current_dataset).opto.(condition_type)];
                current_conditions_ctrl = [passive_all_trial_info_sounds(current_dataset).ctrl.(condition_type),passive_all_trial_info_sounds(current_dataset).sound_only.(condition_type)];
            else
                current_conditions = [passive_all_trial_info_sounds(current_dataset).opto.(condition_type)];
                current_conditions_ctrl = [passive_all_trial_info_sounds(current_dataset).ctrl.(condition_type)];
            end
        else %spont has no conditions
            current_conditions = [];
            current_conditions_ctrl = [];
        end

        % Get trial indices for the current context.
        stim_trials = stim_trials_context{1, current_dataset}{1, context};
        ctrl_trials = ctrl_trials_context{1, current_dataset}{1, context};

        %one could be left sound, left choice, correct
        [~, ~, ~, ~, ~, ~,one_stim_all, one_ctrl_all, zero_stim_all, zero_ctrl_all  ] = ...
                find_condition_trials_single(stim_trials, ctrl_trials, mod(current_conditions,2), mod(current_conditions_ctrl,2));

        %save into original structure
        if context == 1 || strcmpi(condition_type,'condition')
            divided_trials_stim{1}{current_dataset}{context} = one_stim_all;
            divided_trials_ctrl{1}{current_dataset}{context} = one_ctrl_all;
        else %because in passive and spont most conditions (correct, left_turns) do not have anything 
            divided_trials_stim{1}{current_dataset}{context} = zero_stim_all;
            divided_trials_ctrl{1}{current_dataset}{context} = zero_ctrl_all;
        end

        divided_trials_stim{2}{current_dataset}{context} = zero_stim_all;
        divided_trials_ctrl{2}{current_dataset}{context} = zero_ctrl_all;
    end
end
