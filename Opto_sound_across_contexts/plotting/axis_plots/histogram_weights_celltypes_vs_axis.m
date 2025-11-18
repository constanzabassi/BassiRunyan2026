function [binned_weight_all_celltype,hist_weight_ct_stats] = histogram_weights_celltypes_vs_axis(chosen_datasets,proj_weights, axis_type2,all_celltypes,edge_values,num_bins,colorss,save_dir)
num_datasets = length(chosen_datasets);
positions = utils.calculateFigurePositions(1, 5, .5, []);

possible_celltypes = fieldnames(all_celltypes{1,1});

% Bin by engagement
edges = linspace(edge_values(1),edge_values(2), num_bins+1); %linspace(min(all_engagement), max(all_engagement), num_bins+1);
bin_centers = edges(1:end-1) + diff(edges)/2;

figure(806);clf;
hold on;
for celltype = 1:3
    % performance across datasets
    binned_weight_all_celltype = nan(num_bins, num_datasets); % num_bins x num_datasets
    
    all_weight_means = [];
    dataset_means = nan(length(chosen_datasets), 1); % store 1 mean per dataset

    for dataset = chosen_datasets
%         data = proj_weights{dataset, celltype}.(lower(axis_type2));
        %get current dataset celltypes
        current_cells = all_celltypes{1,dataset}.(possible_celltypes{celltype});

        data = proj_weights{dataset, 4}.(lower(axis_type2));
    
        weights = data(current_cells); %zscore(data); % mean across cells
        all_weight_means = [all_weight_means, weights];
        all_weight_means_datasets(celltype,dataset) = mean(abs(weights));
        dataset_means(dataset) = mean(weights); % <- compute dataset-level average
    end

    % Compute histogram (normalized to get fraction of trials)
    %trial means of all trials concatenated!
    h{celltype} = histogram(all_weight_means, edges, 'Normalization', 'probability', ...
                  'DisplayStyle', 'stairs', 'LineWidth', 1, 'EdgeColor', colorss(celltype,:));

%     %trial means of trials concatenated per dataset
%     h{celltype} = histogram(dataset_means, edges, 'Normalization', 'probability', ...
%               'DisplayStyle', 'stairs', 'LineWidth', 1, 'EdgeColor', colorss(celltype,:));

    %save trial means across datasets
    all_weights{celltype} = all_weight_means;

    %get basic stats
    hist_stats.stats{celltype} = utils.get_basic_stats(all_weight_means);

        % Calculate and plot the mean difference
    mean_diff(celltype) = mean(all_weight_means);
    y_limits = ylim;
    plot(mean_diff(celltype), y_limits(2)+.002, 'v', 'MarkerSize', 6,  'MarkerEdgeColor',  colorss(celltype,:),'MarkerFaceColor',  colorss(celltype,:));


end
ylabel('Fraction of Neurons');
xlabel({[ axis_type2 ' Weights']});
xli = xlim;
xlim([xli(1) - (xli(1)*.05),xli(2) + (xli(2)*.05)]); %adjust axis

%Do statistical comparisons across bins
celltype_combos = nchoosek(1:3, 2); % All 3 pairwise combinations
num_combos = size(celltype_combos, 1);
p_values = nan(num_combos,1);


for c = 1:num_combos
    ct1 = celltype_combos(c, 1);
    ct2 = celltype_combos(c, 2);

    x = all_weights{ct1};
    y =all_weights{ct2};
%     valid = ~isnan(x) & ~isnan(y);

    hist_weight_ct_stats.stats{ct1} = utils.get_basic_stats(x);
    hist_weight_ct_stats.stats{ct2} = utils.get_basic_stats(y);
    p_values( c) = permutationTest(x, y, 10000); % unpaired

%     if any(valid)
%         p_values( c) = permutationTest(x, y, 10000); % unpaired
%     end
end


% Store results
hist_weight_ct_stats.p_values = p_values;
hist_weight_ct_stats.test = 'unpaired permutation across bins and celltype pairs';
hist_weight_ct_stats.combos = celltype_combos;
hist_weight_ct_stats.significant = find(p_values < 0.05 / (num_combos)); % Bonferroni correction

%add significant stars
if isfield(hist_weight_ct_stats, 'p_values') && ~isempty(hist_weight_ct_stats.p_values)
    ct_combos = nchoosek(1:3, 2); % assuming 3 cell types
    offset = 0.05; % vertical spacing between stars

    for c = 1:size(ct_combos, 1)
        p = hist_weight_ct_stats.p_values(c);
        if p < 0.05 / 3  % Bonferroni correction
            y = ylim;
            star_y = y(2) - 0.05 + (c * offset);
            x_pos = [min(mean_diff(ct_combos(c,1)),mean_diff(ct_combos(c,2))),max(mean_diff(ct_combos(c,1)),mean_diff(ct_combos(c,2)))];
            utils.plot_pval_star(0, star_y, p, [x_pos, x_pos], 0.05);
        end
    end
end

%adjust plot and position
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;
%% create bar plot summarizing results
% Bar plot of mean ± SEM per cell type
figure(807); clf;
hold on;
means = nan(1, 3);
sems = nan(1, 3);

for ct = 1:3
    weights = abs(all_weights{ct});
    means(ct) = mean(weights);
    sems(ct) = std(weights) / sqrt(length(weights));
end

for ct = 1:3
    e = errorbar(ct, means(ct), sems(ct), 'o', ...
        'LineWidth', 1, ...
        'MarkerSize', 3, ...
        'CapSize', 3, ...
        'MarkerEdgeColor', colorss(ct,:), ...
        'MarkerFaceColor', colorss(ct,:));
    e.Color = colorss(ct,:);  % Set line color manually
end

xticks(1:3);
clean_labels = cellfun(@(s) strrep(s, '_cells', ''), possible_celltypes(1:3), 'UniformOutput', false);
xticklabels(upper(clean_labels));
if strcmpi(axis_type2,'Context')
    ylabel(['|Engagement Weight|']);
else
    ylabel(['|' axis_type2 ' Weight|']);
end

xli = xlim;
xlim([xli(1) - (xli(1)*.1),xli(2) + (xli(2)*.05)]); %adjust axis

% title('Mean Weight ± SEM');
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));

%do statistical analysis
for c = 1:num_combos
    ct1 = celltype_combos(c, 1);
    ct2 = celltype_combos(c, 2);

    x = abs(all_weights{ct1});
    y = abs(all_weights{ct2});
%     valid = ~isnan(x) & ~isnan(y);

    errorbar_weight_ct_stats.stats{ct1} = utils.get_basic_stats(x);
    errorbar_weight_ct_stats.stats{ct2} = utils.get_basic_stats(y);
    p_values( c) = permutationTest(x, y, 10000); % unpaired

%     if any(valid)
%         p_values( c) = permutationTest(x, y, 10000); % unpaired
%     end
end


% Store results
errorbar_weight_ct_stats.p_values = p_values;
errorbar_weight_ct_stats.test = 'unpaired permutation across bins and celltype pairs';
errorbar_weight_ct_stats.combos = celltype_combos;
errorbar_weight_ct_stats.significant = find(p_values < 0.05 / (num_combos)); % Bonferroni correction

%add significant stars
if isfield(errorbar_weight_ct_stats, 'p_values') && ~isempty(errorbar_weight_ct_stats.p_values)
    ct_combos = nchoosek(1:3, 2); % assuming 3 cell types
    offset = 0.001; % vertical spacing between stars
    ct_count = 0;
    for c = 1:size(ct_combos, 1)
        p = errorbar_weight_ct_stats.p_values(c);
        if p < 0.05 / 3  % Bonferroni correction
            
            y = ylim;
            star_y = y(2) + (ct * offset);
            utils.plot_pval_star(0, star_y, p, [ct_combos(c,1), ct_combos(c,2)], offset/2);
            ct = ct+1;
        end
    end
end
%% separate by dataset
% Bar plot of mean ± SEM per cell type
figure(808); clf;
hold on;
means = nan(1, 3);
sems = nan(1, 3);

for ct = 1:3
    weights = abs(all_weight_means_datasets(ct,:));
    means(ct) = mean(weights);
    sems(ct) = std(weights) / sqrt(length(weights));
end

for ct = 1:3
    e = errorbar(ct, means(ct), sems(ct), 'o', ...
        'LineWidth', 1, ...
        'MarkerSize', 3, ...
        'CapSize', 3, ...
        'MarkerEdgeColor', colorss(ct,:), ...
        'MarkerFaceColor', colorss(ct,:));
    e.Color = colorss(ct,:);  % Set line color manually
end

xticks(1:3);
clean_labels = cellfun(@(s) strrep(s, '_cells', ''), possible_celltypes(1:3), 'UniformOutput', false);
xticklabels(upper(clean_labels));
if strcmpi(axis_type2,'Context')
    ylabel(['|Engagement Weight|']);
else
    ylabel(['|' axis_type2 ' Weight|']);
end
xli = xlim;
xlim([xli(1) - (xli(1)*.1),xli(2) + (xli(2)*.05)]); %adjust axis

% title('Mean Weight ± SEM');
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));

%do statistical analysis
for c = 1:num_combos
    ct1 = celltype_combos(c, 1);
    ct2 = celltype_combos(c, 2);

    x = all_weight_means_datasets(ct1,:);
    y = all_weight_means_datasets(ct2,:);
%     valid = ~isnan(x) & ~isnan(y);

    errorbar_weight_datasets_ct_stats.stats{ct1} = utils.get_basic_stats(x);
    errorbar_weight_datasets_ct_stats.stats{ct2} = utils.get_basic_stats(y);
    p_values( c) = permutationTest(x, y, 10000); % unpaired

%     if any(valid)
%         p_values( c) = permutationTest(x, y, 10000); % unpaired
%     end
end


% Store results
errorbar_weight_datasets_ct_stats.p_values = p_values;
errorbar_weight_datasets_ct_stats.test = 'unpaired permutation across bins and celltype pairs';
errorbar_weight_datasets_ct_stats.combos = celltype_combos;
errorbar_weight_datasets_ct_stats.significant = find(p_values < 0.05 / (num_combos)); % Bonferroni correction

%add significant stars
if isfield(errorbar_weight_datasets_ct_stats, 'p_values') && ~isempty(errorbar_weight_datasets_ct_stats.p_values)
    ct_combos = nchoosek(1:3, 2); % assuming 3 cell types
    offset = 0.0005; % vertical spacing between stars
    ct_count = 0;
    for c = 1:size(ct_combos, 1)
        p = errorbar_weight_datasets_ct_stats.p_values(c);
        if p < 0.05 / 3  % Bonferroni correction
            
            y = ylim;
            star_y = y(2) + (ct * offset);
            utils.plot_pval_star(0, star_y, p, [ct_combos(c,1), ct_combos(c,2)], offset/2);
            ct = ct+1*.2;
        end
    end
end

% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(806,strcat('errorbar_weights_celltypes_vs_axis_',num2str(axis_type2),'_n_',num2str(length(chosen_datasets)),'_edges_',num2str(edge_values),'.fig'));
    exportgraphics(figure(806),strcat('errorbar_weights_celltypes_vs_axis_',num2str(axis_type2),'_n_',num2str(length(chosen_datasets)),'_edges_',num2str(edge_values),'.pdf'), 'ContentType', 'vector');

    save(strcat('hist_weights_celltypes_vs_axis_',num2str(axis_type2),'_stats_n',num2str(length(chosen_datasets)),'_edges_',num2str(edge_values),'.mat'),'hist_weight_ct_stats');

    saveas(807,strcat('barplot_weights_celltypes_',axis_type2,'.fig'));
    exportgraphics(figure(807),strcat('barplot_weights_celltypes_',axis_type2,'.pdf'), 'ContentType', 'vector');

    save(strcat('errorbar_weights_celltypes_vs_axis_',num2str(axis_type2),'_stats_n',num2str(length(chosen_datasets)),'_edges_',num2str(edge_values),'.mat'),'errorbar_weight_ct_stats');

    saveas(808,strcat('barplot_weights_datasets_celltypes_',axis_type2,'.fig'));
    exportgraphics(figure(808),strcat('barplot_weights_datasets_celltypes_',axis_type2,'.pdf'), 'ContentType', 'vector');

    save(strcat('errorbar_weights_celltypes_vs_axis_',num2str(axis_type2),'_stats_n',num2str(length(chosen_datasets)),'_edges_',num2str(edge_values),'.mat'),'errorbar_weight_datasets_ct_stats');


end