%% RERUN SVM USING SAME SUBSAMPLED CELLS AND TRIALS AS PREVIOUS SVM!!
%to test regularization parameters of SVM
function [output, output_mat] = rerun_classifier(svm, imaging_st, alignment,plot_info,info)

mdl_param = svm{1,1,1}.mdl_param;

for it = 1:mdl_param.num_iterations
    it
    for m = 1:length(imaging_st)
        count = 0;
        m
        for ce = 1:4 %4th will be all cells together no subsamples!
            count = count+1;
            mdl_param.mouse = m;
            ex_imaging = imaging_st{1,m};

            %get aligned data
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (ex_imaging,30);
            [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);

            %get previously used mdl cells and trials
            mdl_param.selected_trials = svm{it,m,ce}.mdl_param.selected_trials;
            mdl_param.mdl_cells = svm{it,m,ce}.mdl_param.mdl_cells;
                
            %get X and Y ready for classifier
            fieldss = fieldnames(ex_imaging(1).virmen_trial_info);
            [~, condition_array] = divide_trials_updated (ex_imaging,{fieldss{mdl_param.field_to_predict}});
            mdl_Y = condition_array(find(mdl_param.selected_trials),2);%condition_array_trials_t(find(mdl_param.selected_trials),2); %get trained Y labels
            mdl_X = aligned_imaging(find(mdl_param.selected_trials),:,:);
            
            fprintf(['subsample #: ', num2str(it),' || mouse :' , num2str(m), ' ||    celltype :' num2str(ce), ' ||  size Y : ' num2str(size(mdl_Y)) ' || size X : '  num2str(size(mdl_X)) '\n']);
            output{it,m,ce} = classify_over_time(mdl_X,mdl_Y, mdl_param);
        end
    end
end

%convert output to matrix form for easier indexing

%% make quick figure plots! error across subsamples
mdl_param.event_onset_true = determine_onsets(left_padding,right_padding,[1:6]);
%adjust event onsets to bins!
event_onsets = find(histcounts(mdl_param.event_onset_true,mdl_param.binns+mdl_param.event_onset));
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

%save info variables
output{1,1,1}.info = info; %save in the first one

mkdir([info.savepath '\SVM_' alignment.data_type '_' info.savestr])
cd([info.savepath '\SVM_' alignment.data_type '_' info.savestr])

save('output','output','-v7.3');
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




