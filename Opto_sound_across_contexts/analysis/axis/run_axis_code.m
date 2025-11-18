%% load context data

load('V:\Connie\results\opto_sound_2025\context\data_info\all_celltypes.mat');
load('V:\Connie\results\opto_sound_2025\context\data_info\context_data.mat');
keep context_data all_celltypes
%% define axis
[proj,proj_ctrl,proj_norm,proj_norm_ctrl, weights,trial_corr_context,percent_correct,act,act_norm_ctrl,act_norm,percent_correct_concat,proj_concat,proj_concat_norm] = find_axis(context_data.dff, [1:24], all_celltypes,[],[],[]); %,{50:59,63:73}

save_dir = 'V:\Connie\results\opto_sound_2025\context\axis_plots\dff_raw';

%% plot mean projection traces across datasets
celltype = 4; %4 = all

plot_proj_mean_traces([1:24],proj_ctrl, 'sound',celltype, [61:62],[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);
plot_proj_mean_traces([1:24],proj_ctrl, 'context',celltype, [61:62],[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);
plot_proj_mean_traces([1:24],proj, 'stim',celltype, [61:62],[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);

%% plot histogram across contexts
frames_to_avg = 50:59;
bin_edges = [-2:0.4:2];%
hist_stats =  histogram_axis_across_contexts([1:24],proj_ctrl, 'context',celltype, bin_edges,frames_to_avg,[0,0,0;.5,.5,.5],{'Active','Passive'},save_dir);

%% performance vs context
edges_values = [0,2];
num_bins = 5;
[binned_perf_all,errorbar_stats] = plot_error_bars_performance_vs_axis([1:24],proj_ctrl,  'context', celltype,percent_correct,frames_to_avg, edges_values,num_bins,save_dir);
heatmap_nan_datasets(binned_perf_all,['binned_resp_all_ctx' num2str(1) '_edges_' num2str(edges_values)],[]);

edges_values = [0.5,1.5];
num_bins = 5;
[binned_perf_all,errorbar_stats] = plot_error_bars_performance_vs_axis([1:24],proj_ctrl,  'context', celltype,percent_correct,frames_to_avg, edges_values,num_bins,save_dir);
heatmap_nan_datasets(binned_perf_all,['binned_resp_all_ctx' num2str(1) '_edges_' num2str(edges_values)],[]);

edges_values = [-1,1];
num_bins = 5;
[binned_perf_all,errorbar_stats] = plot_error_bars_performance_vs_axis([1:24],proj_ctrl,  'context', celltype,percent_correct,frames_to_avg, edges_values,num_bins,save_dir);

edges_values = [-1,2];
num_bins = 5;
[binned_perf_all,errorbar_stats] = plot_error_bars_performance_vs_axis([1:24],proj_concat,  'context', celltype,percent_correct_concat,frames_to_avg, edges_values,num_bins,[]);

edges_values = [-1,1];
num_bins = 5;
[binned_perf_all,errorbar_stats] = plot_error_bars_performance_vs_axis_rolling_window([1:24],proj_concat,  'context', celltype,percent_correct_concat,frames_to_avg, edges_values,num_bins,save_dir);

edges_values = [-1,1];
num_bins = 5;
[binned_perf_all,errorbar_stats] = plot_error_bars_performance_vs_axis_quantile([1:24],proj_concat,  'context', celltype,percent_correct_concat,frames_to_avg,num_bins,save_dir,0);
heatmap_nan_datasets(binned_perf_all,['binned_resp_all_ctx' num2str(1) '_edges_' num2str(edges_values)],[]);


%% response vs engagement axis
frame_range1 = 50:59; %pre period
frame_range2 = 63:93; %post period
colorss = [0,0,0;.5,.5,.5];
edges_values = [-1,3];
num_bins = 5;
[binned_resp_all_ctx,errorbar_resp_stats] = plot_error_bars_response_vs_axis([1:24],proj_ctrl,  'context',proj_ctrl, 'Sound', celltype,frame_range1,frame_range2,edges_values,num_bins,colorss,save_dir);

[binned_resp_all_stim_ctx,errorbar_resp_stats_stim] = plot_error_bars_response_vs_axis([1:24],proj,  'context',proj, 'Stim', celltype,frame_range1,frame_range2,edges_values,num_bins,colorss,save_dir);

for ctx = 1:2
    heatmap_nan_datasets(binned_resp_all_ctx{1,ctx},['binned_resp_all_ctx' num2str(ctx) '_edges_' num2str(edges_values)],save_dir);
    heatmap_nan_datasets(binned_resp_all_stim_ctx{1,ctx},['binned_resp_all_stim_ctx' num2str(ctx) '_edges_' num2str(edges_values)],save_dir);
end

% repeat but without separated trials across contexts
[binned_resp_all_ctx_together,errorbar_resp_stats_together] = plot_error_bars_response_vs_axis([1:24],proj_concat,  'context_sound',proj_concat, 'Sound', celltype,frame_range1,frame_range2,edges_values,num_bins,colorss,save_dir);
[binned_resp_all_stim_together,errorbar_resp_stats_stim_together] = plot_error_bars_response_vs_axis([1:24],proj_concat,  'context_stim',proj_concat, 'Stim', celltype,frame_range1,frame_range2,edges_values,num_bins,colorss,save_dir);

num_bins = 4;
[binned_resp_all_ctx_together_quant,errorbar_resp_stats_quant] = plot_error_bars_response_vs_axis_quantiles([1:24],proj_ctrl,  'context',proj_ctrl, 'Sound', celltype,frame_range1,frame_range2,edges_values,num_bins,colorss,save_dir);
[binned_resp_all_stim_ctx_together_quant,errorbar_resp_stats_stim_quant] = plot_error_bars_response_vs_axis_quantiles([1:24],proj,  'context',proj, 'Stim', celltype,frame_range1,frame_range2,edges_values,num_bins,colorss,save_dir);

%% response vs engagement axis divided by celltypes
colors_celltypes = [0.16, 0.40, 0.24 %dark green
                    0.13, 0.24, 0.51 %dark blue
                    0.50, 0.06, 0.10%dark red
                    0.54, 0.82, 0.64 %light green
                    0.55, 0.65, 0.89%light blue
                    0.92, 0.36, 0.41]%light red
group_size = 3;
for ctx = 1:2; %focus on active context
    group = [(ctx-1)*group_size + (1:group_size)];

    [binned_resp_all_ct,errorbar_resp_ct_stats] = plot_error_bars_response_celltypes_vs_axis([1:24],proj_ctrl,  'context',proj_ctrl, 'Sound',ctx,frame_range1,frame_range2,edges_values,num_bins,colors_celltypes(group,:),save_dir);
    [binned_resp_all_ct_stim,errorbar_resp_ct_stats_stim] = plot_error_bars_response_celltypes_vs_axis([1:24],proj_ctrl,  'context',proj, 'Stim',ctx,frame_range1,frame_range2,edges_values,num_bins,colors_celltypes(group,:),save_dir);
    % [binned_resp_all_ct,errorbar_resp_ct_stats] = plot_error_bars_response_celltypes_vs_axis([1:24],proj_ctrl,  'context',proj_ctrl, 'Context',ctx,frame_range1,frame_range1,edges_values,num_bins,colors_celltypes,[]);
    
%     edges_values = [0,2];
%     num_bins = 5;
    [~,errorbar_activity_ct_stats.ctx] = plot_error_bars_realactivity_celltypes_vs_axis([1:24],proj_ctrl,  'context',act_ctrl, 'Context',ctx,frame_range1,frame_range1,edges_values,num_bins,colors_celltypes(group,:),save_dir);
    % [binned_resp_all_ct,errorbar_resp_ct_stats] = plot_error_bars_realactivity_celltypes_vs_axis([1:24],proj_ctrl,  'context',act_ctrl, 'Sound',ctx,frame_range1,frame_range2,edges_values,num_bins,colors_celltypes,[]);

end
% % [0.16, 0.40, 0.24 %dark green
% % 0.54, 0.82, 0.64 %0.30 0.58 0.40 %light green
% % 0.54, 0.82, 0.64 %light green
% % 0.13, 0.24, 0.51 %dark blue
% % 0.55, 0.65, 0.89 % light blue 0.17 0.35 0.8  %blue
% % 0.55, 0.65, 0.89 % light blue 
% % 0.50, 0.06, 0.10 %dark red
% % 0.92, 0.36, 0.41 % light red 0.82 0.04 0.04
% % 0.92, 0.36, 0.41];% light red
%% do the same but for concatenated contexts
colors_celltypes = [0.3700    0.7500    0.4900;
                    0.1700    0.3500    0.8000;
                    0.8200    0.0400    0.0400];
group = 1:3;
ctx = 1; %only one context since active and passive are concatenated
[binned_resp_all_ct,errorbar_resp_ct_stats] = plot_error_bars_response_celltypes_vs_axis([1:24],proj_concat,  'context_sound',proj_concat, 'Sound',ctx,frame_range1,frame_range2,edges_values,num_bins,colors_celltypes(group,:),save_dir);
[binned_resp_all_ct_stim,errorbar_resp_ct_stats_stim] = plot_error_bars_response_celltypes_vs_axis([1:24],proj_concat,  'context_stim',proj_concat, 'Stim',ctx,frame_range1,frame_range2,edges_values,num_bins,colors_celltypes(group,:),save_dir);
[~,errorbar_activity_ct_stats.ctx] = plot_error_bars_realactivity_celltypes_vs_axis([1:24],proj_concat,  'context_sound',act, 'context_sound',ctx,frame_range1,frame_range1,edges_values,num_bins,colors_celltypes(group,:),[]);
[~,errorbar_activity_ct_stats.ctx] = plot_error_bars_realactivity_celltypes_vs_axis([1:24],proj_concat,  'context_stim',act, 'context_stim',ctx,frame_range1,frame_range1,edges_values,num_bins,colors_celltypes(group,:),[]);

[~,errorbar_activity_ct_stats.ctx] = plot_error_bars_realactivity_celltypes_vs_axis([1:24],proj_concat,  'sound',act, 'sound',ctx,frame_range2,frame_range2,edges_values,num_bins,colors_celltypes(group,:),[]);
[~,errorbar_activity_ct_stats.ctx] = plot_error_bars_realactivity_celltypes_vs_axis([1:24],proj_concat,  'stim',act, 'stim',ctx,frame_range2,frame_range2,edges_values,num_bins,colors_celltypes(group,:),[]);
%% Plot weights vs axis
colors_medium = [0.37 0.75 0.49 %green
                0.17 0.35 0.8  %blue
                0.82 0.04 0.04];
edges_values_weights = [-.1,.1];
num_bins_weights = 20;
[weight_all_celltype,weight_ct_stats] = histogram_weights_celltypes_vs_axis([1:24],weights, 'Context' ,all_celltypes, edges_values_weights,num_bins_weights,colors_medium,save_dir);

[weight_all_celltype_sound,weight_ct_stats_sound] = histogram_weights_celltypes_vs_axis([1:24],weights, 'Sound',all_celltypes , edges_values_weights,num_bins_weights,colors_medium,save_dir);
[weight_all_celltype_stim,weight_ct_stats_stim] = histogram_weights_celltypes_vs_axis([1:24],weights, 'Stim',all_celltypes , edges_values_weights,num_bins_weights,colors_medium,save_dir);


%% TESTING BELOW
% scatter of IH mean activity vs sound proj or opto proj
figure(8);clf;
celltype = 4;
hold on;
for dataset = 1:size(trial_corr_context,1)
    scatter(weights{dataset,celltype}.stim,weights{dataset,celltype}.sound,'magenta'); % 
end

current_dataset = 1;
celltype = 4;
colorss = [0,0,0;.5,.5,.5];
figure;
hold on;
for dataset = 1:24
for contexts = 1:2
    plot(1:122,(mean(proj_ctrl{dataset,celltype,contexts}.sound) - mean(proj_ctrl{dataset,celltype,contexts}.sound(:,1:59),'all')),'color', colorss(contexts,:)); % 
end
end

figure;
hold on;
for dataset = 1:24
for contexts = 1:2
    plot(1:122,(mean(proj_ctrl{dataset,celltype,contexts}.sound)),'color', colorss(contexts,:)); % 
end
end

figure;
hold on;
for dataset = 1:24
for contexts = 1:2
    plot(1:122,(mean(proj{dataset,celltype,contexts}.stim) - mean(proj{dataset,celltype,contexts}.stim(:,1:59),'all')),'color', colorss(contexts,:)); % 
end
end

figure;
hold on;
for dataset = 1:24
for contexts = 1:2
    plot(1:122,(mean(proj{dataset,celltype,contexts}.stim) ),'color', colorss(contexts,:)); % 
end
end


% figure;
% hold on;
% for dataset = 1:24
% for contexts = 1:2
%     plot(1:122,(mean(proj_ctrl{dataset,celltype,contexts}.context) - mean(proj_ctrl{dataset,celltype,contexts}.context(:,61:122),'all')),'color', colorss(contexts,:)); % 
% end
% end

figure;
hold on;
for dataset = 1:24
for contexts = 1:2
    plot(1:122,proj_ctrl{dataset,celltype,contexts}.context,'color', colorss(contexts,:)); % 
end
end



figure(6);clf;
temp3 = [];
temp4 = [];
celltype = 4;
hold on;
for dataset = 1:size(trial_corr_context,1)
    scatter(trial_corr_context{dataset,celltype,1}.stim_sound_post,trial_corr_context{dataset,celltype,2}.stim_sound_post,'magenta'); % 
    temp3 = [temp3,trial_corr_context{dataset,celltype,1}.stim_sound_post];
    temp4 = [temp4,trial_corr_context{dataset,celltype,2}.stim_sound_post];

end

figure(7);clf;
temp = [];temp2 =[];
celltype = 4;
hold on;
for dataset = 1:size(trial_corr_context,1)
    scatter(trial_corr_context{dataset,celltype,1}.stim_sound,trial_corr_context{dataset,celltype,2}.stim_sound,'magenta'); % 
    temp = [temp,trial_corr_context{dataset,celltype,1}.stim_sound];
    temp2 = [temp2,trial_corr_context{dataset,celltype,2}.stim_sound];

end

figure(8);clf;
celltype = 4;
hold on;
for dataset = 1:size(trial_corr_context,1)
    scatter(weights{dataset,celltype}.stim,weights{dataset,celltype}.sound,'magenta'); % 
end

figure(8);clf;
celltype = 4;
hold on;
for dataset = 1:size(trial_corr_context,1)
    scatter(weights{dataset,celltype}.context,weights{dataset,celltype}.sound,'magenta'); % 
end

figure(9);clf;
hold on
a = Violin({temp},1,'ViolinColor',{[0,0,0]},'EdgeColor',[0,0,0],'QuartileStyle','boxplot'); %,'ViolinAlpha',{0.0, 0.8}
a = Violin({temp2},2,'ViolinColor',{[0.5,0.5,0.5]},'EdgeColor',[0.5,0.5,0.5],'QuartileStyle','boxplot'); %,'ViolinAlpha',{0.0, 0.8}
xticks([1:2])
xticklabels({'Active','Passive'})


figure(10);clf;
hold on
a = Violin({temp3},1,'ViolinColor',{[0,0,0]},'EdgeColor',[0,0,0],'QuartileStyle','boxplot'); %,'ViolinAlpha',{0.0, 0.8}
a = Violin({temp4},2,'ViolinColor',{[0.5,0.5,0.5]},'EdgeColor',[0.5,0.5,0.5],'QuartileStyle','boxplot'); %,'ViolinAlpha',{0.0, 0.8}
xticks([1:2])
xticklabels({'Active','Passive'})


%% plot individual datasets
figure;

for dataset_num = 1:24;
subplot(5,5,dataset_num)
hold on
for contexts = 1:2
    plot(1:122,(proj_ctrl{dataset_num,celltype,contexts}.sound) ,'color', colorss(contexts,:)); % - mean(proj_ctrl{dataset_num,celltype,contexts}.sound(:,1:59),'all')
end
end

figure;

for dataset_num = 1:24;
subplot(5,5,dataset_num)
hold on
for contexts = 1:2
    plot(1:122,(proj{dataset_num,celltype,contexts}.stim) ,'color', colorss(contexts,:)); % - mean(proj_ctrl{dataset_num,celltype,contexts}.sound(:,1:59),'all')
end
end
%%
figure;
hold on;

% Initialize
num_timepoints = 122;
num_datasets = 24;
contexts = 2;

% Preallocate
all_data = cell(contexts, 1);

for ctx = 1:contexts
    ctx_data = zeros(num_datasets, num_timepoints);
    for dataset = 1:num_datasets
        data = proj{dataset,celltype,ctx}.stim;%proj{dataset,celltype,ctx}.stim;%proj_ctrl{dataset, celltype, ctx}.sound; %proj{dataset,celltype,ctx}.stim;%proj{dataset,celltype,ctx}.stim%proj_ctrl{dataset, celltype, ctx}.sound;
        baseline = 0; %mean(data(:,1:59), 'all');
        ctx_data(dataset, :) = mean(data) - baseline;
    end
    all_data{ctx} = ctx_data;
end

% Plot with mean and SEM
for ctx = 1:contexts
    data = all_data{ctx};
    m = mean(data, 1);
    s = std(data, [], 1) / sqrt(size(data,1)); % SEM

    % Plot shaded error bar or mean with error bars
    fill([1:num_timepoints, fliplr(1:num_timepoints)], ...
         [m + s, fliplr(m - s)], ...
         colorss(ctx,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    plot(1:num_timepoints, m, 'Color', colorss(ctx,:), 'LineWidth', 2);
end

xlabel('Time');
ylabel('Mean-centered projection');
legend({'Context 1', 'Context 2'});
title('Mean ± SEM of Sound Projection by Context');

%%
figure;
hold on;

frame_range = 50:59; %63:93; % specify the frames you're averaging over
bin_edges = -2:0.15:2; % adjust bins as needed
all_trial_means_contexts = {};
all_trial_means_datasets = [];
for ctx = 1:2
    all_trial_means = [];

    for dataset = 1:24
        data = proj_ctrl{dataset, celltype, ctx}.context; %proj{dataset,celltype,ctx}.stim; %proj_ctrl{dataset, celltype, ctx}.sound;
        trial_means = mean(data(:, frame_range), 2); % mean per trial in specified frames
        all_trial_means = [all_trial_means; trial_means];
        all_trial_means_datasets(ctx,dataset) = mean(trial_means);
    end

    % Compute histogram (normalized to get fraction of trials)
    h = histogram(all_trial_means, bin_edges, 'Normalization', 'probability', ...
                  'DisplayStyle', 'stairs', 'LineWidth', 2, 'EdgeColor', colorss(ctx,:));
    all_trial_means_contexts{ctx} = all_trial_means;

end

xlabel('Mean projection (frames 60–90)');
ylabel('Fraction of trials');
legend({'Context 1', 'Context 2'});
title('Histogram of Trial Means by Context');

num_contexts = 2;
possible_tests = nchoosek(1:num_contexts,2);
for t = 1:size(possible_tests,1)
            ctx1 = possible_tests(t,1);
                ctx2 = possible_tests(t,2);
                data1 = all_trial_means_contexts{ctx1};
                data2 = all_trial_means_contexts{ctx2};
[p_val_mod(t,celltype), ~, effectsize(t,celltype)] = permutationTest(...
data1, data2, 10000);
end

num_contexts = 2;
possible_tests = nchoosek(1:num_contexts,2);
for t = 1:size(possible_tests,1)
            ctx1 = possible_tests(t,1);
                ctx2 = possible_tests(t,2);
                data1 = all_trial_means_datasets(ctx1,:);
                data2 = all_trial_means_datasets(ctx2,:);
[p_val_mod2(t,celltype), ~, effectsize2(t,celltype)] = permutationTest_updatedcb(...
data1, data2, 10000,'paired',1);
end

%% performance vs pre period across all trials
% Parameters
frame_range = 50:59; %60:90;
num_bins = 10;

% Bin engagement (trial_means) values
edges = linspace(-1, 1.5, num_bins+1); %linspace(min(all_proj), max(all_proj), num_bins+1);
bin_centers = edges(1:end-1) + diff(edges)/2;
binned_perf = zeros(num_bins, 1);
binned_sem = zeros(num_bins, 1);

all_proj = [];
all_perf = [];

% Collect data across datasets
for dataset = 1:24
    data = proj_ctrl{dataset, celltype, 1}.context; %proj{dataset,celltype,ctx}.stim; %proj_ctrl{dataset, celltype, 1}.context; % choose one context for now
    trial_means = mean(data(:, frame_range), 2);
    correct =percent_correct{dataset}; % binary vector
    
    all_proj = [all_proj, trial_means'];
    all_perf = [all_perf, correct];
end


for b = 1:num_bins
    bin_idx = all_proj >= edges(b) & all_proj < edges(b+1);
    trials_in_bin = all_perf(bin_idx);
    
    if ~isempty(trials_in_bin)
        binned_perf(b) = mean(trials_in_bin);
        binned_sem(b) = std(trials_in_bin) / sqrt(length(trials_in_bin));
    else
        binned_perf(b) = NaN;
        binned_sem(b) = NaN;
    end
end

% Plot
figure;
errorbar(bin_centers, binned_perf, binned_sem, '-o', 'LineWidth', 2);
xlabel('Prestimulus "Engagement"');
ylabel('Behavioral Performance (Fraction Correct)');
ylim([0.5 1]);
title('Mouse’s Task Performance');
%
% performance across datasets
binned_perf_all = nan(num_bins, 24); % num_bins x num_datasets

for dataset = 1:24
    data = proj_norm_ctrl{dataset, celltype, 1}.context;
    trial_means = mean(data(:, frame_range), 2);
    correct = percent_correct{dataset};

    for b = 1:num_bins
        bin_idx = trial_means >= edges(b) & trial_means < edges(b+1);
        trials_in_bin = correct(bin_idx);

        if ~isempty(trials_in_bin)
            binned_perf_all(b, dataset) = mean(trials_in_bin);
        end
    end
end

binned_perf = nanmean(binned_perf_all, 2);
binned_sem = nanstd(binned_perf_all, 0, 2) ./ sqrt(sum(~isnan(binned_perf_all), 2));


figure;
errorbar(bin_centers, binned_perf, binned_sem, '-o', 'LineWidth', 2);
xlabel('Prestimulus "Engagement"');
ylabel('Behavioral Performance (Fraction Correct)');
ylim([0.5 1]);
title('Mouse’s Task Performance');
%%

% Parameters
pre_range = 50:59;     % prestimulus (engagement)
resp_range = 63:93;  % poststimulus (response)
num_bins = 10;

all_engagement = [];
all_response = [];

% Aggregate across datasets (one context at a time)
for dataset = 1:24
    data = proj{dataset,celltype,ctx}.stim; %proj_ctrl{dataset, celltype, 1}.sound; %proj{dataset,celltype,ctx}.stim; %proj_ctrl{dataset, celltype, 1}.sound; %proj{dataset,celltype,ctx}.stim; %proj{dataset,celltype,ctx}.stim; %proj_ctrl{dataset, celltype, 1}.sound; % context 1
    pre_mean = mean(data(:, pre_range), 2);   % engagement
    resp_mean = mean(data(:, resp_range), 2); % response to stim/sound

    all_engagement = [all_engagement; pre_mean];
    all_response = [all_response; resp_mean];
end

% Bin by engagement
edges = linspace(-1.5, 1.5, num_bins+1); %linspace(min(all_engagement), max(all_engagement), num_bins+1);
bin_centers = edges(1:end-1) + diff(edges)/2;
binned_resp = zeros(num_bins,1);
binned_resp_sem = zeros(num_bins,1);

for b = 1:num_bins
    bin_idx = all_engagement >= edges(b) & all_engagement < edges(b+1);
    vals = all_response(bin_idx);

    if ~isempty(vals)
        binned_resp(b) = mean(vals);
        binned_resp_sem(b) = std(vals) / sqrt(length(vals));
    else
        binned_resp(b) = NaN;
        binned_resp_sem(b) = NaN;
    end
end

% Plot
figure;
errorbar(bin_centers, binned_resp, binned_resp_sem, '-o', 'LineWidth', 2);
xlabel('Prestimulus "Engagement"');
ylabel('Neural Response to Sound/Stim');
title('Stimulus Response vs Engagement');

%% z score mean activity vs axis?
