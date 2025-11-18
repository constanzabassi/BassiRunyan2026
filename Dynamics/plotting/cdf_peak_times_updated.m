function [ general_stats] =  cdf_peak_times_updated(max_cel_mode,dynamics_info,all_celltypes,plot_info,info,varargin)

binss = 1:length(dynamics_info.binss);
possible_celltypes = fieldnames(all_celltypes{1,1});
cat_max = {};
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

if nargin > 5
   num_nans = varargin{1,1};
else
   num_nans = 2;
end

figure(62); clf;
hold on;
cdf_cat_all = {};mean_cat = [];
for ce = 1:3
    cdf = [];
    cdf_cat = [];
    
    temp = [];
    hist_counts = []; % NEW: store hist counts per dataset
    all_counts_events = [];
    all_counts_sounds_together = [];
    
    for m = 1:size(max_cel_mode,1) 
        current_max = [max_cel_mode{m,all_celltypes{1,m}.(possible_celltypes{ce})}];
        temp = [temp,current_max];
         
        [cdf_temp,p1] = make_cdf(current_max,binss);
        cdf = [cdf; cdf_temp];
        cdf_cat = [cdf_cat, cdf_temp];
        
        % --- NEW: compute histogram for this dataset
        h_counts = histcounts(current_max, binss, 'Normalization', 'probability');
        hist_counts = [hist_counts; h_counts]; % accumulate rows [datasets x bins]

        % --New: compute fraction of peaks separated by ephocs
        all_counts = []; all_counts2 = [];
        for ev = 1:n_events
%             in_event = event_bins(ev):event_bins(ev+1);
            % Count how many peaks fell into each event bin
            counts_events = histcounts(current_max, in_event{ev});  % bin edges center on integers
            all_counts = [all_counts, sum(counts_events)/length(current_max)]; % accumulate rows [datasets x bins]
        end
        %put sounds together?
        for ev = 1:4
            if ev ==1
                counts_events = histcounts(current_max, [in_event{1:3}]);  % bin edges center on integers
            else
                counts_events = histcounts(current_max, in_event{ev+2});  % bin edges center on integers
            end
            all_counts2 = [all_counts2, sum(counts_events)/length(current_max)]; % accumulate rows [datasets x bins]
        end
        all_counts_events = [all_counts_events;all_counts];
        all_counts_sounds_together = [all_counts_sounds_together;all_counts2];

    end
    
    cat_max{ce} = temp;
    general_stats.(possible_celltypes{ce}) = utils.get_basic_stats(mean(cdf,1));
    
    % mean & SEM for CDF
    mean_cdf = mean(cdf,1,'omitnan');
    SEM_cdf = std(cdf,[],1,'omitnan') / sqrt(size(cdf,1));
    
    %mean across points to give me one value per dataset!
    mean_cdf_timepoints = mean(cdf,2,'omitnan');
    mean_cat = [mean_cat, mean_cdf_timepoints];
    name_field = strcat((possible_celltypes{ce}),'_perdataset');
    general_stats.(name_field) = utils.get_basic_stats(mean(cdf,2));
    general_stats.cdf.(possible_celltypes{ce}).mean_across_neurons_in_sec = utils.get_basic_stats(temp/30);%to get sec
    
    nan_insert_positions = [find(histcounts(101,dynamics_info.binss))];
    data_to_plot = include_nans(mean_cdf,num_nans, nan_insert_positions);
    SEM_to_plot = include_nans(SEM_cdf,num_nans, nan_insert_positions);
    
    a(ce) = shadedErrorBar(1:size(data_to_plot,2), data_to_plot, SEM_to_plot, ...
        'lineProps', {'color', plot_info.colors_celltype(ce,:), 'linewidth', 1.5});
    
    for i = 1:length(dynamics_info.new_onsets)
        xline(dynamics_info.new_onsets(i),'--k','LineWidth',.5);
    end
    
    cdf_all{ce} = mean_cdf;
    cdf_cat_all{ce} = cdf_cat;
    
    mean_hist = mean(hist_counts,1,'omitnan');
    SEM_hist = std(hist_counts,[],1,'omitnan') / sqrt(size(hist_counts,1));

    mean_boxplot = mean(all_counts_events,1);
    SEM_boxplot = std(all_counts_events,[],1) / sqrt(size(all_counts_events,1));
    boxplot_stats.mean{ce} = mean_boxplot;
    boxplot_stats.SEM_boxplot{ce} = SEM_boxplot;
    boxplot_stats.all{ce} = all_counts_events;
    
    %do the same for sounds together
    mean_boxplot = mean(all_counts_sounds_together,1);
    SEM_boxplot = std(all_counts_sounds_together,[],1) / sqrt(size(all_counts_sounds_together,1));
    boxplot_stats2.mean{ce} = mean_boxplot;
    boxplot_stats2.SEM_boxplot{ce} = SEM_boxplot;
    boxplot_stats2.all{ce} = all_counts_sounds_together;

    hist_stats.mean{ce} = mean_hist;
    hist_stats.SEM{ce} = SEM_hist;
    general_stats.hist.(possible_celltypes{ce}) = hist_stats;
    utils.place_text_labels(plot_info.celltype_names{ce}, plot_info.colors_celltype(ce,:), 0.3+(0.1 * ce),  7,'topright', (length(cdf_cat)-length(cdf_cat)*.2)*.001);  %- length(cdf_cat)-length(cdf_cat)*.1
%     utils.place_text_labels(plot_info.celltype_names{ce}, plot_info.colors_celltype(ce,:), 0.3, 'FontSize', 8,'UseTop',1,'yoffset',0.3+(0.1 * ce)); %, 8, (0.1 * ce));

end

hold off
ylim([0 1])
xlim([1 binss(end)])
ylabel({'Cumulative Fraction of';'Peak Times'})
set(gca,'fontsize',7)
set(gca,'box','off','xtick',[])

% legend([a(1).mainLine a(2).mainLine a(3).mainLine],'PYR','SOM','PV','Location','southeast','box','off');
if n_events>4
    adjusted_event_onsets = dynamics_info.original_onsets;
    nan_insert_positions = [find(histcounts(101,binss))]; %, new_onsets(5)-num_nans
    for i = 1:length(nan_insert_positions)
        shift = num_nans * i;
        adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) = adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) + num_nans -1;
    end
else
    adjusted_event_onsets = dynamics_info.original_onsets;
end
new_onsets = find(histcounts(adjusted_event_onsets,dynamics_info.binss));
set(gca,'xtick',new_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);
% set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', [1,1,1.2,1.2]);
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', [1,1,1.2*2,1.2]);


% set(gcf,'position',[100,100,175,178])
utils.set_current_fig(7);addScaleBar(gca, 30, "1 sec")

% Add significance test...
%permutation test
possible_tests = nchoosek(1:3,2);
group = [...
    repmat({'celltype1'}, 1, numel(cat_max{1,1})), ...
    repmat({'celltype2'}, 1, numel(cat_max{1,2})), ...
    repmat({'celltype3'}, 1, numel(cat_max{1,3})) ...
    ];
% [KW.peak_celltypes_p_val,KW.tbl, KW.stats_cell] = kruskalwallis(cell2mat(cdf_cat_all')',[1:3],'off');
% [KW.peak_celltypes_p_val,KW.tbl, KW.stats_cell] = kruskalwallis(mean_cat,[1:3],'off');
[KW.cdf_peak_celltypes_p_val,KW.cdf_tbl, KW.cdf_stats_cell] = kruskalwallis(cell2mat(cat_max),group,'off');


ct = 0;
for t = 1:length(possible_tests)
%     [p_cdf(t), observeddifference, effectsize] = permutationTest_updatedcb(cdf_cat_all{1,possible_tests(t,1)}, cdf_cat_all{1,possible_tests(t,2)}, 10000,'paired',1);
%     [p_cdf(t), observeddifference, effectsize] = permutationTest_updatedcb(mean_cat(:,possible_tests(t,1)), mean_cat(:,possible_tests(t,2)), 10000,'paired',1);
    [p_cdf(t), observeddifference, effectsize] = permutationTest_updatedcb(cat_max{1,possible_tests(t,1)}, cat_max{1,possible_tests(t,2)}, 10000,'paired',0);

    if p_cdf(t) < 0.05/length(possible_tests) && KW.cdf_peak_celltypes_p_val < 0.05
        xline_vars(1) = binss(find(cdf_all{1,possible_tests(t,1)} > 0.86+ct,1,'first')); 
        xline_vars(2) = binss(find(cdf_all{1,possible_tests(t,2)} > 0.86+ct,1,'first')); 
        xval = 0;  
        utils.plot_pval_star(xval, 0.87+ct, p_cdf(t), xline_vars,0.01)
        ct = ct+0.05;
    end

    general_stats.p_cdf(t) = p_cdf(t);
    general_stats.cdf_observeddifference(t) = observeddifference/30;
    general_stats.cdf_effectsize(t) = effectsize;
end
general_stats.cdf_test = 'unpaired permutation across all neurons';
general_stats.cdf_possible_tests = possible_tests;
%% === NEW FIGURE for HISTOGRAM ===
figure(63); clf; hold on;
for ce = 1:3
    nan_insert_positions = [find(histcounts(101,dynamics_info.binss))];
    data_to_plot = include_nans(hist_stats.mean{ce},num_nans, nan_insert_positions);
    SEM_to_plot = include_nans(hist_stats.SEM{ce},num_nans, nan_insert_positions);
    b = shadedErrorBar(1:size(data_to_plot,2),data_to_plot, SEM_to_plot, ...
        'lineProps', {'color', plot_info.colors_celltype(ce,:), 'linewidth', 1});
    utils.place_text_labels(plot_info.celltype_names{ce}, plot_info.colors_celltype(ce,:), 0.3+(0.1 * ce),  7,'topright', (binss(end)-binss(end)*.2)*.001);  %- length(cdf_cat)-length(cdf_cat)*.1
%     utils.place_text_labels(plot_info.celltype_names{ce}, plot_info.colors_celltype(ce,:), 0.3, 'FontSize', 8,'UseTop',0,'yoffset',.8-(0.1 * ce),'ylim',[0,.1]);
end
for i = 1:length(dynamics_info.new_onsets)
    xline(dynamics_info.new_onsets(i),'--k','LineWidth',1);
end
ylabel('Fraction of Peak Times');
set(gca,'fontsize',14);
set(gca,'box','off');

% legend('PYR','SOM','PV','Location','northeast','box','off');
xlim([1 binss(end)]);
set(gca,'xtick',dynamics_info.new_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);
set(gcf,'position',[100,100,250,250])
utils.set_current_fig;

%histogram without shaded error bar
figure(64); clf; hold on;
for ce = 1:3
    nan_insert_positions = [find(histcounts(101,dynamics_info.binss))];
    data_to_plot = include_nans(hist_stats.mean{ce},num_nans, nan_insert_positions);
    plot(data_to_plot,'color', plot_info.colors_celltype(ce,:), 'linewidth', .5)
    utils.place_text_labels(plot_info.celltype_names{ce}, plot_info.colors_celltype(ce,:), 0.3+(0.1 * ce),  7,'topright', (binss(end)-binss(end)*.2)*.001);  %- length(cdf_cat)-length(cdf_cat)*.1
%     utils.place_text_labels(plot_info.celltype_names{ce}, plot_info.colors_celltype(ce,:), 0.3, 'FontSize', 8,'UseTop',0,'yoffset',.8-(0.1 * ce),'ylim',[0,.1]);
end
for i = 1:length(dynamics_info.new_onsets)
    xline(dynamics_info.new_onsets(i),'--k','LineWidth',.5);
end
ylabel('Fraction of Peak Times');
set(gca,'fontsize',14);
set(gca,'box','off');

% legend('PYR','SOM','PV','Location','northeast','box','off');
xlim([1 binss(end)]);
set(gca,'xtick',dynamics_info.new_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);
set(gcf,'position',[100,100,250,250])
utils.set_current_fig;


% %% === NEW FIGURE for BOX PLOTS of peak times per event ===
% % === FRACTION OF NEURONS WITH PEAKS IN EACH EVENT WINDOW (for boxplot) ===
% % === BOXPLOT OF FRACTION OF NEURONS WITH PEAKS IN EACH EVENT WINDOW ===
% figure(77); clf; hold on;
% offsets = [-0.25, 0, 0.25];  % shift for 3 cell types
% 
% for ce = 1:3
%     this_data =boxplot_stats.all{ce}';  % [n_events x n_experiments]
%     for ev = 1:n_events
%         data_vec = this_data(ev, :);
%         data_vec = data_vec(~isnan(data_vec));  % remove missing
%         if isempty(data_vec)
%             continue
%         end
%         x_pos = ev + offsets(ce);
%         h = boxplot(data_vec', 'positions', x_pos, 'widths', 0.2, 'Colors', plot_info.colors_celltype(ce,:), 'Symbol', '');
% 
%         %set line width
%         hh = findobj('LineStyle','--','LineWidth',0.5); 
%         set(h(1:6), 'LineStyle','-','LineWidth',1.1);
%     end
% end
% 
% set(gca, 'XTick', 1:n_events, 'XTickLabel', plot_info.xlabel_events, 'XTickLabelRotation', 45)
% ylabel({'Fraction of Neurons with';'Peak Activity'})
% xlim([0.5 n_events + 0.5])
% set(gcf,'position',[100,100,250,250])
% box off
% utils.set_current_fig(10);
% ylim([0,.7])

%% === NEW FIGURE for BAR PLOTS of peak times per event ===
% === FRACTION OF NEURONS WITH PEAKS IN EACH EVENT WINDOW (for barplot) ===
figure(77); clf; hold on;
offsets = [-0.25, 0, 0.25];  % shift for 3 cell types
bar_width = 0.20;            % width of bars

for ce = 1:3
    this_data = boxplot_stats.all{ce}';  % [n_events x n_experiments]
    for ev = 1:n_events
        data_vec = this_data(ev, :);
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
            'FaceColor', [1,1,1], ...
            'EdgeColor', plot_info.colors_celltype(ce,:), ...
            'LineWidth', 1);

        % Add error bar
        errorbar(x_pos, mean_val, sem_val, ...
            'color', plot_info.colors_celltype(ce,:), ...
            'LineWidth', 1, 'CapSize', 4);
    end
end

set(gca, 'XTick', 1:n_events, 'XTickLabel', plot_info.xlabel_events, ...
    'XTickLabelRotation', 45)
ylabel({'Fraction of Neurons Peaking'}) %Fraction of Neurons with Peak Activity%Fraction of Neurons Peaking per Epoch %Fraction of Neurons with Maximum Activity per Epoch
xlim([0.5 n_events + 0.5])
set(gcf,'position',[100,100,250,250])
box off
utils.set_current_fig;


figure(78); clf; hold on;
offsets = [-0.25, 0, 0.25];  % shift for 3 cell types
bar_width = 0.20;            % width of bars

for ev = 1:4
    for ce = 1:3
        this_data = boxplot_stats2.all{ce}';  % [n_events x n_experiments]
        data_vec = this_data(ev, :);
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
            'FaceColor', plot_info.colors_celltype(ce,:), ...
            'EdgeColor', plot_info.colors_celltype(ce,:), ...
            'LineWidth', .1);

        % Add error bar
        errorbar(x_pos, mean_val, sem_val, ...
            'color', [0,0,0], ... %plot_info.colors_celltype(ce,:)
            'LineWidth', .5, 'CapSize', 2);
    end
    %do stats per epoch
    ct = 0;
    data_to_test = [boxplot_stats2.all{1,1}(:,ev),boxplot_stats2.all{1,2}(:,ev),boxplot_stats2.all{1,3}(:,ev)];
    [KW.fraction_celltypes_p_val,KW.fraction_tbl, KW.fraction_stats_cell] = kruskalwallis(data_to_test,[1:3],'off');
    for t = 1:length(possible_tests)     
        [p_cdf(t), observeddifference, effectsize] = permutationTest_updatedcb(boxplot_stats2.all{1,possible_tests(t,1)}(:,ev), boxplot_stats2.all{1,possible_tests(t,2)}(:,ev), 10000,'paired', 1);
%         [p_cdf(t),h] = signrank(boxplot_stats2.all{1,possible_tests(t,1)}(:,ev), boxplot_stats2.all{1,possible_tests(t,2)}(:,ev));
        if p_cdf(t) < 0.05/length(possible_tests) && KW.fraction_celltypes_p_val < 0.05
            xline_vars(1) = ev + offsets(possible_tests(t,1)); 
            xline_vars(2) = ev + offsets(possible_tests(t,2)); 
            y_val = max([mean(boxplot_stats2.all{1,1}(:,ev)), mean(boxplot_stats2.all{1,2}(:,ev)),mean(boxplot_stats2.all{1,3}(:,ev))]+0.02);
            xval = 0;  
            utils.plot_pval_star(xval, y_val+y_val*(.1+ct), p_cdf(t), xline_vars,0.005);
            ct = ct+0.1;
        end
    
        general_stats.p_bar_plot(ev,t) = p_cdf(t);
    end
end
general_stats.p_bar_test = 'paired_permutation_test';
general_stats.KW = KW;
xlabels = {'sounds', plot_info.xlabel_events{[4,5,6]}};
set(gca, 'XTick', 1:4, 'XTickLabel', xlabels, ...
    'XTickLabelRotation', 45)
% ylabel({'Fraction of Neurons with';'Peak Activity'})
ylabel({'Fraction of Neurons Peaking'}) %Fraction of Neurons with Peak Activity%Fraction of Neurons Peaking per Epoch %Fraction of Neurons with Maximum Activity per Epoch
xlim([0.5 4 + 0.5])
ylim([0,.55])
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', [1,1,1.25,1.2]);
% set(gcf,'position',[100,100,250,250])
box off
utils.set_current_fig(7);


figure(79); clf; hold on;
offsets = [-0.25, 0, 0.25];  % shift for 3 cell types
bar_width = 0.20;            % width of bars

for ev = 1:6
    for ce = 1:3
        this_data = boxplot_stats.all{ce}';  % [n_events x n_experiments]
        data_vec = this_data(ev, :);
        data_vec = data_vec(~isnan(data_vec));  % remove missing
        if isempty(data_vec)
            continue
        end
        field_name = strcat('event_',num2str(ev));
        general_stats.bar_plot.(field_name).(possible_celltypes{ce}) = utils.get_basic_stats(data_vec);


        % Mean and SEM across experiments
        mean_val = mean(data_vec);
        sem_val  = std(data_vec) / sqrt(numel(data_vec));

        % X-position for this celltype/event
        x_pos = ev + offsets(ce);

        % Plot bar (white fill, colored edge)
        b = bar(x_pos, mean_val, bar_width, ...
            'FaceColor', plot_info.colors_celltype(ce,:), ...
            'EdgeColor', plot_info.colors_celltype(ce,:), ...
            'LineWidth', .1);

        % Add error bar
        errorbar(x_pos, mean_val, sem_val, ...
            'color', [0,0,0], ... %plot_info.colors_celltype(ce,:)
            'LineWidth', .5, 'CapSize', 2);
    end
    %do stats per epoch
    ct = 0;
    data_to_test = [boxplot_stats.all{1,1}(:,ev),boxplot_stats.all{1,2}(:,ev),boxplot_stats.all{1,3}(:,ev)];
    [KW.fraction_celltypes_p_val,KW.fraction_tbl, KW.fraction_stats_cell] = kruskalwallis(data_to_test,[1:3],'off');
    for t = 1:length(possible_tests)     
        [p_cdf(t), observeddifference, effectsize] = permutationTest_updatedcb(boxplot_stats.all{1,possible_tests(t,1)}(:,ev), boxplot_stats.all{1,possible_tests(t,2)}(:,ev), 10000,'paired', 1);
%         [p_cdf(t),h] = signrank(boxplot_stats.all{1,possible_tests(t,1)}(:,ev), boxplot_stats.all{1,possible_tests(t,2)}(:,ev));
        if p_cdf(t) < 0.05/length(possible_tests) && KW.fraction_celltypes_p_val < 0.05
            xline_vars(1) = ev + offsets(possible_tests(t,1)); 
            xline_vars(2) = ev + offsets(possible_tests(t,2)); 
            y_val = max([mean(boxplot_stats.all{1,1}(:,ev)), mean(boxplot_stats.all{1,2}(:,ev)),mean(boxplot_stats.all{1,3}(:,ev))]+0.02);
            xval = 0;  
            utils.plot_pval_star(xval, y_val+y_val*(.1+ct), p_cdf(t), xline_vars,0.005);
            ct = ct+0.1;
        end
    
        general_stats.p_bar_plot_all_sounds(ev,t) = p_cdf(t);
        general_stats.bar_plot_observeddifference(ev,t) = observeddifference;
        general_stats.bar_plot_effectsize(ev,t) = effectsize;
    end
end
general_stats.p_bar_test_all_sounds = 'paired_permutation_test';
general_stats.KW_all_sounds = KW;
xlabels = {'S1','S2','S3', plot_info.xlabel_events{[4,5,6]}};
set(gca, 'XTick', 1:6, 'XTickLabel', xlabels, ...
    'XTickLabelRotation', 45)
% ylabel({'Fraction of Neurons with';'Peak Activity'})
ylabel({'Fraction of Neurons Peaking'}) %Fraction of Neurons with Peak Activity%Fraction of Neurons Peaking per Epoch %Fraction of Neurons with Maximum Activity per Epoch
xlim([0.5 6 + 0.5])
ylim([0,.55])
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', [1,1,1.25,1.2]);
% set(gcf,'position',[100,100,250,250])
box off
utils.set_current_fig(7);


% save if needed
if ~isempty(info)
    mkdir(fullfile(info.savepath, 'frc_dynamics/'));
    
%     saveas(62, sprintf('cdf_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size));
%     saveas(63, sprintf('hist_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size));
    exportgraphics(figure(62),fullfile(info.savepath, 'frc_dynamics/',sprintf('cdf_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')
    exportgraphics(figure(63),fullfile(info.savepath, 'frc_dynamics/',sprintf('hist_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')
    exportgraphics(figure(64),fullfile(info.savepath, 'frc_dynamics/',sprintf('hist_max_peak_noSEM_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')
%     exportgraphics(figure(77),fullfile(info.savepath, 'frc_dynamics/',sprintf('barplot_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')
    exportgraphics(figure(78),fullfile(info.savepath, 'frc_dynamics/',sprintf('barplot_soundscombined_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')
    exportgraphics(figure(79),fullfile(info.savepath, 'frc_dynamics/',sprintf('barplot_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')

    cdf_dynamics_stats = general_stats;
    save(fullfile(info.savepath, 'frc_dynamics/',sprintf('cdf_max_peak_condition%s_nbins%d.mat', mat2str(dynamics_info.conditions), dynamics_info.bin_size)),'cdf_dynamics_stats')

    set(gca(figure(79)), 'Units', 'inches', 'Position', [1,1,1.25,.81]); %new height
    ylabel({'Fraction of';'Neurons Peaking'}) %Fraction of Neurons with Peak Activity%Fraction of Neurons Peaking per Epoch %Fraction of Neurons with Maximum Activity per Epoch

    set(gca(figure(62)),  'Units', 'inches', 'Position', [1,1,1.2*2,.81]); %.81 = height of 1.125
    exportgraphics(figure(62),fullfile(info.savepath, 'frc_dynamics/',sprintf('smaller_cdf_max_peak_noSEM_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')
    exportgraphics(figure(79),fullfile(info.savepath, 'frc_dynamics/',sprintf('smaller_barplot_max_peak_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')

    set(gca(figure(62)),  'Units', 'inches', 'Position', [1,1,1.25,1.2]); %.81 = height of 1.125
    adjusted_event_onsets(4) = adjusted_event_onsets(4)-5;addScaleBar(gca, 30, "1 sec")
    addScaleBar(gca, 30, "1 sec")
    set(gca,'xtick',adjusted_event_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);

    exportgraphics(figure(62),fullfile(info.savepath, 'frc_dynamics/',sprintf('smaller_cdf_max_peak_noSEM_condition%s_nbins%d.pdf', mat2str(dynamics_info.conditions), dynamics_info.bin_size)), 'ContentType', 'vector')

end
