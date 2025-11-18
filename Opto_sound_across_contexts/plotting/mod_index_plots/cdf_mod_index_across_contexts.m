function [cdf_stats, KW_Test] = cdf_mod_index_across_contexts(save_dir, stim_mod, ctrl_mod, ...
                                        behavioral_contexts, colors, lineStyles_contexts, chosen_mice, label, cell_types, mode, varargin)
% Function to create heatmaps and CDF plots of modulation indices across contexts.
% Allows plotting all cells together or separated by cell type.
% 
% Inputs:
%   - save_dir: Directory to save the plots
%   - stim_mod: NxM matrix of modulation indices for stimulus condition
%   - ctrl_mod: NxM matrix of modulation indices for control condition (optional)
%   - behavioral_contexts: Cell array of context labels
%   - colors: Color matrix for different contexts
%   - lineStyles_contexts: Cell array of line styles for contexts
%   - chosen_mice: Number of datasets/mice included
%   - label: Labels for stimulus and control conditions
%   - cell_types: Vector of cell type labels for each neuron
%   - mode: 'all' (plot all cells together) or 'celltype' (separate by type)
%   - varargin: Optional bin range
% 
% Outputs:
%   - cdf_stats: Struct with p-values and effect sizes
%   - KW_Test: Struct with Kruskal-Wallis test results

p_cdf = {};  % Initialize

% Set bin range
if nargin < 10
    binss = -0.4:0.01:0.7;
else
    bin = varargin{1};
    binss = bin(1):0.01:bin(2);
end

positions = utils.calculateFigurePositions(1, 5, .5, []);

% Determine cell type groups if applicable
if strcmp(mode, 'celltype')
    num_plots = length(cell_types);
    figure_layout = [1, num_plots];
else
    num_plots = 1;
    figure_layout = [1, 1];
end

cdf_stats = struct();
KW_Test = struct();

figure(95); clf;
count = 0; %keep track of colors
count2= 0; %keep track of contexts for labels

for plot_idx = 1:num_plots
    
    subplot(figure_layout(1), figure_layout(2), plot_idx);
    hold on;    
    if strcmp(mode, 'celltype')
        cell_mask = cell_types{1,plot_idx};
    else
        cell_mask = true(size(stim_mod, 1), 1);
    end
    
   
    for context = 1:length(behavioral_contexts)
        count = count+1;

        [stim_cdf, ~] = make_cdf(stim_mod(cell_mask, context), binss);
        stim_cdf_contexts{context} = stim_cdf;
        a(context) = plot(binss, stim_cdf, 'LineWidth', 1.5, ...
            'LineStyle', lineStyles_contexts{context}, 'Color', colors(count, :));
        
        if ~isempty(ctrl_mod)
            [ctrl_cdf, ~] = make_cdf(ctrl_mod(cell_mask, context), binss);
            ctrl_cdf_contexts{context} = ctrl_cdf;
            b(context) = plot(binss, ctrl_cdf, 'LineWidth', 1.5, ...
                'LineStyle', lineStyles_contexts{context}, 'Color', colors(count + length(behavioral_contexts)+num_plots, :));
        end
    end

    
    % Formatting
    ylim([0 1]); xlim([binss(1) binss(end)]);
    if plot_idx == 1
        ylabel('Cumulative Fraction'); 
    end
    xlabel('Modulation Index');
    set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(plot_idx, :));
    utils.set_current_fig;
    grid on;
    
    % Legend
    stim_legend =  behavioral_contexts;
%     stim_legend = utils.generate_legend_entries(label{1}, behavioral_contexts);
    if ~isempty(ctrl_mod)
        ctrl_legend = utils.generate_legend_entries(label{2}, behavioral_contexts);
        legend_entries = [stim_legend, ctrl_legend];
    else
        legend_entries = stim_legend;
    end
    color_index =1+count2:length(behavioral_contexts)+count2;
    utils.place_text_labels(legend_entries, colors(color_index,:), 0.4, 8);

    %increase context
    count2=count2+length(behavioral_contexts);
    
    % Statistical comparisons
    possible_tests = nchoosek(1:length(behavioral_contexts), 2);
    ct = 0; ct2 = 0;
    
    for t = 1:size(possible_tests, 1)
        [p_cdf_stim(t), ~, effectsize_context(t)] = ...
            permutationTest_updatedcb(stim_mod(cell_mask, possible_tests(t, 1)), ...
                                      stim_mod(cell_mask, possible_tests(t, 2)), 10000, 'paired', 1);
        
        if ~isempty(ctrl_mod)
            [p_cdf_paired(t), ~, effectsize_stimctrl(t)] = ...
                permutationTest_updatedcb(ctrl_mod(cell_mask, t), stim_mod(cell_mask, t), 10000, 'paired', 1);
        end
        
        if p_cdf_stim(t) < 0.05 / size(possible_tests, 1)
            xline_vars = [binss(find(stim_cdf_contexts{1, possible_tests(t, 1)} > 0.6 + ct, 1, 'first')), ...
                          binss(find(stim_cdf_contexts{1, possible_tests(t, 2)} > 0.6 + ct, 1, 'first'))];
            utils.plot_pval_star(0, 0.61 + ct, p_cdf_stim(t), xline_vars, 0.01);
            ct = ct + 0.03;
        end
        
        if ~isempty(ctrl_mod) && p_cdf_paired(t) < 0.05 / size(possible_tests, 1)
            xline_vars = [binss(find(ctrl_cdf_contexts{1, t} > 0.8 + ct2, 1, 'first')), ...
                          binss(find(stim_cdf_contexts{1, t} > 0.8 + ct2, 1, 'first'))];
            utils.plot_pval_star(0, 0.81 + ct2, p_cdf_paired(t), xline_vars, 0.01);
            ct2 = ct2 + 0.03;
        end
    end
    
    % Kruskal-Wallis tests
    KW_Test(plot_idx).stimcontext_p_val = kruskalwallis(stim_mod(cell_mask, :), [], 'off');
    if ~isempty(ctrl_mod)
        KW_Test(plot_idx).ctrlcontext_p_val = kruskalwallis(ctrl_mod(cell_mask, :), [], 'off');
    end
    
    % Save stats
    cdf_stats(plot_idx).p_stimcontext = p_cdf_stim;
    cdf_stats(plot_idx).effect_stimcontext = effectsize_context;
    
    if ~isempty(ctrl_mod)
        cdf_stats(plot_idx).p_ctrlstim = p_cdf_paired;
        cdf_stats(plot_idx).effect_ctrlstim = effectsize_stimctrl;
    end
    

end

    % Save plots
    if ~isempty(save_dir)
        mkdir(save_dir);
        saveas(gcf, fullfile(save_dir, sprintf('mod_index_cdf_%s_%d_datasets.svg', mode, length(chosen_mice))));
        saveas(gcf, fullfile(save_dir, sprintf('mod_index_cdf_%s_%d_datasets.fig', mode, length(chosen_mice))));
        exportgraphics(gcf,fullfile(save_dir, sprintf('mod_index_cdf_%s_%d_datasets.pdf', mode, length(chosen_mice))), 'ContentType', 'vector');
    end
