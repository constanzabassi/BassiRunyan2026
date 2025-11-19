function plot_mean_axis_stability_across_splits(weights,celltype,save_dir)
%compute mean stability across splits per dataset, each dot is a dataset

positions = utils.calculateFigurePositions(1, 5, .5, []);

figure(100); clf; hold on;

contexts = {'context', 'sound', 'stim'};
labels = {'Engagement','Sound','Photostim'};

for i = 1:numel(contexts)
    [axis_stability, mean_stability] = compute_axis_stability(weights, celltype, contexts{i});
    stats.(contexts{i}) = get_basic_stats(mean_stability);
    % Make violins outline-only with semi-transparent edge
    v = Violin({mean_stability}, i, ...
        'ViolinColor', {[1 1 1]}, ...          % white fill (transparent background look)
        'EdgeColor', [0.5 0.5 0.5], ...              % black outline
        'BoxColor', [0.5 0.5 0.5], ...               % box outline
        'ShowMean', false, ...                 % hide big mean dot
        'ShowMedian', true, ...                % show median instead (cleaner)
        'MedianColor', [0 0 0], ...
        'ShowData', true, ...                  % show points
        'QuartileStyle', 'shadow');            % subtle quartile shadow

    % Overlay scatter points (jittered horizontally)
    x_jitter = i + (rand(size(mean_stability)) - 0.5) * 0.2;  % ±0.1 jitter
    scatter(x_jitter, mean_stability, 10, 'k', 'filled', ...
        'MarkerFaceAlpha', 0.2, 'MarkerEdgeColor', 'none');
end

ylabel('Mean Axis Stability')
xticks(1:3)
xticklabels(labels)

% Beautify axes
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 7)
ylim([0.7 1])
pbaspect([1 1 1])
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

if ~isempty(save_dir)
    mkdir([save_dir])
    exportgraphics(figure(100),fullfile(save_dir,strcat('mean_axis_stability_celltype',num2str(celltype),'.pdf')), 'ContentType', 'vector');
    save(fullfile(save_dir,strcat('stats_mean_axis_stability_celltype',num2str(celltype),'.mat')),'stats');
end