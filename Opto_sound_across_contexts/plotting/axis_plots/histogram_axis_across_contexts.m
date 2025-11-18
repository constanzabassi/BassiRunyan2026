function [hist_stats,all_trial_means_contexts] =  histogram_axis_across_contexts(chosen_datasets,proj, axis_type, celltype, bin_edges,frame_range,colorss,legend_string,save_dir)
positions = utils.calculateFigurePositions(1, 5, .5, []);

figure(800);clf;
hold on;

% frame_range = 50:59; %63:93; % specify the frames you're averaging over
if ~isempty(bin_edges)
    bin_edges = bin_edges;
else
    bin_edges = -2:0.15:2; % adjust bins as needed
end

all_trial_means_contexts = {};
all_trial_means_datasets = [];
for ctx = 1:2
    all_trial_means = [];
    dataset_means = nan(length(chosen_datasets), 1); % store 1 mean per dataset

    for dataset = chosen_datasets
%         data = proj_ctrl{dataset, celltype, ctx}.context; %proj{dataset,celltype,ctx}.stim; %proj_ctrl{dataset, celltype, ctx}.sound;
        data = proj{dataset, celltype, ctx}.(lower(axis_type));
        trial_means = mean(data(:, frame_range), 2); % mean per trial in specified frames
        all_trial_means = [all_trial_means; trial_means];
        all_trial_means_datasets(ctx,dataset) = mean(trial_means);
        dataset_means(dataset) = mean(trial_means); % <- compute dataset-level average
    end

    % Compute histogram (normalized to get fraction of trials)
    %trial means of all trials concatenated!
    h{ctx} = histogram(all_trial_means, bin_edges, 'Normalization', 'probability', ...
                  'DisplayStyle', 'stairs', 'LineWidth', 1, 'EdgeColor', colorss(ctx,:));

%     %trial means of trials concatenated per dataset
%     h{ctx} = histogram(dataset_means, bin_edges, 'Normalization', 'probability', ...
%               'DisplayStyle', 'stairs', 'LineWidth', 1, 'EdgeColor', colorss(ctx,:));

    %save trial means across datasets
    all_trial_means_contexts{ctx} = all_trial_means;

    %get basic stats
    hist_stats.stats{ctx} = utils.get_basic_stats(all_trial_means);

        % Calculate and plot the mean difference
    mean_diff(ctx) = mean(all_trial_means);
    y_limits = ylim;
    plot(mean_diff(ctx), y_limits(2)+.05, 'v', 'MarkerSize', 6,  'MarkerEdgeColor',  colorss(ctx,:),'MarkerFaceColor',  colorss(ctx,:));

end
if strcmp((lower(axis_type)),'context')
    xlabel('Engagement Projection'); %'Pre-stimulus Difference'); %Mean projection (frames 60–90)
else
    xlabel([axis_type ' Projection'])
end
ylabel('Fraction of Trials');
% legend(legend_string);
% Get current axis limits
x_range = xlim;
y_range = ylim;
y_offset_base = .1;
% Calculate base text position
text_x = x_range(2) -.09 * diff(x_range);
text_y = y_range(2) - .2 * diff(y_range);

% Auto-calculate evenly spaced y-offsets
num_labels = 2;
y_offsets = linspace(0, 0.1 * (num_labels - 1), num_labels); % Adjusted scaling
% Place text labels
for i = 1:num_labels
    text(text_x, text_y - y_offsets(i) * diff(y_range), legend_string{i}, ...
         'Color',colorss(i,:), 'FontSize', 8);
end

% Perform a permutation test to compare differences against zero
[p_val, ~, ~] = permutationTest(all_trial_means_contexts{1}, all_trial_means_contexts{2},10000);

set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

% Store statistics
hist_stats.tests = [1,2];
hist_stats.p_test = 'unpaired permutation across contexts (trials)';
hist_stats.p_val = p_val;
hist_stats.n_trials = [length(all_trial_means_contexts{1}),length(all_trial_means_contexts{2})];
offset = 0.02;
%add significant stars
if p_val < 0.05
    yli = ylim;
    xli = xlim;
    utils.plot_pval_star(0, yli(2) + offset, p_val,[mean(mean_diff),mean(mean_diff)],.05);
end
% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(800,strcat('hist_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.svg'));
    saveas(800,strcat('hist_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.fig'));
    exportgraphics(figure(800),strcat('hist_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.pdf'), 'ContentType', 'vector');
    save(strcat('hist_stats_n',num2str(length(chosen_datasets))),'hist_stats');
end
