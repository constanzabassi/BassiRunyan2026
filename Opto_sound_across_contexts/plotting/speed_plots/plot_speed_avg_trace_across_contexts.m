function plot_speed_avg_trace_across_contexts(avg_speed_stats, function_params, save_data_directory)
%avg_speed_axis_data(context, speed axis) - ROLL = 1, PITCH = 2, BOTH = 3;
% FRAMES WERE AVERAGE ACROSS LEFT AND RIGHT TRIALS!!!!!!
    %make average trace and cdf plots!
    positions = utils.calculateFigurePositions(1, 7, .3,[]);

    figure(661); clf;
    hold on;
    % Extract movement types (e.g., Pitch, Roll, Both) and contexts (e.g., Active, Passive) dynamically
    movement_types = fieldnames(avg_speed_stats.Active); % Assume both contexts have the same movement fields
    contexts = fieldnames(avg_speed_stats); % Extract context labels (Active, Passive)
    % Loop through movement types
    for i = 1:length(movement_types)
        movement = movement_types{i}; % Get current movement type
        subplot(3,1,i);
        hold on;
        % Loop through contexts (Active & Passive)
        for contextIdx = 1:length(contexts)
            ctx = contexts{contextIdx}; % Get current context (Active or Passive)
            shadedErrorBar(1:size(avg_speed_stats.(ctx).(movement).mean,2), ...
                           avg_speed_stats.(ctx).(movement).mean, ...
                           avg_speed_stats.(ctx).(movement).sem, ...
                           'lineprops', {'Color', function_params.contexts_colors(contextIdx,:), 'LineWidth', 1.5}); %function_params.([lower(ctx) '_color'])
        end
        % Add vertical line and format x-axis
        xline(function_params.stim_frame, '--k', 'LineWidth', 2);
        [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(function_params.stim_frame, size(avg_speed_stats.(contexts{1}).(movement).mean, 2));
        xticks(xticks_in);
        xticklabels(xticks_lab);
        yl = ylim;
        ylim([0 yl(2)])
        % Add labels and formatting
        if i == 3
            title('Total Speed', 'FontWeight', 'normal');
                for contextIdx = 1:length(contexts)
                    fontSize = 7;
                    y_offset_base = 0.4;
                    utils.place_text_labels(function_params.contexts, function_params.contexts_colors, y_offset_base, fontSize);
                end
        else
            title(movement, 'FontWeight', 'normal');
        end
        xlabel('Time (s)');
        if i == 1
            ylabel('Speed');
        end
        set(gca, 'XTickLabelRotation', 90, 'FontSize', 7, 'Units', 'inches', 'Position', positions(i, :));
        hold off;
    end
    hold off;
    
    if ~isempty(save_data_directory)
        
        exportgraphics(figure(661),['avg_traces_all_axis_acrosscontext_' strcat(num2str(function_params.frames_before_event),'-', num2str(function_params.frames_after_event),'_abs_',num2str(function_params.abs)) '.pdf'], 'ContentType', 'vector');
        saveas(figure(661),['avg_traces_all_axis_acrosscontext_' strcat(num2str(function_params.frames_before_event),'-', num2str(function_params.frames_after_event),'_abs_',num2str(function_params.abs)) '.fig']);

    end
end