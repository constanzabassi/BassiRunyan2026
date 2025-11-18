function p_values = cdf_corr_across_contexts(mouse_corr_stats, function_params, save_data_directory,varargin)
    % Extract velocity types
    vel_types = fieldnames(mouse_corr_stats);
    
    % Define bins for CDF
    if nargin == 3
        binss = -.5:0.05:.5; % Adjust based on expected correlation range
    else
        binss = varargin{1,1};
    end
    
    % Initialize storage for CDF data
    cdf_data = struct();
    
    %Get total contexts in the structure
    total_contexts = size(mouse_corr_stats.(vel_types{1}),2);

    corr_data_all = [];
    
    for direction = 1:2 %left and right

    % Set up figure
    figure(662+direction); clf;
    positions = utils.calculateFigurePositions(1, 6, .4, []);%(1, length(vel_types), .4, []);

        % Loop through velocity types
        for vel_idx = 1:length(vel_types)
            vel_type = vel_types{vel_idx};
            subplot(length(vel_types), 1, vel_idx);
            hold on;
            
            % Loop through contexts
            for context_idx = 1:total_contexts
                data = []; % Collect correlation data across mice
                
                % Loop through mice
                for mouse_idx = 1:size(mouse_corr_stats.(vel_type), 1)
                    data = [data; mouse_corr_stats.(vel_type){mouse_idx, context_idx, direction}(:)]; % Use first or second index based on requirement
                end
    
                %Save across mice
                corr_data_all(vel_idx,context_idx,:,direction) = data;
                
                % Compute CDF
                [cdf_data.(vel_type)(context_idx, :), ~] = make_cdf(data, binss);
                plot(binss, cdf_data.(vel_type)(context_idx, :), 'LineWidth', 2, 'LineStyle', '-', ...
                    'Color', function_params.colors_contexts_simple(context_idx, :));
            end
            
            % Adjust axes and labels
            ylim([0 1]);
            xlim([binss(1), binss(end)]);
            xlabel('Correlation');
            if vel_idx == 1
                ylabel('CDF');
            end
            title(strrep(vel_type, '_', ' '), 'FontWeight', 'normal');
            set(gca, 'XTickLabelRotation', 0, 'FontSize', 12, 'Units', 'inches', 'Position', positions(vel_idx, :));
            hold off;
    
           
        end
    
    end
    % Statistical comparisons for each velocity type correlations across contexts
    comparisons = vel_types;
    
    num_comparisons = numel(comparisons); % Number of velocity types
    alpha = 0.05 / num_comparisons; % Bonferroni-corrected significance level
    
    possible_tests = nchoosek(1:2, 2); % All pairwise context comparisons
    num_neurons = size(corr_data_all, 3); % Number of neurons
    
    % Initialize storage for p-values
    p_values = cell(size(possible_tests,1), num_comparisons, 2,2); 
    
    for direction = 1:2 %left and right
        % Loop through each velocity type (Pitch, Roll, Both)
        for c = 1:num_comparisons
            curr_comp = comparisons{c};
    
            
            matching_comparisons = c; %
            
            
            % Loop through each context pair
            for t = 1:size(possible_tests,1)
                ctx1 = possible_tests(t,1);
                ctx2 = possible_tests(t,2);
                
                % Extract correlation values for all neurons in both contexts
                corr_ctx1 = squeeze(corr_data_all(matching_comparisons,ctx1,:,direction));%{ctx1, c}; % Correlations for context 1
                corr_ctx2 = squeeze(corr_data_all(matching_comparisons,ctx2,:,direction)); % Correlations for context 2
        
                % Loop through each neuron to do paired comparisons
                p_val = signrank(corr_ctx1, corr_ctx2); % Paired comparison
                
                % Store results
                p_values{t, c, 1,direction} = p_val; % Store p-value
                p_values{t, c, 2,direction} = sprintf('%s: Context %d vs %d', curr_comp, ctx1, ctx2);
                
                % Display results
                fprintf('Comparison: %s between contexts %d and %d \n', curr_comp, ctx1, ctx2);
                fprintf('p-value: %.4f (Significant: %d)\n', p_val, p_val < alpha);
            end
        end
    end

    
    % Save plots if directory is specified
    if ~isempty(save_data_directory)
        mkdir(save_data_directory);
        exportgraphics(figure(663), fullfile(save_data_directory, 'corr_left_cdf_across_contexts.pdf'), 'ContentType', 'vector');
        saveas(figure(663), fullfile(save_data_directory, 'corr_left_cdf_across_contexts.fig'));

                exportgraphics(figure(664), fullfile(save_data_directory, 'corr_right_cdf_across_contexts.pdf'), 'ContentType', 'vector');
        saveas(figure(664), fullfile(save_data_directory, 'corr_right_cdf_across_contexts.fig'));

    end
end
