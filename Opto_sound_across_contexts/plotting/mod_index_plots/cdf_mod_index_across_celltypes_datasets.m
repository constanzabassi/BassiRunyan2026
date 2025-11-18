function [all_stats] = cdf_mod_index_across_celltypes_datasets(save_dir, mod_all, all_celltypes, ...
                                        colors, mode, label,chosen_cells, varargin)
% Compare modulation index distributions (CDFs) across cell types
% using concatenated data from multiple datasets.
%
% Inputs:
%   - save_dir: directory to save plots
%   - mod_all: [neurons x 1] or [neurons x contexts] modulation indices
%   - all_celltypes: cell array {datasets}, each with fields (e.g., .pyr, .som, .pv)
%   - behavioral_contexts: context names for labeling (optional)
%   - colors: color map for cell types
%   - mode: 'all' or 'celltype' (currently only 'celltype' meaningful)
%   - label: title/label for plot
%   - varargin: optional bin range [min max]
%
% Outputs:
% all_stats with fields
%   - cdf_stats: struct with pairwise permutation test results
%   - KW_Test: struct with Kruskal-Wallis p-values across cell types

%% --- Setup bin range ---
if nargin < 8
    binss = -0.4:0.01:0.7;
else
    bin = varargin{1};
    binss = bin(1):0.01:bin(2);
end
positions = utils.calculateFigurePositions(1, 5, .5, []);

%% --- Clean data ---
mod_all(~isfinite(mod_all)) = NaN; % replace Inf with NaN
celltype_indices = struct();
possible_celltypes = fieldnames(all_celltypes{1,1});

if isempty(chosen_cells)
%% --- Compute neuron indices per cell type ---
offset = 0;

n_datasets = numel(all_celltypes);
datasetNeuronCounts = zeros(1, n_datasets);
for d = 1:n_datasets
    fields_d = fieldnames(all_celltypes{d});
    if isempty(fields_d)
        datasetNeuronCounts(d) = 0;
    else
        counts = cellfun(@(f) numel(all_celltypes{d}.(f)), fields_d);
        datasetNeuronCounts(d) = sum(counts);
    end
end

%% Aggregate indices per celltype (with offsets)
% Build cumulative offsets
offsets = [0, cumsum(datasetNeuronCounts(1:end-1))]; % offsets(d) is offset for dataset d
celltype_indices = struct();
for d = 1:n_datasets
    fields_d = fieldnames(all_celltypes{d});
    for f = 1:numel(fields_d)
        this_type = fields_d{f};
        local_idx = all_celltypes{d}.(this_type);
        if isempty(local_idx)
            continue;
        end
        global_idx = local_idx + offsets(d);              % ADD offset here
        % initialize if needed
        if ~isfield(celltype_indices, this_type)
            celltype_indices.(this_type) = [];
        end
        celltype_indices.(this_type) = [celltype_indices.(this_type), global_idx(:)'];
    end
end
else %assume they are given in the correct order (same as all_celltypes)
    fields_d = fieldnames(all_celltypes{1,1});
    for f = 1:numel(fields_d)
        this_type = fields_d{f};
        if ~isfield(celltype_indices, this_type)
            celltype_indices.(this_type) = [];
        end
        celltype_indices.(this_type) = [celltype_indices.(this_type), chosen_cells{f}];
    end
end
%% --- Plot CDFs per cell type ---
figure(95); clf; hold on;
cdf_stats = struct();
colors = colors(1:numel(possible_celltypes), :);

for f = 1:numel(possible_celltypes)
    type = possible_celltypes{f};
    inds = celltype_indices.(type);
    data_type = mod_all(inds, :);
    data_type = data_type(:);
    data_type = data_type(isfinite(data_type)); % remove NaNs

    [cdf_y, ~] = make_cdf(data_type, binss);
    plot(binss, cdf_y, 'LineWidth', 1.5, 'Color', colors(f,:));
    cdf_stats.(type) = get_basic_stats(data_type);
    cdf_stats.(type).values = data_type;
end

xlabel(label);
ylabel('Cumulative Fraction');
ylim([0 1]);
xlim([binss(1) binss(end)]);
grid on;
% legend(possible_celltypes, 'Box', 'off', 'Location', 'best');
set(gca, 'FontSize', 7,'box','off','Units','Inches','Position',positions(1,:));
utils.set_current_fig;

%% --- Kruskal-Wallis across all types ---
group_labels = [];
values_all = [];
for f = 1:numel(possible_celltypes)
    vals = cdf_stats.(possible_celltypes{f}).values;
    group_labels = [group_labels; f * ones(size(vals))];
    values_all = [values_all; vals];
end
[KW_Test.p_val,~,KW_Test.stats] = kruskalwallis(values_all, group_labels, 'off');

%% --- Stats: pairwise permutation tests ---
possible_tests = nchoosek(1:numel(possible_celltypes), 2);
ct2 = 0;
for t = 1:size(possible_tests, 1)
    type1 = possible_celltypes{possible_tests(t,1)};
    type2 = possible_celltypes{possible_tests(t,2)};
    vals1 = cdf_stats.(type1).values;
    vals2 = cdf_stats.(type2).values;
    [p_val, ~, eff_size] = permutationTest_updatedcb(vals1, vals2, 10000, 'paired', 0);
    cdf_stats.pairs(t).types = [type1 ' vs ' type2];
    cdf_stats.pairs(t).types_up = [upper(type1) ' vs ' upper(type2)];
    cdf_stats.pairs(t).p = p_val;
    cdf_stats.pairs(t).effect_size = eff_size;
    if p_val < 0.05/size(possible_tests, 1) && KW_Test.p_val < 0.05
        
        y_sig = 0.025+ct2;%%0.9;
        x_val = [binss(end)/2];%
        if p_val < 0.0001
            sig_symbol = '****';
        elseif p_val < 0.001
            sig_symbol = '***';
        elseif p_val < 0.01
            sig_symbol = '**';
        elseif p_val < 0.05
            sig_symbol = '*';
        else
            sig_symbol = 'ns';
        end
        xline_vars = [0, 0];
%         utils.plot_pval_star(x_val, y_sig, p_val, [0,0], 0.01);
        celltype_names_clean = regexprep(cdf_stats.pairs(t).types, '_cells', '');
%         text(x_val+mean([xline_vars(1),xline_vars(2)]), y_sig+.1,celltype_names_clean ,'HorizontalAlignment', 'center', 'Color', 'k','FontSize',6);
        text(x_val+mean([xline_vars(1),xline_vars(2)]), y_sig+.1,[sig_symbol ' ' celltype_names_clean] ,'HorizontalAlignment', 'center', 'Color', 'k','FontSize',6);

        ct2= ct2+.1;
    end
end

all_stats.cdf = cdf_stats;
all_stats.KW = KW_Test;


%% --- Save plot ---
if ~isempty(save_dir)
    mkdir(save_dir);
    saveas(gcf, fullfile(save_dir, sprintf('mod_index_cdf_acrosscelltypes_%s.svg', mode)));
    saveas(gcf, fullfile(save_dir, sprintf('mod_index_cdf_acrosscelltypes_%s.fig', mode)));
    exportgraphics(gcf, fullfile(save_dir, sprintf('mod_index_cdf_acrosscelltypes_%s.pdf', mode)), 'ContentType', 'vector');
    save(fullfile(save_dir, sprintf('mod_index_cdf_acrosscelltypes_%s.mat', mode)),'all_stats');
end
end
