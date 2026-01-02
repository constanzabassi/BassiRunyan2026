function [silhouette_struct] = get_red_silhouettes(info,save_dir)
all_sil = []; missing_data =[];
all_silhouettes = {}; total_pyr = [];
for dataset_index = 1:length(info.mouse_date)
    dataset_index
    temp = [];
    datasets_id = info.mouse_date(dataset_index)
    datasets_id = datasets_id{1,1};
    ss = info.serverid(dataset_index);
    ss = ss {1,1};
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(datasets_id),'/dual_red/clustering_info.mat')); %load clustering info!

    red_vects = find(clustering_info.redvect); 
    celltype_ids = clustering_info.cellids(red_vects);
    if length(clustering_info.used_silhouettes) == length(celltype_ids)
        temp(1,:)= clustering_info.used_silhouettes;
        temp(2,:) = celltype_ids;
        all_sil = [all_sil, temp];
    else %mouse that had uncertain cells that were deleted!
%         allredvect = clustering_info.redvect;
%         allredvect(unique([clustering_info.uncertain])) = 1;
%         new_ids = find(ismember(find(allredvect),red_vects)); %this should match the number of actually used cells
% 
%         temp(1,:)= clustering_info.used_silhouettes(new_ids);
%         temp(2,:) = celltype_ids;
%         all_sil = [all_sil, temp];
        % Given `redvect` after removing uncertain values (length 62)
        redvect = find(clustering_info.redvect); % Your filtered redvect
        
        % Uncertain values to locate in the original sequence
        uncertain_positions = clustering_info.uncertain; % Example: [218, 251, 261]
        if contains(datasets_id,'2023-07-07')
            uncertain_positions = uncertain_positions(2:3); %union(clustering_info.uncertain,clustering_info.excluded);
        elseif contains(datasets_id,'2023-03-31')
            uncertain_positions = uncertain_positions(2);
        end
        % Find where these uncertain values **would have been** in `redvect`
            indices_to_remove = zeros(size(uncertain_positions)); % Preallocate
        
        
        for i = 1:length(uncertain_positions)
            % Find the first index where redvect surpasses the uncertain value
            idx = find(redvect >= uncertain_positions(i), 1, 'first');
            
            if isempty(idx)
                indices_to_remove(i) = length(redvect) + 1; % If it's larger than all elements
            else
                indices_to_remove(i) = idx;
                
                % If multiple uncertain values lie between, increment the indices
                if i > 1 && indices_to_remove(i) == (indices_to_remove(i-1))
                    indices_to_remove(i:end) = indices_to_remove(i:end) + 1;
                end
            end
        end
        clustering_info.used_silhouettes(indices_to_remove) = [];
        temp(1,:)= clustering_info.used_silhouettes;
        temp(2,:) = celltype_ids;
        all_sil = [all_sil, temp];
        
        missing_data = [missing_data,info.mouse_date(dataset_index)];
    end
    som_indices = find(temp(2,:) == 1);
    pv_indices = find(temp(2,:) == 2);
    all_silhouettes{dataset_index,1} = temp(1,som_indices); %SOM
    all_silhouettes{dataset_index,2} = temp(1,pv_indices); %PV
    total_pyr =[ total_pyr ,length(find(clustering_info.cellids == 0))];

end

silhouette_struct.all_silhouettes = all_silhouettes;
silhouette_struct.total_pyr = total_pyr;
silhouette_struct.all_sil = all_sil;
if ~isempty(save_dir)
    save(fullfile(save_dir,'silhouette_struct.mat'),'silhouette_struct','-v7.3')
end


% % %% get silhouette scores across all datasets!
% % function [all_sil,missing_data,all_silhouettes,total_pyr] = get_red_silhouettes(info,plot_info,save_data_directory)
% % all_sil = []; missing_data =[];
% % all_silhouettes = {}; total_pyr = [];
% % for dataset_index = 1:length(info.mouse_date)
% %     dataset_index
% %     temp = [];
% %     datasets_id = info.mouse_date(dataset_index)
% %     datasets_id = datasets_id{1,1};
% %     ss = info.serverid(dataset_index);
% %     ss = ss {1,1};
% %     load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(datasets_id),'/dual_red/clustering_info.mat')); %load clustering info!
% % 
% %     red_vects = find(clustering_info.redvect); 
% %     celltype_ids = clustering_info.cellids(red_vects);
% %     if length(clustering_info.used_silhouettes) == length(celltype_ids)
% %         temp(1,:)= clustering_info.used_silhouettes;
% %         temp(2,:) = celltype_ids;
% %         all_sil = [all_sil, temp];
% %     else %mouse that had uncertain cells that were deleted!
% % %         allredvect = clustering_info.redvect;
% % %         allredvect(unique([clustering_info.uncertain])) = 1;
% % %         new_ids = find(ismember(find(allredvect),red_vects)); %this should match the number of actually used cells
% % % 
% % %         temp(1,:)= clustering_info.used_silhouettes(new_ids);
% % %         temp(2,:) = celltype_ids;
% % %         all_sil = [all_sil, temp];
% %         % Given `redvect` after removing uncertain values (length 62)
% %         redvect = find(clustering_info.redvect); % Your filtered redvect
% %         
% %         % Uncertain values to locate in the original sequence
% %         uncertain_positions = clustering_info.uncertain; % Example: [218, 251, 261]
% %         if contains(datasets_id,'2023-07-07')
% %             uncertain_positions = uncertain_positions(2:3); %union(clustering_info.uncertain,clustering_info.excluded);
% %         elseif contains(datasets_id,'2023-03-31')
% %             uncertain_positions = uncertain_positions(2);
% %         end
% %         % Find where these uncertain values **would have been** in `redvect`
% %             indices_to_remove = zeros(size(uncertain_positions)); % Preallocate
% %         
% %         
% %         for i = 1:length(uncertain_positions)
% %             % Find the first index where redvect surpasses the uncertain value
% %             idx = find(redvect >= uncertain_positions(i), 1, 'first');
% %             
% %             if isempty(idx)
% %                 indices_to_remove(i) = length(redvect) + 1; % If it's larger than all elements
% %             else
% %                 indices_to_remove(i) = idx;
% %                 
% %                 % If multiple uncertain values lie between, increment the indices
% %                 if i > 1 && indices_to_remove(i) == (indices_to_remove(i-1))
% %                     indices_to_remove(i:end) = indices_to_remove(i:end) + 1;
% %                 end
% %             end
% %         end
% %         clustering_info.used_silhouettes(indices_to_remove) = [];
% %         temp(1,:)= clustering_info.used_silhouettes;
% %         temp(2,:) = celltype_ids;
% %         all_sil = [all_sil, temp];
% %         
% %         missing_data = [missing_data,info.mouse_date(dataset_index)];
% %     end
% %     som_indices = find(temp(2,:) == 1);
% %     pv_indices = find(temp(2,:) == 2);
% %     all_silhouettes{dataset_index,1} = temp(1,som_indices); %SOM
% %     all_silhouettes{dataset_index,2} = temp(1,pv_indices); %PV
% %     total_pyr =[ total_pyr ,length(find(clustering_info.cellids == 0))];
% % 
% % end
% % 
% % %% make histogram of silhoutte scores across celltypes!
% % pv = find(all_sil(2,:)== 2);
% % som = find(all_sil(2,:)== 1);
% % figure(88);clf;
% % hold on
% % histogram(all_sil(1,som),'BinWidth',0.05,'FaceColor',plot_info.colors_celltype(2,:),'Normalization','probability'); 
% % histogram(all_sil(1,pv),'BinWidth',0.05,'FaceColor',plot_info.colors_celltype(3,:),'Normalization','probability'); 
% % hold off
% % set(gcf,'units','points','position',[100,100,100,100])
% % xlabel('Silhouette Scores')
% % % ylabel('Proportion')
% % xline(.7,'--','color',[.5 .5 .5]) %exclusion criteria line
% % legend('SOM','PV','','location','northwest','box','off')
% % utils.set_current_fig;
% % 
% % 
% % 
% % figure(89);clf;
% % hold on;
% % Violin({all_sil(1,som)},1,'QuartileStyle','none','ShowMedian',logical(0),'ViolinColor', {plot_info.colors_celltype(2,:)});Violin({all_sil(1,pv)},2,'QuartileStyle','none','ShowMedian',logical(0),'ViolinColor', {plot_info.colors_celltype(3,:)});hold off
% % ylabel('Silhouette Scores')
% % xticks([1,2])
% % xticklabels({'SOM','PV'})
% % box off
% % set(gcf,'units','points','position',[100,100,100,100])
% % yline(.7,'--','color',[.5 .5 .5])
% % utils.set_current_fig;
% % 
% % [red_stats.all] = utils.get_basic_stats(all_sil(1,:));
% % [red_stats.som] = utils.get_basic_stats(all_sil(1,som));
% % [red_stats.pv] = utils.get_basic_stats(all_sil(1,pv));
% % 
% % som_sem = red_stats.som.sd/sqrt(red_stats.som.n);
% % pv_sem = red_stats.pv.sd/sqrt(red_stats.pv.n);
% % 
% % red_stats.pv.sem = pv_sem;
% % red_stats.som.sem = som_sem;
% % 
% % p_val = ranksum(all_sil(1,som),all_sil(1,pv));
% % red_stats.p_val = p_val;
% % 
% % %make box plot of all neurons????
% % figure(94);clf;
% % for celltype= 1:2
% %     current_cells = find(all_sil(2,:)== celltype);
% %     hold on
% %     %SOM
% %     %set line width
% %     for c = current_cells
% %     jitter = (rand-.5) *.5;
% % %     plot(1+jitter, mean(all_silhouettes{m,1})  ,'o','MarkerFaceColor', plot_info.colors_celltype(2,:),0.2);
% %     scatter(celltype+jitter,all_sil(1,c), 30, ...
% %                         plot_info.colors_celltype(celltype+1,:), 'o', 'filled', ...
% %                         'MarkerFaceAlpha', 0.4)
% %     end
% % %     plot([celltype-.3,celltype+.3],[mean(all_sil(1,current_cells)),mean(all_sil(1,current_cells))],'LineWidth',1.5,'color','k');
% %     h = boxplot(all_sil(1,current_cells), 'position', celltype, 'width', .7, 'colors', 'k' ,'symbol', 'o'); %plot_info.colors_celltype(celltype+1,:)
% %     out_line = findobj(h, 'Tag', 'Outliers');
% %     set(out_line, 'Visible', 'off');
% %     hh = findobj('LineStyle','--','LineWidth',1); 
% %     set(h(1:6), 'LineStyle','-','LineWidth',1);
% % 
% %     ylim([0 1])
% %     yline(.7,'--','color',[.5 .5 .5])
% %     
% %     hold off
% % end
% % xlim([0,3])
% % xticks([1,2])
% % xticklabels({'SOM', 'PV'});
% % ylabel('Silhouette Score')
% % box off
% % set(gcf,'units','points','position',[100,100,100,100])
% % utils.set_current_fig;
% % 
% % 
% % figure(90);clf;
% % hold on;
% % 
% % x_values = 1:2;  % x-values for plots
% % 
% % scatter(1,mean(all_sil(1,som)),'filled','SizeData',60, 'LineWidth', 1, 'MarkerEdgeColor', plot_info.colors_celltype(2,:), 'Color', plot_info.colors_celltype(2,:));  % som
% % scatter(2,mean(all_sil(1,pv)), 'filled','SizeData',60, 'LineWidth', 1, 'MarkerEdgeColor', plot_info.colors_celltype(3,:), 'Color', plot_info.colors_celltype(3,:));  % pv
% % 
% % errorbar(1, mean(all_sil(1,som)), som_sem, 'o', 'MarkerSize', 10, 'MarkerEdgeColor',plot_info.colors_celltype(2,:), 'Color', plot_info.colors_celltype(2,:));  % som
% % errorbar(2, mean(all_sil(1,pv)), pv_sem, 'o', 'MarkerSize', 10, 'MarkerEdgeColor', plot_info.colors_celltype(3,:), 'Color', plot_info.colors_celltype(3,:));  % pv
% % 
% % 
% % % if p_val< 0.05
% % %     xline_vars = 1:2;   
% % %     y_val = max(all_sil(1,:));
% % %     plot_pval_star(0, y_val+.1, p_val, xline_vars,0.01)
% % % end
% % 
% % ylabel('Silhouettes Scores')
% % xticks([1,2])
% % xticklabels({'SOM','PV'})
% % xlim([0 3])
% % set(gcf,'units','points','position',[100,100,100,100])
% % utils.set_current_fig;
% % 
% % %% make plots divided by datasets
% % n_mice = length(all_silhouettes);
% % figure(91);clf;
% % for celltype= 1:2
% %     hold on
% %     %SOM
% %     h = boxplot(cellfun(@nanmean ,{all_silhouettes{:,celltype}}), 'position', celltype, 'width', .7, 'colors',  plot_info.colors_celltype(celltype+1,:),'symbol', 'o');
% %     %set line width
% %     out_line = findobj(h, 'Tag', 'Outliers');
% %     set(out_line, 'Visible', 'off');
% %     hh = findobj('LineStyle','--','LineWidth',1); 
% %     set(h(1:6), 'LineStyle','-','LineWidth',1.5);
% %     for m = 1:n_mice
% %         jitter = (rand-.5) *.5;
% %     %     plot(1+jitter, mean(all_silhouettes{m,1})  ,'o','MarkerFaceColor', plot_info.colors_celltype(2,:),0.2);
% %         scatter(celltype+jitter, mean(all_silhouettes{m,1}), 30, ...
% %                             plot_info.colors_celltype(celltype+1,:), 'o', 'filled', ...
% %                             'MarkerFaceAlpha', 0.4)
% %     end
% %     ylim([.5 1])
% %     yline(.7,'--','color',[.5 .5 .5])
% %     
% %     hold off
% % end
% % xlim([0,3])
% % xticks([1,2])
% % xticklabels({'SOM', 'PV'});
% % ylabel('Silhouette Score')
% % box off
% % set(gcf,'units','points','position',[100,100,100,100])
% % utils.set_current_fig;
% % 
% % p_val = signrank(cellfun(@nanmean ,{all_silhouettes{:,1}}),cellfun(@nanmean ,{all_silhouettes{:,2}}));
% % red_stats.p_val_sign_datasets = p_val;
% % 
% % %get dataset stats!
% % for i =1:25; red_stats.dataset{i}.som = utils.get_basic_stats(all_silhouettes{i,1});end
% % for i =1:25; red_stats.dataset{i}.pv = utils.get_basic_stats(all_silhouettes{i,2});end
% % red_stats.dataset_means.pv = utils.get_basic_stats(cellfun(@mean,{all_silhouettes{:,2}}));
% % red_stats.dataset_means.som = utils.get_basic_stats(cellfun(@mean,{all_silhouettes{:,1}}));
% % 
% % figure(92);clf;
% % mouse_means = [cellfun(@length ,{all_silhouettes{:,1}});cellfun(@length ,{all_silhouettes{:,2}})];
% % for celltype= 1:2
% %     mean_cel = mean(cellfun(@length ,{all_silhouettes{:,celltype}}));
% %     err = std(cellfun(@length ,{all_silhouettes{:,celltype}})) / sqrt(length(all_silhouettes));
% %     hold on
% %     errorbar(celltype, mean_cel, err, 'o', ...
% %         'Color', plot_info.colors_celltype(celltype+1,:), ...
% %         'LineWidth', 1, 'MarkerSize', 2,'MarkerFaceColor', plot_info.colors_celltype(celltype+1,:));
% %     % Plot connected line for this mouse
% %     plot([1+.2,2-.2], mouse_means, '-', 'Color', ...
% %         [0.5,0.5,0.5, 0.3], 'LineWidth', 1)
% % 
% % end
% % xlim([0,3])
% % xticks([1,2])
% % xticklabels({'SOM', 'PV'});
% % box off
% % set(gcf,'units','points','position',[100,100,100,100])
% % ylabel('Cell Counts')
% % utils.set_current_fig;
% % 
% % %save stats about Ns per cell type
% % red_stats.count_stats.som.mean =  mean(cellfun(@length ,{all_silhouettes{:,1}}));
% % red_stats.count_stats.som.sem =  std(cellfun(@length ,{all_silhouettes{:,1}})) / sqrt(length(all_silhouettes));
% % 
% % red_stats.count_stats.pv.mean =  mean(cellfun(@length ,{all_silhouettes{:,2}}));
% % red_stats.count_stats.pv.sem =  std(cellfun(@length ,{all_silhouettes{:,2}})) / sqrt(length(all_silhouettes));
% % 
% % red_stats.count_stats.pyr.mean =  mean(total_pyr);
% % red_stats.count_stats.pyr.sem =  std(total_pyr)/sqrt(length(total_pyr));
% % 
% % 
% % 
% % 
% % if ~isempty(save_data_directory)
% %     mkdir(save_data_directory)
% %     cd(save_data_directory)
% % 
% %     image_string = strcat('Silhouettes_scores_',num2str(length(info.mouse_date)));
% %     saveas(88,[image_string '_datasets.svg']);
% %     saveas(88,[image_string '_datasets.fig']);
% % %     saveas(88,[image_string '_datasets.pdf']);
% % 
% %     saveas(90,[image_string '_datasets_scattersem.svg']);
% %     saveas(90,[image_string '_datasets_scattersem.fig']);
% % %     saveas(90,[image_string '_datasets_scattersem.pdf']);
% % 
% %     exportgraphics(figure(92),strcat('cell_counts_connected_lines_n',num2str(n_mice),'_datasets.pdf'), 'ContentType', 'vector');
% %     exportgraphics(figure(91),strcat('Silouette_scores_n',num2str(n_mice),'_datasets.pdf'), 'ContentType', 'vector');
% %     exportgraphics(figure(88),[image_string '_datasets_histogram.pdf'], 'ContentType', 'vector');
% %     exportgraphics(figure(89),[image_string '_datasets_violin.pdf'], 'ContentType', 'vector');
% %     exportgraphics(figure(90),[image_string '_datasets_meanscattersem.pdf'], 'ContentType', 'vector');
% %     exportgraphics(figure(94),[image_string '_datasets_scatterall_mean.pdf'], 'ContentType', 'vector');
% % 
% % 
% % 
% %     save('all_sil','all_sil');
% %     save('all_silhouettes','all_silhouettes');
% %     save('missing_data','missing_data')
% %     save('red_stats','red_stats');
% % end