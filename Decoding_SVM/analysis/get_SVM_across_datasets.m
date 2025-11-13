function [output_mat, output_mat2] = get_SVM_across_datasets(info, acc, shuff_acc, plot_info, savepath,doplot, varargin)

output_mat = [];
output_mat2 = [];
num_nans = 1;

for m = 1:length(info.chosen_mice)
    
    if doplot
        figure(m); clf;
    end

    if length(plot_info.colors) > 2
        total_celltypes = size(acc{1,1},3);
    end

    for ce = 1:total_celltypes
        if doplot
            hold on;
        end

        temp1 = vertcat(acc{1,m}{1:10,1:50,ce});
        temp2 = vertcat(shuff_acc{1,m}{1:10,1:50,ce});

        folds_mean = [];
        folds_mean_shuff = [];
        for i = 0:9
            folds_mean = [folds_mean; mean(temp1(i*10+1:i*10+10,:))];
            folds_mean_shuff = [folds_mean_shuff; mean(temp2(i*10+1:i*10+10,:))];
        end

        output_mat{m,ce}.accuracy = folds_mean;
        output_mat{m,ce}.shuff_accuracy = folds_mean_shuff;

        if doplot
            % Insert NaNs if needed
            if length(mean(output_mat{m,ce}.accuracy,1)) > 33
                nan_insert_positions = 34;
                data_to_plot = include_nans(mean(output_mat{m,ce}.accuracy,1), num_nans, nan_insert_positions);
            else
                data_to_plot = mean(output_mat{m,ce}.accuracy,1);
            end
            SEM = std(output_mat{m,ce}.accuracy) / sqrt(size(output_mat{m,ce}.accuracy,1));
            h1(1) = shadedErrorBar(1:size(output_mat{m,ce}.accuracy,2), data_to_plot, SEM, 'lineProps', {'color', plot_info.colors(ce,:)});

            if length(mean(output_mat{m,ce}.accuracy,1)) > 33
                data_to_plot = include_nans(mean(output_mat{m,ce}.shuff_accuracy,1), num_nans, nan_insert_positions);
            else
                data_to_plot = mean(output_mat{m,ce}.shuff_accuracy,1);
            end
            SEM2 = std(output_mat{m,ce}.shuff_accuracy) / sqrt(size(output_mat{m,ce}.shuff_accuracy,1));
            shadedErrorBar(1:size(output_mat{m,ce}.shuff_accuracy,2), data_to_plot, SEM2, 'lineProps', {'color', [0.2 0.2 0.2]*ce});
        end

        % Passive condition (if available)
        if nargin > 6
            temp3 = vertcat(varargin{1,1}{1,1}{1,m}{1:10,1:50,ce});
            temp4 = vertcat(varargin{1,1}{1,2}{1,m}{1:10,1:50,ce});

            folds_mean_passive = [];
            folds_mean_shuff_passive = [];
            for i = 0:9
                folds_mean_passive = [folds_mean_passive; mean(temp3(i*10+1:i*10+10,:))];
                folds_mean_shuff_passive = [folds_mean_shuff_passive; mean(temp4(i*10+1:i*10+10,:))];
            end
            output_mat2{m,ce}.accuracy = folds_mean_passive;
            output_mat2{m,ce}.shuff_accuracy = folds_mean_shuff_passive;

            if doplot
                SEM = std(output_mat2{m,ce}.accuracy) / sqrt(size(output_mat2{m,ce}.accuracy,1));
                h1(2) = shadedErrorBar(1:size(output_mat2{m,ce}.accuracy,2), mean(output_mat2{m,ce}.accuracy,1), SEM, 'lineProps', {'color', plot_info.colors(ce+total_celltypes,:)});
                SEM2 = std(output_mat2{m,ce}.shuff_accuracy) / sqrt(size(output_mat2{m,ce}.shuff_accuracy,1));
                shadedErrorBar(1:size(output_mat2{m,ce}.shuff_accuracy,2), mean(output_mat2{m,ce}.shuff_accuracy,1), SEM2, 'lineProps', {'color', [0.2 0.2 0.2]*ce});
            end
        end

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
    for m = 1:length(info.chosen_mice)
        str = [info.mouse_date{1,info.chosen_mice(m)} '_' info.task_event_type];
        str = erase(str, {'/', '\'});
        saveas(m, strcat(savepath, 'SVM_glm_inputs_overtime_', str, '.svg'));
        saveas(m, strcat(savepath, 'SVM_glm_inputs_overtime_', str, '.png'));
    end
    save('info', 'info');
end
