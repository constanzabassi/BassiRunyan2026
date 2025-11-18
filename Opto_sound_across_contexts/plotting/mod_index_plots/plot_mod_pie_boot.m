function [sorted_cells] = plot_mod_pie_boot(mod_params, sorted_cells, mod_index_all, significant_neurons, savepath, total_cells)
% PLOT_MOD_PIE_BOOT - Plot modulation pie charts for cells.
%
% This function generates pie charts that show the proportions of cells 
% that are positively modulated, negatively modulated, and not modulated 
% based on a provided modulation threshold. If a structure containing sorted
% cell types is given, a separate pie chart is created for each cell type.
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
% Example:
%   mod_threshold = 0.5;
%   sorted_cells = struct('pyr', pyrCells, 'som', somCells, 'pv', pvCells);
%   mod_index_all = allModIndices;
%   savepath = 'C:\Figures';
%   sorted_cells = plot_mod_pie_boot(mod_threshold, sorted_cells, mod_index_all, savepath);

%% Identify positively and negatively modulated cells
mod_threshold = mod_params.mod_threshold;
% Classify significantly modulated neurons using mod_threshold
globalSigIndices = significant_neurons;
al_pos_mod = globalSigIndices(mod_index_all(globalSigIndices) > mod_threshold);
al_neg_mod = globalSigIndices(mod_index_all(globalSigIndices) < (mod_threshold *-1));

%% Check if sorted cell types were provided
if isempty(sorted_cells)
    % -----------------------------
    % OVERALL PIE CHART (no cell types provided)
    % -----------------------------
    f = figure(72); clf;
    hold on;
    
%     total_cells = length(mod_index_all);
    % Calculate the proportion of cells in each modulation category
    pos_pct = length(al_pos_mod) / total_cells;
    neg_pct = length(al_neg_mod) / total_cells;
    non_mod_pct = (total_cells - (length(al_pos_mod) + length(al_neg_mod))) / total_cells;
    percent_cells = [pos_pct, neg_pct, non_mod_pct];
    
    % Define the labels for the pie slices
    labels = {'Positively modulated', 'Negatively modulated', 'Not modulated'};
    
    % Plot the pie chart
    pie(percent_cells);
    
    % Set a custom colormap: first row = white, second = black, third = grey
    colormap([1 1 1; 
              0 0 0; 
              0.5 0.5 0.5]);
          
    % Set title and hide axes for a cleaner look
    title('All Cells', 'Units', 'normalized', 'Position', [0.5, 1.2, 0]);
    set(gca, 'visible', 'off');
    set(gcf, 'Position', [150, 150, 500, 500]);
    hold off;
    
else
    % -----------------------------
    % PIE CHARTS FOR EACH CELL TYPE
    % -----------------------------
    % Combine the significantly modulated cells and store in the structure.
    sorted_sig_cells = sort([al_pos_mod, al_neg_mod]);
    sorted_cells.sig_cells = sorted_sig_cells;
    
    % Get all field names from the sorted_cells structure.
    % (Exclude 'sig_cells' so that only the actual cell types are plotted.)
    cellTypeNames = fieldnames(sorted_cells);
    cellTypeNames(strcmp(cellTypeNames, 'sig_cells')) = [];
    
    % Determine the number of cell types so that we can arrange subplots vertically.
    numTypes = numel(cellTypeNames);

    %get positions
    positions = utils.calculateFigurePositions(7, 1, .5,.1);
    fixed_positions = positions; %to start from the bottom!

    f = figure(72); clf;
    
    % Define common labels and colormap for all subplots.
    labels = {'Positively modulated', 'Negatively modulated', 'Not modulated'};
    customColormap = [1 1 1;    % white
                      0 0 0;    % black
                      0.5 0.5 0.5];  % grey
                  
    % Loop over each cell type and plot its pie chart
    for celltypes = 1:numTypes
        cellType = cellTypeNames{celltypes};
        % Retrieve the IDs (or indices) for the current cell type.
        cellIDs = sorted_cells.(cellType);
%         totalCells = length(mod_index_all);%length(cellIDs);
        
        % Count how many of these cells fall into each modulation category.
        pos_count = sum(ismember(cellIDs, al_pos_mod));
        neg_count = sum(ismember(cellIDs, al_neg_mod));
        totalCells = total_cells(celltypes);
%         totalCells = length(cellIDs);
        non_mod_count = totalCells - (pos_count + neg_count);
        
        % Compute the percentages for the pie chart.
        percent_cells = [pos_count, neg_count, non_mod_count] / totalCells;
        
        % Create a subplot for the current cell type.
        subplot(numTypes, 1, celltypes);
        hold on;
        
        % Plot the pie chart. The handle h returns both patch and text objects.
        h = pie(percent_cells);
        % Set the font properties for the text labels (which are in even indices).
        set(h(2:2:end), 'FontSize', 10, 'FontName', 'Arial');
        
        % Apply the custom colormap.
        colormap(customColormap);
        

        set(gca,  'Units', 'inches', 'Position', fixed_positions(celltypes,:));
        set(gca, 'XColor', 'none', 'YColor', 'none','Color','none');  % Hide tick marks and box lines.

        % Add a legend only to the last subplot.
        if celltypes == numTypes
            % Create the legend.
            leg = legend(labels, 'FontSize', 10, 'Box', 'off');
            % Set legend units to normalized so that you can adjust its position relative to the figure.
            leg.Units = 'Inches';
            % Adjust the legend position manually.
            % [x y width height] -- tweak these numbers until the legend is placed as desired.
            leg_pos = fixed_positions(numTypes,:);
            leg_pos(2) = leg_pos(2) - leg_pos(4) + 0.1;
            leg_pos(4) = leg_pos(4)/3;
            leg.Position = leg_pos; %subtract to make it a rectangle
        end
        % Use the field name (converted to uppercase) as the title.
        title_pos = [0,1.3];
        title(upper(cellType),'FontWeight', 'normal', 'FontName', 'Arial','FontSize',12,'Position',title_pos);

        hold off;
        
        % If you have a custom function to adjust figure properties, you can call it here.
        % set_current_fig;  % Uncomment if this function exists.
    end
    
    % Adjust the overall figure size (height is increased for multiple subplots).
    set(gcf, 'Position', [100, 10, 500, 800]);
    
    % Optionally, pause the execution to allow manual legend adjustment.
%     pause;
end

%% Save the figure if a save path is provided
if ~isempty(savepath)
    % Create a subdirectory named "mod" within the savepath if it does not exist.
    modDir = fullfile(savepath);
    if ~exist(modDir, 'dir')
        mkdir(modDir);
    end
    
    % Build the base filename using the modulation threshold.
    filenameBase = fullfile(modDir, ['mod_pie_thr_', num2str(mod_threshold), '_context_', num2str(mod_params.current_context)]);
    
    % Save the current figure in several formats.
    saveas(f, [filenameBase, '.svg']);
    saveas(f, [filenameBase, '.fig']);
    exportgraphics(f,[filenameBase, '.pdf'], 'ContentType', 'vector');
end

end
