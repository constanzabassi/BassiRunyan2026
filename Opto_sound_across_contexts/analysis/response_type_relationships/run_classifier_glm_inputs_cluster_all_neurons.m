%% SVM predict choice using cell type activity
function [acc] = run_classifier_glm_inputs_cluster_all_neurons(current_mouse , save_string_glm,all_celltypes,mdl_param, alignment,info)
possible_celltypes = fieldnames(all_celltypes{1,1});

acc = {};
shuff_acc = {};
mdl_results = {};
for m = current_mouse
%     ss = info.server(m);
%     ss = ss {1,1};
info.mouse_date{1,m} = strrep(info.mouse_date{1,m}, '\', '/');
    base = strcat('/ix/crunyan/cdb66/Data/',num2str(info.mouse_date{1,m}),'/',save_string_glm,'/');

%load GLM data!
for splits = 1:10
dir_base = strcat(base,'/prepost trial cv 73 #', num2str(splits));
base_testing = strcat(dir_base, '/test');
% Process training and testing data
load(strcat(dir_base, '/condition_array_trials.mat'));
% Load imaging data
if alignment.active_passive == 1
    base_imaging = strcat('/ix/crunyan/cdb66/Data/',num2str(info.mouse_date{1,m}),'/VR/');
else
    base_imaging = strcat('/ix/crunyan/cdb66/Data/',num2str(info.mouse_date{1,m}),'/passive/');
end
load(strcat(base_imaging,'/imaging.mat'));
train_imaging_spk = make_imaging_from_trials(condition_array_trials, imaging);

%For some reason I saved them differently for active vs passive
if alignment.active_passive == 1
    load(strcat(base_testing, '/condition_array_trials.mat'));
    test_imaging_spk = make_imaging_from_trials(condition_array_trials, imaging);
else
    load(strcat(dir_base, '/condition_array_trials_test.mat'));
    test_imaging_spk = make_imaging_from_trials(condition_array_trials_test, imaging);
end

%load minimum # of trials!!
if contains(dir_base, 'passive')
        % Replace "passive" with "pre"
    newDir = strrep(dir_base, 'passive', 'pre');
    load(strcat(newDir,'/sound_trials.mat'));
else
    load(strcat(dir_base,'/sound_trials.mat'));
end

if contains(dir_base, 'passive')
    % Replace "passive" with "pre"
    newDir = strrep(dir_base, 'passive', 'pre');
    load(strcat(newDir,'/photostim_trials.mat'));
else
    load(strcat(dir_base,'/photostim_trials.mat'));
end

%could consider using the exact same trials as original decoder (but would
%not work for shuffled bc the trials ids are shuffled
%find(decoder_results.aligned.shuffled.photostim(1).cat_results.alignment.trials_used.train);
% disp(['Saving path: ' info.savepath '/SVM_' alignment.data_type '_' info.savestr]);
    for it = 1:mdl_param.num_iterations
%         it
%     for m = 1:length(imaging_st)
        count = 0;
%         m
        for ce = 1:4 %4th will be all cells together no subsamples!
            count = count+1;
            mdl_param.mouse = m;
            %do current split
%             ex_imaging = imaging_st{1,m};
            imaging_train_input = train_imaging_spk; %imaging_st{1,m};
            imaging_test_input = test_imaging_spk;
            

            if alignment.active_passive == 2
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging_train_input,30,alignment.active_passive);
                [align_info_test,alignment_frames_test,left_padding_t,right_padding_t] = find_align_info_updated (imaging_test_input,30,alignment.active_passive);
            else
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging_train_input,30);
                [align_info_test,alignment_frames_test,left_padding_t,right_padding_t] = find_align_info_updated (imaging_test_input,30);
            end
            [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging_train_input,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames
            [aligned_imaging_test,imaging_array_test,align_info_test] = align_behavior_data (imaging_test_input,align_info_test,alignment_frames_test,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames

                        
            %subsample cells!
            if ce <4
                mdl_param.mdl_cells = all_celltypes{1,m}.(possible_celltypes{ce});
            else
                mdl_param.mdl_cells = 1:sum(cellfun(@length,struct2cell(all_celltypes{1,m}))); %all cells together
            end
            %BALANCE TRIALS!!! THIS IS THE PART THAT MIGHT DIFFER FROM WHAT I HAD BEFORE (COPYING TO GLM DECODER CODE)            
            if count == 1 %keep the trials the same across cell types!
                %load same trials used in glm!!!
                if mdl_param.field_to_predict == 1
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_outcome.mat'));
                    selected_trials = decoder_results.aligned.outcome(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.outcome(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 2
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_choice.mat'));
                    selected_trials = decoder_results.aligned.choice(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.choice(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 3
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_sound_category.mat'));
                    selected_trials = decoder_results.aligned.sound_category(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.sound_category(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 4
                    load(strcat(base,'/decoding/',num2str(splits),'_1/decoder_results_regular_photostim_updated.mat'));
                    selected_trials = decoder_results.aligned.photostim(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.photostim(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                end

                selected_trials_id = find(mdl_param.selected_trials);
                rearraged_trials = selected_trials_id(randperm(length(selected_trials_id)));

                selected_trials_test_id = find(mdl_param.selected_trials_test);
                rearraged_trials_test = selected_trials_test_id(randperm(length(selected_trials_test_id)));
               
            
            end
            % assign to param regardless
            mdl_param.selected_trials = selected_trials;
            mdl_param.selected_trials_test = selected_trials_test;
    
            %get X and Y ready for classifier
            fieldss = fieldnames(imaging_train_input(1).virmen_trial_info);
%             [~, condition_array] = divide_trials_updated (ex_imaging,{fieldss{mdl_param.field_to_predict}});
            [~, condition_array] = divide_trials_updated (imaging_train_input,{fieldss{mdl_param.field_to_predict}});
            %shuffle trial order before putting it into the matrix

            mdl_Y = condition_array(rearraged_trials,2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X = aligned_imaging(rearraged_trials,:,:);

            %repeat for test trials!
            [~, condition_array_test] = divide_trials_updated (imaging_test_input,{fieldss{mdl_param.field_to_predict}});
            %shuffle trial order before putting it into the matrix
            mdl_Y_test = condition_array_test(rearraged_trials_test,2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X_test = aligned_imaging_test(rearraged_trials_test,:,:);
            
            fprintf(['split #: ', num2str(splits),' || subsample #: ', num2str(it),' || mouse :' , num2str(info.mouse_date{1,m}), ' ||    celltype :' num2str(ce), ' ||  size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) '\n']);
            output{splits,it,ce} = classify_over_time_glm_inputs(mdl_X,mdl_Y, mdl_param,mdl_X_test,mdl_Y_test);
            
            % gete accuracy!
            acc{splits,it,ce} = output{splits,it,ce}.accuracy;
            shuff_acc{splits,it,ce} = output{splits,it,ce}.shuff_accuracy;
            mdl_results{splits, it, ce}.train_accuracy = output{splits, it, ce}.train_accuracy;
            mdl_results{splits, it, ce}.shuffled_train_accuracy = output{splits, it, ce}.shuff_train_accuracy;
            mdl_results{splits, it, ce}.BoxConstraints = output{splits, it, ce}.mdl{1, 1}.BoxConstraints(1);

            %get betas across all celltypes
            if ce == 4
                for bin = 1:length(output{splits,it,ce}.mdl)
                    betas{splits,it,bin} = output{splits,it,ce}.mdl{1,bin}.Beta; 
                    mdl_results{splits, it, ce}.bin(bin).IsSupportVector = output{splits, it, ce}.mdl{1, bin}.IsSupportVector;
                    mdl_results{splits, it, ce}.bin(bin).Alpha = output{splits, it, ce}.mdl{1, bin}.Alpha;
                    mdl_results{splits, it, ce}.bin(bin).Bias = output{splits, it, ce}.mdl{1, bin}.Bias;
                end
            end
            clear output
            all_model_outputs{splits,it,ce} = mdl_param;
        end
    end
end
end

%convert output to matrix form for easier indexing
%% Save the output

%save info variables
%output{1,1,1}.info = info; %save in the first one

% mkdir([info.savepath '/SVM_' alignment.data_type '_' info.savestr])
% cd([info.savepath '/SVM_' alignment.data_type '_' info.savestr])

mkdir(strcat(base,'/decoding/SVM_1/'));
cd(strcat(base,'/decoding/SVM_1/'));

if mdl_param.field_to_predict == 1
    save_string = 'outcome_all';
elseif mdl_param.field_to_predict == 2
    save_string = 'choice_all';
elseif mdl_param.field_to_predict == 3
    save_string = 'sound_category_all';
elseif mdl_param.field_to_predict == 4
    save_string = 'photostim_all';
end


svm_info = info;
save(strcat(save_string,'_svm_info'),'svm_info','-v7.3');
save(strcat(save_string,'_betas'),'betas','-v7.3');
save(strcat(save_string,'_all_model_outputs'),'all_model_outputs','-v7.3');
save(strcat(save_string,'_acc'),'acc','-v7.3');
save(strcat(save_string,'_shuff_acc'),'shuff_acc','-v7.3');
save(strcat(save_string,'_mdl_results'),'mdl_results','-v7.3');

