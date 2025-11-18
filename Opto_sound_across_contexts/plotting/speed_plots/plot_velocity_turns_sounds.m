function plot_velocity_turns_sounds(chosen_mice,info,mouse_vel_turns,mouse_vel_pass,turn_params,trial_event_info, save_data_directory)
% Make heatmaps across trials (if two mouse_vel matrices given will concatenate)
% will plot aligned velocity and trial event (stimulus_rel which is
% actually turn relative to stimulus)

vel_aligned_right_all= {};
vel_aligned_left_all = {};
for m = chosen_mice %pos roll mice: [1,3,7,8,13,14,15,21,22,23]; %neg roll mice: [5,6,10,24,25] -25 has outlier points
    mm = info.mouse_date(m)
    mouse_date = info.mouse_date;

    vel_aligned_left = [];
    vel_aligned_right = [];
    num_filler_rows = 15;
    intervals_y = 20;
    %GET ALIGNED RUNNING DATA
    if strcmp(turn_params.vel_type,'roll')
        vel_aligned_left = mouse_vel_turns(m).both_opto_roll; %trials_left [varargin{1,1}{1,1}{1,m}{1,:}]
        vel_aligned_right = mouse_vel_turns(m).both_control_roll; %trials_right [varargin{1,1}{2,1}{1,m}{1,:}]
        caxis_values = [-30,30];
        ylims = [-25,25];

        if ~isempty(mouse_vel_pass)
            
            active_vel_left = mouse_vel_turns(m).both_opto_roll; %trials_left [varargin{1,1}{1,1}{1,m}{1,:}]
            active_vel_right = mouse_vel_turns(m).both_control_roll; %trials_right [varargin{1,1}{2,1}{1,m}{1,:}]
            zero_mat = zeros(num_filler_rows,size(active_vel_left,2));

            length_active_left = size(active_vel_left,1);
            length_active_right = size(active_vel_right,1);
            passive_vel_left =  mouse_vel_pass(m).both_opto_roll;
            passive_vel_right =  mouse_vel_pass(m).both_control_roll;
            vel_aligned_left = [vel_aligned_left;zero_mat;passive_vel_left];
            vel_aligned_right = [vel_aligned_right;zero_mat;passive_vel_right];
            caxis_values = [-40,40];
            ylims = [-35,35];
        end
    elseif strcmp(turn_params.vel_type,'pitch') %use pitch
        vel_aligned_left = mouse_vel_turns(m).both_opto_pitch;
        vel_aligned_right = mouse_vel_turns(m).both_control_pitch;
        caxis_values = [0,60];
        ylims = [0,60];

        if ~isempty(mouse_vel_pass)
            active_vel_left = mouse_vel_turns(m).both_opto_pitch; %trials_left [varargin{1,1}{1,1}{1,m}{1,:}]
            active_vel_right = mouse_vel_turns(m).both_control_pitch; %trials_right [varargin{1,1}{2,1}{1,m}{1,:}]
            median_num = median([caxis_values(1):caxis_values(2)]);

            zero_mat = zeros(num_filler_rows,size(active_vel_left,2)); %ones(num_filler_rows,size(active_vel_left,2)) *median_num;


            length_active_left = size(active_vel_left,1);
            length_active_right = size(active_vel_right,1);
            passive_vel_left =  mouse_vel_pass(m).both_opto_pitch;
            passive_vel_right =  mouse_vel_pass(m).both_control_pitch;
            vel_aligned_left = [vel_aligned_left;zero_mat;passive_vel_left];
            vel_aligned_right = [vel_aligned_right;zero_mat;passive_vel_right];
        end
    else
        vel_aligned_left = mouse_vel_turns(m).both_opto;
        vel_aligned_right = mouse_vel_turns(m).both_control;
        caxis_values = [0,70];
        ylims = [0,70];

        if ~isempty(mouse_vel_pass)
            active_vel_left = mouse_vel_turns(m).both_opto; %trials_left [varargin{1,1}{1,1}{1,m}{1,:}]
            active_vel_right = mouse_vel_turns(m).both_control; %trials_right [varargin{1,1}{2,1}{1,m}{1,:}]
            median_num = median([caxis_values(1):caxis_values(2)]);

            zero_mat = zeros(num_filler_rows,size(active_vel_left,2)); %ones(num_filler_rows,size(active_vel_left,2)) *median_num;

            length_active_left = size(active_vel_left,1);
            length_active_right = size(active_vel_right,1);
            passive_vel_left =  mouse_vel_pass(m).both_opto;
            passive_vel_right =  mouse_vel_pass(m).both_control;
            vel_aligned_left = [vel_aligned_left;zero_mat;passive_vel_left];
            vel_aligned_right = [vel_aligned_right;zero_mat;passive_vel_right];
        end
    end

    
    colorList= colormaps.slanCM(turn_params.colormap,100); %'RdBu'
    vel_to_plot = vel_aligned_left;
    figure(111); clf;
    set(gcf, 'Units', 'inches', 'Position', [0.7, 0.7, 6, 6]); % Increase size slightly
    colormap(colorList)
    % Top-left plot (Roll Left Trials)
    subplot(2,2,1)
    hold on
    title('Left Sound Trials','FontWeight','normal','FontName','Arial');
    imagesc(vel_to_plot);
    if ~isempty(mouse_vel_pass)
        for t = 1:length_active_left
            plot(trial_event_info(m).stimulus_rel(t), t, 'ok', 'MarkerSize', 1, 'MarkerFaceColor', 'k');
        end
    end
    xline(turn_params.onset_frame, '--k','LineWidth',2); % Add vertical line

    [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(turn_params.onset_frame, size(vel_to_plot, 2), 2);
    xticks(xticks_in);
    xticklabels(xticks_lab);
    xlim([1 size(vel_to_plot, 2)])
    ylim([1 size(vel_to_plot, 1)])
    if ~isempty(mouse_vel_pass)
        % Adjust Y-axis to exclude filler
        all_trials = [1:size(vel_aligned_left,1)];
        trials_used = [1:length_active_left, (length_active_left + num_filler_rows + 1):size(vel_aligned_left,1)];
        mod_trials = trials_used(mod(trials_used, intervals_y) == 0);
        ytick_positions = all_trials(mod_trials);
    %     ytick_positions = round((linspace(trials_used(1),trials_used(end),4)));
        yticks(mod_trials);
        yticklabels(ytick_positions); % Active + Passive only
    end

    caxis(caxis_values);
    ylabel('Trials')
    set(gca, 'FontSize', 7)
    % Adjust position for the top-left plot (square)
    set(gca, 'Units', 'inches', 'Position', [0.6, 4, 1.0, 1.0],'YDir', 'reverse'); %flip Y axis to start trials from top to bottom!
    drawnow;
%     set(gca, 'Units', 'inches', 'Position', [1, 1, 2, 2]); % Subplot centered at (2,3) with 2x2 size
%     set(gca, 'Position', [0.05, 0.55, 0.25, 0.25]); % [left, bottom, width, height]
    % Top-right plot (Roll Right Trials)
    vel_to_plot = vel_aligned_right;
    subplot(2,2,2)
    hold on
    title('Right Sound Trials','FontWeight','normal','FontName','Arial');
    imagesc(vel_to_plot);
    if ~isempty(mouse_vel_pass)
        for t = 1:length_active_right
            plot(trial_event_info(m).stimulus_rel(t+length_active_left), t , 'ok', 'MarkerSize', 1, 'MarkerFaceColor', 'k');
        end
    end

    xline(turn_params.onset_frame, '--k','LineWidth',2); % Add vertical line

    [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(turn_params.onset_frame, size(vel_to_plot, 2), 2);
    xticks(xticks_in);
    xticklabels(xticks_lab);
    xlim([1 size(vel_to_plot, 2)])
    ylim([1 size(vel_to_plot, 1)])
    if ~isempty(mouse_vel_pass)
        % Adjust Y-axis to exclude filler
        all_trials = [1:size(vel_aligned_right,1)];
        trials_used = [1:length_active_right, (length_active_right + num_filler_rows + 1):size(vel_aligned_right,1)];
        mod_trials = trials_used(mod(trials_used, intervals_y) == 0);
        ytick_positions = all_trials(mod_trials);
        yticks(mod_trials);
    %     ytick_positions = round((linspace(trials_used(1),trials_used(end),4)));
        yticklabels(ytick_positions); % Active + Passive only
    end
    caxis(caxis_values);
%     ylabel('Trials')
    set(gca, 'FontSize', 7)
    % Adjust position for the top-right plot (square)
    set(gca, 'Units', 'inches', 'Position', [2.0, 4, 1.0, 1.0],'YDir', 'reverse'); % [left, bottom, width, height] top = 6-0.5-height// width 1 + width first plot
    % Add colorbar and adjust its position
    cb = colorbar;
    set(cb, 'Units', 'inches', 'Position', [3.1, 4, .1, 1.0]); %'Position', [.96, 0.55, 0.02, 0.3]); % Adjust colorbar position to the right
    drawnow;

    if turn_params.plot_avg == 1;
        % Bottom-left plot (Roll Left Speed)
        subplot(2,2,3)
        vel_to_plot = vel_aligned_left;
        hold on
        
        if ~isempty(mouse_vel_pass)
            SEM = std(active_vel_left) / sqrt(size(active_vel_left, 1)); % Calculate SEM
        shadedErrorBar(1:size(active_vel_left, 2), mean(active_vel_left), SEM, ...
            'lineProps', {'color', turn_params.left_color_active});
        SEM = std(passive_vel_left) / sqrt(size(passive_vel_left, 1)); % Calculate SEM
        shadedErrorBar(1:size(passive_vel_left, 2), mean(passive_vel_left), SEM, ...
            'lineProps', {'color', turn_params.left_color_passive});
        else
            SEM = std(vel_to_plot) / sqrt(size(vel_to_plot, 1)); % Calculate SEM
        shadedErrorBar(1:size(vel_to_plot, 2), mean(vel_to_plot), SEM, ...
            'lineProps', {'color', turn_params.left_color});
        end
        hold off
        xline(turn_params.onset_frame, '--k','LineWidth',2); % Add vertical line
        xlim([1 size(vel_to_plot, 2)])
        [xticks_in, xticks_lab] = x_axis_sec_aligned(turn_params.onset_frame, size(vel_to_plot, 2), 2);
        xticks(xticks_in);
        xticklabels(xticks_lab);
        xlabel('Time (s)')
        ylabel('Average Velocity')
        ylim(ylims)
        set(gca, 'FontSize', 7)
        % Adjust position for the bottom-left plot (rectangular)
        set(gca, 'Units', 'inches', 'Position', [0.6, 2.75, 1.0, .75]); % [left, bottom, width, height]
        % Bottom-right plot (Roll Right Speed)
        subplot(2,2,4)
        vel_to_plot = vel_aligned_right;
        hold on
    
        
        if ~isempty(mouse_vel_pass)
            SEM = std(active_vel_right) / sqrt(size(active_vel_right, 1)); % Calculate SEM
        shadedErrorBar(1:size(active_vel_right, 2), mean(active_vel_right), SEM, ...
            'lineProps', {'color', turn_params.right_color_active});
        SEM = std(passive_vel_right) / sqrt(size(passive_vel_right, 1)); % Calculate SEM
        shadedErrorBar(1:size(passive_vel_right, 2), mean(passive_vel_right), SEM, ...
            'lineProps', {'color', turn_params.right_color_passive});
        else
            SEM = std(vel_to_plot) / sqrt(size(vel_to_plot, 1)); % Calculate SEM
        shadedErrorBar(1:size(vel_to_plot, 2), mean(vel_to_plot), SEM, ...
            'lineProps', {'color', turn_params.right_color});
        end
    
        xline(turn_params.onset_frame, '--k','LineWidth',2); % Add vertical line
        xlim([1 size(vel_to_plot, 2)])
        [xticks_in, xticks_lab] = x_axis_sec_aligned(turn_params.onset_frame, size(vel_to_plot, 2), 2);
        xticks(xticks_in);
        xticklabels(xticks_lab);
        xlabel('Time (s)')
    %     ylabel('Average Speed')
        ylim(ylims)
        set(gca, 'FontSize', 7)
        % Adjust position for the bottom-right plot (rectangular)
        set(gca, 'Units', 'inches', 'Position', [2.0, 2.75, 1.0, .75]);% [left, bottom, width, height]
    end

    temp = strfind(mouse_date{1,m},'/');
    if isempty(temp)
        temp = strfind(mouse_date{1,m},'\');
    end
    mouse_title = [mouse_date{1,m}(1:temp-1) '-' mouse_date{1,m}(temp+1:end)]
    
    if ~isempty(save_data_directory)
        
        mkdir(save_data_directory);
        cd (save_data_directory);
        
        
        exportgraphics(figure(111),strcat(mouse_title,'_velocity_',num2str(turn_params.vel_type),'_example_trials_abs_',num2str(turn_params.abs),'_avg_',num2str(turn_params.plot_avg),'.pdf'), 'ContentType', 'vector');
        saveas(figure(111),strcat(mouse_title,'_velocity_',num2str(turn_params.vel_type),'_example_trials_abs_',num2str(turn_params.abs),'_avg_',num2str(turn_params.plot_avg),'.fig'));
    %     exportgraphics(figure(601),strcat(mouse_title,'_speed_v_neural_trials_right_difference',strcat(num2str(frames_before_left),'-', num2str(frames_after_left)),'context',num2str(function_params.context),'_sig_cells.pdf'), 'ContentType', 'vector');
    %     saveas(figure(601),strcat(mouse_title,'_speed_v_neural_trials_right_difference',strcat(num2str(frames_before_left),'-', num2str(frames_after_left)),'context',num2str(function_params.context),'_sig_cells.fig'));
    end



end