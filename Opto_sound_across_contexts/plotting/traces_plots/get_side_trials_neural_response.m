function neural_response_sided = get_side_trials_neural_response(neural_response,mod_params,varargin)
%goal: separate trials into left and right!
%input deconv_response{context,dataset_index,cel}.stim and
%deconv_response{context,dataset_index,cel}.ctrl (inside it is trials x
%cell x frames)

neural_response_sided = {};
% 1) load data that has condition information!
% Load trial information (adjust paths as needed) -virmen trial info left turns/sound condition/is stim
load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat');
passive_all_trial_info_sounds = load('V:\Connie\results\opto_sound_2025\context\sound_info\passive_all_trial_info_sounds.mat').all_trial_info_sounds;

nContexts = 2;
frames = size(neural_response{1,1,1}.stim,3);
% Loop through datasets.
for current_dataset = 1: size(neural_response,2)
%     current_dataset
    for context = 1:nContexts
            if context == 1
                if strcmpi(mod_params.data_type,'sound')
                    current_conditions = [all_trial_info_sounds(current_dataset).opto.condition];
                    current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.condition,all_trial_info_sounds(current_dataset).sound_only.condition];
                else
                    current_conditions = [all_trial_info_sounds(current_dataset).opto.condition];
                    current_conditions_ctrl = [all_trial_info_sounds(current_dataset).ctrl.condition];
                end
            elseif context == 2
                if strcmpi(mod_params.data_type,'sound')
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
    
            % Get trial indices for the current context.
            stim_trials = 1:length(current_conditions);
            ctrl_trials = 1:length(current_conditions_ctrl);
    
            %get the left and right trials for 
            [~, ~, ~, ~, ~, ~, left_stim_all, left_ctrl_all,  right_stim_all, right_ctrl_all] = ...
                    find_sound_trials_single(stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl);

            %separate neural response into left and right sided
            for celltype = 1:size(neural_response,3)
                if ~isnan(neural_response{context,current_dataset,celltype}.stim)
                    %left
                    neural_response_sided{1,context,current_dataset,celltype}.stim = neural_response{context,current_dataset,celltype}.stim(left_stim_all,:,:);
                    neural_response_sided{1,context,current_dataset,celltype}.ctrl = neural_response{context,current_dataset,celltype}.ctrl(left_ctrl_all,:,:);
                    %right
                    neural_response_sided{2,context,current_dataset,celltype}.stim = neural_response{context,current_dataset,celltype}.stim(right_stim_all,:,:);
                    neural_response_sided{2,context,current_dataset,celltype}.ctrl = neural_response{context,current_dataset,celltype}.ctrl(right_ctrl_all,:,:);

                    %find max side (used for mod index calculations)
                    if nargin > 2
                        %preferred/max
                        results = mod_params.results;
                        chosen_cells = varargin{1,1};
                        pref_side = results(current_dataset).context(context).cv_mod_index_separate.side(chosen_cells{current_dataset,celltype});
                        %separate into left and right cells
                        % Find indices of left- and right-preferring neurons
                        left_cells  = find(strcmp(pref_side,'left'));
                        right_cells = find(strcmp(pref_side,'right'));

                        %Find mean here because they probably
                        %have different # of trials!
                        left_stim_response = [];left_ctrl_response =[];right_stim_response =[];right_ctrl_response =[];
                        % --- LEFT preferred neurons ---
                        if ~isempty(left_cells)
                            left_stim_response = ...
                                squeeze(mean(neural_response{context,current_dataset,celltype}.stim(left_stim_all,left_cells,:),1));
                            left_ctrl_response = ...
                                squeeze(mean(neural_response{context,current_dataset,celltype}.ctrl(left_ctrl_all,left_cells,:),1));
                            if size(left_stim_response,1) >size(left_stim_response,2) && size(left_stim_response,2) ~= frames
                                left_stim_response = left_stim_response.'; 
                                left_ctrl_response = left_ctrl_response.';
                            end
                        end

                        % --- RIGHT preferred neurons ---
                        if ~isempty(right_cells)
                            right_stim_response = ...
                                squeeze(mean(neural_response{context,current_dataset,celltype}.stim(right_stim_all,right_cells,:),1));
                            right_ctrl_response = ...
                                squeeze(mean(neural_response{context,current_dataset,celltype}.ctrl(right_ctrl_all,right_cells,:),1));
                            if size(right_stim_response,1) >size(right_stim_response,2) && size(right_stim_response,2) ~= frames
                                right_stim_response = right_stim_response.';
                                right_ctrl_response = right_ctrl_response.';
                            end
                        end
                        if ~isempty(left_cells) && ~isempty(right_cells)
                            neural_response_sided{3,context,current_dataset,celltype}.stim = [left_stim_response;right_stim_response];
                            neural_response_sided{3,context,current_dataset,celltype}.ctrl = [left_ctrl_response;right_ctrl_response];
                        elseif ~isempty(left_cells) && isempty(right_cells)
                            neural_response_sided{3,context,current_dataset,celltype}.stim = [left_stim_response];
                            neural_response_sided{3,context,current_dataset,celltype}.ctrl = [left_ctrl_response];
                        elseif ~isempty(right_cells) && isempty(left_cells)
                            neural_response_sided{3,context,current_dataset,celltype}.stim = [right_stim_response];
                            neural_response_sided{3,context,current_dataset,celltype}.ctrl = [right_ctrl_response];
                        end
                    end
                else
                    %left
                    neural_response_sided{1,context,current_dataset,celltype}.stim = NaN;
                    neural_response_sided{1,context,current_dataset,celltype}.ctrl = NaN;
                    %right
                    neural_response_sided{2,context,current_dataset,celltype}.stim = NaN;
                    neural_response_sided{2,context,current_dataset,celltype}.ctrl = NaN;

                end
                
            end
    end
end
