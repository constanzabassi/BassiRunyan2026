function [update_stim_trials_context,update_ctrl_trials_context, updated_mouse_context_tr] = find_specified_VR_trials_in_context_trials(stim_trials_context, ctrl_trials_context, variable_to_find,variable_to_equal,include_all_passive_and_spont)

%LOAD VIRMEN TRIAL INFO
all_trial_info = load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat').all_trial_info_sounds; %all_trial_info
passive_all_trial_info = load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat').all_trial_info_sounds;

num_datasets = length(stim_trials_context);
update_stim_trials_context = cell(size(stim_trials_context));
update_ctrl_trials_context = cell(size(ctrl_trials_context));

if nargin < 5
    include_all_passive_and_spont = false;
end


for dataset_index = 1:num_datasets
    num_contexts = length(stim_trials_context{dataset_index});
    update_stim_trials_context{dataset_index} = cell(1, num_contexts);
    update_ctrl_trials_context{dataset_index} = cell(1, num_contexts);

    for context_index = 1:num_contexts
        % Get trial indices for current context
        stim_trials = stim_trials_context{dataset_index}{context_index};
        ctrl_trials = ctrl_trials_context{dataset_index}{context_index};

        % Context 1: active → apply filtering
        if context_index == 1 || ~include_all_passive_and_spont
            % Use appropriate trial info
            if context_index == 1
                opto_info = all_trial_info(dataset_index).opto;
                ctrl_info = all_trial_info(dataset_index).ctrl;

                %making the assumption that if there is only two contexts ctrl and sound
                %only trials are combined together!
                if num_contexts == 2
                   ctrl_info = [all_trial_info(dataset_index).ctrl,all_trial_info(dataset_index).sound_only];
                end

            else
                opto_info = passive_all_trial_info(dataset_index).opto;
                ctrl_info = passive_all_trial_info(dataset_index).ctrl;

                %making the assumption that if there is only two contexts ctrl and sound
                %only trials are combined together!
                if num_contexts == 2
                   ctrl_info = [passive_all_trial_info(dataset_index).ctrl,passive_all_trial_info(dataset_index).sound_only];
                end
            end

            % Logical mask
            opto_keep = true(1, length(opto_info));
            ctrl_keep = true(1, length(ctrl_info));

            for i = 1:length(variable_to_find)
                var_name = variable_to_find{i};
                val = variable_to_equal{i};

                opto_vals = [opto_info.(var_name)];
                ctrl_vals = [ctrl_info.(var_name)];

                opto_keep = opto_keep & (opto_vals == val);
                ctrl_keep = ctrl_keep & (ctrl_vals == val);
            end

            % Apply filter only to the trials in current context
            update_stim_trials_context{dataset_index}{context_index} = stim_trials(opto_keep(stim_trials));
            update_ctrl_trials_context{dataset_index}{context_index} = ctrl_trials(ctrl_keep(ctrl_trials));

            updated_mouse_context_tr{1,dataset_index}{context_index,1} = stim_trials(opto_keep(stim_trials));
            updated_mouse_context_tr{1,dataset_index}{context_index,2} = ctrl_trials(ctrl_keep(ctrl_trials));


        else
            % Passive/spont: return all trials as-is
            update_stim_trials_context{dataset_index}{context_index} = stim_trials;
            update_ctrl_trials_context{dataset_index}{context_index} = ctrl_trials;

            updated_mouse_context_tr{1,dataset_index}{context_index,1} = stim_trials;
            updated_mouse_context_tr{1,dataset_index}{context_index,2} = ctrl_trials;

        end
    end
end
end

% for dataset_index = 1:length(stim_trials_context)
%     curr_trials = [];
%     for var = 1:length(variable_to_find)
%         if length(variable_to_equal) == 1
%         else
%             %do context 1( active)
%             find([all_trial_info(dataset_index).opto(:).(var)]); %get trials
%             [all_trial_info(dataset_index).ctrl(:).(var)]; %get trials
%         
%             %do context 2(passive)
%             [passive_all_trial_info(dataset_index).opto(:).(var)]; %get trials
%             [passive_all_trial_info(dataset_index).ctrl(:).(var)]; %get trials
%         end
%     end
% 
% 
% end
