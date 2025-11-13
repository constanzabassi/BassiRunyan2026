function [mouse_data_conditions,sorting_id_updated_datasets] = heatmaps_avg_combined_selected_cells_spont (context_data, plot_info,alignment,sorting_id,save_data_directory,bin_size,sig_mod_boot,avg_across_datasets )
%% create grand avg plot!
adjusted_event_onsets = 61;

possible_conditions =  fields(context_data.dff{1,1});
for conditions = 1:2
    for celltypes = 1:3
        celltype = {alignment.cells{celltypes,:}};
        temp = [];
        for dataset = 1:length(sig_mod_boot)
            celltypes_permouse = celltype{dataset};
%             temp = [temp; squeeze(mean(context_data.dff{3, dataset}.(possible_conditions{conditions+2}),[1]))]; %find mean across trials x cells
            binned_data_all(dataset,conditions,celltypes,:) = squeeze(mean(context_data.dff{3, dataset}.(possible_conditions{conditions+2}),[1,2]));
        end
        
    end
end
      
sorting_id_updated_datasets = {}; %save for other plots!
%find the mean across datasets for each celltype!
% alignment.data_type = 'z_dff';
if length(alignment.conditions) >= 1
    for con = 1:length(alignment.conditions)
         figure(90);clf;
         hold on
        colormap(viridis)
        
        % Create a tiled layout
        t = tiledlayout(4,1,"TileSpacing","tight")
        set(gcf,'Units','points','Position',[100 100 170 216])
        for ce = 1:3
            %Initialize variables
            celltype = {alignment.cells{ce,:}};
            mouse_data ={}; mouse_data_conditions ={};mouse_data_sort = {};
    
            %find infor for each mouse and combine it
            for dataset = 1:length(sig_mod_boot)
                c = alignment.conditions(con);
                imaging = context_data.dff{3, dataset};
                celltypes_permouse = celltype{dataset};
                sig_cells_permouse_temp = find(ismember(sig_mod_boot{dataset},celltypes_permouse));
                sig_cells_permouse = sig_mod_boot{dataset}(sig_cells_permouse_temp);
                if isempty(sig_cells_permouse_temp); continue; end

                aligned_imaging = imaging.(possible_conditions{con+2})(:,sig_cells_permouse,:);
        
                trials_all = 1:size(aligned_imaging,1);
                n_trials = length(trials_all);
                rng(1) % for reproducibility, or set it uniquely per mouse if needed
                
                % Random permutation of trials
                perm = randperm(n_trials);
                half = floor(n_trials / 2);
                
                % Use first half for sorting, second half for plotting
                trials_sort = trials_all(perm(1:half));
                trials_plot = trials_all(perm(half+1:end));
                
                % Save trials used for sorting separately (for each mouse and con)
                mouse_data_sort{dataset,con} = aligned_imaging(trials_sort,:,:);  % for sorting
                mouse_data{dataset,con} = aligned_imaging(trials_plot,:,:);       % for plotting
                mouse_data_conditions{dataset,con} = mouse_data{dataset,con};
            end

            mean_mouse_data = {}; mean_mouse_sort= {};
            for dataset = 1:length(mouse_data)
                if ~isempty(mouse_data{dataset, con})
                    mean_mouse_data{dataset} = squeeze(mean(mouse_data{dataset, con}, 1, 'omitnan'));
                    mean_mouse_sort{dataset} = squeeze(mean(mouse_data_sort{dataset, con}, 1, 'omitnan')); %
                else
                    mean_mouse_data{dataset} = nan;  % or skip depending on your logic
                end
            end

            ax = nexttile(ce); %subplot(4,1,ce)
            hold on
            out = concat_neuron_data(mean_mouse_data);
            data_to_plot = out; %cat(1,mean_mouse_data{1,:});%concatenated mouse data
    
            %get sorting id from original trials
            % Combine sorting trials from all conditions
            sorting_data = concat_neuron_data(mean_mouse_sort); %cat(1, mean_mouse_data_sort{:});  % adjust if multiple conditions
            mean_sorting_response = sorting_data; %squeeze(mean(sorting_data, 1));  % avg over trials            
            % Optional: use max activity for sorting
            [~, sorting_id_updated] = max(mean_sorting_response, [], 2);  
            [~, sorting_id_updated] = sort(sorting_id_updated, 'ascend');  % sort by peak response
            
            %save across datasets
            sorting_id_updated_datasets{con,ce} = sorting_id_updated;
            %make heatmap of specific condition with alignment event onset
            %based on alignment type
            if isempty(sorting_id)
                make_heatmap_sorted(data_to_plot,plot_info,sorting_id_updated,adjusted_event_onsets);
%                 make_heatmap(data_to_plot,plot_info,alignment_event_onset,adjusted_event_onsets); 
            else
                make_heatmap_sorted(data_to_plot,plot_info,sorting_id{ce},adjusted_event_onsets);
            end
            set(gca, 'box', 'off', 'xtick', [])
            set(gca,'fontsize', 7,'FontName','Arial')
            ylabel({alignment.title{ce}}) %({alignment.title{ce};'Neurons'}
            % Add colorbar and make it skinnier
            % Add colorbar to the *current axis*, and make it skinny
            cb = colorbar(ax, 'eastoutside');  % attach to the correct axes
            cb.FontSize = 6;
            
            % Make colorbar skinny
            cb_pos = cb.Position;
            cb_pos(3) = cb_pos(3) * 0.3;  % narrow width
            cb.Position = cb_pos;
            
            % Optional: move colorbar closer to the plot
            cb_pos(1) = cb_pos(1) + 0.16;
            cb_pos(2) = cb_pos(2) + 0.05;
            cb_pos(4) = cb_pos(4) - 0.05;
            cb.Position = cb_pos;
         
            % Make NaNs transparent
            hImg = findobj(gca, 'Type', 'Image');  % find the image object in current axes
            set(hImg, 'AlphaData', ~isnan(data_to_plot));

            mean_mouse_data_celltypes{ce} = concat_neuron_data(mean_mouse_data);
            
        end
                % Fourth tile: average trace plot for this condition
            ax = nexttile(4);  % tile 4 in this condition figure
            hold on
            for ce = 1:3
                if  avg_across_datasets == 0
                    data = mean_mouse_data_celltypes{ce};  % shape: [mice × time]
                    SEM = std(data, 'omitnan') / sqrt(size(data,1));
                else
                    data = squeeze(binned_data_all(:,con,ce,:));  % shape: [mice × time]
                    SEM = std(data, 'omitnan') / sqrt(size(data,1));
                end
            
                data_to_plot = data;
                SEM_to_plot = SEM;
            
                shadedErrorBar(1:size(data_to_plot,2), mean(data_to_plot, 1, 'omitnan'), ...
                    SEM_to_plot, 'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth',1.2});
            
                for i = 1:length(adjusted_event_onsets)
                    xline(adjusted_event_onsets(i),'--k','LineWidth',1);
                end
            

            end
            ylabel({'Mean';'activity'})
            xlim([1 size(data_to_plot,2)])
            set(gca, 'box', 'off', 'xtick', [])
            set(gca, 'fontsize', 7, 'FontName', 'Arial')
            set(gca, 'xtick', adjusted_event_onsets, ...
                'xticklabel', plot_info.xlabel_events, 'xticklabelrotation', 45)

            %set sizing
            set(gcf,'Units','points','Position',plot_info.position) %[100 100 160 155]
            set(gca,'xtick',adjusted_event_onsets,'xticklabel','Stim','xticklabelrotation',45);

            if ~isempty(save_data_directory)
                mkdir(save_data_directory)
                image_string = strcat('heatmaps_spont_avgtrace_condition_',num2str(alignment.conditions(con)),'_avgdatasets',num2str(avg_across_datasets));
                saveas(90, fullfile(save_data_directory, [image_string '_datasets.fig']));
                exportgraphics(figure(90), fullfile(save_data_directory, [image_string '_datasets.pdf']), 'ContentType', 'vector');
            end


    end
else
        figure(90);clf;
        colormap(viridis)
        
        % Create a tiled layout
        t = tiledlayout(4,1,"TileSpacing","tight")
        set(gcf,'Units','points','Position',[100 100 170 216])
    
        for ce = 1:3
        %find infor for each mouse and combine it
            for dataset = 1:length(sig_mod_boot)
                c = alignment.conditions(con);
                imaging = context_data.dff{3, dataset};
                celltypes_permouse = celltype{dataset};
                sig_cells_permouse_temp = find(ismember(sig_mod_boot{dataset},celltypes_permouse));
                sig_cells_permouse = sig_mod_boot{dataset}(sig_cells_permouse_temp);
                if isempty(sig_cells_permouse_temp); continue; end

                aligned_imaging = [imaging.stim(:,sig_cells_permouse,:);imaging.ctrl(:,sig_cells_permouse,:)];
        
                trials_all = 1:size(aligned_imaging,1);    
                n_trials = length(trials_all);
                rng(1) % for reproducibility, or set it uniquely per mouse if needed
                
                % Random permutation of trials
                perm = randperm(n_trials);
                half = floor(n_trials / 2);
                
                % Use first half for sorting, second half for plotting
                trials_sort = trials_all(perm(1:half));
                trials_plot = trials_all(perm(half+1:end));
                
                % Save trials used for sorting separately (for each mouse and con)
                mouse_data_sort{dataset} = aligned_imaging(trials_sort,:,:);  % for sorting
                mouse_data{dataset} = aligned_imaging(trials_plot,:,:);       % for plotting
                mouse_data_conditions{dataset} = mouse_data{dataset};
            end
    %         mouse_data_conditions{m} = mouse_data{m};
            mean_mouse_data = cellfun(@(x) squeeze(mean(x,1)),mouse_data,'UniformOutput',false);
            mean_mouse_data_sort = cellfun(@(x) squeeze(mean(x,1)),mouse_data_sort,'UniformOutput',false);
    
            ax = nexttile(ce); %subplot(4,1,ce);
            hold on
            out = concat_neuron_data(mean_mouse_data);
            data_to_plot = out; %cat(1,mean_mouse_data{1,:});%concatenated mouse data
    
            %get sorting id from original trials
            % Combine sorting trials from all conditions
            sorting_data = concat_neuron_data(mean_mouse_data_sort); %cat(1, mean_mouse_data_sort{:});  % adjust if multiple conditions
            mean_sorting_response = sorting_data; %squeeze(mean(sorting_data, 1));  % avg over trials
            
            % Optional: use max activity for sorting
            [~, sorting_id_updated] = max(mean_sorting_response, [], 2);  
            [~, sorting_id_updated] = sort(sorting_id_updated, 'ascend');  % sort by peak response
            
    
            %find alignment event
            event_onsets = adjusted_event_onsets; 
    
            %make heatmap of specific condition with alignment event onset
            %based on alignment type
            if isempty(sorting_id)
                make_heatmap_sorted(data_to_plot,plot_info,sorting_id_updated,adjusted_event_onsets);
%                 make_heatmap(data_to_plot,plot_info,alignment_event_onset,adjusted_event_onsets); 
            else
                make_heatmap_sorted(data_to_plot,plot_info,sorting_id{ce},adjusted_event_onsets);
            end
            set(gca, 'box', 'off', 'xtick', [])
            set(gca,'fontsize', 7,'FontName','Arial')
            ylabel({alignment.title{ce}}) %({alignment.title{ce};'Neurons'}
            % Add colorbar and make it skinnier
            % Add colorbar to the *current axis*, and make it skinny
           
                cb = colorbar(ax, 'eastoutside');  % attach to the correct axes
                cb.FontSize = 6;
                
                % Make colorbar skinny
                cb_pos = cb.Position;
                cb_pos(3) = cb_pos(3) * 0.3;  % narrow width
                cb.Position = cb_pos;
                
                % Optional: move colorbar closer to the plot
                cb_pos(1) = cb_pos(1) + 0.16;
                cb_pos(2) = cb_pos(2) + 0.05;
                cb_pos(4) = cb_pos(4) - 0.05;
                cb.Position = cb_pos;
         
            % Make NaNs transparent
            hImg = findobj(gca, 'Type', 'Image');  % find the image object in current axes
            set(hImg, 'AlphaData', ~isnan(data_to_plot));    
                    ax = nexttile(4);  % tile 4 in this condition figure
                hold on
        
                if  avg_across_datasets == 0
                    data = concat_neuron_data(mean_mouse_data);  % shape: [mice × time]
                    SEM = std(data, 'omitnan') / sqrt(size(data,1));
                else
                    data = squeeze(binned_data_all(:,ce,:));  % shape: [mice × time]
                    SEM = std(data, 'omitnan') / sqrt(size(data,1));
                end
        
            data_to_plot = include_nans(data,num_nans, nan_insert_positions);
            SEM_to_plot = include_nans(SEM,num_nans, nan_insert_positions);
        
            a(ce) = shadedErrorBar(1:size(data_to_plot,2),mean(data_to_plot,1,'omitnan'), SEM_to_plot, 'lineProps',{'color', plot_info.colors_celltype(ce,:),'LineWidth',1.2});
        
            %     plot(squeeze(mean(binned_data_all(:,ce,:),1)),'LineWidth',1.5,'color',plot_info.colors_celltype(ce,:));
            
                for i = 1:length(adjusted_event_onsets)
                    xline(adjusted_event_onsets(i),'--k','LineWidth',1)
                end
            
                for i = 1:length(nan_insert_positions)
                    for n = 1:num_nans
                        xline(nan_insert_positions(i)+n-1,'-w','LineWidth',1);
                    end
            
                end
            
                ylabel({'Mean';'activity'}) %
                xlim([1 length(binss)])
                set(gca, 'box', 'off', 'xtick', [])
            %     set(gcf,'Position',[23 453 683 133])
                set(gca,'fontsize', 7,'FontName','Arial')

    
        end
        
    
    hold off
    set(gcf,'Units','points','Position',plot_info.position)
    set(gca,'xtick',adjusted_event_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);

        if ~isempty(save_data_directory)
            mkdir(save_data_directory)
            image_string = ['heatmaps_spont_avgtrace_all_conditions_avgdatasets' num2str(avg_across_datasets)];
            saveas(90, fullfile(save_data_directory, [image_string '_datasets.fig']));
            exportgraphics(figure(90), fullfile(save_data_directory, [image_string '_datasets.pdf']), 'ContentType', 'vector');
        end
end 
