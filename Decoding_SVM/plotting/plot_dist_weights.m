function plot_dist_weights(bin_id, betas,all_celltypes,plot_info,data_type,svm_info,celtype, savepath, varargin)
possible_celltypes = fieldnames(all_celltypes{1,1});


figure(572);clf;
[rows,columns] = determine_num_tiles(size(betas,2)); %uses length of input
tiledlayout(rows,columns);

edges = -.2:0.1:.2; %bin edges can be changed

for m = 1:size(betas,2) %per mouse

    all_data = [betas{:,m,bin_id}]; %neurons x num_iterations
    if ~isempty(all_data)
        nexttile
        hold on;
    
        if ~isempty(celtype)
            for ce = celtype
                ex_mouse = m;
                
                % Plotting the histogram %PLOT standard error of the mean across
                % subsample iterations
                
                mean_data = mean(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),2); %find mean for specified cells across all subsamples
                [mean_prob]= get_hist(mean_data,edges);
                [across_prob] = get_hist(all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:),edges);%cellfun(@(x) get_hist(x,edges),{all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:)},'UniformOutput',false);%probability values for each cell across subsamples
        
        
                SEM= std(across_prob')/sqrt(size(across_prob,2)); %frames/num iterations
                shadedErrorBar(edges,mean_prob, SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:),'LineWidth', 1.5});
            end
        else
                ex_mouse = m;
                
                % Plotting the histogram %PLOT standard error of the mean across
                % subsample iterations
                
                mean_data = mean(all_data,2); %find mean for specified cells across all subsamples
                [mean_prob]= get_hist(mean_data,edges);
                [across_prob] = get_hist(all_data,edges);%cellfun(@(x) get_hist(x,edges),{all_data(all_celltypes{1,m}.(possible_celltypes{ce}),:)},'UniformOutput',false);%probability values for each cell across subsamples
        
        
                SEM= std(across_prob')/sqrt(size(across_prob,2)); %frames/num iterations
                shadedErrorBar(edges,mean_prob, SEM, 'lineProps',{'color', plot_info.colors_celltype(1,:),'LineWidth', 1.5});
    
        end
    
        % Adding labels and title
        xlabel('Classifier Weight');
        ylabel({'Probability'});
        title(svm_info.mouse_date(m));
    end
end
hold off
if ~isempty(savepath)
    mkdir([savepath '\SVM_' data_type '_' svm_info.savestr]);
    cd([savepath '\SVM_' data_type '_' svm_info.savestr]);
    
    if nargin > 8
        string_to_use = varargin{1};
    else
        string_to_use = '';
    end
    
    % save('roc_mdl','roc_mdl');
    saveas(572,strcat('SVM_weights_across_cells_bin',num2str(bin_id),string_to_use,'.png'));
    saveas(572,strcat('SVM_weights_across_cells_bin',num2str(bin_id),string_to_use,'.svg'));
    exportgraphics(gcf,strcat('SVM_weights_across_cells_bin',num2str(bin_id),string_to_use,'.pdf'), 'ContentType', 'vector');
end
% --- NEW FINAL FIGURE FOR AVERAGE ACROSS DATASETS ---
figure(573); clf;

hold on;
edges = -1:0.1:1;

for ce = celtype
    histograms_per_mouse = []; % rows = datasets, cols = histogram bins
    
    for m = 1:size(betas,2)
        if isempty(betas{1,m,bin_id})
            continue; % skip if no data
        end
        all_data = [betas{:,m,bin_id}]; % neurons x iterations
        if ~isempty(all_data)
            cell_inds = all_celltypes{1,m}.(possible_celltypes{ce});
            if isempty(cell_inds)
                continue;
            end

            % Compute mean across iterations for each cell, then get histogram
            mean_data = mean(all_data(cell_inds, :), 2); % avg across iterations
            [mean_prob] = get_hist(mean_data, edges);    % histogram for this mouse

            histograms_per_mouse = [histograms_per_mouse; mean_prob]; % accumulate
        end
    end

    if ~isempty(histograms_per_mouse)
        % Now take mean and SEM across mice (each row = one mouse)
        mean_hist = mean(histograms_per_mouse, 1);
        sem_hist = std(histograms_per_mouse, 0, 1) / sqrt(size(histograms_per_mouse, 1));

        shadedErrorBar(edges, mean_hist, sem_hist, ...
            'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth', 2});
    end
end

xlabel('Classifier Weight');
ylabel('Probability');
% legend(plot_info.labels,'Box','off','Location','best');

% Get current axis limits
x_range = xlim;
y_range = ylim;
y_offset_base = .2;
% Calculate base text position
text_x = x_range(2) - y_offset_base * diff(x_range);
text_y = y_range(2) - y_offset_base * diff(y_range);

% Auto-calculate evenly spaced y-offsets
num_labels = length(celtype);
y_offsets = linspace(0, 0.1 * (num_labels - 1), num_labels); % Adjusted scaling
% Place text labels
for i = 1:num_labels
    text(text_x, text_y - y_offsets(i) * diff(y_range), plot_info.labels{i}, ...
         'Color', plot_info.colors_celltype(i,:), 'FontSize', 7);
end
set(gca,'fontsize',10);
set(gcf,'position',[100,100,150,150])

if ~isempty(savepath)
    exportgraphics(gcf,strcat('AVG_SVM_weights_across_cells_bin',num2str(bin_id),string_to_use,'.pdf'), 'ContentType', 'vector');
end

% --- CUMULATIVE SUM / LORENZ CURVE OF ABSOLUTE CLASSIFIER WEIGHTS ---

% First pass: compute min_n per cell type
min_n_per_celltype = [];%containers.Map('KeyType','double','ValueType','double');
for ce = celtype
    min_n = inf;
    for m = 1:size(betas,2)
        if isempty(betas{1,m,bin_id})
            continue;
        end
        cell_inds = all_celltypes{1,m}.(possible_celltypes{ce});
        if isempty(cell_inds)
            continue;
        end
        min_n = min(min_n, length(cell_inds));
    end
    min_n_per_celltype(ce) = min_n;
end

figure(574); clf;
hold on;
% title('Cumulative Sum of Absolute Beta Weights');
xlabel('Fraction of Neurons');
ylabel('Cumulative |β|');
set(gca,'fontsize',12);

for ce = celtype
    cum_weights_all = [];

    for m = 1:size(betas,2)
        if isempty(betas{1,m,bin_id})
            continue;
        end

        all_data = [betas{:,m,bin_id}]; % neurons x iterations
        cell_inds = all_celltypes{1,m}.(possible_celltypes{ce});
        if isempty(cell_inds)
            continue;
        end

        % Mean beta per neuron (average over iterations)
        mean_data = mean(all_data(cell_inds,:), 2);

        % Sort by |B| and compute cumulative sum
        abs_betas = abs(mean_data);
        sorted_betas = sort(abs_betas, 'ascend');
        cum_sum = cumsum(sorted_betas);
        cum_sum = cum_sum / max(cum_sum); % Normalize to 1
%         frac_neurons = linspace(0, 1, length(cum_sum));
% 
%         % Store for averaging
%         cum_weights_all = pad_and_stack(cum_weights_all, cum_sum);

        % Interpolate to min_n for this cell type
        min_n = min_n_per_celltype(ce);
        common_frac = linspace(0, 1, min_n);
        orig_frac = linspace(0, 1, length(cum_sum));
        interp_cum = interp1(orig_frac, cum_sum, common_frac, 'linear');

        cum_weights_all = pad_and_stack(cum_weights_all, interp_cum);
    end

    if ~isempty(cum_weights_all)
        mean_cum = nanmean(cum_weights_all, 1);
        sem_cum = nanstd(cum_weights_all, 0, 1) / sqrt(size(cum_weights_all,1));
        frac_x = linspace(0, 1, size(cum_weights_all,2));

        shadedErrorBar(frac_x, mean_cum, sem_cum, ...
            'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth', 2});
    end
end
set(gca,'fontsize',10);

% legend(plot_info.labels(celtype), 'Box', 'off', 'Location', 'southeast');
% Get current axis limits
x_range = xlim;
y_range = ylim;
y_offset_base = .2;
% Calculate base text position
text_x = x_range(2) - y_offset_base * diff(x_range);
text_y = y_range(2) - .5 * diff(y_range);

% Auto-calculate evenly spaced y-offsets
num_labels = length(celtype);
y_offsets = linspace(0, 0.1 * (num_labels - 1), num_labels); % Adjusted scaling

% Place text labels
for i = 1:num_labels
    text(text_x, text_y - y_offsets(i) * diff(y_range), plot_info.labels{i}, ...
         'Color', plot_info.colors_celltype(i,:), 'FontSize', 7);
end
grid on
set(gcf,'position',[100,100,150,150])
if ~isempty(savepath)
    exportgraphics(gcf, strcat('CUMSUM_BetaWeights_bin',num2str(bin_id),string_to_use,'.pdf'), 'ContentType', 'vector');
end
end
function stacked = pad_and_stack(existing, new_row)
    max_len = max([size(existing, 2), length(new_row)]);
    if isempty(existing)
        stacked = nan(1, max_len);
        stacked(1:length(new_row)) = new_row;
    else
        padded = nan(1, max_len);
        padded(1:length(new_row)) = new_row;
        existing_padded = nan(size(existing,1), max_len);
        existing_padded(:,1:size(existing,2)) = existing;
        stacked = [existing_padded; padded];
    end
end
