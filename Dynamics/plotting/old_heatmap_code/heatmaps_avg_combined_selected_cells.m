function [mouse_data_conditions,sorting_id_updated_datasets] = heatmaps_avg_combined_selected_cells (imaging_st,plot_info,alignment,sorting_id,save_data_directory,bin_size,sig_mod_boot,avg_across_datasets, active_passive )
%% create grand avg plot!
if active_passive == 1
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging_st{1,1},30);
else
    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging_st{1,1},30,2);
end
[aligned_imaging] = align_behavior_data (imaging_st{1,1},align_info,alignment_frames,left_padding,right_padding,alignment,1:10);
sorting_id_updated_datasets = {};
binss = 1:bin_size:size(aligned_imaging,3)-bin_size;
num_nans = 2;
%find event onsets if using bins
event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
new_onsets = find(histcounts(event_onsets,binss));
if length(event_onsets)>4
    adjusted_event_onsets = new_onsets;
    nan_insert_positions = [find(histcounts(101,binss))]; %, new_onsets(5)-num_nans
    for i = 1:length(nan_insert_positions)
        shift = num_nans * i;
        adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) = adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) + num_nans -1;
    end
else
    adjusted_event_onsets = new_onsets;
end

%find the mean across datasets for each celltype!
% alignment.data_type = 'z_dff';
for m = 1:length(sig_mod_boot)
    m
    for ce = 1:3
        celltype = {alignment.cells{ce,:}};
        imaging = imaging_st{1,m};
        [all_conditions, condition_array_trials] = divide_trials_updated(imaging,alignment.field_to_separate); %divide trials into all possible conditions   
        celltypes_permouse = celltype{m};
        sig_cells_permouse_temp = find(ismember(sig_mod_boot{m},celltypes_permouse));
        sig_cells_permouse = sig_mod_boot{m}(sig_cells_permouse_temp);
        if active_passive == 1
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30);
        else
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30,2);
        end
        [aligned_imaging] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,sig_cells_permouse);

        for b = 1:length(binss)
            if length(alignment.conditions) >= 1
                for con = 1:length(alignment.conditions)
                    con_trials = all_conditions{alignment.conditions(con),1};
                    binned_data(con,ce,b) = squeeze(mean(aligned_imaging(con_trials,:,binss(b):binss(b)+bin_size-1),[1,2,3]));
                end
%                 binned_data(ce,b) = squeeze(mean(aligned_imaging(cat(1,all_conditions{alignment.conditions,1}),:,binss(b):binss(b)+bin_size-1),[1,2,3]));
            else
                binned_data(ce,b) = squeeze(mean(aligned_imaging(:,:,binss(b):binss(b)+bin_size-1),[1,2,3])); %mean across trials and celltypes
            end
        end
        
    end
    if length(alignment.conditions) >= 1
        binned_data_all(m,:,:,:) = binned_data;
    else
        binned_data_all(m,:,:) = binned_data;
    end
end

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
            for m = 1:length(sig_mod_boot)
                c = alignment.conditions(con);
                imaging = imaging_st{1,m};
                [all_conditions, condition_array_trials] = divide_trials_updated (imaging,alignment.field_to_separate); %divide trials into all possible conditions   
                celltypes_permouse = celltype{m};
                sig_cells_permouse_temp = find(ismember(sig_mod_boot{m},celltypes_permouse));
                sig_cells_permouse = sig_mod_boot{m}(sig_cells_permouse_temp);
                if isempty(sig_cells_permouse_temp); continue; end

                if active_passive == 1
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30);
                else
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30,2);
                end
                [aligned_imaging,imaging_array] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,sig_cells_permouse);
    
    %           %previous trials was using 
    %             mouse_data{m,con} = aligned_imaging(all_conditions{c,1},:,:); %use specified trials in the condition array
    
                trials_all = all_conditions{c,1};
                n_trials = length(trials_all);
                rng(1) % for reproducibility, or set it uniquely per mouse if needed
                
                % Random permutation of trials
                perm = randperm(n_trials);
                half = floor(n_trials / 2);
                
                % Use first half for sorting, second half for plotting
                trials_sort = trials_all(perm(1:half));
                trials_plot = trials_all(perm(half+1:end));
                
                % Save trials used for sorting separately (for each mouse and con)
                mouse_data_sort{m,con} = aligned_imaging(trials_sort,:,:);  % for sorting
                mouse_data{m,con} = aligned_imaging(trials_plot,:,:);       % for plotting
                mouse_data_conditions{m,con} = mouse_data{m,con};
            end

            mean_mouse_data = {}; mean_mouse_sort= {};
            for m = 1:length(mouse_data)
                if ~isempty(mouse_data{m, con})
                    mean_mouse_data{m} = squeeze(mean(mouse_data{m, con}, 1, 'omitnan'));
                    mean_mouse_sort{m} = squeeze(mean(mouse_data_sort{m, con}, 1, 'omitnan')); %
                else
                    mean_mouse_data{m} = nan;  % or skip depending on your logic
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
                    %find alignment event
            event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
            alignment_event_onset = event_onsets(1);
    
            % add NANs between big alignment jumps
            % -----> Add this block:
            if length(event_onsets) > 4
                nan_insert_positions = [101]; %, event_onsets(5)-1
                data_to_plot = include_nans(data_to_plot,num_nans, nan_insert_positions);
        
                %update event onsets!
                % Adjust event_onsets
                adjusted_event_onsets = event_onsets;
                
                for i = 1:length(nan_insert_positions)
                    shift = num_nans * i;
                    adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) = adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) + num_nans -1;
                end
            elseif length(event_onsets) < 4
                nan_insert_positions = [];
                adjusted_event_onsets = event_onsets;
            end
    
    
            %make heatmap of specific condition with alignment event onset
            %based on alignment type
            %save across datasets
            sorting_id_updated_datasets{con,ce} = sorting_id_updated;
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
            
                data_to_plot = include_nans(data, num_nans, nan_insert_positions);
                SEM_to_plot = include_nans(SEM, num_nans, nan_insert_positions);
            
                shadedErrorBar(1:size(data_to_plot,2), mean(data_to_plot, 1, 'omitnan'), ...
                    SEM_to_plot, 'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth',1.2});
            
                for i = 1:length(adjusted_event_onsets)
                    xline(adjusted_event_onsets(i),'--k','LineWidth',1);
                end
            
                for i = 1:length(nan_insert_positions)
                    for n = 1:num_nans
                        xline(nan_insert_positions(i)+n-1,'-w','LineWidth',1);
                    end
                end
            end
            ylabel({'Mean';'activity'})
            xlim([1 size(data_to_plot,2)])
            set(gca, 'box', 'off', 'xtick', [])
            set(gca, 'fontsize', 7, 'FontName', 'Arial')
            set(gca, 'xtick', adjusted_event_onsets, ...
                'xticklabel', plot_info.xlabel_events, 'xticklabelrotation', 45)

            %set sizing
            set(gcf,'Units','points','Position',plot_info.position)
            set(gca,'xtick',adjusted_event_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);

            if ~isempty(save_data_directory)
                mkdir(save_data_directory)
                image_string = strcat('heatmaps_avgtrace_condition_',num2str(alignment.conditions(con)),'_avgdatasets',num2str(avg_across_datasets));
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
            for m = 1:length(sig_mod_boot)
                imaging = imaging_st{1,m};
                [~, ~] = divide_trials_updated (imaging,alignment.field_to_separate); %divide trials into all possible conditions   
                celltype = {alignment.cells{ce,:}};
                celltypes_permouse = celltype{m};
                sig_cells_permouse_temp = find(ismember(sig_mod_boot{m},celltypes_permouse));
                sig_cells_permouse = sig_mod_boot{m}(sig_cells_permouse_temp);
                if isempty(sig_cells_permouse_temp) 
                    continue; 
                end
                if active_passive == 1
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30);
                else
                    [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (imaging,30,2);
                end
                [aligned_imaging,~] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,sig_cells_permouse);
    %             mouse_data{m} = aligned_imaging(:,:,:); %use specified trials in the condition array
    
                trials_all =1:size(aligned_imaging,1);
                n_trials = length(trials_all);
                rng(1) % for reproducibility, or set it uniquely per mouse if needed
                
                % Random permutation of trials
                perm = randperm(n_trials);
                half = floor(n_trials / 2);
                
                % Use first half for sorting, second half for plotting
                trials_sort = trials_all(perm(1:half));
                trials_plot = trials_all(perm(half+1:end));
                
                % Save trials used for sorting separately (for each mouse and con)
                mouse_data_sort{m} = aligned_imaging(trials_sort,:,:);  % for sorting
                mouse_data{m} = aligned_imaging(trials_plot,:,:);       % for plotting
                mouse_data_conditions{m} = mouse_data{m};
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
            event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
            alignment_event_onset = event_onsets(1);
    
            % add NANs between big alignment jumps
            % -----> Add this block:
            if length(event_onsets) > 4
                num_nans = 2;
                nan_insert_positions = [101]; %, event_onsets(5)-1
                data_to_plot = include_nans(data_to_plot,num_nans, nan_insert_positions);
        
                %update event onsets!
                % Adjust event_onsets
                adjusted_event_onsets = event_onsets;
                
                for i = 1:length(nan_insert_positions)
                    shift = num_nans * i;
                    adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) = adjusted_event_onsets(adjusted_event_onsets >= nan_insert_positions(i)) + num_nans -1;
                end
            elseif length(event_onsets) < 4
                nan_insert_positions = [];
            end
    
    
            %make heatmap of specific condition with alignment event onset
            %based on alignment type
            sorting_id_updated_datasets{1,ce} = sorting_id_updated;
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
            image_string = ['heatmaps_avgtrace_all_conditions_avgdatasets' num2str(avg_across_datasets)];
            saveas(90, fullfile(save_data_directory, [image_string '_datasets.fig']));
            exportgraphics(figure(90), fullfile(save_data_directory, [image_string '_datasets.pdf']), 'ContentType', 'vector');
        end
end 




