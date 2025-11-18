function  [all_bin_perf,errorbar_correct_stats] = plot_error_bars_response_vs_axis(chosen_datasets,avg_trial_ctrl_pre,correct_trials_ctrl,cur_celltype,n_bins,plot_datasets,save_dir,varargin)
% cur_celltype = 1;
n_datasets = length(chosen_datasets);
% n_bins = 5;

% Store bin centers and performance per session
all_bin_centers = nan(n_datasets, n_bins);
all_bin_perf = nan(n_datasets, n_bins);

for dataset = 1:n_datasets
    context = 1;
    
    % Extract data
    pre = zscore(avg_trial_ctrl_pre{dataset, context, cur_celltype}');
    correct = correct_trials_ctrl{1, dataset}.all;
    
    % Define quantile bins
    edges = quantile(pre, linspace(0,1,n_bins+1));
%     edges = linspace(-1,1,n_bins+1);
    for b = 1:n_bins
        in_bin = pre >= edges(b) & pre < edges(b+1);
        if b == n_bins
            in_bin = pre >= edges(b) & pre <= edges(b+1);
        end
        
        if any(in_bin)
            all_bin_centers(dataset, b) = mean(pre(in_bin));
            all_bin_perf(dataset, b) = mean(correct(in_bin));
        end
    end
end

% Compute average and SEM across sessions
mean_centers = nanmean(all_bin_centers);
mean_perf = nanmean(all_bin_perf);
sem_perf = nanstd(all_bin_perf) ./ sqrt(sum(~isnan(all_bin_perf))); % SEM

% Plot
figure(82); clf;
positions = utils.calculateFigurePositions(1, 5, .5, []);

% Individual session curves (optional, faded)
if plot_datasets == 1
plot(all_bin_centers', all_bin_perf', '-', 'Color', [0.8 0.8 0.8]); hold on;
end

% Error bar plot of mean
if nargin > 7
    errorbar(mean_centers, mean_perf, sem_perf, '-o','MarkerSize',2,'Color',varargin{1,1}, 'LineWidth', 1, 'CapSize', 2);
else
    errorbar(mean_centers, mean_perf, sem_perf, '-o','MarkerSize',2,'Color','k', 'LineWidth', 1, 'CapSize', 2);
end

xlabel('Pre-stim rate (z-scored)'); %, per-session quantiles
ylabel('Fraction Correct');

%Do statistical comparisons across bins
%perform stats
p_values = nan(n_bins);
for i = 1:n_bins
    for j = i+1:n_bins
        x = all_bin_perf(:,i); % Bin i
        y = all_bin_perf(:,j); % Bin j
        valid = ~isnan(x) & ~isnan(y);
        if sum(valid) > 2
            p_values(i,j) = permutationTest_updatedcb(x(valid), y(valid), 10000, 'paired', 1);
        end
    end
end
errorbar_correct_stats.test = 'within-context paired permutation';
errorbar_correct_stats.p_values = p_values;
errorbar_correct_stats.significant = find(errorbar_correct_stats.p_values < 0.05/((n_bins*(n_bins-1))/2));
[bin_i, bin_j] = find(errorbar_correct_stats.p_values < 0.05/((n_bins*(n_bins-1))/2)); 

ct = 0;
yli = ylim;
for k = 1:length(bin_i)
    i = bin_i(k);
    j = bin_j(k);

    % Position stars slightly above the max y value
    
    y_star = yli(2) + 0.05 + ct * 0.2;
        
    % Star in the center
    utils.plot_pval_star(0, y_star, errorbar_correct_stats.p_values(errorbar_correct_stats.significant(k)),[mean_centers(i), mean_centers(j)],.02);

    ct = ct + 0.5;
end

%clean up figure
xli = xlim;
xlim([xli(1) - .5,xli(2) + .5]); %adjust axis
box off
set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;


% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
%     saveas(82,strcat('errorbar_correct_vs_pre_stim_rate_n_',num2str(length(chosen_datasets)),'_celltype_',num2str(cur_celltype),'_bins_',num2str(n_bins),'.svg'));
    saveas(82,strcat('errorbar_correct_vs_pre_stim_rate_n_',num2str(length(chosen_datasets)),'_celltype_',num2str(cur_celltype),'_bins_',num2str(n_bins),'.fig'));
    exportgraphics(figure(82),strcat('errorbar_correct_vs_axis_pre_stim_rate_n_',num2str(length(chosen_datasets)),'_celltype_',num2str(cur_celltype),'_bins_',num2str(n_bins),'.pdf'), 'ContentType', 'vector');

    save(strcat('errorbar_performance_stats_n',num2str(length(chosen_datasets)),'_celltype_',num2str(cur_celltype),'_bins_',num2str(n_bins)),'errorbar_correct_stats');

end