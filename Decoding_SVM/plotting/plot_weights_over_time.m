function plot_weights_over_time(bin_ids,event_onset, betas, all_celltypes, event_onsets, data_type, svm_info, celtype,mdl_param,savepath, varargin)
% bin_ids = array of bins you want to plot (e.g., [1,2,3,4,5])
input_param{1,1}{1} = mdl_param;
plot_info = default_plot_info(input_param);
plot_info.event_onsets =  event_onsets;
plot_info.labels = {'Pyr','SOM','PV','All','Top Pyr'}; %{'Active'};


possible_celltypes = fieldnames(all_celltypes{1,1});

figure(572); clf;
[rows, columns] = determine_num_tiles(size(betas,2)); % tiles = number of mice
tiledlayout(rows, columns);

for m = 1:size(betas,2) % loop over mice
    nexttile;
    hold on;
    
    for ce = celtype
        mean_weights = nan(length(bin_ids), 1); % timepoints
        sem_weights = nan(length(bin_ids), 1);

        for b = 1:length(bin_ids)
            bin_id = bin_ids(b);
            all_data = abs([betas{:,m,bin_id}]); % neurons x num_iterations- take the absolute value

            if isempty(all_data)
                continue
            end

            if ~isempty(celtype)
                cell_inds = all_celltypes{1,m}.(possible_celltypes{ce});
                if isempty(cell_inds)
                    continue
                end
                % Average weights across iterations for each cell
                mean_per_cell = mean(all_data(cell_inds, :), 2);
            else
                % All cells
                mean_per_cell = mean(all_data, 2);
            end

            % Across all cells of this type, mean and SEM
            mean_weights(b) = mean(mean_per_cell);
            sem_weights(b) = std(mean_per_cell) / sqrt(length(mean_per_cell));
        end

        % Now plot for this cell type
        shadedErrorBar(bin_ids, mean_weights, sem_weights, ...
            'lineProps', {'Color', plot_info.colors_celltype(ce,:), 'LineWidth', 2});
    end

    ylabel('|Beta|');
    title(svm_info.mouse_date(m));
    set(gca,'fontsize',7);
    xline(event_onset,'--k')
%     second_frames = find(rem(bin_ids-event_onset,30) == 0);
%     second_ticks = find(histcounts(second_frames,bin_ids));
%     
%     % 2) get labels for the seconds!
%     frame_around = bin_ids - event_onset;
%     second_labels = frame_around(second_frames)/30;
% 
%     xticks([second_ticks]);
%     xticklabels(second_labels);
%     xlabel('Time (s)');

xlim([1 bin_ids(end)])
[second_ticks,second_labels] = x_axis_sec_onset(mdl_param);
xticks([second_ticks]);
xticklabels(second_labels);
ax = gca;  % Get current axes
set(gca,'xtick',plot_info.event_onsets,'xticklabel',{'S1','S2','S3','T','R'},'xticklabelrotation',45);



end

hold off;

if ~isempty(savepath)
    mkdir(fullfile(savepath, ['SVM_' data_type '_' svm_info.savestr]));
    cd(fullfile(savepath, ['SVM_' data_type '_' svm_info.savestr]));
    
    if nargin > 10
        string_to_use = varargin{1};
    else
        string_to_use = '';
    end
    
    saveas(572, strcat('SVM_weights_over_time_', string_to_use, '.png'));
    saveas(572, strcat('SVM_weights_over_time_', string_to_use, '.fig'));
    exportgraphics(gcf, strcat('SVM_weights_over_time_', string_to_use, '.pdf'), 'ContentType', 'vector');
end


% --- FINAL SUMMARY FIGURE ACROSS MICE ---
figure(573); clf;
hold on;

for ce = celtype
    mean_weights_allmice = nan(length(bin_ids), size(betas,2)); % bins x mice

    for m = 1:size(betas,2)
        weights_per_mouse = nan(length(bin_ids),1);

        for b = 1:length(bin_ids)
            bin_id = bin_ids(b);
            all_data = abs([betas{:,m,bin_id}]);

            if isempty(all_data)
                continue
            end

            if ~isempty(celtype)
                cell_inds = all_celltypes{1,m}.(possible_celltypes{ce});
                if isempty(cell_inds)
                    continue
                end
                mean_per_cell = mean(all_data(cell_inds, :), 2);
            else
                mean_per_cell = mean(all_data, 2);
            end

            weights_per_mouse(b) = mean(mean_per_cell);
        end

        mean_weights_allmice(:,m) = weights_per_mouse;
    end

    % Now across mice
    mean_over_mice = nanmean(mean_weights_allmice, 2);
    sem_over_mice = nanstd(mean_weights_allmice, 0, 2) ./ sqrt(sum(~isnan(mean_weights_allmice),2));

    shadedErrorBar(bin_ids, mean_over_mice, sem_over_mice, ...
        'lineProps', {'Color', plot_info.colors_celltype(ce,:), 'LineWidth', 2});
end

% xlabel('Time Bin');
ylabel('|Beta|');
% second_frames = find(rem(bin_ids-event_onset,30) == 0);
% second_ticks = find(histcounts(second_frames,bin_ids));
% 
% % 2) get labels for the seconds!
% frame_around = bin_ids - event_onset;
% second_labels = frame_around(second_frames)/30;
% 
% xticks([second_ticks]);
% xticklabels(second_labels);
% xlabel('Time (s)');
xline(event_onset,'--k')
xlim([1 bin_ids(end)])
[second_ticks,second_labels] = x_axis_sec_onset(mdl_param);
xticks([second_ticks]);
xticklabels(second_labels);
ax = gca;  % Get current axes
set(gca,'xtick',plot_info.event_onsets,'xticklabel',{'S1','S2','S3','T','R'},'xticklabelrotation',45);


% legend(plot_info.labels(celtype), 'Box', 'off', 'Location', 'best');
% Get current axis limits
x_range = xlim;
y_range = ylim;
y_offset_base = .1;
% Calculate base text position
text_x = x_range(2) -.05 * diff(x_range);
text_y = y_range(1) +.3 * diff(y_range);

% Auto-calculate evenly spaced y-offsets
num_labels = length(celtype);
y_offsets = linspace(0, 0.1 * (num_labels - 1), num_labels); % Adjusted scaling
% Place text labels
for i = 1:num_labels
    text(text_x, text_y - y_offsets(i) * diff(y_range), plot_info.labels{i}, ...
         'Color', plot_info.colors_celltype(i,:), 'FontSize', 7);
end

set(gca,'fontsize',7);
set(gcf,'position',[100,100,150,150]);

if ~isempty(savepath)
    exportgraphics(gcf, strcat('AVG_SVM_weights_over_time_', string_to_use, '.pdf'), 'ContentType', 'vector');
end

end

