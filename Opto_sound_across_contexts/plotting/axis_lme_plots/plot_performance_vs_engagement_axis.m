function plot_performance_vs_engagement_axis(percent_correct_concat,engagement_proj_all_sound,engagement_proj_all_stim,context_all_sound,context_all_stim,window_bins,save_dir,edge_input,varargin)
%% collect correctness across mice
correct_all_ctrl = []; animal_id_all=[];
for dataset = 1:24
    correct_all_ctrl = [correct_all_ctrl; percent_correct_concat{dataset}'];
    animal_id_all = [animal_id_all; repmat(dataset, size(percent_correct_concat{dataset},2), 1)];
end

active_trials = context_all_sound == 0;
engagement_active = [engagement_proj_all_sound(active_trials);engagement_proj_all_stim(context_all_stim == 0)];
performance_active =  correct_all_ctrl;
animal_active = animal_id_all;  % Categorical ID
%%
% Parameters
window_size = window_bins(1);
if nargin < 9
    plot_sessions = 0;
else
    plot_sessions = varargin{1,1};
end
% Unique animals/sessions
animal_ids = unique(animal_id_all);
% Initialize pooled vectors
all_success = [];
all_engagement = [];
session_success = {};
session_engagement = {};
for a = 1:length(animal_ids)
    idx = animal_id_all == animal_ids(a);
    perf = performance_active(idx);         % Binary performance (0/1)
    engagement = engagement_active(idx);    % Continuous engagement projection
    % :arrow_down: Z-score engagement per animal
    if std(engagement) == 0
        continue  % skip if std = 0 to avoid NaNs
    end
    engagement = (engagement - mean(engagement)) / std(engagement);  % z-score
    % Sort trials by engagement
    [sorted_eng, sort_idx] = sort(engagement);
    sorted_perf = perf(sort_idx);
    n = length(sorted_eng);
    if n < window_size
        continue
    end
    temp_e = [];
    temp_s = [];
    % Sliding window
    for i = 1:(n - window_size + 1)
        win_eng = sorted_eng(i:i + window_size - 1);
        win_perf = sorted_perf(i:i + window_size - 1);
        % Store mean per window
        all_engagement(end+1,1) = mean(win_eng);
        all_success(end+1,1) = mean(win_perf);
        temp_e = [temp_e, mean(win_eng)];
        temp_s = [temp_s, mean(win_perf)];
    end
    session_success{a} = temp_s;
    session_engagement{a} = temp_e;
end

positions = utils.calculateFigurePositions(1, 5, .5, []);

% ─────────────────────────────────────────────
% Scatter plot of sliding window means
figure(401); clf;
scatter(all_engagement, all_success, 8, 'filled', ...
    'MarkerFaceAlpha', 0.1, 'MarkerEdgeAlpha', 0.1);
xlabel({'Engagement Projection';'(z-scored)'});
ylabel('Fraction Correct');
% title(sprintf('Sliding window (n = %d trials per window)', window_size));
% % Optional: Linear regression overlay
% mdl = fitlm(all_engagement, all_success);
% hold on;
% xfit = linspace(min(all_engagement), max(all_engagement), 100);
% yfit = predict(mdl, xfit');
% plot(xfit, yfit, 'k-', 'LineWidth', 1.2);
% % text(mean(xfit), max(yfit), sprintf('R = %.2f, p = %.3g', mdl.Correlation, mdl.Coefficients.pValue(2)), ...
% %     'FontSize', 7);
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));

% Bin data based on engagement quantiles
edges = linspace(edge_input(1),edge_input(2), window_bins(2)+1);%prctile(engagement_active, linspace(0, 100, 6));%linspace(0,2, 6); %prctile(engagement_active, linspace(0, 100, 6));  % 5 bins
bin_centers = movmean(edges, 2, 'Endpoints','discard');
n_bins = length(bin_centers);

[~, ~, bin_idx] = histcounts(all_engagement, edges);

%separate per session
% Initialize per-animal matrix [animal x bins]
animal_success_by_bin = NaN(length(animal_ids), n_bins);
% Loop through animals/sessions
for a = 1:length(animal_ids)
    e = session_engagement{a};
    s = session_success{a};
    if isempty(e)
        continue
    end
    % Bin this session's engagement values
    [~, ~, bin_idx] = histcounts(e, edges);
    % For each bin, compute mean success
    for b = 1:n_bins
        bin_trials = s(bin_idx == b);
        if ~isempty(bin_trials)
            animal_success_by_bin(a, b) = mean(bin_trials);
        end
    end
end
% Compute across-animal mean and SEM
mean_success_per_bin = nanmean(animal_success_by_bin, 1);
sem_success_per_bin = nanstd(animal_success_by_bin, [], 1) ./ sqrt(sum(~isnan(animal_success_by_bin),1));
% Plot
figure(404);clf;
hold on;
% Individual animal traces (light gray lines)
if plot_sessions == 1
    for a = 1:size(animal_success_by_bin,1)
        plot(bin_centers, animal_success_by_bin(a,:), '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 0.8);
    end
end
% Group mean with error bars (black line)
errorbar(bin_centers, mean_success_per_bin, sem_success_per_bin,  '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1,'MarkerSize',3,'CapSize',2);
xlabel({'Engagement Projection';'(z-scored)'});
ylabel('Fraction Correct');
ylims = ylim;
ylim([ylims(1)-(ylims(1)*.03),ylims(2)+(ylims(2)*.03)])
xli = xlim;
xlim([xli(1)- xli(2)*.3,xli(2) + xli(2)*.3]); %adjust axis
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
box off

% % correect (xaxis) vs engagemnt (yaxis)
% Correlation
[r, p] = corr(all_success, all_engagement);
% Plot
figure(405);clf; hold on;
scatter(all_success, all_engagement, 20, ...
    'MarkerFaceColor', [0.3 0.6 0.9], ...
    'MarkerEdgeColor', 'none', ...
    'MarkerFaceAlpha', 0.1);

% Linear regression
mdl = fitlm(all_success, all_engagement);
xvals = linspace(min(all_success), max(all_success), 100);
yhat = predict(mdl, xvals');
plot(xvals, yhat, 'b-', 'LineWidth', 1.5);

% Annotations
text(0.43, max(all_engagement)*0.95, ...
    sprintf('P = %.3g\nR = %.2f', p, r), 'FontSize', 6);

xlabel('Fraction Correct');
ylabel({'Engagement Projection';'(z-scored)'});
% title('Correlation: Engagement vs Performance (sliding window)');
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
box off

if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(404,strcat('errorbar_performance_vs_zengagement_axis_windownbin',num2str(window_bins),'edges',num2str(edges(1)),num2str(edges(end)),'.fig'));
    exportgraphics(figure(404),strcat('errorbar_performance_vs_engagement_axis_windownbin',num2str(window_bins),'edges',num2str(edges(1)),num2str(edges(end)),'.pdf'), 'ContentType', 'vector');
    exportgraphics(figure(405),strcat('scatter_performance_vs_engagement_axis_windownbin',num2str(window_bins),'edges',num2str(edges(1)),num2str(edges(end)),'.pdf'), 'ContentType', 'vector');

end