function plot_error_bars_response_vs_axis_allbinned(proj,proj_all,engagement_proj,context_all,y_label,colorss,save_dir)

edges = prctile(engagement_proj, linspace(0, 100, 6));  % 5 bins
bin_centers = movmean(edges, 2, 'Endpoints','discard');
n_bins = length(bin_centers);

n_animals = 24;
perf_by_bin = nan(n_animals, n_bins);


figure(105);clf; hold on;
for ctx = 1:2
    animal_id_all=[];

    engagement_proj_used = engagement_proj(context_all == ctx-1);
    proj_all_used = proj_all(context_all == ctx-1);
    % Loop through animals
    for dataset = 1:n_animals
        animal_id_all = [animal_id_all; repmat(dataset, size(proj{dataset,4,ctx}.(lower(y_label)),1), 1)];
        idx = animal_id_all == dataset;
        
        e = engagement_proj_used(idx);
        p = proj_all_used(idx);
    
        if numel(e) > 10
            [~,~,bin] = histcounts(e, edges);
            for b = 1:n_bins
                trials_in_bin = p(bin == b);
                if numel(trials_in_bin) >= 1
                    perf_by_bin(dataset, b) = mean(trials_in_bin);
                end
            end
        end
    end

% Compute mean and SEM across animals
mean_perf = nanmean(perf_by_bin, 1);
sem_perf = nanstd(perf_by_bin, 0, 1) ./ sqrt(sum(~isnan(perf_by_bin), 1));

% Plot
errorbar(bin_centers, mean_perf, sem_perf, '-o', 'Color',colorss(ctx,:), 'LineWidth', 1,'MarkerSize',3,'CapSize',2);
end

xlabel('Engagement Projection');
ylabel([y_label ' Projection']);
% title('Performance vs Engagement (mean ± SEM across mice)');
positions = utils.calculateFigurePositions(1, 5, .5, []);
set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;
xli = xlim;
xlim([xli(1)- xli(2)*.3,xli(2) + xli(2)*.3]); %adjust axis

figure(106);clf
bar(sum(~isnan(perf_by_bin), 1));
xlabel('Bin'); ylabel('# Animals'); title('Animals per Engagement Bin');

if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(105,strcat('errorbar_',y_label,'_vs_engagement_axis','.fig'));
    exportgraphics(figure(105),strcat('errorbar_',y_label,'_vs_engagement_axis','.pdf'), 'ContentType', 'vector');
end
