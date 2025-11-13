function [output_mat, output_mat_ctrl, output_mat_passive, output_mat_passive_ctrl] = load_SVM_output_datasets(save_dir,plot_info, savepath,doplot, do_passive)
output_mat = [];
output_mat_ctrl = [];
output_mat_passive = [];
output_mat_passive_ctrl = [];
num_nans = 1;
%1) load data which is organized as dataset,iteration, ce (1-5)
acc = load(strcat(save_dir,'sound_category_active_opto1_acc.mat')).acc;
shuff_acc = load(strcat(save_dir,'sound_category_active_opto1_shuff_acc.mat')).shuff_acc;
acc_ctrl = load(strcat(save_dir,'sound_category_active_opto0_acc.mat')).acc;
shuff_acc_ctrl = load(strcat(save_dir,'sound_category_active_opto0_shuff_acc.mat')).shuff_acc;


if do_passive == 1
    acc_passive = load(strcat(save_dir,'sound_category_passive_opto1_acc.mat')).acc;
    shuff_acc_passive  = load(strcat(save_dir,'sound_category_passive_opto1_shuff_acc.mat')).shuff_acc;
    acc_ctrl_passive  = load(strcat(save_dir,'sound_category_passive_opto0_acc.mat')).acc;
    shuff_acc_ctrl_passive  = load(strcat(save_dir,'sound_category_passive_opto0_shuff_acc.mat')).shuff_acc;
end

for dataset_index = 1:size(acc,1)
    
    if doplot
        figure(dataset_index); clf;
    end

    if length(plot_info.colors) > 2
        total_celltypes = size(acc,3);
    end

    for ce = 1:total_celltypes
        if doplot
            hold on;
        end

        temp1 = vertcat(acc{dataset_index,:,ce}); % iterations x bins
        temp2 = vertcat(shuff_acc{dataset_index,:,ce}); % iterations x bins
        %control
        temp3 = vertcat(acc_ctrl{dataset_index,:,ce}); % iterations x bins
        temp4 = vertcat(shuff_acc_ctrl{dataset_index,:,ce}); % iterations x bins



        output_mat{dataset_index,ce}.accuracy = temp1;
        output_mat{dataset_index,ce}.shuff_accuracy = temp2;

        output_mat_ctrl{dataset_index,ce}.accuracy = temp3;
        output_mat_ctrl{dataset_index,ce}.shuff_accuracy = temp4;

        if doplot
            % Insert NaNs if needed
            if length(mean(output_mat{dataset_index,ce}.accuracy,1)) > 33
                nan_insert_positions = 34;
                data_to_plot = include_nans(mean(output_mat{dataset_index,ce}.accuracy,1), num_nans, nan_insert_positions);
            else
                data_to_plot = mean(output_mat{dataset_index,ce}.accuracy,1);
            end
            SEM = std(output_mat{dataset_index,ce}.accuracy) / sqrt(size(output_mat{dataset_index,ce}.accuracy,1));
            h1(1) = shadedErrorBar(1:size(output_mat{dataset_index,ce}.accuracy,2), data_to_plot, SEM, 'lineProps', {'color', plot_info.colors(ce,:)});

            if length(mean(output_mat{dataset_index,ce}.accuracy,1)) > 33
                data_to_plot = include_nans(mean(output_mat{dataset_index,ce}.shuff_accuracy,1), num_nans, nan_insert_positions);
            else
                data_to_plot = mean(output_mat{dataset_index,ce}.shuff_accuracy,1);
            end
            SEM2 = std(output_mat{dataset_index,ce}.shuff_accuracy) / sqrt(size(output_mat{dataset_index,ce}.shuff_accuracy,1));
            shadedErrorBar(1:size(output_mat{dataset_index,ce}.shuff_accuracy,2), data_to_plot, SEM2, 'lineProps', {'color', [0.2 0.2 0.2]*ce});
        end

        % Passive condition (if available)
        if do_passive == 1
                temp1 = vertcat(acc_passive{dataset_index,:,ce}); % iterations x bins
                temp2 = vertcat(shuff_acc_passive{dataset_index,:,ce}); % iterations x bins
                %control
                temp3 = vertcat(acc_ctrl_passive{dataset_index,:,ce}); % iterations x bins
                temp4 = vertcat(shuff_acc_ctrl_passive{dataset_index,:,ce}); % iterations x bins
        
        
        
                output_mat_passive{dataset_index,ce}.accuracy = temp1;
                output_mat_passive{dataset_index,ce}.shuff_accuracy = temp2;
        
                output_mat_passive_ctrl{dataset_index,ce}.accuracy = temp3;
                output_mat_passive_ctrl{dataset_index,ce}.shuff_accuracy = temp4;

            if doplot
                SEM = std(output_mat_passive{dataset_index,ce}.accuracy) / sqrt(size(output_mat_passive{dataset_index,ce}.accuracy,1));
                h1(2) = shadedErrorBar(1:size(output_mat_passive{dataset_index,ce}.accuracy,2), mean(output_mat_passive{dataset_index,ce}.accuracy,1), SEM, 'lineProps', {'color', plot_info.colors(ce+total_celltypes,:)});
                SEM2 = std(output_mat_passive{dataset_index,ce}.shuff_accuracy) / sqrt(size(output_mat_passive{dataset_index,ce}.shuff_accuracy,1));
                shadedErrorBar(1:size(output_mat_passive{dataset_index,ce}.shuff_accuracy,2), mean(output_mat_passive{dataset_index,ce}.shuff_accuracy,1), SEM2, 'lineProps', {'color', [0.2 0.2 0.2]*ce});
            end
        end
% 
        if doplot
            if ~isempty(plot_info.minmax)
                ylim([plot_info.minmax(1) plot_info.minmax(2)])
            end
            if ~isempty(plot_info.xlims)
                xlim([plot_info.xlims(1) plot_info.xlims(2)])
            end
            for i = 1:length(plot_info.event_onsets)
                xline(plot_info.event_onsets(i), '--k', 'LineWidth', 1.5)
                if i == 4
                    xline(plot_info.event_onsets(i), '--k', {'turn onset'}, 'LineWidth', 1.5)
                end
            end
            yline(.5, '--k');
            ylabel('% Accuracy')
            legend([h1(:).mainLine], plot_info.labels, 'location', 'northeast', 'Box', 'off');
        end
    end

    if doplot
        hold off
        set(gca, 'box', 'off')
        set(gca, 'fontsize', 14)
    end
end

% Save figures and data
if doplot & ~isempty(savepath)
    mkdir(savepath);
    cd(savepath);
    for dataset_index = 1:length(info.chosen_mice)
        str = [info.mouse_date{1,info.chosen_mice(dataset_index)} '_' info.task_event_type];
        str = erase(str, {'/', '\'});
        saveas(dataset_index, strcat(savepath, 'SVM_glm_inputs_overtime_', str, '.svg'));
        saveas(dataset_index, strcat(savepath, 'SVM_glm_inputs_overtime_', str, '.png'));
    end
    save('info', 'info');
end