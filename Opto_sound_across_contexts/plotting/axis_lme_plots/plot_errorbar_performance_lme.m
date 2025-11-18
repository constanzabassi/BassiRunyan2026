function lme_perf = plot_errorbar_performance_lme(percent_correct_concat,engagement_proj_all_sound,engagement_proj_all_stim,context_all_sound,context_all_stim,save_dir,varargin)
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

%concatenate with stim trials to have more trials!

%% me logistic regression

% Create table
tbl_perf = table(engagement_active, performance_active, animal_active, ...
    'VariableNames', {'EngagementProj', 'Performance', 'AnimalID'});
tbl_perf.Performance = logical(tbl_perf.Performance); % Ensure binary
tbl_perf.AnimalID = categorical(tbl_perf.AnimalID);   % Random effect grouping

% Fit GLME: random intercept for each animal
lme_perf = fitglme(tbl_perf, 'Performance ~ EngagementProj + (1|AnimalID)', ...
                   'Distribution', 'binomial');
disp(lme_perf)


edges = prctile(engagement_active, linspace(0, 100, 6));  % 5 bins
bin_centers = movmean(edges, 2, 'Endpoints','discard');
n_bins = length(bin_centers);

% Initialize
% animals = categories(animal_id_all);
n_animals = 24;
perf_by_bin = nan(n_animals, n_bins);
if nargin > 6
    act_by_bin = nan(n_animals, n_bins);
end

min_num_trials = 3;
% Loop through animals
for i = 1:n_animals
    idx = animal_id_all == i;
    
    e = engagement_active(idx);
    p = performance_active(idx);
    if nargin > 6
        activity = mean(varargin{1,1}{i,1}(:,varargin{1,2}),2);
        activity = (activity - mean(activity)) / std(activity);  % z-score per animal
    end

    if numel(e) > 10
        [~,~,bin] = histcounts(e, edges);
        for b = 1:n_bins
            trials_in_bin = p(bin == b);
            if numel(trials_in_bin) >= min_num_trials
                perf_by_bin(i, b) = mean(trials_in_bin);
            end
            if nargin > 6
                trials_in_bin = activity(bin == b,:);
                if numel(trials_in_bin) >= min_num_trials
                    act_by_bin(i, b) = mean(activity);
                end
            end
        end
    end
end

% Compute mean and SEM across animals
mean_perf = nanmean(perf_by_bin, 1);
sem_perf = nanstd(perf_by_bin, 0, 1) ./ sqrt(sum(~isnan(perf_by_bin), 1));

% Compute mean and SEM across animals
if nargin > 6
    mean_act = nanmean(act_by_bin, 1);
    sem_act = nanstd(act_by_bin, 0, 1) ./ sqrt(sum(~isnan(act_by_bin), 1));
end


% Plot
figure(105);clf; hold on;
errorbar(bin_centers, mean_perf, sem_perf, '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1,'MarkerSize',3,'CapSize',2);
xlabel('Engagement projection');
ylabel('Fraction Correct');
% title('Performance vs Engagement (mean ± SEM across mice)');
set(gca, 'FontSize', 7);
positions = utils.calculateFigurePositions(1, 5, .5, []);
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;
xli = xlim;
xlim([xli(1)- xli(2)*.3,xli(2) + xli(2)*.3]); %adjust axis
ylim([.6 .9])

figure(106);clf
bar(sum(~isnan(perf_by_bin), 1),'FaceColor',[.6,.6,1]);
xlabel('Bin'); ylabel('# Datasets'); title('Datasets per Engagement Bin','FontWeight','normal');
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
box off

if nargin > 6
    figure(107);clf; hold on;
    errorbar(bin_centers, mean_act, sem_act, '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1,'MarkerSize',3,'CapSize',2);
    xlabel('Engagement projection');
    ylabel('Mean Activity (z-score)');
    % title('Performance vs Engagement (mean ± SEM across mice)');
    set(gca, 'FontSize', 7);
    positions = utils.calculateFigurePositions(1, 5, .5, []);
    set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
    utils.set_current_fig;
    xli = xlim;
    xlim([xli(1)- xli(2)*.3,xli(2) + xli(2)*.3]); %adjust axis
end

if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(105,strcat('errorbar_performance_vs_engagement_axis_mintrial',num2str(min_num_trials),'.fig'));
    exportgraphics(figure(105),strcat('errorbar_performance_vs_engagement_axis_mintrial',num2str(min_num_trials),'.pdf'), 'ContentType', 'vector');
    exportgraphics(figure(106),strcat('errorbar_perf_bar_dataset_n_mintrial',num2str(min_num_trials),'.pdf'), 'ContentType', 'vector');
    if nargin > 6
       exportgraphics(figure(107),strcat('errorbar_activity_vs_engagement_axis_mintrial',num2str(min_num_trials),'.pdf'), 'ContentType', 'vector');
    end
end
