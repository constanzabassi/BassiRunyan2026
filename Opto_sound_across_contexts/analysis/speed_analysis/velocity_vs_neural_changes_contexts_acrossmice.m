% filepath: /c:/Code/Github/Opto-analysis/context/running/velocityroll_vs_sound_acrossmice.m

function [mouse_trial_stats, trial_indices_right_all, trial_indices_left_all] = velocity_vs_neural_changes_contexts_acrossmice(chosen_mice, mouse_date, server, mouse_vel, dff_st, frames_before_left, frames_after_left, stim_frame, save_data_directory, trials, function_params)
%process and plot aligned (to sound or opto?) changes in velocity vs neural data for specific context

    % Initialize output variables
    mouse_trial_stats = {};
    vel_aligned_right_all = {};
    vel_aligned_left_all = {};
    neural_aligned_right_all = {};
    neural_aligned_left_all = {};
    
    % Load significance cells thresholds
    [combined_thres] = load_significance_thresholds(dff_st);

    % Initialize stats structure
    mouse_trial_stats = {};
    vel_aligned_right_all= {};
    vel_aligned_left_all = {};
    neural_aligned_right_all = {};
    neural_aligned_left_all = {};

    % Load cell types IDs in case we need them
    load('V:\Connie\results\opto_2024\context\data_info\all_celltypes.mat');

    
    % Process each mouse
    for m = chosen_mice
        % Get mouse info
        current_mouse_date = mouse_date{m}
        current_server = server{m};

        % Get current dataset's cell types
        function_params.current_celltypes = all_celltypes{1,m};
        
        % Get trial indices based on context
        [trials_left, trials_right] = get_trial_indices(trials, m, function_params);
        
        % Store trial indices
        trial_indices_left_all{m} = trials_left;
        trial_indices_right_all{m} = trials_right;
        
        % Process trials and store results
        [mouse_stats,vel_aligned_right,vel_aligned_left,neural_aligned_right,neural_aligned_left ]= process_mouse_trials(chosen_mice, m, current_mouse_date, current_server, ...
            mouse_vel, dff_st, frames_before_left, frames_after_left, ...
            trials_left, trials_right, combined_thres,stim_frame, function_params,save_data_directory);
        mouse_trial_stats{m,1} = mouse_stats(1,:);
        mouse_trial_stats{m,2} = mouse_stats(2,:);
        mouse_trial_stats{m,3} = mouse_stats(3,:);
        mouse_trial_stats{m,4} = mouse_stats(4,:);
        vel_aligned_right_all{m} = vel_aligned_right;
        vel_aligned_left_all{m} = vel_aligned_left;
        neural_aligned_right_all{m} = neural_aligned_right;
        neural_aligned_left_all {m} = neural_aligned_left;

    end
    %generate scatter plots including all trials across all datasets!
    [mouse_trial_stats,difference_stats_info,trial_indices_right_all,trial_indices_left_all] = generate_scatter_differences_plots_running(mouse_trial_stats,chosen_mice,vel_aligned_right_all,vel_aligned_left_all,...
        neural_aligned_right_all,neural_aligned_left_all,function_params);

    %save single_mouse_plots if finished
    if function_params.single_mouse_plot == 1
        if ~isempty(save_data_directory)
            mkdir(save_data_directory);
            cd (save_data_directory);
            exportgraphics(figure(603),strcat('scatter_speed_v_neural_trials_difference',strcat(num2str(frames_before_left),'-', num2str(frames_after_left)),'context',num2str(function_params.context),'_sig_cells',function_params.chosen_cells,num2str(function_params.neural_abs),'_abs_',num2str(function_params.abs),'.pdf'), 'ContentType', 'vector');
            saveas(figure(603),strcat('scatter_speed_v_neural_trials_difference',strcat(num2str(frames_before_left),'-', num2str(frames_after_left)),'context',num2str(function_params.context),'_sig_cells',function_params.chosen_cells,num2str(function_params.neural_abs),'_abs_',num2str(function_params.abs),'.fig'));
            
            exportgraphics(figure(605),['vel_heatmaps_left_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.pdf'], 'ContentType', 'vector');
            saveas(figure(605),['vel_heatmaps_left_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.fig']);
            
            exportgraphics(figure(606),['vel_heatmaps_right_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.pdf'], 'ContentType', 'vector');
            saveas(figure(606),['vel_heatmaps_right_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.fig']);
            
            exportgraphics(figure(607),['vel_avg_traces_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.pdf'], 'ContentType', 'vector');
            saveas(figure(607),['vel_avg_traces_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.fig']);
           
        end
    end

        %PLOT SCATTER OF PITCH AND ROLL 
        %PLOT ACTIVE AND PASSIVE HAVE TO LOAD DATA AGAIN
        % Initialize variables to store combined data across mice
        deltaNeuralActivity = [];
        deltaRoll = [];
        deltaPitch = [];
        % Initialize separate arrays for left and right values
        deltaRoll_left = [];
        deltaRoll_right = [];
        deltaPitch_left = [];
        deltaPitch_right = [];
        
        
        for m = chosen_mice
            %TRIALS TO USE!
            if strcmp(function_params.context,'all')
                trials_left = [trials{1,1}{1,m}{1,:}];
                trials_right = [trials{2,1}{1,m}{1,:}];
            else
                trials_left = trials{1,1}{1,m}{1,function_params.context};
                trials_right = trials{2,1}{1,m}{1,function_params.context};
            end
            %RUNNING DATA
            field_name = [function_params.field_name_vel '_roll'];
            vel_aligned_left_roll = mouse_vel(m).(field_name)(trials_left,:); %trials_left [varargin{1,1}{1,1}{1,m}{1,:}]
            vel_aligned_right_roll = mouse_vel(m).(field_name)(trials_right,:); %trials_right [varargin{1,1}{2,1}{1,m}{1,:}]
            
            field_name = [function_params.field_name_vel '_pitch'];
            vel_aligned_left_pitch = mouse_vel(m).(field_name)(trials_left,:);
            vel_aligned_right_pitch = mouse_vel(m).(field_name)(trials_right,:);
            
            [speed_left_avg_r,speed_right_avg_r] = difference_2event(vel_aligned_left_roll,vel_aligned_right_roll,stim_frame, frames_before_left,frames_after_left);
            [speed_left_avg_p,speed_right_avg_p] = difference_2event(vel_aligned_left_pitch,vel_aligned_right_pitch,stim_frame, frames_before_left,frames_after_left);
            vel_aligned_right_r{m} = speed_right_avg_r;
            vel_aligned_left_r{m} = speed_left_avg_r;
        
            vel_aligned_right_p{m} = speed_right_avg_p;
            vel_aligned_left_p{m} = speed_left_avg_p;
        
            % Neural activity differences (aligned to events)
            neural_left = neural_aligned_left_all{m} ; % Replace with your actual left trial neural activity matrix
            neural_right = neural_aligned_right_all{m} ; % Replace with your actual right trial neural activity matrix
            % Concatenate across mice for left and right trials
            deltaNeuralActivity = [deltaNeuralActivity; neural_left(:); neural_right(:)];
            deltaRoll = [deltaRoll; speed_left_avg_r(:); speed_right_avg_r(:)];
            deltaPitch = [deltaPitch; speed_left_avg_p(:); speed_right_avg_p(:)];
        
            if function_params.abs == 1
                % Separate the left and right components
                deltaRoll_left = [deltaRoll_left; abs(speed_left_avg_r(:))];
                deltaRoll_right = [deltaRoll_right; abs(speed_right_avg_r(:))];
                deltaPitch_left = [deltaPitch_left; abs(speed_left_avg_p(:))];
                deltaPitch_right = [deltaPitch_right; abs(speed_right_avg_p(:))];
            else
                deltaRoll_left = [deltaRoll_left; speed_left_avg_r(:)];
                deltaRoll_right = [deltaRoll_right; speed_right_avg_r(:)];
                deltaPitch_left = [deltaPitch_left; speed_left_avg_p(:)];
                deltaPitch_right = [deltaPitch_right; speed_right_avg_p(:)];
            end
        
        end
        
        % Assuming you have the following vectors:
        % Create a table with your data
        tbl = table(deltaNeuralActivity, deltaRoll, deltaPitch, ...
                    'VariableNames', {'DeltaNeuralActivity', 'DeltaRollVelocity', 'DeltaPitchVelocity'});
        % Fit a linear model with main effects and interaction
        lm = fitlm(tbl, 'DeltaNeuralActivity ~ DeltaRollVelocity + DeltaPitchVelocity');
        % Display the results
        disp(lm);
        
        figure(625); clf;
        hold on;
        % Scatter plot for positive right trial points
        scatter(deltaRoll_right, deltaPitch_right, 30, 'filled', 'MarkerFaceColor', function_params.right_color, 'MarkerFaceAlpha', 0.3);
        % Scatter plot for positive left trial points
        scatter(deltaRoll_left, deltaPitch_left, 30, 'filled', 'MarkerFaceColor', function_params.left_color, 'MarkerFaceAlpha', 0.3);
        % Fit linear models for right and left positive trials
        lm_right_pos = fitlm(deltaRoll_right, deltaPitch_right);%,'RobustOpts','on');
        lm_left_pos = fitlm(deltaRoll_left, deltaPitch_left);%,'RobustOpts','on');
        % Get R-squared values
        r_squared_right_pos = lm_right_pos.Rsquared.Ordinary;
        r_squared_left_pos = lm_left_pos.Rsquared.Ordinary;
        % Get plot axis ranges
        x_range = xlim;
        y_range = ylim;
        % Plot regression lines
        x_fit = linspace(min([deltaRoll_right; deltaRoll_left]), max([deltaRoll_right; deltaRoll_left]), 100);
        y_fit_right = predict(lm_right_pos, x_fit'); % Predicted values for right trials
        y_fit_left = predict(lm_left_pos, x_fit');   % Predicted values for left trials
        % Plot regression lines
        plot(x_fit, y_fit_right,'Color', function_params.right_color, 'LineWidth', 1.5); % Right trial regression line
        plot(x_fit, y_fit_left, 'Color', function_params.left_color, 'LineWidth', 1.5); % Left trial regression line
        % Extract p value for each model!
        p_value_right_roll_pitch =  lm_right_pos.Coefficients.pValue(2); % p-value for the slope (2nd row) 
        p_value_left_roll_pitch = lm_left_pos.Coefficients.pValue(2); % p-value for the slope (2nd row)
        
        
        % Add R-squared text to the plot
        text_x = x_range(2) - 0.2 * diff(x_range);
        text_y = y_range(1) + 0.25 * diff(y_range);
        text(text_x, text_y, sprintf('Right Trials R^2 = %.3f', r_squared_right_pos), 'Color', function_params.right_color, 'FontSize', 12);
        text(text_x, text_y - 0.15 * range([deltaPitch_right; deltaPitch_left]), ...
            sprintf('Left Trials R^2 = %.3f', r_squared_left_pos), 'Color', function_params.left_color, 'FontSize', 12);
        if function_params.abs == 1
            xlabel('Roll Speed Change');
            ylabel('Pitch Speed Change');
        else
            xlabel('Roll Velocity Change');
            ylabel('Pitch Velocity Change');
        end
        set(gca, 'FontSize', 12, 'Units', 'inches', 'Position', [1, 1, 1.5, 1.5]);
        hold off;

    %save figures and stats
    if ~isempty(save_data_directory)
        mkdir(save_data_directory);
        cd (save_data_directory);
        save_str=strcat("difference_",function_params.vel_type,"_neural-",function_params.chosen_cells,"_stats_context", num2str(function_params.context) ,"_" ,num2str(frames_before_left),"-", num2str(frames_after_left),'_abs_',num2str(function_params.abs), ".mat");
        save(save_str, 'mouse_trial_stats','difference_stats_info');

        exportgraphics(figure(613),[function_params.vel_type '_mean_difference_neural-',function_params.chosen_cells,'_vs_speed_binned_scatter_error_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.pdf'], 'ContentType', 'vector');
        saveas(figure(613),[function_params.vel_type '_mean_difference_neural-',function_params.chosen_cells,'_vs_speed_binned_scatter_error_context' num2str(function_params.context) '.fig']);
    
        exportgraphics(figure(620),[function_params.vel_type '_scatter_all_difference_neural-',function_params.chosen_cells,'_vs_speed_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left),'_abs_',num2str(function_params.abs)) '.pdf'], 'ContentType', 'vector');
        saveas(figure(620),[function_params.vel_type '_scatter_all_difference_neural-',function_params.chosen_cells,'_vs_speed_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left),'_abs_',num2str(function_params.abs)) '.fig']);

    end

end

function [combined_thres] = load_significance_thresholds(dff_st)
    % Load significance thresholds from files
%     passive = load('V:\Connie\results\passive\mod\sig_mod_boot_thr.mat');
%     passive_sig = passive.sig_mod_boot_thr;
%     
%     active = load('V:\Connie\results\active\mod\sig_mod_boot_thr.mat');
%     active_sig = active.sig_mod_boot_thr;
    sig_mod_boot_thr = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot_thr.mat').sig_mod_boot_thr;
    active_sig = sig_mod_boot_thr(:,1)';
    passive_sig = sig_mod_boot_thr(:,2)';
    
    [combined_thres, ~] = union_sig_cells(active_sig, passive_sig, dff_st);
end

function [trials_left, trials_right] = get_trial_indices(trials, m, function_params)
    % Get trial indices based on context
    if strcmp(function_params.context, 'all')
        trials_left = [trials{1,1}{1,m}{1,:}];
        trials_right = [trials{2,1}{1,m}{1,:}];
    else
        trials_left = trials{1,1}{1,m}{1,function_params.context};
        trials_right = trials{2,1}{1,m}{1,function_params.context};
    end
end

function [mouse_trial_stats,vel_aligned_right_all,vel_aligned_left_all,neural_aligned_right_all,neural_aligned_left_all] = process_mouse_trials(chosen_mice,m, mouse_date, server, mouse_vel, dff_st, ...
    frames_before_left, frames_after_left, trials_left, trials_right, combined_thres, stim_frame, function_params,save_data_directory)
        
    %LOAD ALIGNED RUNNING DATA
    if strcmp(function_params.vel_type,'roll')
        field_name = [function_params.field_name_vel '_roll'];
        vel_aligned_left = mouse_vel(m).(field_name)(trials_left,:); %trials_left [varargin{1,1}{1,1}{1,m}{1,:}]
        vel_aligned_right = mouse_vel(m).(field_name)(trials_right,:); %trials_right [varargin{1,1}{2,1}{1,m}{1,:}]
        function_params.caxis_values = [-60,60];
        function_params.ylims2 = [-40,40];
    elseif strcmp(function_params.vel_type,'pitch') %use pitch
        field_name = [function_params.field_name_vel '_pitch'];
        vel_aligned_left = mouse_vel(m).(field_name)(trials_left,:);
        vel_aligned_right = mouse_vel(m).(field_name)(trials_right,:);
        function_params.caxis_values = [0,70];
        function_params.ylims2 = [0,70];
    else % square root(pitch^2 + roll^2)
        field_name = function_params.field_name_vel;
        vel_aligned_left = mouse_vel(m).(field_name)(trials_left,:);
        vel_aligned_right = mouse_vel(m).(field_name)(trials_right,:);
        function_params.caxis_values = [0,70];
        function_params.ylims2 = [0,70];
    end

    [speed_left_avg,speed_right_avg] = difference_2event(vel_aligned_left,vel_aligned_right,stim_frame, frames_before_left,frames_after_left);
%     %take absolute value of the difference? speed vs velocity
    if function_params.abs ==1
        speed_right_avg = abs(speed_right_avg);
        speed_left_avg = abs(speed_left_avg);
    end

    [p_left,p_right,h_opto,h_right] = wilk_sign_rank(vel_aligned_left, vel_aligned_right,stim_frame, frames_before_left,frames_after_left);
    mouse_trial_stats(1,:) = [p_left,p_right];
    mouse_trial_stats(2,:) = [h_opto,h_right];

    %IMPORTANT!! DECIDE WHAT TO SHOW! 
    %decide if you want to plot only velocity before or after or the difference
    if function_params.only_before == 1
        frame2comp_before = stim_frame - frames_before_left;
        speed_left_avg  = mean(vel_aligned_left(:,frame2comp_before:stim_frame-1),2);
        speed_right_avg = mean(vel_aligned_right(:,frame2comp_before:stim_frame-1),2);
    elseif function_params.only_before == 2
        frame2comp_after = stim_frame + frames_after_left;
        speed_left_avg  = mean(vel_aligned_left(:,stim_frame-1:frame2comp_after),2);
        speed_right_avg = mean(vel_aligned_right(:,stim_frame-1:frame2comp_after),2);
    end

    %LOAD ALIGNED NEURAL DATA!
    % Normalize along the frames dimension for each cell
    field_name_neural = function_params.field_name_neural; %decide if we want to use control or opto trials!
    if strcmp(function_params.chosen_cells, 'all')
        cellCount = size(dff_st{1,m}.(field_name_neural),2); %loading from control which does not have opto so only sounds!
        mod_cells = 1:cellCount;
        sig_mod_boot{1,m} = mod_cells;
    elseif strcmp(function_params.chosen_cells, 'sig')
        sig_mod_boot{1,m} = combined_thres{1,m};
    elseif strcmp(function_params.chosen_cells, 'som')
        sig_mod_boot{1,m} = function_params.current_celltypes.som_cells;
    elseif strcmp(function_params.chosen_cells, 'pv')
        sig_mod_boot{1,m} = function_params.current_celltypes.pv_cells;
    elseif strcmp(function_params.chosen_cells, 'pyr')
        sig_mod_boot{1,m} = function_params.current_celltypes.pyr_cells;
    end

    smoothing_param = [];
    method_norm = 'zscore';
    aligned_neural_data = dff_st{1,m}.(field_name_neural); %using control trials which do not have opto!!

    %figure out another way to remove outlier
    if strcmp(mouse_date,'HE4-1L1R\2023-09-04')
        aligned_neural_data(70,:,:) = NaN;
    end

    data_norm = normalize_aligned_data(aligned_neural_data,method_norm,smoothing_param); %inside behavior-analysis
    left_matrix = data_norm(trials_left,sig_mod_boot{1,m},:);
    right_matrix = data_norm(trials_right,sig_mod_boot{1,m},:);

    left_matrix_trials = squeeze(mean(left_matrix,2,'omitnan')); %mean across cells, gives trials vs time
    right_matrix_trials = squeeze(mean(right_matrix,2,'omitnan')); %mean across cells, gives trials vs time

    [neural_left_avg,neural_right_avg] = difference_2event(left_matrix_trials, right_matrix_trials,stim_frame, frames_before_left,frames_after_left);

        %     %take absolute value of the neural difference?
    if function_params.neural_abs ==1
        neural_left_avg = abs(neural_left_avg);
        neural_right_avg = abs(neural_right_avg);
    end

    [p_left,p_right,h_opto,h_right]=wilk_sign_rank(left_matrix_trials, right_matrix_trials,stim_frame, frames_before_left,frames_after_left);
    mouse_trial_stats(3,:) = [p_left,p_right];
    mouse_trial_stats(4,:) = [h_opto,h_right];


   %MAKE SINGLE MOUSE PLOTS!!
    if function_params.single_mouse_plot == 1
        %make scatter/heamtaps for each dataset 
        save_string_frames = strcat(num2str(frames_before_left),'-', num2str(frames_after_left));
        generate_single_mouse_plots_running(chosen_mice, m, mouse_date,speed_right_avg,speed_left_avg,neural_right_avg,neural_left_avg,left_matrix,right_matrix,vel_aligned_left,vel_aligned_right,stim_frame,function_params,save_data_directory,save_string_frames);
        if ~isempty(save_data_directory)
            mkdir(save_data_directory);
            cd (save_data_directory);
            exportgraphics(figure(603),strcat(function_params.vel_type,'_all_mice_scatter_speed_v_neural_trials_difference',strcat(num2str(frames_before_left),'-', num2str(frames_after_left)),'context',num2str(function_params.context),'_sig_cells',function_params.chosen_cells,num2str(function_params.neural_abs),'_abs_',num2str(function_params.abs),'.pdf'), 'ContentType', 'vector');
            saveas(figure(603),strcat(function_params.vel_type,'_all_mice_scatter_speed_v_neural_trials_difference',strcat(num2str(frames_before_left),'-', num2str(frames_after_left)),'context',num2str(function_params.context),'_sig_cells',function_params.chosen_cells,num2str(function_params.neural_abs),'_abs_',num2str(function_params.abs),'.fig'));
            
            exportgraphics(figure(605),[function_params.vel_type '_all_mice_vel_heatmaps_left_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.pdf'], 'ContentType', 'vector');
            saveas(figure(605),[function_params.vel_type '_all_mice_vel_heatmaps_left_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.fig']);
            
            exportgraphics(figure(606),[function_params.vel_type '_all_mice_vel_heatmaps_right_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.pdf'], 'ContentType', 'vector');
            saveas(figure(606),[function_params.vel_type '_all_mice_vel_heatmaps_right_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.fig']);
            
            exportgraphics(figure(607),[function_params.vel_type '_all_mice_vel_avg_traces_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.pdf'], 'ContentType', 'vector');
            saveas(figure(607),[function_params.vel_type '_all_mice_vel_avg_traces_context' num2str(function_params.context) '_' strcat(num2str(frames_before_left),'-', num2str(frames_after_left)) '.fig']);
           
        end
    end

    
    % Store processed data
    vel_aligned_right_all = speed_right_avg;
    vel_aligned_left_all = speed_left_avg;
    neural_aligned_right_all = neural_right_avg;
    neural_aligned_left_all = neural_left_avg;
end

function generate_single_mouse_plots_running(chosen_mice,m,mouse_date,speed_right_avg,speed_left_avg,neural_right_avg,neural_left_avg,left_matrix,right_matrix,vel_aligned_left,vel_aligned_right,stim_frame,function_params, save_data_directory,save_string_frames)
%generates plots for each mouse indiividually (scatter and heatmaps of
%speed and neural data) and also big figures with many subplots for each
%dataset
    figure(600); clf;
    colormap viridis
    % Parameters for shifting subplots
    shift_x = 0.05; % Amount to shift the subplots to the left
    cb_width = 0.01; % Width of the colorbar
    cb_padding = 0.01; % Space between the colorbar and its subplot
    % Subplot 1
    ax1 = subplot(1, 5, 1);
    hold on;
    scatter(speed_right_avg, neural_right_avg, 'MarkerEdgeColor', function_params.right_color, 'LineWidth', 1.3);
    scatter(speed_left_avg, neural_left_avg, 'MarkerEdgeColor', function_params.left_color, 'LineWidth', 1.3);
    xlabel('Speed Change');
    ylabel('Neural Change');
    hold off;
    axis square;
    % Adjust position
    pos1 = get(ax1, 'Position');
    set(ax1, 'Position', [pos1(1) - shift_x - 0.01, pos1(2), pos1(3), pos1(4)]);
    % Subplot 2
    ax2 = subplot(1, 5, 2);
    imagesc(squeeze(mean(left_matrix(:,:,:), 2)));
    xline(stim_frame, 'y', 'color', 'w', 'LineWidth', 2, 'alpha', 0.5);
    ylabel('Trial ID');
    xlabel('Time (s)');
    title('Avg Neural Data Left', 'FontWeight', 'normal');
    caxis([0 .6]);
    [xticks_in, xticks_lab] = x_axis_sec_aligned(stim_frame, size(left_matrix, 3));
    xticks(xticks_in);
    xticklabels(xticks_lab);
    axis square;
    % Adjust position
    pos2 = get(ax2, 'Position');
    set(ax2, 'Position', [pos2(1) - shift_x, pos2(2), pos2(3), pos2(4)]);
    % Subplot 3
    ax3 = subplot(1, 5, 3);
    imagesc(vel_aligned_left);
    xline(stim_frame, 'y', 'color', 'w', 'LineWidth', 2, 'alpha', 0.5);
    caxis(function_params.caxis_values);
    xlabel('Time (s)');
    title('Speed Data Left', 'FontWeight', 'normal');
    [xticks_in, xticks_lab] = x_axis_sec_aligned(stim_frame, size(left_matrix, 3));
    xticks(xticks_in);
    xticklabels(xticks_lab);
    axis square;
    % Adjust position
    pos3 = get(ax3, 'Position');
    set(ax3, 'Position', [pos3(1) - shift_x, pos3(2), pos3(3), pos3(4)]);
    % Subplot 4
    ax4 = subplot(1, 5, 4);
    imagesc(squeeze(mean(right_matrix(:,:,:), 2)));
    pos4 = get(ax4, 'Position');
    xline(stim_frame, 'y', 'color', 'w', 'LineWidth', 2, 'alpha', 0.5);
    xlabel('Time (s)');
    title('Avg Neural Data Right', 'FontWeight', 'normal');
    caxis([0 .6]);
    [xticks_in, xticks_lab] = x_axis_sec_aligned(stim_frame, size(left_matrix, 3));
    xticks(xticks_in);
    xticklabels(xticks_lab);
    axis square;
    % Add colorbar for Subplot 4
    cb4 = colorbar;
    set(cb4, 'Position', [pos4(1) + pos4(3) + cb_padding- shift_x, 0.28, cb_width, 0.47]);%[pos4(1) + pos4(3) + cb_padding, pos4(2), cb_width, pos4(4)]);
    % Subplot 5
    ax5 = subplot(1, 5, 5);
    imagesc(vel_aligned_right);
    pos5 = get(ax5, 'Position');
    xline(stim_frame, 'y', 'color', 'w', 'LineWidth', 2, 'alpha', 0.5);
    caxis(function_params.caxis_values);
    xlabel('Time (s)');
    title('Speed Data Right', 'FontWeight', 'normal');
    [xticks_in, xticks_lab] = x_axis_sec_aligned(stim_frame, size(left_matrix, 3));
    xticks(xticks_in);
    xticklabels(xticks_lab);
    axis square;
    % Add colorbar for Subplot 5
    cb5 = colorbar;
    set(cb5, 'Position', [pos5(1) + pos5(3) + cb_padding, 0.28, cb_width, 0.47]);%[pos5(1) + pos5(3) + cb_padding, pos5(2), cb_width, pos5(4)]); %left,right,width,height
    % Adjust position
    pos4 = get(ax4, 'Position');
    set(ax4, 'Position', [pos4(1) - shift_x, pos4(2), pos4(3), pos4(4)]);
    % Adjust position
    pos5 = get(ax5, 'Position');
    set(ax5, 'Position', [pos5(1), pos5(2), pos5(3), pos5(4)]);
    set(gcf,'Units', 'inches', 'Position', [1, 1, 7.5 ,2 ]); %7.5 ,2 

    temp = strfind(mouse_date,'/');
    if isempty(temp)
        temp = strfind(mouse_date,'\');
    end
    mouse_title = [mouse_date(1:temp-1) '-' mouse_date(temp+1:end)]
    
    if ~isempty(save_data_directory)     
        mkdir(save_data_directory);
        cd (save_data_directory);
        exportgraphics(figure(600),strcat(mouse_title,'_speed_',function_params.vel_type,'_v_neural_trials_difference',function_params.vel_type,'_',save_string_frames,'context',num2str(function_params.context),'_sig_cells',function_params.chosen_cells,num2str(function_params.neural_abs),'_abs_',num2str(function_params.abs),'.pdf'), 'ContentType', 'vector');
        saveas(figure(600),strcat(mouse_title,'_speed_',function_params.vel_type,'_v_neural_trials_difference',function_params.vel_type,'_',save_string_frames,'context',num2str(function_params.context),'_sig_cells',function_params.chosen_cells,num2str(function_params.neural_abs),'_abs_',num2str(function_params.abs),'.fig'));
    end


    %doing a big figure containing scatter plot of differences for all
    %datasets
    figure_size = ceil(sqrt(length(chosen_mice)));
    figure(603);%tiledlayout(4,4)
    subplot(figure_size,figure_size,m)
    hold on
    scatter(speed_right_avg,neural_right_avg,'MarkerEdgeColor', function_params.right_color,'LineWidth', 1.3)
    scatter(speed_left_avg,neural_left_avg,'MarkerEdgeColor', function_params.left_color,'LineWidth', 1.3)
    % legend('left trials', 'right trials','location','southeast','box','off');
    xlabel('Speed Change');%('Speed pre (30 frames)')%
    ylabel('Neural Change')
    title(num2str(mouse_date),'FontWeight','normal')
    hold off
    set(gcf,'Units', 'inches', 'Position', [1, 1, 7.5, 7.5]);
    
    %plot heatmaps of running speeds for each dataset (left)
    figure(605);%tiledlayout(4,4)
    subplot(figure_size,figure_size,m)
    hold on
    colormap viridis
    imagesc(vel_aligned_left); 
    xline(stim_frame, 'y','color','w','LineWidth',2,'alpha',0.5);
    caxis(function_params.caxis_values)
    xlim([1 size(vel_aligned_left,2)])
    ylim([1 size(vel_aligned_left,1)])
    ylabel('Trial ID')
    xlabel('Time (s)')
    title('Speed Left')
    title(num2str(mouse_title),'FontWeight','normal')
    [xticks_in,xticks_lab]  = x_axis_sec_aligned(stim_frame,size(left_matrix,3));
    xticks(xticks_in);
    xticklabels(xticks_lab);
    hold off
    set(gcf,'Units', 'inches', 'Position', [1, 1, 7.5, 7.5]);
    
    %plot heatmaps of running speeds for each dataset (right)
    figure(606);%tiledlayout(4,4)
    subplot(figure_size,figure_size,m)
    hold on
    colormap viridis
    imagesc(vel_aligned_right); 
    xline(stim_frame, 'y','color','w','LineWidth',2,'alpha',0.5);
    caxis(function_params.caxis_values)
    xlim([1 size(vel_aligned_right,2)])
    ylim([1 size(vel_aligned_right,1)])
    ylabel('Trial ID')
    xlabel('Time (s)')
    title('Speed Data')
    title(num2str(mouse_title),'FontWeight','normal')
    [xticks_in,xticks_lab]  = x_axis_sec_aligned(stim_frame,size(left_matrix,3));
    xticks(xticks_in);
    xticklabels(xticks_lab);
    hold off
    set(gcf,'Units', 'inches', 'Position', [1, 1, 7.5, 7.5]);
    
    %plot average traces for left and right for each dataset
    figure(607);
    subplot(figure_size,figure_size,m)
    hold on;
    SEM = std(vel_aligned_right) / sqrt(size(vel_aligned_right, 1)); % Calculate SEM
    shadedErrorBar(1:size(vel_aligned_right, 2), mean(vel_aligned_right), SEM, ...
        'lineProps', {'color', function_params.right_color});
    
    SEM = std(vel_aligned_left) / sqrt(size(vel_aligned_left, 1)); % Calculate SEM
    shadedErrorBar(1:size(vel_aligned_left, 2), mean(vel_aligned_left), SEM, ...
        'lineProps', {'color', function_params.left_color});
    
    xline(stim_frame, '--k'); % Add vertical line
    xlim([1 size(vel_aligned_left,2)])
    ylim(function_params.ylims2)
    [xticks_in,xticks_lab]  = x_axis_sec_aligned(stim_frame,size(left_matrix,3));
    xticks(xticks_in);
    xticklabels(xticks_lab);
    xlabel('Time (s)')
    title(num2str(mouse_title),'FontWeight','normal')
    
    hold off
    set(gcf,'Units', 'inches', 'Position', [1, 1, 7.5, 7.5]);

end

function [mouse_trial_stats,stats_info,trial_indices_right_all,trial_indices_left_all] = generate_scatter_differences_plots_running(mouse_trial_stats,chosen_mice,vel_aligned_right_all,vel_aligned_left_all,neural_aligned_right_all,neural_aligned_left_all,function_params)
%Create scatter and binned plots of the differences in speed vs neural using all trials across datasets!

colors_right = function_params.right_color;%[0 0 0]; % Black for right
    colors_left = function_params.left_color;%[0.5 0.5 0.5]; % Gray for left
    
    figure(620); clf;
    hold on;
    % Colors for right and left trials
    % Initialize arrays to store all data points across datasets
    all_vel_right = [];
    all_metric_right = [];
    all_vel_left = [];
    all_metric_left = [];
    % Loop through datasets
    for m = chosen_mice %1:length(chosen_mice)
        % Append right trial data
        all_vel_right = [all_vel_right; vel_aligned_right_all{m}];
        all_metric_right = [all_metric_right; neural_aligned_right_all{m}];
        % Append left trial data
        all_vel_left = [all_vel_left; vel_aligned_left_all{m}];
        all_metric_left = [all_metric_left; neural_aligned_left_all{m}];
    end
    % Scatter plot for all right trial points
    scatter(all_vel_right, all_metric_right, 30,'filled', 'MarkerFaceColor', colors_right,'MarkerFaceAlpha', 0.3);%'filled', 'MarkerFaceAlpha', 0.3);
    % Scatter plot for all left trial points
    scatter(all_vel_left, all_metric_left, 30,'filled', 'MarkerFaceColor', colors_left,'MarkerFaceAlpha', 0.3);%
    
    % Fit linear models
    model_right = fitlm(all_vel_right, all_metric_right); % Linear model for right trials
    model_left = fitlm(all_vel_left, all_metric_left);    % Linear model for left trials
    % Get fitted lines for plotting
    x_fit = linspace(min([all_vel_right; all_vel_left]), max([all_vel_right; all_vel_left]), 100);
    y_fit_right = predict(model_right, x_fit'); % Predicted values for right trials
    y_fit_left = predict(model_left, x_fit');   % Predicted values for left trials
    % Plot regression lines
    plot(x_fit, y_fit_right,'Color', colors_right, 'LineWidth', 1.5); % Right trial regression line
    plot(x_fit, y_fit_left, 'Color', colors_left, 'LineWidth', 1.5); % Left trial regression line
    % Extract R-squared values
    r2_right = model_right.Rsquared.Ordinary;
    r2_left = model_left.Rsquared.Ordinary;
    % Extract p value for each model!
    p_value_right = model_right.Coefficients.pValue(2); % p-value for the slope (2nd row) 
    p_value_left = model_left.Coefficients.pValue(2); % p-value for the slope (2nd row)

    %save into structure
    stats_info.linear_model_p_right = p_value_right;
    stats_info.linear_model_p_left = p_value_left;
    stats_info.linear_model_r2_right = r2_right;
    stats_info.linear_model_r2_left = r2_left;
    stats_info.total_trials_right = length(all_vel_right);
    stats_info.total_trials_left = length(all_vel_left);
    
    
    mouse_trial_stats{length(chosen_mice)+1,1} = [r2_right,r2_left];
    mouse_trial_stats{length(chosen_mice)+1,2} = [p_value_right,p_value_left];
    
    % Display R^2 values in the bottom-right corner
    x_range = xlim; % Get x-axis range
    y_range = ylim; % Get y-axis range
    
    % % Add R-squared text to the plot
    text_x = x_range(2) - 0.2 * diff(x_range);
    text_y = y_range(1) + 0.3 * diff(y_range);
    text(text_x, text_y, sprintf('Right Trials R^2 = %.3f', r2_right), 'Color', colors_right, 'FontSize', 12);
    text(text_x, text_y - 0.15 * range([all_metric_right; all_metric_left]), ...
        sprintf('Left Trials R^2 = %.3f', r2_left), 'Color', colors_left, 'FontSize', 12);
    % Customize the plot
    if function_params.abs == 1
        xlabel('Speed Change');
    else
        xlabel('Velocity Change');
    end
    ylabel('Neural Change');
    xlim([min(x_fit) max(x_fit)]);
    ylim([min([all_metric_right; all_metric_left]) max([all_metric_right; all_metric_left])]);
    axis square;
    hold off;
    set(gca, 'FontSize', 12, 'Units', 'inches', 'Position', [1, 2, 1.5,1.5]);
    
    %MAKE PLOT BINNING THE DATA!! and also count how many trials per bin!
    figure(614);clf;
    % Define speed change bins
    
    bins = function_params.bins; %[0,10,Inf]%[-Inf,-10, 0, 10, Inf]; %[-Inf, -20, -10, 0, 10, 20, Inf]; % Thresholds for speed change
    num_bins = length(bins) - 1;
    % Initialize variables to store metrics across datasets
    trial_right_metric_bin_all = zeros(length(chosen_mice), num_bins);
    trial_left_metric_bin_all = zeros(length(chosen_mice), num_bins);
    trial_counts_right = zeros(length(chosen_mice), num_bins); % Count of trials for right
    trial_counts_left = zeros(length(chosen_mice), num_bins);  % Count of trials for left
    trial_indices_right_all = cell(length(chosen_mice), num_bins); % Indices for right trials
    trial_indices_left_all = cell(length(chosen_mice), num_bins);  % Indices for left trials
    
    hold on
    % Loop through datasets
    for m = chosen_mice
        % Separate left and right group data
        trial_right_metric = neural_aligned_right_all{m};
        trial_left_metric = neural_aligned_left_all{m};
        % Data for velocity alignment
        vel_right = vel_aligned_right_all{m};
        vel_left = vel_aligned_left_all{m};
        % Initialize variables to store mean activity for each bin in this dataset
        trial_right_metric_bin = zeros(1, num_bins);
        trial_left_metric_bin = zeros(1, num_bins);
        counts_right = zeros(1, num_bins);
        counts_left = zeros(1, num_bins);
        trial_indices_right = cell(1, num_bins); % Temporary storage for right trial indices
        trial_indices_left = cell(1, num_bins); % Temporary storage for left trial indices
    
        % Loop through bins
        for b = 1:num_bins
            % Identify trials in the current bin
            idx_right = vel_right >= bins(b) & vel_right < bins(b + 1);
            idx_left = vel_left >= bins(b) & vel_left < bins(b + 1);
            % Calculate mean for each bin
            trial_right_metric_bin(b) = mean(trial_right_metric(idx_right), 'omitnan');
            trial_left_metric_bin(b) = mean(trial_left_metric(idx_left), 'omitnan');
            % Count trials in each bin
            counts_right(b) = sum(idx_right);
            counts_left(b) = sum(idx_left);
            % Store indices for each bin
            trial_indices_right{b} = find(idx_right);
            trial_indices_left{b} = find(idx_left);
    
            % Plot individual data points for right and left metrics
            scatter(repmat(b, sum(idx_right), 1), trial_right_metric(idx_right), ...
                    30, colors_right, 'filled', 'MarkerFaceAlpha', 0.3); % Right
            scatter(repmat(b, sum(idx_left), 1)+.25, trial_left_metric(idx_left), ...
                    30, colors_left, 'filled', 'MarkerFaceAlpha', 0.3); % Left
        end
        % Store results for this dataset
        trial_right_metric_bin_all(m, :) = trial_right_metric_bin;
        trial_left_metric_bin_all(m, :) = trial_left_metric_bin;
        trial_counts_right(m, :) = counts_right;
        trial_counts_left(m, :) = counts_left;
        mouse_trial_stats{m,5} = counts_right;
        mouse_trial_stats{m,6} = counts_left;
        trial_indices_right_all(m, :) = trial_indices_right;
        trial_indices_left_all(m, :) = trial_indices_left;
    end
    hold off
    axis square;
    % Plot the results
    x_values = 1:num_bins; % x-values for bins
    
    % Create dynamic labels for the x-ticks
    xticks(x_values);
    xtick_labels = arrayfun(@(b1, b2) sprintf('%.0f to %.0f', b1, b2), bins(1:end-1), bins(2:end), 'UniformOutput', false);
    xticklabels(xtick_labels);
    xlim([0.5, num_bins + 0.5]);
    ylabel('Neural Change');
    xlabel('Speed Change Bins');
    
    
    set(gca, 'FontSize', 12, 'Units', 'inches', 'Position', [1, 2, 1.5, 1.9]);
    
    % Calculate mean and SEM across datasets for each bin
    trial_right_metric_mean = mean(trial_right_metric_bin_all, 1, 'omitnan');
    trial_left_metric_mean = mean(trial_left_metric_bin_all, 1, 'omitnan');
    trial_right_metric_sem = std(trial_right_metric_bin_all, 0, 1, 'omitnan') / sqrt(length(chosen_mice));
    trial_left_metric_sem = std(trial_left_metric_bin_all, 0, 1, 'omitnan') / sqrt(length(chosen_mice));
    % Count total trials per bin across datasets
    total_trials_right = sum(trial_counts_right, 1);
    total_trials_left = sum(trial_counts_left, 1);
    figure(613);clf;hold on;
    % Scatter plots for means
    scatter(x_values, trial_right_metric_mean, 'o', 'SizeData', 60, 'LineWidth', 1, ...
            'MarkerEdgeColor', function_params.right_color, 'MarkerFaceColor', [1, 1, 1]); % Right group
    scatter(x_values + 0.25, trial_left_metric_mean, 'o', 'SizeData', 60, 'LineWidth', 1, ...
            'MarkerEdgeColor', function_params.left_color, 'MarkerFaceColor', [1, 1, 1]); % Left group
    % Error bars for SEM
    errorbar(x_values, trial_right_metric_mean, trial_right_metric_sem, 'o', ...
             'MarkerSize', 10, 'MarkerEdgeColor', function_params.right_color, 'Color', function_params.right_color);
    errorbar(x_values + 0.25, trial_left_metric_mean, trial_left_metric_sem, 'o', ...
             'MarkerSize', 10, 'MarkerEdgeColor', function_params.left_color, 'Color', function_params.left_color);
    % Customize the plot
    ylabel('Neural Change');
    xlabel('Speed Change Bins');
    xticks(x_values);
    ylim([-.1, .1]);
    axis square;
    set(gca, 'FontSize', 12, 'Units', 'inches', 'Position', [1, 2, 1.5, 1.9]);
    xticklabels(xtick_labels);
    xlim([0.5, num_bins + 0.5]);
    
    hold off;
    % Display trial counts per bin
    disp('Trial counts per bin (right):');
    disp(array2table(total_trials_right, 'VariableNames', xtick_labels));
    disp('Trial counts per bin (left):');
    disp(array2table(total_trials_left, 'VariableNames', xtick_labels));
    
    % separate by quartiles!
    prtiles = [0 25 50 75 100]; %[0:10:100];%[0:20:100];%
    
    divisions = prctile(all_vel_right, prtiles); %across all datasets
    divisions_left = prctile(all_vel_left, prtiles); %across all datasets

    stats_info.divisions = divisions;
    stats_info.divisions_left = divisions_left;

    
end
