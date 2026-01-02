function plot_red_silhouettes(red_silhouettes_structure,plot_info,save_data_directory)
all_sil = red_silhouettes_structure.all_sil;
all_silhouettes = red_silhouettes_structure.all_silhouettes;
total_pyr = red_silhouettes_structure.total_pyr;
%% make histogram of silhoutte scores across celltypes!
pv = find(all_sil(2,:)== 2);
som = find(all_sil(2,:)== 1);
figure(88);clf;
hold on
histogram(all_sil(1,som),'BinWidth',0.05,'FaceColor',plot_info.colors_celltype(2,:),'Normalization','probability'); 
histogram(all_sil(1,pv),'BinWidth',0.05,'FaceColor',plot_info.colors_celltype(3,:),'Normalization','probability'); 
hold off
set(gcf,'units','points','position',[100,100,100,100])
xlabel('Silhouette Scores')
% ylabel('Proportion')
xline(.7,'--','color',[.5 .5 .5]) %exclusion criteria line
legend('SOM','PV','','location','northwest','box','off')
utils.set_current_fig;



figure(89);clf;
hold on;
Violin({all_sil(1,som)},1,'QuartileStyle','none','ShowMedian',logical(0),'ViolinColor', {plot_info.colors_celltype(2,:)});Violin({all_sil(1,pv)},2,'QuartileStyle','none','ShowMedian',logical(0),'ViolinColor', {plot_info.colors_celltype(3,:)});hold off
ylabel('Silhouette Scores')
xticks([1,2])
xticklabels({'SOM','PV'})
box off
set(gcf,'units','points','position',[100,100,100,100])
yline(.7,'--','color',[.5 .5 .5])
utils.set_current_fig;

[red_stats.all] = utils.get_basic_stats(all_sil(1,:));
[red_stats.som] = utils.get_basic_stats(all_sil(1,som));
[red_stats.pv] = utils.get_basic_stats(all_sil(1,pv));

som_sem = red_stats.som.sd/sqrt(red_stats.som.n);
pv_sem = red_stats.pv.sd/sqrt(red_stats.pv.n);

red_stats.pv.sem = pv_sem;
red_stats.som.sem = som_sem;

p_val = ranksum(all_sil(1,som),all_sil(1,pv));
red_stats.p_val = p_val;

%make box plot of all neurons????
figure(94);clf;
for celltype= 1:2
    current_cells = find(all_sil(2,:)== celltype);
    hold on
    %SOM
    %set line width
    for c = current_cells
    jitter = (rand-.5) *.5;
%     plot(1+jitter, mean(all_silhouettes{m,1})  ,'o','MarkerFaceColor', plot_info.colors_celltype(2,:),0.2);
    scatter(celltype+jitter,all_sil(1,c), 30, ...
                        plot_info.colors_celltype(celltype+1,:), 'o', 'filled', ...
                        'MarkerFaceAlpha', 0.4)
    end
%     plot([celltype-.3,celltype+.3],[mean(all_sil(1,current_cells)),mean(all_sil(1,current_cells))],'LineWidth',1.5,'color','k');
    h = boxplot(all_sil(1,current_cells), 'position', celltype, 'width', .7, 'colors', 'k' ,'symbol', 'o'); %plot_info.colors_celltype(celltype+1,:)
    out_line = findobj(h, 'Tag', 'Outliers');
    set(out_line, 'Visible', 'off');
    hh = findobj('LineStyle','--','LineWidth',1); 
    set(h(1:6), 'LineStyle','-','LineWidth',1);

    ylim([0 1])
    yline(.7,'--','color',[.5 .5 .5])
    
    hold off
end
xlim([0,3])
xticks([1,2])
xticklabels({'SOM', 'PV'});
ylabel('Silhouette Score')
box off
set(gcf,'units','points','position',[100,100,100,100])
utils.set_current_fig;


%% make plots divided by datasets
n_mice = length(all_silhouettes);
figure(91);clf;
for celltype= 1:2
    hold on
    %SOM
    h = boxplot(cellfun(@nanmean ,{all_silhouettes{:,celltype}}), 'position', celltype, 'width', .7, 'colors',  plot_info.colors_celltype(celltype+1,:),'symbol', 'o');
    %set line width
    out_line = findobj(h, 'Tag', 'Outliers');
    set(out_line, 'Visible', 'off');
    hh = findobj('LineStyle','--','LineWidth',1); 
    set(h(1:6), 'LineStyle','-','LineWidth',1.5);
    for m = 1:n_mice
        jitter = (rand-.5) *.5;
    %     plot(1+jitter, mean(all_silhouettes{m,1})  ,'o','MarkerFaceColor', plot_info.colors_celltype(2,:),0.2);
        scatter(celltype+jitter, mean(all_silhouettes{m,1}), 30, ...
                            plot_info.colors_celltype(celltype+1,:), 'o', 'filled', ...
                            'MarkerFaceAlpha', 0.4)
    end
    ylim([.5 1])
    yline(.7,'--','color',[.5 .5 .5])
    
    hold off
end
xlim([0,3])
xticks([1,2])
xticklabels({'SOM', 'PV'});
ylabel('Silhouette Score')
box off
set(gcf,'units','points','position',[100,100,100,100])
utils.set_current_fig;

p_val = signrank(cellfun(@nanmean ,{all_silhouettes{:,1}}),cellfun(@nanmean ,{all_silhouettes{:,2}}));
red_stats.p_val_sign_datasets = p_val;

%get dataset stats!
for i =1:25; red_stats.dataset{i}.som = utils.get_basic_stats(all_silhouettes{i,1});end
for i =1:25; red_stats.dataset{i}.pv = utils.get_basic_stats(all_silhouettes{i,2});end
red_stats.dataset_means.pv = utils.get_basic_stats(cellfun(@mean,{all_silhouettes{:,2}}));
red_stats.dataset_means.som = utils.get_basic_stats(cellfun(@mean,{all_silhouettes{:,1}}));

figure(92);clf;
mouse_means = [cellfun(@length ,{all_silhouettes{:,1}});cellfun(@length ,{all_silhouettes{:,2}})];
for celltype= 1:2
    mean_cel = mean(cellfun(@length ,{all_silhouettes{:,celltype}}));
    err = std(cellfun(@length ,{all_silhouettes{:,celltype}})) / sqrt(length(all_silhouettes));
    hold on
    errorbar(celltype, mean_cel, err, 'o', ...
        'Color', plot_info.colors_celltype(celltype+1,:), ...
        'LineWidth', 1, 'MarkerSize', 2,'MarkerFaceColor', plot_info.colors_celltype(celltype+1,:));
    % Plot connected line for this mouse
    plot([1+.2,2-.2], mouse_means, '-', 'Color', ...
        [0.5,0.5,0.5, 0.3], 'LineWidth', 1)

end
xlim([0,3])
xticks([1,2])
xticklabels({'SOM', 'PV'});
box off
set(gcf,'units','points','position',[100,100,100,100])
ylabel('Cell Counts')
utils.set_current_fig;

%save stats about Ns per cell type
red_stats.count_stats.som.mean =  mean(cellfun(@length ,{all_silhouettes{:,1}}));
red_stats.count_stats.som.sem =  std(cellfun(@length ,{all_silhouettes{:,1}})) / sqrt(length(all_silhouettes));

red_stats.count_stats.pv.mean =  mean(cellfun(@length ,{all_silhouettes{:,2}}));
red_stats.count_stats.pv.sem =  std(cellfun(@length ,{all_silhouettes{:,2}})) / sqrt(length(all_silhouettes));

red_stats.count_stats.pyr.mean =  mean(total_pyr);
red_stats.count_stats.pyr.sem =  std(total_pyr)/sqrt(length(total_pyr));


if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('Silhouettes_scores_',num2str(length(info.mouse_date)));
    saveas(88,[image_string '_datasets.fig']);

    exportgraphics(figure(92),strcat('cell_counts_connected_lines_n',num2str(n_mice),'_datasets.pdf'), 'ContentType', 'vector');
    exportgraphics(figure(91),strcat('Silouette_scores_n',num2str(n_mice),'_datasets.pdf'), 'ContentType', 'vector');
    exportgraphics(figure(88),[image_string '_datasets_histogram.pdf'], 'ContentType', 'vector');
    exportgraphics(figure(89),[image_string '_datasets_violin.pdf'], 'ContentType', 'vector');
    exportgraphics(figure(94),[image_string '_datasets_scatterall_mean.pdf'], 'ContentType', 'vector');

    save('red_stats','red_stats');
end
