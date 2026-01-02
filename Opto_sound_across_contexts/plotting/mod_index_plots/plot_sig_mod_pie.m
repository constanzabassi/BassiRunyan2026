function [percentage_stats] = plot_sig_mod_pie(mod_params, mod_index_all, sig_mod_boot, context, savepath, plot_mode,varargin)
% plot_sig_mod_pie - Plot modulation pie charts for cells.
%
% This function generates pie charts that show the proportions of cells 
% that are positively modulated, negatively modulated, and not modulated 
% based on a provided modulation threshold. 
%
% Inputs:
%   mod_params.mod_threshold - Numeric threshold used to classify modulation indices.
%   sorted_cells  - Structure containing arrays of cell IDs for different 
%                   cell types (e.g., 'pyr', 'som', 'pv'). If empty, a single 
%                   overall pie chart is produced.
%   mod_index_all - Array of modulation index values for all cells.
%   savepath      - (Optional) Directory path where the figures will be saved.
%                   If empty, the figures are not saved.
%   mod_params.current_context -used in save string
%
% Output:
%   sorted_cells  - The (possibly augmented) input structure. A new field 
%                   'sig_cells' is added that contains the IDs (or modulation
%                   values) for all significantly modulated cells.
%
%% Check if sorted cell types were provided
if nargin < 6
    % -----------------------------
    % OVERALL PIE CHART (no cell types provided)
    % -----------------------------
    f = figure(72); clf;
    hold on;
    
%     total_cells = length(mod_index_all);
    % Calculate the proportion of cells in each dataset
    current_total = zeros(1,length(sig_mod_boot));
    pos_percent = zeros(1,length(sig_mod_boot));
    neg_percent = zeros(1,length(sig_mod_boot));
    non_mod_percent = zeros(1,length(sig_mod_boot));
    for dataset = length(sig_mod_boot)
        current_total(dataset) = length(mod_index_all{dataset,context});

        pos_percent(dataset) = length(find(mod_index_all{dataset,context}(sig_mod_boot{dataset_context})>0))/current_total(dataset);
        neg_percent(dataset) = length(find(mod_index_all{dataset,context}(sig_mod_boot{dataset_context})<0))/current_total(dataset);
        non_mod_percent(dataset) = (current_total(dataset) - length(sig_mod_boot{dataset_context}))/current_total(dataset);
    end

    percent_cells = [mean(pos_percent), mean(neg_percent), mean(non_mod_percent)];
    
    %save percentages
    percentage_stats.pos_percent = utils.get_basic_stats(pos_percent);
    percentage_stats.neg_percent = utils.get_basic_stats(neg_percent);
    percentage_stats.non_mod_percent = utils.get_basic_stats(non_mod_percent);

    % Define the labels for the pie slices
    labels = {'Positively modulated', 'Negatively modulated', 'Not modulated'};

    % --- NEW CODE: remove zero-percent categories ---
    nonzero_idx = percent_cells > 0;             % keep only categories with non-zero %
    percent_cells = percent_cells(nonzero_idx);
    labels = labels(nonzero_idx);
    customColormap = [1 1 1; 0 0 0; 0.5 0.5 0.5];
    customColormap = customColormap(nonzero_idx, :);

    % Plot the pie chart
    pie(percent_cells);
    
    % Set a custom colormap: first row = white, second = black, third = grey
    colormap(customColormap);
          
    % Set title and hide axes for a cleaner look
%     title('All Cells', 'Units', 'normalized', 'Position', [0.5, 1.2, 0]);
    set(gca, 'visible', 'off');
    set(gcf, 'Position', [150, 150, 500, 500]);
    hold off;

    %perform calculation pooling across all datasets
    current_sig = sig_mod_boot(:, context);
    concatenated_mod_index = horzcat(mod_index_all{:, context});
    global_sig_ids = convert_indices_local_to_global(current_sig, cellfun(@length, mod_index_all(:, context)));
    percentage_stats.pooled_percentages = [length(find(concatenated_mod_index(global_sig_ids)>0))/length(concatenated_mod_index),length(find(concatenated_mod_index(global_sig_ids)<0))/length(concatenated_mod_index),(length(concatenated_mod_index)-length(global_sig_ids))/length(concatenated_mod_index)];

    
else
    % -----------------------------
    % PIE CHARTS FOR EACH CELL TYPE
    % -----------------------------
    % Combine the significantly modulated cells and store in the structure.

    % Determine the number of cell types so that we can arrange subplots .
    
    all_celltypes = varargin{1,1};
    possible_celltypes = fieldnames(all_celltypes{1,1});
    numTypes = length(possible_celltypes);
    current_total = zeros(numTypes,length(sig_mod_boot));
    pos_percent = zeros(numTypes,length(sig_mod_boot));
    neg_percent = zeros(numTypes,length(sig_mod_boot));
    non_mod_percent = zeros(3,length(sig_mod_boot));
    
    for celltype = 1:numTypes
        for dataset = 1:length(sig_mod_boot)
            current_total(celltype,dataset) = length(all_celltypes{dataset}.(possible_celltypes{celltype}));
            celltype_array{celltype,dataset} = all_celltypes{dataset}.(possible_celltypes{celltype})';
            current_sig_cells = [sig_mod_boot{dataset,context}];
            current_mod = mod_index_all{dataset,context};
            current_sig = find(ismember([sig_mod_boot{dataset,context}],all_celltypes{dataset}.(possible_celltypes{celltype})));
            pos_percent(celltype,dataset) = length(find(current_mod(current_sig_cells(current_sig))>0))/current_total(celltype,dataset);
            neg_percent(celltype,dataset) = length(find(current_mod(current_sig_cells(current_sig))<0))/current_total(celltype,dataset);
            non_mod_percent(celltype,dataset) = (current_total(celltype,dataset) - length(current_sig_cells(current_sig)))/current_total(celltype,dataset);
        end
            %save percentages
    percentage_stats.pos_percent{celltype} = utils.get_basic_stats(pos_percent(celltype,:));
    percentage_stats.neg_percent{celltype} = utils.get_basic_stats(neg_percent(celltype,:));
    percentage_stats.non_mod_percent{celltype} = utils.get_basic_stats(non_mod_percent(celltype,:));

    percentage_stats.pos_percent_all{celltype} = pos_percent(celltype,:);
    percentage_stats.neg_percent_all{celltype} = neg_percent(celltype,:);
    percentage_stats.non_mod_percent_all{celltype} = non_mod_percent(celltype,:);
    end
    
    % perform Calculation but pooling across all neurons together
    current_sig = sig_mod_boot(:, context);
    global_sig_ids = convert_indices_local_to_global(current_sig, cellfun(@length, mod_index_all(:, context)));
    concatenated_mod_index = horzcat(mod_index_all{:, context});

    for celltype = 1:numTypes
        current_celltype_array = celltype_array(celltype,:);
        current_sig_celltype = intersect_sig_cells(current_celltype_array,current_sig',mod_index_all(:, context)');
        current_celltype = convert_indices_local_to_global(current_sig_celltype, cellfun(@length, mod_index_all(:, context)));

        current_all_celltype = convert_indices_local_to_global(current_celltype_array, cellfun(@length, mod_index_all(:, context)));

        percentage_stats.pooled_percentages{celltype} = [length(find(concatenated_mod_index(current_celltype)>0))/length(current_all_celltype),length(find(concatenated_mod_index(current_celltype)<0))/length(current_all_celltype),(length(current_all_celltype)-length(current_celltype))/length(current_all_celltype)];
    end
    
    % Get all field names from the sorted_cells structure.
    cellTypeNames = {'PYR','SOM','PV'};
    if numTypes == 1
        cellTypeNames = {'All cell types'};
    end
    
    %get positions
    if strcmp(plot_mode,'vertical')
        positions = utils.calculateFigurePositions(9, 1, .5,.1);
        figure_position = [100, 10, 500, 800];
    else
        positions = utils.calculateFigurePositions(1,7, .5,.1);
        figure_position = [100, 10, 800, 500];
    end
    fixed_positions = positions; %to start from the bottom!

    f = figure(72); clf;
    
    % Define common labels and colormap for all subplots.
    
    customColormap = [1 1 1;    % white
                      0 0 0;    % black
                      0.5 0.5 0.5];  % grey
                  
    % Loop over each cell type and plot its pie chart
    for celltypes = 1:numTypes
        labels = {'Positively modulated', 'Negatively modulated', 'Not modulated'};
        cellType = cellTypeNames{celltypes};
                
        % Create a subplot for the current cell type.
        subplot(numTypes, 1, celltypes);
        hold on;

        percent_cells = [mean(pos_percent(celltypes,:)), mean(neg_percent(celltypes,:)), mean(non_mod_percent(celltypes,:))];

        % --- NEW CODE: remove zero-percent categories ---
        nonzero_idx = percent_cells > 0;             % keep only categories with non-zero %
        percent_cells = percent_cells(nonzero_idx);
        labels = labels(nonzero_idx);
        customColormap = [1 1 1; 0 0 0; 0.5 0.5 0.5];
        customColormap = customColormap(nonzero_idx, :);
    
        
        % Plot the pie chart. The handle h returns both patch and text objects.
        h = pie(percent_cells);
        % Set the font properties for the text labels (which are in even indices).
        set(h(2:2:end), 'FontSize', 6, 'FontName', 'Arial');
        
        % Apply the custom colormap.
        colormap(customColormap);
        

        set(gca,  'Units', 'inches', 'Position', fixed_positions(celltypes,:));
        set(gca, 'XColor', 'none', 'YColor', 'none','Color','none');  % Hide tick marks and box lines.

        % Add a legend only to the last subplot.
        if celltypes == numTypes
            % Create the legend.
            leg = legend(labels, 'FontSize', 6, 'Box', 'off');
            % Set legend units to normalized so that you can adjust its position relative to the figure.
            leg.Units = 'Inches';
            % Adjust the legend position manually.
            % [x y width height] -- tweak these numbers until the legend is placed as desired.
            leg_pos = fixed_positions(numTypes,:);
            if strcmp(plot_mode,'vertical')
                leg_pos(2) = leg_pos(2) - leg_pos(4) + 0.1;
                leg_pos(4) = leg_pos(4)/3;
                leg.Position = leg_pos; %subtract to make it a rectangle
            else
                leg_pos = fixed_positions(numTypes+1,:);
                leg.Position = leg_pos; %subtract to make it a rectangle
            end
            leg.ItemTokenSize = [10, 10];
        end
        % Use the field name (converted to uppercase) as the title.
        if strcmp(plot_mode,'vertical')
            title_pos = [0,1.3];
        else
            title_pos = [0,1.5];
        end
        if numTypes > 1
            title(cellType,'FontWeight', 'normal', 'FontName', 'Arial','FontSize',8,'Position',title_pos);
        end

        hold off;
        
        % If you have a custom function to adjust figure properties, you can call it here.
        % set_current_fig;  % Uncomment if this function exists.
    end
    
    % Adjust the overall figure size (height is increased for multiple subplots).
    set(gcf, 'Position', figure_position);
    
    % Optionally, pause the execution to allow manual legend adjustment.
    pause;
end

%% Save the figure if a save path is provided
if ~isempty(savepath)
    % Create a subdirectory named "mod" within the savepath if it does not exist.
    modDir = fullfile(savepath);
    if ~exist(modDir, 'dir')
        mkdir(modDir);
    end
    
    % Build the base filename using the modulation threshold.
    filenameBase = fullfile(modDir, ['percent_pie_sig_mod_thr_', num2str(mod_params.mod_threshold), '_context_', num2str(context),'_datasets_', num2str(length(sig_mod_boot))]);
    
    % Save the current figure in several formats.
    saveas(f, [filenameBase, '.fig']);
%     saveas(f, [filenameBase, '.svg']);
    exportgraphics(f,[filenameBase, '.pdf'], 'ContentType', 'vector');

    save(fullfile(modDir,'percent_pie_stats'),'percentage_stats')
end

end
