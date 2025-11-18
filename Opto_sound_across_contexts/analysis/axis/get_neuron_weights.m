function [proj,proj_ctrl,proj_norm,proj_ctrl_norm, weights,trial_corr_context,percent_correct] = get_neuron_weights(dff_st, chosen_mice, all_celltypes,sig_mod_boot,varargin)
        total_trials = {};
        possible_celltypes = fieldnames(all_celltypes{1,1});

        %LOAD VIRMEN TRIAL INFO
        all_trial_info = load('V:\Connie\results\opto_sound_2025\context\sound_info\active_all_trial_info_sounds.mat').all_trial_info_sounds; %all_trial_info

        rng(2025);
    % Loop through the selected mice datasets
    for current_dataset = chosen_mice
        % Example: Randomly split trials into train (80%) and test (20%)
        total_trials_stim = [size(dff_st{1, current_dataset}.stim,1),size(dff_st{2, current_dataset}.stim,1)]; %get total # trials across contexts
        total_trials_ctrl = [size(dff_st{1, current_dataset}.ctrl,1),size(dff_st{2, current_dataset}.ctrl,1)]; %get total # trials across contexts

        train_frac = 0.5;
        ctx_count = 0;ctx_count2 = 0;
        train_trials = [];
        test_trials = [];

        train_trials_ctr = [];
        test_trials_ctr = [];

        trial_counts = [];
        for ctx = 1:2
            num_stim_train = round(total_trials_stim(ctx) * train_frac); % Number of train trials for stim
            num_ctrl_train = round(total_trials_ctrl(ctx) * train_frac); % Number of train trials for control
            
            % Generate random indices for train and test trials
            train_stim_trials_idx{ctx} = randperm((total_trials_stim(ctx)), num_stim_train)+ctx_count;
            test_stim_trials_idx{ctx} = setdiff((1:total_trials_stim(ctx))+ctx_count, train_stim_trials_idx{ctx});
            
            train_ctrl_trials_idx{ctx} = randperm((total_trials_ctrl(ctx)), num_ctrl_train)+ctx_count2;
            test_ctrl_trials_idx{ctx} = setdiff((1:total_trials_ctrl(ctx))+ctx_count2, train_ctrl_trials_idx{ctx});
            ctx_count = ctx_count+total_trials_stim(ctx);
            ctx_count2 = ctx_count2+total_trials_ctrl(ctx);
            
            train_trials = [train_trials,train_stim_trials_idx{ctx}];
            test_trials = [test_trials,test_stim_trials_idx{ctx}];
            train_trials_ctr = [train_trials_ctr,train_ctrl_trials_idx{ctx}];
            test_trials_ctr = [test_trials_ctr ,test_ctrl_trials_idx{ctx}];
                
        end

        train_trials2 = test_trials;
        test_trials2 = train_trials;
        train_trials_ctr2 = test_trials_ctr ;
        test_trials_ctr2 = train_trials_ctr; 
        train_ctrl_trials_idx2 = test_ctrl_trials_idx;
        test_ctrl_trials_idx2 = train_ctrl_trials_idx;
        train_stim_trials_idx2 = test_stim_trials_idx;
        test_stim_trials_idx2 =train_stim_trials_idx;

%         ctx_count = 0;ctx_count2 = 0;
%         train_trials2 = [];
%         test_trials2 = [];
% 
%         train_trials_ctr2 = [];
%         test_trials_ctr2 = [];
% 
%         trial_counts = [];
%         for ctx = 1:2
%             num_stim_train = round(total_trials_stim(ctx) * train_frac); % Number of train trials for stim
%             num_ctrl_train = round(total_trials_ctrl(ctx) * train_frac); % Number of train trials for control
%             
%             % Generate random indices for train and test trials
%             train_stim_trials_idx{ctx} = randperm((total_trials_stim(ctx)), num_stim_train)+ctx_count;
%             test_stim_trials_idx{ctx} = setdiff((1:total_trials_stim(ctx))+ctx_count, train_stim_trials_idx{ctx});
%             
%             train_ctrl_trials_idx{ctx} = randperm((total_trials_ctrl(ctx)), num_ctrl_train)+ctx_count2;
%             test_ctrl_trials_idx{ctx} = setdiff((1:total_trials_ctrl(ctx))+ctx_count2, train_ctrl_trials_idx{ctx});
%             ctx_count = ctx_count+total_trials_stim(ctx);
%             ctx_count2 = ctx_count2+total_trials_ctrl(ctx);
%             
%             train_trials2 = [train_trials2,train_stim_trials_idx{ctx}];
%             test_trials2 = [test_trials2,test_stim_trials_idx{ctx}];
%             train_trials_ctr2 = [train_trials_ctr2,train_ctrl_trials_idx{ctx}];
%             test_trials_ctr2 = [test_trials_ctr2 ,test_ctrl_trials_idx{ctx}];
%                 
%         end

        for celltype = 1:4

            if celltype == 4
                mod_cells = 1:size(dff_st{1, current_dataset}.stim,2);
                if ~isempty(sig_mod_boot)
                    mod_cells = sig_mod_boot{1, current_dataset};
                end
            else
                mod_cells = all_celltypes{1,current_dataset}.(possible_celltypes{celltype});
            end
            % Get the data for the stim and control contexts
            stim_matrix = [dff_st{1, current_dataset}.stim(:,mod_cells,:); dff_st{2, current_dataset}.stim(:,mod_cells,:)]; % stim + sound (active and passive)
            ctrl_matrix = [dff_st{1, current_dataset}.ctrl(:,mod_cells,:); dff_st{2, current_dataset}.ctrl(:,mod_cells,:)]; % sound only (active and passive)
            [~, n_neurons, frames] = size(stim_matrix);
%             [trials_ctrl] = size(ctrl_matrix, 1);

            trials_stim = train_trials;
            trials_ctrl = train_trials_ctr;
            % Define the frames for after and before stimulus
            aframes = 63:93;  % After stimulus
            bframes = 50:59;   % Before stimulus
    
%             % Initialize trial indexing containers
%             context_count = 0;
%             context_count_ctrl = 0;
%             % Generate trial indices for stim and control contexts (active and passive)
%             for contexts = 1:2
%                 total_trials{current_dataset, contexts, 1} = (1:size(dff_st{contexts, current_dataset}.stim, 1)) + context_count; % active stim (stim + sound)
%                 total_trials{current_dataset, contexts, 2} = (1:size(dff_st{contexts, current_dataset}.ctrl, 1)) + context_count_ctrl; % active sound (sound only)
%                 context_count = context_count + size(dff_st{1, current_dataset}.stim, 1);  % Update context count for stim trials
%                 context_count_ctrl = context_count_ctrl + size(dff_st{1, current_dataset}.ctrl, 1);  % Update context count for control trials
%             end
    
            % --- 1) Calculate Sound Axis (pre-post sound) ---
            data_matrix = ctrl_matrix;  % Use the control matrix for the sound axis calculation
            prepost_trial = [];
            data_matrix = ctrl_matrix;
            tr_ct = 0;
            for tr = train_trials_ctr %1:trials_ctrl
                tr_ct = tr_ct +1;
                prepost_trial(tr,:,:) = [nanmean(data_matrix(tr, 1:n_neurons, aframes), [3]);
                                       nanmean(data_matrix(tr, 1:n_neurons, bframes), [3])]; % [post, pre]
            end
            sound_diff = mean((squeeze(prepost_trial(:, 1,:))) -squeeze(prepost_trial(:, 2,:)),[1]);%mean((squeeze(prepost_trial(:, 1,:))));% -squeeze(prepost_trial(:, 2,:)),[1]); %difference size is neurons
            norm_sound_diff = sound_diff ./ sqrt(sum(sound_diff.^2)); % Normalize sound axis
    
            if nargin > 4
                mod_cells2 = varargin{1,1}{1, current_dataset};
                stim_matrix2 = [dff_st{1, current_dataset}.stim(:,mod_cells2,:); dff_st{2, current_dataset}.stim(:,mod_cells2,:)]; % stim + sound (active and passive)
                ctrl_matrix2 = [dff_st{1, current_dataset}.ctrl(:,mod_cells2,:); dff_st{2, current_dataset}.ctrl(:,mod_cells2,:)]; % sound only (active and passive)
                
                % --- 2) Calculate Stimulus + Sound Axis (stim + sound - sound) ---
                stim_sound_mean = mean(stim_matrix2(train_trials,:, aframes), [1, 3]);
                sound_mean = mean(ctrl_matrix2(train_trials_ctr, :, aframes), [1, 3]);
                stim_axis = stim_sound_mean - sound_mean; % Difference between stim + sound and sound
                norm_stim_diff = stim_axis ./ sqrt(sum(stim_axis.^2)); % Normalize stimulus axis
            else
                 % --- 2) Calculate Stimulus + Sound Axis (stim + sound - sound) ---
                stim_sound_mean = mean(stim_matrix(train_trials, 1:n_neurons, aframes), [1, 3]);
                sound_mean = mean(ctrl_matrix(train_trials_ctr, 1:n_neurons, aframes), [1, 3]);
                stim_axis = stim_sound_mean - sound_mean; % Difference between stim + sound and sound
                norm_stim_diff = stim_axis ./ sqrt(sum(stim_axis.^2)); % Normalize stimulus axis
            end

           
    
            % --- 3) Calculate Active-Passive Axis (active - passive) ---

            %use different trials to find this axis (just in case)
            active_passive_sound_mean = [
                nanmean(ctrl_matrix(train_trials_ctr2(find(ismember( train_trials_ctr2,train_ctrl_trials_idx2{1}))), 1:n_neurons, bframes), [1, 3]); % active sound total_trials{current_dataset, 1, 2}
                nanmean(ctrl_matrix(train_trials_ctr2(find(ismember( train_trials_ctr2,train_ctrl_trials_idx2{2}))), 1:n_neurons, bframes), [1, 3])]; % passive sound total_trials{current_dataset, 2, 2}
            context_axis = active_passive_sound_mean(1,:) - active_passive_sound_mean(2,:); % active - passive
            norm_context_diff = context_axis ./ sqrt(sum(context_axis.^2)); % Normalize context axis
    
    
            %5) PROJECT THE DATA! onto test trials!!
            tr = 0;
            for trial = test_trials_ctr%1: trials_ctrl
                tr = tr+1;
                sound_proj_ctrl(tr,:) = squeeze(ctrl_matrix(trial,:,:))'*norm_sound_diff';
                stim_proj_ctrl(tr,:) = squeeze(ctrl_matrix(trial,:,:))'*norm_stim_diff';
%                 context_proj_ctrl(tr,:) = squeeze(ctrl_matrix(trial,:,:))'*norm_context_diff';
            end

            tr = 0;
            for trial = test_trials%1: trials_stim
                tr = tr+1;
                sound_proj_stim(tr,:) = squeeze(stim_matrix(trial,:,:))'*norm_sound_diff';
                stim_proj_stim(tr,:) = squeeze(stim_matrix(trial,:,:))'*norm_stim_diff';
%                 context_proj_stim(tr,:) = squeeze(stim_matrix(trial,:,:))'*norm_context_diff';
            end

            tr = 0;
            for trial = test_trials_ctr2
                tr = tr+1;
                context_proj_ctrl(tr,:) = squeeze(ctrl_matrix(trial,:,:))'*norm_context_diff';
            end

            tr = 0;
            for trial = test_trials2
                tr = tr+1;
                context_proj_stim(tr,:) = squeeze(stim_matrix(trial,:,:))'*norm_context_diff';
            end

            %axis save into a structure?
            weights{current_dataset,celltype}.sound = norm_sound_diff;
            weights{current_dataset,celltype}.stim = norm_stim_diff;
            weights{current_dataset,celltype}.context = norm_context_diff;

            %projections
            %stim
            for context = 1:2
                proj{current_dataset,celltype,context}.sound = sound_proj_stim(find(ismember( test_trials,test_stim_trials_idx{context})),:); %total_trials{current_dataset, context, 1}
                proj{current_dataset,celltype,context}.stim = stim_proj_stim(find(ismember( test_trials,test_stim_trials_idx{context})),:);
%                 proj{current_dataset,celltype,context}.context = context_proj_stim(find(ismember( test_trials,test_stim_trials_idx{context})),:);
                proj{current_dataset,celltype,context}.context = context_proj_stim(find(ismember( test_trials2,test_stim_trials_idx2{context})),:);
                
                %ctrl
                proj_ctrl{current_dataset,celltype,context}.sound = sound_proj_ctrl(find(ismember( test_trials_ctr,test_ctrl_trials_idx{context})),:);
                proj_ctrl{current_dataset,celltype,context}.stim = stim_proj_ctrl(find(ismember( test_trials_ctr,test_ctrl_trials_idx{context})),:);
%                 proj_ctrl{current_dataset,celltype,context}.context = context_proj_ctrl(find(ismember( test_trials_ctr,test_ctrl_trials_idx{context})),:);
                proj_ctrl{current_dataset,celltype,context}.context = context_proj_ctrl(find(ismember( test_trials_ctr2,test_ctrl_trials_idx2{context})),:);

                % find correlations before and after
                trial_corr_context{current_dataset,celltype,context}.sound =  corr(nanmean(sound_proj_ctrl(find(ismember( test_trials_ctr,test_ctrl_trials_idx{context})),aframes),2),nanmean(context_proj_ctrl(find(ismember( test_trials_ctr,test_ctrl_trials_idx{context})),bframes),2),'Type','Pearson');% corr(nanmean(sound_proj_ctrl(total_trials{current_dataset, context, 2},:),2),nanmean(context_proj_ctrl(total_trials{current_dataset, context, 2},:),2),'Type','Pearson');
                trial_corr_context{current_dataset,celltype,context}.stim = corr(nanmean(stim_proj_stim(find(ismember( test_trials,test_stim_trials_idx{context})),aframes),2),nanmean(context_proj_stim(find(ismember( test_trials,test_stim_trials_idx{context})),bframes),2),'Type','Pearson');

                 % Normalize (z-score) the projections per dataset/context
                for key = ["sound", "stim", "context"]
                    this_proj = proj_ctrl{current_dataset,celltype,context}.(key);
                    proj_ctrl_norm{current_dataset,celltype,context}.(key) = (this_proj - mean(this_proj,2)) ./ std(this_proj,[],2);
                
                    this_proj = proj{current_dataset,celltype,context}.(key);
                    proj_norm{current_dataset,celltype,context}.(key) = (this_proj - mean(this_proj,2)) ./ std(this_proj,[],2);
                end
            end

            %save correct trials
            all_correct_trials = [all_trial_info(current_dataset).ctrl(:).correct];
            percent_correct{current_dataset} = all_correct_trials(test_trials_ctr2(find(ismember( test_trials_ctr2,test_ctrl_trials_idx2{1}))));

    
    
    
%             %6) small figures
%             figure;
%             colorss = [0,0,0;.5,.5,.5];
%             colorss2 = [.4,0,0;.8,0,0]
%             hold on;
%             for contexts = 1:2
%                 plot(1:122,mean(sound_proj_ctrl(total_trials{current_dataset, contexts, 2},:)),'color', colorss(contexts,:)); % 
%                 plot(1:122,mean(sound_proj_stim(total_trials{current_dataset, contexts, 1},:)),'color', colorss2(contexts,:)); % 
%             end
%     

        end
    end
end