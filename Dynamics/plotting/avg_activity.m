function [cel_avg,new_onsets,binss,original_onsets] = avg_activity (imaging_st,alignment,dynamics_info,active_passive,all_celltypes,plot_info,varargin)

for m = 1:length(imaging_st)
    m
    %peak_times_all = [];
    ex_imaging = imaging_st{1,m};
    if active_passive == 1
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30);
    else
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30,2);
    end
    [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);

    if ~isempty(dynamics_info.conditions)
        [all_conditions,~] = divide_trials_updated (ex_imaging,alignment.field_to_separate);
        aligned_imaging =  aligned_imaging(vertcat(all_conditions{dynamics_info.conditions,1}),:,:);
    end
    
    bin_size = dynamics_info.bin_size;
    binss = 1:bin_size:size(aligned_imaging,3)-bin_size;
    binned_data =[];
    for cel = 1:size(aligned_imaging,2)
        
    for b = 1:length(binss)
        if strcmp(alignment.data_type,'deconv')
            binned_data(:,cel,b) = sum(aligned_imaging(:,cel,binss(b):binss(b)+bin_size-1),3); %bin data
        else
            binned_data(:,cel,b) = mean(aligned_imaging(:,cel,binss(b):binss(b)+bin_size-1),3); %bin data
        end
    end
            


        % Load or generate your data
        aligned_trials = squeeze(binned_data(:,cel,:)); %gives trials x time!
        % Number of trials
        mean_across_trials = mean(aligned_trials, 1);
        cel_avg{m,cel} = mean_across_trials; %time
    end
    
end
event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
new_onsets = find(histcounts(event_onsets,binss));
original_onsets = event_onsets;


possible_celltypes = fieldnames(all_celltypes{1,1});
event_bins = [dynamics_info.new_onsets, binss(end)+1]; % add final bin for last interval
n_events = length(event_bins) - 1;
%define event edges (for turn use period before also)
for ev = 1:n_events
   in_event{ev} = event_bins(ev):event_bins(ev+1);
   if ev == 3
       in_event{ev} = event_bins(ev):[find(histcounts(100,dynamics_info.binss))];
   elseif ev == 4
       in_event{ev} = [find(histcounts(100,dynamics_info.binss))]+1:event_bins(ev+1);
   end
end
in_event{6} = in_event{6}(1:end-1);


mean_cat = {};
mean_cat_datasets = {};
for ce = 1:3
    temp = [];
    all_counts_events = [];
    all_counts_sounds_together = [];
    
    for m = 1:length(imaging_st)
        current_avg =  cat(1, cel_avg{m, all_celltypes{1,m}.(possible_celltypes{ce})}); %cells x frames
        temp = [temp;current_avg];
        mean_cat_datasets{ce,m} = current_avg;
        
    end
    
    mean_cat{ce} = temp;
    general_stats.(possible_celltypes{ce}) = utils.get_basic_stats(mean(temp,2)); %one number per neuron
    
end

celltype_avgs = [];
figure(779); clf; hold on;
offsets = [-0.25, 0, 0.25];  % shift for 3 cell types
bar_width = 0.20;            % width of bars
possible_tests = nchoosek(1:3,2);
for ev = 1:6
    for ce = 1:3
        temp2 = [];
        for m = 1:size(mean_cat_datasets,2)
            temp2 = [temp2 , mean(mean_cat_datasets{ce,m}(:,in_event{ev}),[1,2])'];  % [n_events x n_experiments]
        end
        celltype_avgs(:,ce) = temp2;
        field_name = strcat(possible_celltypes{ce},'event',num2str(ev),'_datasets');
        general_stats.(field_name) = utils.get_basic_stats(temp2);
        data_vec = temp2;
        data_vec = data_vec(~isnan(data_vec));  % remove missing
        if isempty(data_vec)
            continue
        end

        % Mean and SEM across experiments
        mean_val = mean(data_vec);
        sem_val  = std(data_vec) / sqrt(numel(data_vec));

        % X-position for this celltype/event
        x_pos = ev + offsets(ce);

        % Plot bar (white fill, colored edge)
        b = bar(x_pos, mean_val, bar_width, ...
            'FaceColor', plot_info.colors_celltypes(ce,:), ...
            'EdgeColor', plot_info.colors_celltypes(ce,:), ...
            'LineWidth', .1);

        % Add error bar
        errorbar(x_pos, mean_val, sem_val, ...
            'color', [0,0,0], ... %plot_info.colors_celltype(ce,:)
            'LineWidth', .5, 'CapSize', 2);
    end
    %do stats per epoch
    ct = 0;
    [KW.avg_celltypes_p_val,KW.avg_celltypes, KW.avg_celltypes] = kruskalwallis(celltype_avgs,[1:3],'off');
    for t = 1:length(possible_tests)     
        [p_cdf(t), observeddifference, effectsize] = permutationTest_updatedcb(celltype_avgs(:,possible_tests(t,1)), celltype_avgs(:,possible_tests(t,2)), 10000,'paired', 1);
%         [p_cdf(t),h] = signrank(boxplot_stats.all{1,possible_tests(t,1)}(:,ev), boxplot_stats.all{1,possible_tests(t,2)}(:,ev));
        if p_cdf(t) < 0.05/length(possible_tests) && KW.avg_celltypes_p_val < 0.05
            xline_vars(1) = ev + offsets(possible_tests(t,1)); 
            xline_vars(2) = ev + offsets(possible_tests(t,2)); 
            y_val = max([mean(celltype_avgs(:,1)),mean(celltype_avgs(:,2)), mean(celltype_avgs(:,3))]);
            xval = 0;  
            utils.plot_pval_star(xval, y_val+y_val*(.1+ct), p_cdf(t), xline_vars,0.005);
            ct = ct+0.1;
        end
    
        general_stats.p_bar_plot_all_sounds(ev,t) = p_cdf(t);
    end
end
general_stats.p_bar_test_all_sounds_avg = 'paired_permutation_test';
general_stats.KW_all_sounds_avg = KW;
xlabels = {'S1','S2','S3', plot_info.xlabel_events{[4,5,6]}};
set(gca, 'XTick', 1:6, 'XTickLabel', xlabels, ...
    'XTickLabelRotation', 45)
% ylabel({'Fraction of Neurons with';'Peak Activity'})
ylabel({'Mean Activity per Epoch'}) %Fraction of Neurons with Peak Activity%Fraction of Neurons Peaking per Epoch %Fraction of Neurons with Maximum Activity per Epoch
xlim([0.5 6 + 0.5])
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', [1,1,1.25,1.2]);
% set(gcf,'position',[100,100,250,250])
box off


info.savepath='W:/Connie/results/Bassi2025/fig1';
% save if needed
if ~isempty(info)
    mkdir(fullfile(info.savepath, 'frc_dynamics/'));
    
    exportgraphics(figure(779),fullfile(info.savepath, 'frc_dynamics/',sprintf('barplot_avg_activity_condition%s_nbins%d_%s.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size, alignment.data_type)), 'ContentType', 'vector')

    avg_dynamics_stats = general_stats;
    save(fullfile(info.savepath, 'frc_dynamics/',sprintf('stats_barplot_avg_activity_condition%s_nbins%d_%s.mat', mat2str(dynamics_info.conditions), dynamics_info.bin_size, alignment.data_type)),'avg_dynamics_stats')
end