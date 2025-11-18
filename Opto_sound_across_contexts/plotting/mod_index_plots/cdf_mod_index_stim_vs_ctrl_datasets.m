function [cdf_stats, KW_Test] = cdf_mod_index_stim_vs_ctrl_datasets(save_dir, stim_mod, ctrl_mod, ...
                                        behavioral_contexts, colors, lineStyles_contexts, label, mode, varargin)
% Compare modulation index distributions (CDFs) between STIM and CTRL mice.
% Performs unpaired tests across contexts, optionally per cell type.
%
% Inputs:
%   - save_dir: Directory to save plots
%   - stim_mod: [neurons x contexts] modulation indices for STIM mice
%   - ctrl_mod: [neurons x contexts] modulation indices for CTRL mice
%   - behavioral_contexts: Cell array of context labels (e.g., {'Active','Passive'})
%   - colors: Color matrix (rows = colors per context)
%   - lineStyles_contexts: Cell array of line styles for each context
%   - label: Cell array of {'StimLabel','CtrlLabel'} for legend
%   - mode: 'all' (combine all cells) or 'celltype' (separate by type)
%   - varargin: Optional bin range, e.g. [-0.4 0.7]
%
% Outputs:
%   - cdf_stats: Struct with p-values and effect sizes for each context
%   - KW_Test: Struct with Kruskal-Wallis results across contexts
%
% Example:
%   [stats,KW] = cdf_mod_index_stim_vs_ctrl(save_dir, stim_mod, ctrl_mod, ...
%                    {'Active','Passive'}, colors, {'-','--'}, {'Stim','Ctrl'}, 'all');

%% Bin range
if nargin < 9
    binss = -0.4:0.01:0.7;
else
    bin = varargin{1};
    binss = bin(1):0.01:bin(2);
end

positions = utils.calculateFigurePositions(1, 5, .5, []);
num_contexts = length(behavioral_contexts);

figure(95); clf;
cdf_stats = struct();
KW_Test = struct();

%% Plot each context (or each cell type if extended)
for context = 1:num_contexts
    subplot(1, num_contexts, context);
    hold on;

    % Compute CDFs
    [stim_cdf, ~] = make_cdf(stim_mod(:, context), binss);
    [ctrl_cdf, ~] = make_cdf(ctrl_mod(:, context), binss);

    % Plot
    plot(binss, stim_cdf, 'LineWidth', 1.5, 'Color', colors(context,:), ...
         'LineStyle', lineStyles_contexts{context});
    plot(binss, ctrl_cdf, 'LineWidth', 1.5, 'Color', colors(context + num_contexts,:), ...
         'LineStyle', lineStyles_contexts{context});

    % Labels & formatting
    xlabel('Modulation Index');
    ylabel('Cumulative Fraction');
    title(behavioral_contexts{context},'fontweight','normal');
    ylim([0 1]); xlim([binss(1) binss(end)]);
    set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(context, :));
    grid on;

    % Stats (unpaired permutation test)
    [p_val, ~, effect_size] = permutationTest_updatedcb( ...
        stim_mod(:, context), ctrl_mod(:, context), 10000, 'paired', 0);

    cdf_stats(context).p_value = p_val;
    cdf_stats(context).effect_size = effect_size;
    cdf_stats(context).stim = get_basic_stats(stim_mod(:, context));
    cdf_stats(context).ctrl = get_basic_stats(ctrl_mod(:, context));

    % Annotate significance
    if p_val < 0.05
        y_sig = 0.7;%%0.9;
        x_val = bin(2)/2;%
        ct2 = 0;
        xline_vars = [binss(find(ctrl_cdf > y_sig + ct2, 1, 'first')), ...
                          binss(find(stim_cdf > y_sig + ct2, 1, 'first'))];
        utils.plot_pval_star(x_val, y_sig, p_val, [0,0], 0.01);
%         utils.plot_pval_star(xline_vars(2)+0.01, y_sig, p_val, [xline_vars(2)+0.01,xline_vars(2)+0.01], 0.01);
%         utils.plot_pval_star(0, y_sig, p_val, xline_vars(2)+0.05, 0.01); %[binss(1) binss(end)]
    end
end

%% Kruskal-Wallis across contexts
KW_Test.stim_p_val = kruskalwallis(stim_mod, [], 'off');
KW_Test.ctrl_p_val = kruskalwallis(ctrl_mod, [], 'off');

%% Legend
% legend_entries = [ ...
%     utils.generate_legend_entries(label{1}, behavioral_contexts), ...
%     utils.generate_legend_entries(label{2}, behavioral_contexts)];
% legend(legend_entries, 'Box', 'off', 'Location', 'best');

%% Save plots
if ~isempty(save_dir)
    mkdir(save_dir);
    saveas(gcf, fullfile(save_dir, sprintf('mod_index_cdf_stim_vs_ctrl_%s.svg', mode)));
    saveas(gcf, fullfile(save_dir, sprintf('mod_index_cdf_stim_vs_ctrl_%s.fig', mode)));
    exportgraphics(gcf, fullfile(save_dir, sprintf('mod_index_cdf_stim_vs_ctrl_%s.pdf', mode)), ...
        'ContentType', 'vector');
end
end
