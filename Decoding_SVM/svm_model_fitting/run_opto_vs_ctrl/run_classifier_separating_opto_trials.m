%% SVM predict choice using cell type activity
function [output ] = run_classifier_separating_opto_trials(all_celltypes,mdl_param, alignment,info,single_event)
possible_celltypes = fieldnames(all_celltypes{1,1});
splits = 1; %putting all the data together
if alignment.active_passive == 2
    field_string = 'passive_sound_category_14to100'; %# are frames used to define peaks
else
    field_string = 'sound_category_14to100'; %# are frames used to define peaks
end

%load informative cells
data = load(strcat('V:\Connie\ProcessedData\sorted_peaks/sorted_peaks_',field_string,'.mat')); %putting it here so I dont have to do it per dataset 
celltypes_to_do = 1; %just doing pyr for right now


disp(['Saving path: ' info.savepath ]);
for opto_trials = 1:2
    dataset_count = 0;
    for current_dataset_id = info.datasets_to_model
            current_dataset_id
            dataset_count = dataset_count +1;

            %GET CURRENT MOUSE'S TOP NEURONS
            curr_mouse_updated = strrep(info.mouse_date{1,current_dataset_id}, '\', '/');
            curr_mouse = strrep(curr_mouse_updated, '/', '_');
            curr_mouse = strrep(curr_mouse, '-', '_');
            curr_mouse = [curr_mouse '_pyr'];

            % load imaging data!
            if alignment.active_passive == 1
                base_imaging = strcat(num2str(info.serverid{1,current_dataset_id}), '\Connie/ProcessedData/',num2str(info.mouse_date{1,current_dataset_id}),'/VR/');
            else
                base_imaging = strcat(num2str(info.serverid{1,current_dataset_id}), '\Connie/ProcessedData/',num2str(info.mouse_date{1,current_dataset_id}),'/passive/');
            end
            load(strcat(base_imaging,'/imaging.mat'));

            %eliminate long trials
            imaging_st{1,1} = imaging;
            [imaging_st,~] = eliminate_trials(imaging_st,7,800);
            imaging = imaging_st{1,1};

        for it = 1:mdl_param.num_iterations
            it
            for ce = 1:5 %4th will be all cells together no subsamples!
                mdl_param.mouse = current_dataset_id;
                ex_imaging = imaging;%%imaging_st{1,m};

                if alignment.active_passive == 2
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30,alignment.active_passive);
                else
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30);
                end
                
%                 if single_event == 1
%                     [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30,1);
%                 else
%                     [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
%                 end
                [aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
                
                [all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
                %  condition_array_trials (trial_ids, correct or not, left or not, stim or not)
                
                % [train_imaging, test_imaging,all_trials] = split_imaging_train_test_cb(ex_imaging,condition_array_trials,0.7,0,0);
                
    %             mdl_param.mdl_cells = all_celltypes{1,m}.(possible_celltypes{ce}); %which cell type to use
    
                %subsample cells!
                if ce <4
                    num_observations_needed = min(cellfun(@length,struct2cell(all_celltypes{1,current_dataset_id}))); %min number of cells 
                    sub_data = subsample_fun(all_celltypes{1,current_dataset_id}.(possible_celltypes{ce}),num_observations_needed);
                    mdl_param.mdl_cells = sub_data;
                elseif ce == 4
                    mdl_param.mdl_cells = 1:sum(cellfun(@length,struct2cell(all_celltypes{1,current_dataset_id}))); %all cells together
                else %get top pyramidal neurons!!
                    curr_cells = data.(curr_mouse)+1;%+1 bc of Python indexing
                    mdl_param.mdl_cells = curr_cells(1:num_observations_needed);  
    
                end
                
    %             %use training data
    %             % [align_info,alignment_frames,left_padding,right_padding] = find_align_info (train_imaging,30);
    %             % [aligned_imaging,imaging_array,align_info] = align_behavior_data (train_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
    %             % [all_conditions_t, condition_array_trials_t] = divide_trials (train_imaging); %divide trials into all possible conditions
                
                % divide trials into opto or not BEFORE balancing! 
                selected_trials = get_specified_field_trials (current_dataset_id,alignment.active_passive,ex_imaging,[opto_trials-1]); %4th field is opto!
                ex_imaging = ex_imaging(selected_trials);

                if ce == 1 %keep the trials the same across cell types!
                    %selected_trials = subsample_trials_to_decorrelate_choice_and_category(condition_array_trials);%(condition_array_trials_t);
                    %[selected_trials,~,~] = get_balanced_condition_trials(ex_imaging);
                    if alignment.active_passive == 1
                        [selected_trials_balanced,~,~,~,lc,li,rc,ri] = get_balanced_field_trials(ex_imaging,mdl_param.fields_to_balance,info.set_size(current_dataset_id));
                        all_trials_selected = find(selected_trials_balanced);
                        idx00 = all_trials_selected(ismember(all_trials_selected,find(rc)));
                        idx01 = all_trials_selected(ismember(all_trials_selected,find(ri)));
                        idx10 = all_trials_selected(ismember(all_trials_selected,find(li)));
                        idx11 = all_trials_selected(ismember(all_trials_selected,find(lc)));

                        %randomly reorganize them
                        n_min = info.set_size(current_dataset_id);
                        idx00 = idx00(randperm(length(idx00), n_min));
                        idx01 = idx01(randperm(length(idx01), n_min));
                        idx10 = idx10(randperm(length(idx10), n_min));
                        idx11 = idx11(randperm(length(idx11), n_min));

                        % Step 4: Stratified train/test split making sure
                        % they have equal balancing!!
                        train_idx = [];
                        test_idx = [];
                        n_min = info.set_size(current_dataset_id);
                        n_min = n_min - mod(n_min, 4);  % Makes it divisible by 4
                    
                        for group = {idx00, idx01, idx10, idx11}
                            group_idx = group{1};
                            n_train = round(0.75 * n_min);
                            n_test = round(0.25 * n_min);
                            train_idx = [train_idx, group_idx(1:n_train)];
                            test_idx = [test_idx, group_idx(n_train+1:n_train+n_test)];
                        end

                        train_idx = train_idx(randperm(length(train_idx)));
                        test_idx = test_idx(randperm(length(test_idx)));

                    else
                        [selected_trials_balanced,left_trials,right_trials] = get_balanced_field_trials(ex_imaging,mdl_param.fields_to_balance,info.set_size(current_dataset_id)*2); %set size times 2 because we can only balance one thing in passive (this makes trials equal between active and passive)
                        all_trials_selected = find(selected_trials_balanced);
                        idx00 = all_trials_selected(ismember(all_trials_selected,left_trials));
                        idx11 = all_trials_selected(ismember(all_trials_selected,right_trials));

                        %randomly reorganize them
                        n_min = info.set_size(current_dataset_id)*2;
                        idx00 = idx00(randperm(length(idx00), n_min));
                        idx11 = idx11(randperm(length(idx11), n_min));

                        % Step 4: Stratified train/test split making sure
                        % they have equal balancing!!
                        train_idx = [];
                        test_idx = [];

                        n_min = n_min/2 - mod(n_min/2, 4);
                    
                        for group = {idx00, idx11}
                            group_idx = group{1};
                            n_train = round(0.75 * n_min*2);
                            n_test = round(0.25 * n_min*2);
                            train_idx = [train_idx, group_idx(1:n_train)];
                            test_idx = [test_idx, group_idx(n_train+1:n_train+n_test)];
                        end

                        train_idx = train_idx(randperm(length(train_idx)));
                        test_idx = test_idx(randperm(length(test_idx)));
                    end
                end
                mdl_param.selected_trials = selected_trials_balanced;
                mdl_param.train_trials = train_idx;
                mdl_param.test_trials = test_idx ;
        
                %get X and Y ready for classifier
                fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
                [~, condition_array] = divide_trials_updated (ex_imaging,{fieldss{mdl_param.field_to_predict}}); %all Y labels

                %update alignment with stim/ctrl only trials!!
                if alignment.active_passive == 2
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30,alignment.active_passive);
                else
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30);
                end
                [aligned_imaging_updated,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
                
                %get X and Y train/test matrices ready
                mdl_Y = condition_array(mdl_param.train_trials,2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
                mdl_X = aligned_imaging_updated(mdl_param.train_trials,:,:);
                mdl_Y_test = condition_array(mdl_param.test_trials,2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
                mdl_X_test = aligned_imaging_updated(mdl_param.test_trials,:,:);

                
                fprintf(['opto #:' num2str(opto_trials-1), '|| subsample #: ', num2str(it),' || mouse :' , num2str(current_dataset_id), ' ||    celltype :' num2str(ce), ' ||  size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) ' ||  size Y_test : ' num2str(size(mdl_Y_test)) '\n']);
                
                output{it,dataset_count,ce} = classify_over_time_glm_inputs(mdl_X,mdl_Y, mdl_param,mdl_X_test,mdl_Y_test);
%                 output{it,dataset_count,ce} = classify_over_time(mdl_X,mdl_Y, mdl_param);
                            % gete accuracy!

                %Store results from SVM
                acc{dataset_count,it,ce} = output{it,dataset_count,ce}.accuracy;
                shuff_acc{dataset_count,it,ce} = output{it,dataset_count,ce}.shuff_accuracy;
                mdl_results{dataset_count, it, ce}.train_accuracy = output{it,dataset_count,ce}.accuracy;
                mdl_results{dataset_count, it, ce}.shuffled_train_accuracy = output{it,dataset_count,ce}.shuff_accuracy;
                mdl_results{dataset_count, it, ce}.BoxConstraints = output{it,dataset_count,ce}.mdl{1, 1}.BoxConstraints(1);

    
                %get betas across all celltypes
                if ce == 4
                    for bin = 1:length(mdl_param.binns) %length(output{1,1,ce}.mdl)
                        betas{it,dataset_count,bin} = output{it,dataset_count,ce}.mdl{1,bin}.Beta;
                        mdl_results{dataset_count, it, ce}.bin(bin).IsSupportVector = output{it,dataset_count,ce}.mdl{1, bin}.IsSupportVector;
                        mdl_results{dataset_count, it, ce}.bin(bin).Alpha = output{it,dataset_count,ce}.mdl{1, bin}.Alpha;
                        mdl_results{dataset_count, it, ce}.bin(bin).Bias = output{it,dataset_count,ce}.mdl{1, bin}.Bias;

                    end
                end
                all_model_outputs{it,dataset_count,ce} = mdl_param;
            end
        end
    end
    
    %convert output to matrix form for easier indexing
    %% Save the output
    
    %save info variables
    %output{1,1,1}.info = info; %save in the first one
    
    
    if contains(field_string,'passive')
        save_string = strcat('sound_category_passive_opto',num2str(opto_trials-1));
    else 
        save_string = strcat('sound_category_active_opto',num2str(opto_trials-1));
    end

    mkdir([info.savepath ])
    cd([info.savepath])
    
    svm_info = info;
    save(strcat(save_string,'svm_info'),'svm_info');
    save(strcat(save_string,'betas'),'betas')
    save(strcat(save_string,'all_model_outputs'),'all_model_outputs','-v7.3');
    save(strcat(save_string,'_acc'),'acc','-v7.3');
    save(strcat(save_string,'_shuff_acc'),'shuff_acc','-v7.3');
    
    %SAVE SVM OUTPUT!
end

% %% make quick figure plots! error across subsamples
% mdl_param.event_onset_true = determine_onsets(left_padding,right_padding,alignment.events);
% %adjust event onsets to bins!
% event_onsets = find(histcounts(mdl_param.event_onset_true,mdl_param.binns+mdl_param.event_onset(1)));
% for m = 1:length(imaging_st)
% ex_mouse = m;
% figure(m);clf;
% subplot(2,1,1)
% for ce = 1:4
%     hold on; 
%     title(info.mouse_date{1,m})
%     
%     temp = [output{1:mdl_param.num_iterations,m,ce}];
%     output_mat{m,ce}.accuracy = cell2mat({temp.accuracy}'); %gives num subsample iterations x timepoints
%     output_mat{m,ce}.shuff_accuracy = cell2mat({temp.shuff_accuracy}');
%     % find squared error from the mean
%     SEM= std(output_mat{m,ce}.accuracy)/sqrt(size(output_mat{m,ce}.accuracy,1));
%     shadedErrorBar(1:size(output_mat{m,ce}.accuracy,2),mean(output_mat{m,ce}.accuracy,1), SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:)});
% 
%     SEM= std(output_mat{m,ce}.accuracy)/sqrt(size(output_mat{m,ce}.accuracy,1));
%     shadedErrorBar(1:size(output_mat{m,ce}.shuff_accuracy,2),mean(output_mat{m,ce}.shuff_accuracy,1), SEM, 'lineProps',{'color', [0.2 0.2 0.2]*ce});
% 
% %     plot(output{ex_mouse,ce}.accuracy,'color',plot_info.colors_celltypes(ce,:));
% %     plot(output{ex_mouse,ce}.shuff_accuracy,'color',[0.2 0.2 0.2]*ce);
% 
% 
%     for i = 1:length(event_onsets)
%         xline(event_onsets(i),'--k','LineWidth',1.5)
%         if i == 4
%             xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
%         end
%     end
% yline(.5,'--k');
% end
% hold off
% 
% subplot(2,1,2)
% for ce = 1:4
%     hold on; 
%         
%     shadedErrorBar(1:size(output_mat{m,ce}.accuracy,2),smooth(mean(output_mat{m,ce}.accuracy,1),3, 'boxcar'), smooth(SEM,3, 'boxcar'), 'lineProps',{'color', plot_info.colors_celltype(ce,:)});
% 
%     shadedErrorBar(1:size(output_mat{m,ce}.shuff_accuracy,2),smooth(mean(output_mat{m,ce}.shuff_accuracy,1),3, 'boxcar'), smooth(SEM,3, 'boxcar'), 'lineProps',{'color', [0.2 0.2 0.2]*ce});
% 
% %     plot(smooth(output{ex_mouse,ce}.accuracy,3, 'boxcar'),'color',plot_info.colors_celltypes(ce,:));
% %     plot(smooth(output{ex_mouse,ce}.shuff_accuracy,3, 'boxcar'),'color',[0.2 0.2 0.2]*ce);
% 
%     for i = 1:length(event_onsets)
%         xline(event_onsets(i),'--k','LineWidth',1.5)
%         if i == 4
%             xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
%         end
%     end
% yline(.5,'--k');
% end
% hold off
% movegui(gcf,'center')
% end
% 
% save('output_mat','output_mat');
% 
% 
% %save_figs
% for m = 1:length(imaging_st)
%     str = info.mouse_date{1,m} ;
%     if ismember('/',info.mouse_date{1,m})
%         str = erase(info.mouse_date{1,m},'/');
%     else
%         str = erase(info.mouse_date{1,m},'\');
%     end
%     saveas(m,strcat('SVM_overtime_',str,'.svg'));
%     saveas(m,strcat('SVM_overtime_',str,'.png'));
% end