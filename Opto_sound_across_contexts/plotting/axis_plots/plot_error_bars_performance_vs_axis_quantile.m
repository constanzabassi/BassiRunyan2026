function [binned_perf_all,errorbar_stats] = plot_error_bars_performance_vs_axis_quantile(chosen_datasets,proj, axis_type, celltype,percent_correct,frame_range,num_bins,save_dir,plot_datasets )

% Plot
positions = utils.calculateFigurePositions(1, 5, .5, []);

ctx = 1; %focus on performance in the active context

num_datasets = length(chosen_datasets);
figure(802);clf;
hold on;


%
% performance across datasets
binned_perf_all = nan(num_bins, num_datasets); % num_bins x num_datasets

for dataset = chosen_datasets
    data = proj{dataset, celltype, ctx}.(axis_type);
    trial_means = mean(data(:, frame_range), 2);
    correct = percent_correct{dataset};
    % Bin engagement (trial_means) values
    edges = quantile(trial_means, linspace(0,1,num_bins+1));%linspace(edges_values(1), edges_values(2), num_bins+1); %linspace(min(all_proj), max(all_proj), num_bins+1);
    bin_centers = edges(1:end-1) + diff(edges)/2;

    for b = 1:num_bins
        bin_idx = trial_means >= edges(b) & trial_means < edges(b+1);
        trials_in_bin = correct(bin_idx);

        if ~isempty(trials_in_bin)
            binned_perf_all(b, dataset) = mean(trials_in_bin);
            all_bin_centers(b, dataset) = mean(trial_means(bin_idx));
        end
    end
end

binned_perf = nanmean(binned_perf_all, 2);
binned_sem = nanstd(binned_perf_all, 0, 2) ./ sqrt(sum(~isnan(binned_perf_all), 2));

% Individual session curves (optional, faded)
if plot_datasets == 1
    plot(bin_centers', binned_perf_all', '-', 'Color', [0.8 0.8 0.8]); hold on;
end

mean_centers = nanmean(all_bin_centers,2);

e = errorbar(mean_centers, binned_perf, binned_sem, '-o', 'LineWidth', 1,'MarkerSize',2,'Color','k');
set(e, 'CapSize', 2);   % Increase cap size (default is 6)
xlabel('Prestimulus "Engagement"');
ylabel({'Behavioral Performance';'(Fraction Correct)'});
ylim([0.5 1]);
xli = xlim;
% xlim([xli(1) - .5,xli(2) + .5]); %adjust axis
xlim([xli(1)- xli(2)*.5,xli(2) + xli(2)*.5]); %adjust axis


set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

%Do statistical comparisons across bins
combos = nchoosek(1:num_bins,2);
p_values = nan(length(combos), 1);
for b = 1:length(combos)
    x = binned_perf_all(combos(b,1), :);
    y = binned_perf_all(combos(b,2), :);
    valid = ~isnan(x) & ~isnan(y);
    errorbar_stats.stats{b} = utils.get_basic_stats(x);

    errorbar_stats.p_values(b) = permutationTest_updatedcb(x(valid), y(valid), 10000, 'paired', 1);
end
errorbar_stats.test = 'paired permutation across bins';
errorbar_stats.combos = combos;
errorbar_stats.significant = find(errorbar_stats.p_values < 0.05/length(combos));

%plot imagesc to compare % correct across datasets
figure(804);clf; colormap gray; 
imagesc(binned_perf_all); 
c = colorbar;
set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;
c.Label.String = {'Fraction Correct'}; %'Prestimulus "Engagement"';
c.Label.Rotation = 270; % Rotate the ylabel by 270 degrees'Rotation',270;
c.Label.Position = [4.258666624943416,0.500000476837158,0];
ylabel({'Prestimulus'; '"Engagement" Bin'});
xlabel('Dataset ID')



% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(802,strcat('errorbar_quant_correct_vs_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.svg'));
    saveas(802,strcat('errorbar_quant_correct_vs_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.fig'));
    exportgraphics(figure(802),strcat('errorbar_quant_correct_vs_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.pdf'), 'ContentType', 'vector');

    saveas(804,strcat('heatmap_quant_correct_vs_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.fig'));
    exportgraphics(figure(804),strcat('heatmap_quant_correct_vs_axis_',num2str(axis_type),'_n_',num2str(length(chosen_datasets)),'.pdf'), 'ContentType', 'vector');

    save(strcat('errorbar_quant_stats_n',num2str(length(chosen_datasets))),'errorbar_stats');

end