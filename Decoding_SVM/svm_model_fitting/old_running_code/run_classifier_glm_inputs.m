%% SVM predict choice using cell type activity
function [output, output_mat] = run_classifier_glm_inputs(save_string_glm,all_celltypes,mdl_param, alignment,plot_info,info,single_event)
possible_celltypes = fieldnames(all_celltypes{1,1});

for m = 1:length(info.mouse_date)
    m
    ss = info.server(m);
    ss = ss {1,1};
    base = strcat(num2str(ss),'\Connie\ProcessedData\',num2str(info.mouse_date{1,m}),'\',save_string_glm,'/');

%load GLM data!
for splits = 1:10
dir_base = strcat(base,'/prepost trial cv 73 #', num2str(splits));
base_testing = strcat(dir_base, '/test');
% Process training and testing data
load(strcat(dir_base, '/condition_array_trials.mat'));
% Load imaging data
if alignment.active_passive == 1
    base_imaging = strcat(num2str(ss),'\Connie\ProcessedData\',num2str(info.mouse_date{1,m}),'\VR\');
else
    base_imaging = strcat(num2str(ss),'\Connie\ProcessedData\',num2str(info.mouse_date{1,m}),'\passive\');
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
disp(['Saving path: ' info.savepath '\SVM_' alignment.data_type '_' info.savestr]);
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
            
%             %original code
%             if single_event == 1
%                 [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30,1);
%             else
%                 [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
%             end

            if alignment.active_passive == 2
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging_train_input,30,alignment.active_passive);
                [align_info_test,alignment_frames_test,left_padding_t,right_padding_t] = find_align_info_updated (imaging_test_input,30,alignment.active_passive);
            else
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging_train_input,30);
                [align_info_test,alignment_frames_test,left_padding_t,right_padding_t] = find_align_info_updated (imaging_test_input,30);
            end
            [aligned_imaging,imaging_array,align_info] = align_behavior_data (imaging_train_input,align_info,alignment_frames,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames
            [aligned_imaging_test,imaging_array_test,align_info_test] = align_behavior_data (imaging_test_input,align_info_test,alignment_frames_test,left_padding,right_padding,alignment); % sample_data is n_trials x n_cells x n_frames

%             [aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
            
%             [all_conditions, condition_array_trials] = divide_trials(imaging_train_input); % (ex_imaging); %divide trials into all possible conditions
            %  condition_array_trials (trial_ids, correct or not, left or not, stim or not)
                        
            %subsample cells!
            if ce <4
                num_observations_needed = min(cellfun(@length,struct2cell(all_celltypes{1,m}))); %min number of cells 
                sub_data = subsample_fun(all_celltypes{1,m}.(possible_celltypes{ce}),num_observations_needed);
                mdl_param.mdl_cells = sub_data;
            else
                mdl_param.mdl_cells = 1:sum(cellfun(@length,struct2cell(all_celltypes{1,m}))); %all cells together
            end
            %BALANCE TRIALS!!! THIS IS THE PART THAT MIGHT DIFFER FROM WHAT I HAD BEFORE (COPYING TO GLM DECODER CODE)            
            if count == 1 %keep the trials the same across cell types!
                %load same trials used in glm!!!
                if mdl_param.field_to_predict == 1
                    load(strcat(base,'\decoding\',num2str(splits),'_1\decoder_results_regular_outcome.mat'));
                    selected_trials = decoder_results.aligned.outcome(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.outcome(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 2
                    load(strcat(base,'\decoding\',num2str(splits),'_1\decoder_results_regular_choice.mat'));
                    selected_trials = decoder_results.aligned.choice(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.choice(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 3
                    load(strcat(base,'\decoding\',num2str(splits),'_1\decoder_results_regular_sound_category.mat'));
                    selected_trials = decoder_results.aligned.sound_category(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.sound_category(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                elseif mdl_param.field_to_predict == 4
                    load(strcat(base,'\decoding\',num2str(splits),'_1\decoder_results_regular_photostim.mat'));
                    selected_trials = decoder_results.aligned.photostim(it).results.alignment.trials_used.train;
                    selected_trials_test = decoder_results.aligned.photostim(it).results.alignment.trials_used.test;
                    mdl_param.selected_trials = selected_trials;
                    mdl_param.selected_trials_test = selected_trials_test;
                end
                
                %[selected_trials,~,~] = get_balanced_field_trials(ex_imaging,mdl_param.fields_to_balance);
                
%                 %mdl_param.fields_to_balance = [1,2]; %{'correct'}=1 {'left_turn'}=2 {'condition'}=3 {'is_stim_trial'}=4
%                 if mdl_param.field_to_predict == 3
%                     
%                     min_trials = sound_trials;
%                     if alignment.single_balance == 1
%                          if alignment.active_passive == 1
%                             field_indices = [2,3]; % %virmen fields in order: {'correct'1 }{'left_turn'2} {'condition'3}{'is_stim_trial'4}
%         %                      %varagin would have directory of sound_trials or photostim_trials
%                               %only balance the thing we are predicting for the test!
%                             field_indices_test = [3];
%                             if length(min_trials)>2
%                                 min_trials(2) = min_trials(3) *2;
%                                 min_trials(3) = [];
%                             else
%                                 min_trials(2) = min_trials(2) *2;
%                             end
%             
%                         else %PASSIVE
%                             field_indices = [3]; % %NO LEFT TURN
%                             field_indices_test = [3];
%                             if length(min_trials)>2
%                                 min_trials(2) = min_trials(3);
%                                 min_trials(3) = [];
%                             end
%                             min_trials = min_trials*2;
%                         end
%                     else
%                         if alignment.active_passive == 1
%                             field_indices = [2,3]; % %virmen fields in order: {'correct'1 }{'left_turn'2} {'condition'3}{'is_stim_trial'4}
%                             field_indices_test = [2,3];
%             
%                         else %PASSIVE
%                             field_indices = [3]; % %NO LEFT TURN
%                             field_indices_test = [3];
%                             min_trials = sound_trials*2; %train,test (*2 because only balancing one thing)
%                         end
%                     end
%                 elseif mdl_param.field_to_predict == 2 %decouple choice and stimuli
%                     field_indices = [2,3];
%                     if alignment.single_balance == 1
%                         field_indices_test = [2];
%                         %adding this so shuffles are not including too many trials
%                         
%                         if length(min_trials)>2
%                             min_trials(2) = min_trials(3) *2;
%                             min_trials(3) = [];
%                         else
%                             min_trials(2) = min_trials(2) *2;
%                         end
%                     else
%                         field_indices_test = [2,3];
%                         %adding this so shuffles are not including too many trials
%                         
%                          %varagin would have directory of sound_trials or photostim_trials
%                         min_trials = sound_trials;
%                     end
%                 elseif  mdl_param.field_to_predict == 1
%                     field_indices = [1,2];
%                     if alignment.single_balance == 1
%                         field_indices_test = [1];
%                         %adding this so shuffles are not including too many trials
%                         
%                         if length(min_trials)>2
%                             min_trials(2) = min_trials(3) *2;
%                             min_trials(3) = [];
%                         else
%                             min_trials(2) = min_trials(2) *2;
%                         end
%                     else
%                         field_indices_test = [1,2];
%                         min_trials = sound_trials;
%                     end
%                 elseif mdl_param.field_to_predict == 4
%                     field_indices = [3,4];
%                     min_trials = photostim_trials;
%                     if alignment.single_balance == 1
%                     %only balance the thing we are predicting for the test!
%                         field_indices_test = [4];
%                         if length(min_trials)>2
%                             min_trials(2) = min_trials(3) *2;
%                             min_trials(3) = [];
%                             else
%                                 min_trials(2) = min_trials(2) *2;
%                         end
%                     else
%                         field_indices_test = [3,4];
%                         min_trials(2) = min_trials(2);
%                     end
%                 end
%                 % Create a temporary imaging structure with only fitting trials
%                 temp_imaging = imaging_train_input(fitting_trials);
%                 
%                 % Get balanced trials (using min)
%                 
%                     [selected_trials, ~, ~, ~] = get_balanced_field_trials(temp_imaging, field_indices,min_trials(1));
%                     %only needed for test here bc of comparisons across models need
%                     %same number of trials!
%                     temp_imaging_test = imaging_test(testing_trials);
%                     [selected_trials_test, ~, ~, ~] = get_balanced_field_trials(temp_imaging_test, field_indices_test,min_trials(2));
%                     test_trial_indices = find(testing_trials);
%                     selected_original_indices_t = test_trial_indices(selected_trials_test);
%                     new_testing_trials(selected_original_indices_t) = true;
%                     n_testing_trials =   nnz(new_testing_trials);
%                     testing_trials = new_testing_trials;
%                     imaging_test = imaging_test(testing_trials);
% 
% 
% 
% 

            else %MAKE SURE YOU USE THE SAME TRIALS ACROSS CELL TYPES 
                mdl_param.selected_trials = selected_trials;
            end
            mdl_param.selected_trials = selected_trials;
    
            %get X and Y ready for classifier
            fieldss = fieldnames(imaging_train_input(1).virmen_trial_info);
%             [~, condition_array] = divide_trials_updated (ex_imaging,{fieldss{mdl_param.field_to_predict}});
            [~, condition_array] = divide_trials_updated (imaging_train_input,{fieldss{mdl_param.field_to_predict}});
            mdl_Y = condition_array(find(mdl_param.selected_trials),2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X = aligned_imaging(find(mdl_param.selected_trials),:,:);

            %repeat for test trials!
            [~, condition_array_test] = divide_trials_updated (imaging_test_input,{fieldss{mdl_param.field_to_predict}});
            mdl_Y_test = condition_array_test(find(mdl_param.selected_trials_test),2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X_test = aligned_imaging_test(find(mdl_param.selected_trials_test),:,:);
            
            fprintf(['split #: ', num2str(splits),' || subsample #: ', num2str(it),' || mouse :' , num2str(m), ' ||    celltype :' num2str(ce), ' ||  size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) '\n']);
            output{splits,it,m,ce} = classify_over_time_glm_inputs(mdl_X,mdl_Y, mdl_param,mdl_X_test,mdl_Y_test);

            %get betas across all celltypes
            if ce == 4
                for bin = 1:length(output{1,1,1,ce}.mdl)
                    betas{splits,it,m,bin} = output{splits,it,m,ce}.mdl{1,bin}.Beta;     
                end
            end
            all_model_outputs{splits,it,m,ce} = mdl_param;
        end
    end
end
end

%convert output to matrix form for easier indexing
%% Save the output

%save info variables
%output{1,1,1}.info = info; %save in the first one

mkdir([info.savepath '\SVM_' alignment.data_type '_' info.savestr])
cd([info.savepath '\SVM_' alignment.data_type '_' info.savestr])

svm_info = info;
save('svm_info','svm_info');
save('betas','betas')
save('all_model_outputs','all_model_outputs','-v7.3');

%SAVE SVM OUTPUT!
save('output','output','-v7.3');

%% make quick figure plots! error across subsamples
mdl_param.event_onset_true = determine_onsets(left_padding,right_padding,alignment.events);
%adjust event onsets to bins!
event_onsets = find(histcounts(mdl_param.event_onset_true,mdl_param.binns+mdl_param.event_onset(1)));
for m = 1:length(info.mouse_date) %:length(imaging_st)
ex_mouse = m;
figure(m);clf;
subplot(2,1,1)
for ce = 1:4
    hold on; 
    title(info.mouse_date{1,m})
    
    temp = [output{1:10,1:mdl_param.num_iterations,m,ce}];
    output_mat{m,ce}.accuracy = cell2mat({temp.accuracy}'); %gives num subsample iterations x timepoints
    output_mat{m,ce}.shuff_accuracy = cell2mat({temp.shuff_accuracy}');
    % find squared error from the mean
    SEM= std(output_mat{m,ce}.accuracy)/sqrt(size(output_mat{m,ce}.accuracy,1));
    shadedErrorBar(1:size(output_mat{m,ce}.accuracy,2),mean(output_mat{m,ce}.accuracy,1), SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:)});

    SEM= std(output_mat{m,ce}.accuracy)/sqrt(size(output_mat{m,ce}.accuracy,1));
    shadedErrorBar(1:size(output_mat{m,ce}.shuff_accuracy,2),mean(output_mat{m,ce}.shuff_accuracy,1), SEM, 'lineProps',{'color', [0.2 0.2 0.2]*ce});

%     plot(output{ex_mouse,ce}.accuracy,'color',plot_info.colors_celltypes(ce,:));
%     plot(output{ex_mouse,ce}.shuff_accuracy,'color',[0.2 0.2 0.2]*ce);


    for i = 1:length(event_onsets)
        xline(event_onsets(i),'--k','LineWidth',1.5)
        if i == 4
            xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
        end
    end
yline(.5,'--k');
end
hold off

subplot(2,1,2)
for ce = 1:4
    hold on; 
        
    shadedErrorBar(1:size(output_mat{m,ce}.accuracy,2),smooth(mean(output_mat{m,ce}.accuracy,1),3, 'boxcar'), smooth(SEM,3, 'boxcar'), 'lineProps',{'color', plot_info.colors_celltype(ce,:)});

    shadedErrorBar(1:size(output_mat{m,ce}.shuff_accuracy,2),smooth(mean(output_mat{m,ce}.shuff_accuracy,1),3, 'boxcar'), smooth(SEM,3, 'boxcar'), 'lineProps',{'color', [0.2 0.2 0.2]*ce});

%     plot(smooth(output{ex_mouse,ce}.accuracy,3, 'boxcar'),'color',plot_info.colors_celltypes(ce,:));
%     plot(smooth(output{ex_mouse,ce}.shuff_accuracy,3, 'boxcar'),'color',[0.2 0.2 0.2]*ce);

    for i = 1:length(event_onsets)
        xline(event_onsets(i),'--k','LineWidth',1.5)
        if i == 4
            xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
        end
    end
yline(.5,'--k');
end
hold off
movegui(gcf,'center')
end

save('output_mat','output_mat');


%save_figs
for m = 1:length(imaging_st)
    str = info.mouse_date{1,m} ;
    if ismember('/',info.mouse_date{1,m})
        str = erase(info.mouse_date{1,m},'/');
    else
        str = erase(info.mouse_date{1,m},'\');
    end
    saveas(m,strcat('SVM_overtime_',str,'.svg'));
    saveas(m,strcat('SVM_overtime_',str,'.png'));
end

%output{1,1,1} = rmfield(output{1,1,1},'info');



