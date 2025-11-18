
function plot_avg_traces_direction_comparison(avg_results, selectivity_results,orientation,save_dir,varargin)
    % Plot average responses for both left and right selective populations
    
    
        params = get_default_params();

    
    % Create figure with 2 rows (left/right selective) x 2 columns (left/right sounds)
    if strcmp(orientation,'vertical')
        figure('Position', [100 100 900 800]);
        positions = utils.calculateFigurePositions(5,5,0.5,[]);
        
    else
        figure('Position', [100 100 800 900]);
        positions = utils.calculateFigurePositions(1,7,0.4,[]);
    end

        params.colors.active = [0,0,0];
    params.colors.passive = [0.5,0.5,0.5];
    params.stim_onset = 61;
    params.positions = positions;
    params.orientation = orientation;

    if nargin > 4
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

    
%     sgtitle('Population Responses by Selectivity', 'FontWeight', 'normal','Fontsize',7);
    
    function save_name = plot_population(pool_type, row,varargin)
        parts = strsplit(pool_type, '.');
        if strcmp(parts{2}, 'nonsel')
            cell_indices = selectivity_results.both.nonsel.cell_indices;
        else
            cell_indices = selectivity_results.(parts{1}).(parts{2}).cell_indices;
        end
        directions = {'Left', 'Right'};
        hold on;
        for dir = 1:2
            if strcmp(params.orientation, 'horizontal')
                subplot(1,6, (row-1)*2 + dir);
            else
                subplot(3, 2, (row-1)*2 + dir);
            end
            
            
            % Get responses for this direction in both contexts
            active_responses = avg_results{1,1}.(lower(directions{dir})).neuron_mean(cell_indices,:);
            passive_responses = avg_results{1,2}.(lower(directions{dir})).neuron_mean(cell_indices,:);
            
            % Calculate mean and SEM
            active_mean = mean(active_responses, 1);
            passive_mean = mean(passive_responses, 1);
            active_sem = std(active_responses, [], 1)/sqrt(size(active_responses,1));
            passive_sem = std(passive_responses, [], 1)/sqrt(size(passive_responses,1));
            
            % Plot with shadedErrorBar
            time_vector = 1:size(active_responses,2);
            h1 = shadedErrorBar(time_vector, active_mean, active_sem, ...
                'lineProps', {'Color', params.colors.active, 'LineWidth', 1.5}, ...
                'patchSaturation', 0.5);
            h2 = shadedErrorBar(time_vector, passive_mean, passive_sem, ...
                'lineProps', {'Color', params.colors.passive, 'LineWidth', 1.5}, ...
                'patchSaturation', 0.5);
            
            % Add stimulus onset line
            xline(params.stim_onset, '--k', 'LineWidth', 1);
            
            % Format plot
            xlabel('Time (s)');
            if nargin > 2 && numel(varargin)>0 &&length(varargin{1, 1}{1, 1}{1, 1})>1
                ylabel(varargin{1, 1}{1, 1}{1, 1}{1, 2});
                ylabel_text = varargin{1, 1}{1, 1}{1, 1}{1, 2};
            else
                ylabel('Response (ΔF/F)');
                ylabel_text = 'Response (ΔF/F)';
            end
                        % Sanitize ylabel text for filenames (remove spaces and special characters)
            save_name = strrep(ylabel_text, ' ', '_');  % Replace spaces with underscores
            save_name = regexprep(save_name, '[^\w_]', '');  % Remove non-alphanumeric characters except underscores

            if strcmp(params.orientation, 'horizontal')
                title(sprintf('%s Sound', directions{dir}),'FontSize',7,'FontWeight','normal');
            else
                % Add legend only once
                if row == 1 && dir == 1
                    legend([h1.mainLine, h2.mainLine], {'Active', 'Passive'}, ...
                        'Location', 'southeast', 'box', 'off');
    %                 utils.place_text_labels({'Active', 'Passive'}, [params.colors.active;params.colors.passive],.3);
                end
                title(sprintf('%s Sound (n=%d)', directions{dir}, length(cell_indices)),'FontSize',7,'FontWeight','normal');
            end
            
            % Add axis ticks
            [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(...
                params.stim_onset, length(time_vector), 1);
            xticks(xticks_in);
            xticklabels(xticks_lab);
            
            
%             
            if strcmp(params.orientation,'vertical')
                idx = (row-1)*5 + dir;   % same index you were using
                set(gca,'Units', 'inches', 'Position', params.positions(idx, :));
            else
                idx = (row-1)*2 + dir;   % same index you were using
                set(gca,'Units', 'inches', 'Position', params.positions(idx, :));
            end
            utils.set_current_fig;
            
            if nargin > 2 && numel(varargin)>0
                ylim(varargin{1, 1}{1, 1}{1, 1}{1});
            else
                ylim([.10 .4])
            end
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

        
    end

    % Save plots with the ylabel in the filename
    if ~isempty(save_dir)
        mkdir(save_dir);
%         saveas(gcf, fullfile(save_dir, ['avg_traces_direction_comparison_' save_name '.png']));
        saveas(gcf, fullfile(save_dir, ['avg_traces_direction_comparison_' save_name '_' params.orientation '.fig']));
        exportgraphics(gcf, fullfile(save_dir, ['avg_traces_direction_comparison_' save_name '_' params.orientation '.pdf']), 'ContentType', 'vector');
    end
end

function params = get_default_params()
    params = struct();
    params.colors.active = [0.86, 0.15, 0.49];   % Pink
    params.colors.passive = [0.39, 0.56, 1.0];   % Light blue
    params.patch_saturation = 0.2;
    params.stim_onset = 61;
end