%% SVM predict choice using cell type activity
function [output, output_mat] = run_classifier(imaging_st,all_celltypes,mdl_param, alignment,plot_info,info,single_event)
possible_celltypes = fieldnames(all_celltypes{1,1});

disp(['Saving path: ' info.savepath '\SVM_' alignment.data_type '_' info.savestr]);
for it = 1:mdl_param.num_iterations
    it
    for m = 1:length(imaging_st)
        count = 0;
        m
        for ce = 1:4 %4th will be all cells together no subsamples!
            count = count+1;
            mdl_param.mouse = m;
            ex_imaging = imaging_st{1,m};
            
            if single_event == 1
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30,1);
            else
                [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
            end
            [aligned_imaging,imaging_array,align_info] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
            
            [all_conditions, condition_array_trials] = divide_trials (ex_imaging); %divide trials into all possible conditions
            %  condition_array_trials (trial_ids, correct or not, left or not, stim or not)
            
            % [train_imaging, test_imaging,all_trials] = split_imaging_train_test_cb(ex_imaging,condition_array_trials,0.7,0,0);
            
%             mdl_param.mdl_cells = all_celltypes{1,m}.(possible_celltypes{ce}); %which cell type to use

            %subsample cells!
            if ce <4
                num_observations_needed = min(cellfun(@length,struct2cell(all_celltypes{1,m}))); %min number of cells 
                sub_data = subsample_fun(all_celltypes{1,m}.(possible_celltypes{ce}),num_observations_needed);
                mdl_param.mdl_cells = sub_data;
            else
                mdl_param.mdl_cells = 1:sum(cellfun(@length,struct2cell(all_celltypes{1,m}))); %all cells together
            end
            
%             %use training data
%             % [align_info,alignment_frames,left_padding,right_padding] = find_align_info (train_imaging,30);
%             % [aligned_imaging,imaging_array,align_info] = align_behavior_data (train_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);
%             % [all_conditions_t, condition_array_trials_t] = divide_trials (train_imaging); %divide trials into all possible conditions
            
            if count == 1 %keep the trials the same across cell types!
                %selected_trials = subsample_trials_to_decorrelate_choice_and_category(condition_array_trials);%(condition_array_trials_t);
                %[selected_trials,~,~] = get_balanced_condition_trials(ex_imaging);
                [selected_trials,~,~] = get_balanced_field_trials(ex_imaging,mdl_param.fields_to_balance);
            else
                mdl_param.selected_trials = selected_trials;
            end
            mdl_param.selected_trials = selected_trials;
    
            %get X and Y ready for classifier
            fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
            [~, condition_array] = divide_trials_updated (ex_imaging,{fieldss{mdl_param.field_to_predict}});
            mdl_Y = condition_array(find(mdl_param.selected_trials),2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X = aligned_imaging(find(mdl_param.selected_trials),:,:);
            
            fprintf(['subsample #: ', num2str(it),' || mouse :' , num2str(m), ' ||    celltype :' num2str(ce), ' ||  size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) '\n']);
            output{it,m,ce} = classify_over_time(mdl_X,mdl_Y, mdl_param);

            %get betas across all celltypes
            if ce == 4
                for bin = 1:length(output{1,1,ce}.mdl)
                    betas{it,m,bin} = output{it,m,ce}.mdl{1,bin}.Beta;     
                end
            end
            all_model_outputs{it,m,ce} = mdl_param;
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
for m = 1:length(imaging_st)
ex_mouse = m;
figure(m);clf;
subplot(2,1,1)
for ce = 1:4
    hold on; 
    title(info.mouse_date{1,m})
    
    temp = [output{1:mdl_param.num_iterations,m,ce}];
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



