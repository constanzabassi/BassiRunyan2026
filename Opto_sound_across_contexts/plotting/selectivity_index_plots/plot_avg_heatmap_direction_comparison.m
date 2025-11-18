
function plot_avg_heatmap_direction_comparison(avg_results, selectivity_results,save_dir,varargin)
    % Plot average responses for both left and right selective populations
    
    
        params = get_default_params();

    
    % Create figure with 2 rows (left/right selective) x 2 columns (left/right sounds)
    figure('Position', [100 100 900 800]);
    positions = utils.calculateFigurePositions(5,5,0.5,[]);
        params.colors.active = [0,0,0];
    params.colors.passive = [0.5,0.5,0.5];
    params.stim_onset = 61;
    params.positions = positions;

    if nargin > 3
        % Plot left selective population
        save_name = plot_population('both.left', 1, varargin);
        
        % Plot right selective population
        save_name = plot_population('both.right', 2, varargin);

        % Plot non-selective population (added as the third row)
        save_name = plot_population('both.nonsel', 3, varargin);
    else
        % Plot left selective population
        save_name = plot_population('both.left', 1);
        
        % Plot right selective population
        save_name = plot_population('both.right', 2);

        % Plot non-selective population (added as the third row)
        save_name = plot_population('both.nonsel', 3);
    end

    
%     sgtitle('Population Responses by Selectivity', 'FontWeight', 'normal');
    
    function save_name = plot_population(pool_type, row,varargin)
        parts = strsplit(pool_type, '.');
        if strcmp(parts{2}, 'nonsel')
            cell_indices = selectivity_results.both.nonsel.cell_indices;
        else
            cell_indices = selectivity_results.(parts{1}).(parts{2}).cell_indices;
        end
        directions = {'Left', 'Right'};
        
        for dir = 1:2
            subplot(3, 2, (row-1)*2 + dir);
            hold on;
            
            % Get responses for this direction in both contexts
            active_responses = avg_results{1,1}.(lower(directions{dir})).neuron_mean(cell_indices,:);
            passive_responses = avg_results{1,2}.(lower(directions{dir})).neuron_mean(cell_indices,:);
                        % Sizes
            nA   = size(active_responses,1);
            nP   = size(passive_responses,1);
            gap  = ceil((nA+nP)*0.05);   % or keep your mid
            % Build matrix with a white gap using NaNs (no need for a rectangle)
            mat  = [active_responses; nan(gap, size(active_responses,2)); passive_responses];
            imagesc(mat);  % YDir is 'normal' by default for imagesc
            % (If you prefer the rectangle, keep your zeros + rectangle instead)
            % Stim onset line
            xline(params.stim_onset, '-w', 'LineWidth', 1);
            % Y axis ticks: positions vs labels
            set(gca,'YDir','reverse')
            tick_step = 100;  % tick spacing
            if nA > 500
                tick_step = 500;
                active_tick_pos  = 0:tick_step:nA;
            passive_tick_pos = nA + gap +500+(0:tick_step:nP);
            else
                active_tick_pos  = 0:tick_step:nA;
                passive_tick_pos = nA + gap +100+(0:tick_step:nP);
            end
            % Labels as multiples of tick_step
            active_tick_lab  = active_tick_pos;     % shows 100, 200, 300...
            passive_tick_lab = active_tick_pos(2:end);     % if you want same scale as active
            % Alternatively, restart passive labeling:
            % passive_tick_lab = (1:tick_step:nP);  % shows 100, 200, 300... restarted
            set(gca, 'YTick', [active_tick_pos, passive_tick_pos], ...
                     'YTickLabel', [active_tick_lab, passive_tick_lab], ...
                     'YLim', [0.5, nA + gap + nP + 0.5]);

            % Define rectangle position: [x, y, width, height]
            mid = ceil(size([active_responses;passive_responses],1)*0.05);
            x = 0.5;  % left edge
            y = size(active_responses, 1) + 0.5;  % start just above active_responses
            width = size(active_responses, 2);
            height = mid;
            
            % Draw rectangle
            rectangle('Position', [x, y, width, height], 'FaceColor', 'w', 'EdgeColor', 'none');
            % Optional: annotate blocks
%             text(1,          1,        'Active',  'Color','w','FontSize',7,'VerticalAlignment','top');
%             text(1, nA+gap+1,          'Passive', 'Color','w','FontSize',7,'VerticalAlignment','top');
            % Rest of your formatting...
            xlabel('Time (s)');
            ylabel('Neurons');
            title(sprintf('%s Sound (n=%d)', directions{dir}, length(cell_indices)), ...
                  'FontSize',7,'FontWeight','normal');
            [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(params.stim_onset, size(mat,2), 1);
            xticks(xticks_in); xticklabels(xticks_lab);
            caxis([-.02, .4]); colormap viridis;
            idx = (row-1)*5 + dir;   % same index you were using
            set(gca,'Units', 'inches', 'Position', params.positions(idx, :))
            axis tight
            utils.set_current_fig;
% %             % Plot with shadedErrorBar
% %             time_vector = 1:size(active_responses,2);
% %             mid = ceil(size([active_responses;passive_responses],1)*0.05);
% %             imagesc(([active_responses;zeros(mid,size(active_responses,2));passive_responses]));
% % 
% %             % Define rectangle position: [x, y, width, height]
% %             x = 0.5;  % left edge
% %             y = size(active_responses, 1) + 0.5;  % start just above active_responses
% %             width = size(active_responses, 2);
% %             height = mid;
% %             
% %             % Draw rectangle
% %             rectangle('Position', [x, y, width, height], 'FaceColor', 'w', 'EdgeColor', 'none');
% %             % Add stimulus onset line
% %             xline(params.stim_onset, '-w', 'LineWidth', 1);
% % 
% %             % Adjust y-axis ticks
% %             num_active = size(active_responses,1);
% %             num_passive = size(passive_responses,1);
% %             num_neurons = num_active + num_passive; % ignore mid for numbering
% %             % Define y-ticks
% %             tick_step = 100;  % adjust to your preference
% %             active_ticks = 1:tick_step:num_active;
% %             passive_ticks = num_active + mid + (1:tick_step:num_passive);
% %             
% %             yticks = [active_ticks, passive_ticks];
% %             
% %             % Define continuous neuron numbering for labels
% %             active_labels = active_ticks;
% %             passive_labels = num_active + (1:tick_step:num_passive);
% %             yticklabels = [active_labels, passive_labels];
% %             
% %             % Apply to axis
% %             set(gca, 'YTick', yticks, 'YTickLabel', yticklabels);
% % 
% %             utils.set_current_fig
% %             
% %             % Format plot
% %             xlabel('Time (s)');
% %             if nargin > 2 && numel(varargin)>0 &&length(varargin{1, 1}{1, 1}{1, 1})>1
% %                 ylabel(varargin{1, 1}{1, 1}{1, 1}{1, 2});
% %             else
% %                 ylabel('Neurons'); %'Response Nuerons (ΔF/F)'
% %             end
% %                         % Sanitize ylabel text for filenames (remove spaces and special characters)
% % 
% %             title(sprintf('%s Sound (n=%d)', directions{dir}, length(cell_indices)),'FontSize',7,'FontWeight','normal');
% %             idx = (row-1)*5 + dir;   % same index you were using
% %             set(gca,'Units', 'inches', 'Position', params.positions(idx, :))
% %             % Add axis ticks
% %             [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(...
% %                 params.stim_onset, length(time_vector), 1);
% %             xticks(xticks_in);
% %             xticklabels(xticks_lab);
% %             caxis([-.02,.4])
% %             colormap viridis
                        
%             if nargin > 2 && numel(varargin)>0
%                 ylim(varargin{1, 1}{1, 1}{1, 1}{1});
%             else
%                 ylim([.10 .4])
%             end
        end

        % Add row label
        if strcmp(parts{2}, 'nonsel')
            row_label = 'Non-Selective';
        else
            row_label = sprintf('%s Selective', parts{2});
        end
        
%         % Add row label
%         annotation('textbox', [0.01, 1.05 - row * 0.33, 0.1, 0.1], ...
%             'String', row_label, ...
%             'EdgeColor', 'none', 'FontSize', 7);

        save_name = 'test';
    end

    
    % Save plots with the ylabel in the filename
    if ~isempty(save_dir)
        mkdir(save_dir);
        saveas(gcf, fullfile(save_dir, ['avg_heatmap_direction_comparison_' save_name '.png']));
        saveas(gcf, fullfile(save_dir, ['avg_heatmap_direction_comparison_' save_name '.fig']));
        exportgraphics(gcf, fullfile(save_dir, ['avg_heatmap_direction_comparison_' save_name '.pdf']), 'ContentType', 'vector');
    end
end

function params = get_default_params()
    params = struct();
    params.colors.active = [0.86, 0.15, 0.49];   % Pink
    params.colors.passive = [0.39, 0.56, 1.0];   % Light blue
    params.patch_saturation = 0.2;
    params.stim_onset = 61;
end