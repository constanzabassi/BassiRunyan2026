function mouse_data_conditions = heatmaps_avg_combined_all_celltypes_extra_fields (imaging_st,plot_info,alignment,sorting_id,save_data_directory,bin_size,extra_fields,thr)
% Create a tiled layout
tiledlayout(5, 1,"TileSpacing","tight");

for ce = 1:3
%Initialize variables
celltype = {alignment.cells{ce,:}};
mouse_data ={}; mouse_data_conditions ={};
if length(alignment.conditions) >= 1
    for con = 1:length(alignment.conditions)
        %find infor for each mouse and combine it
        for m = 1:length(celltype)
            imaging = imaging_st{1,m};
            [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
            celltypes_permouse = celltype{m};
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
            [aligned_imaging,imaging_array] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,celltypes_permouse);
            [aligned_imaging_array] = align_imaging_array (imaging_array,align_info,alignment_frames,left_padding,right_padding,alignment,extra_fields);
            
            trials_to_use =cat(1,all_conditions{alignment.conditions,1});
            if ~isempty(thr)
                new_trials = find(abs(mean(aligned_imaging_array(trials_to_use,:),2,'omitnan'))> thr); %across time
                trials_to_use = trials_to_use(new_trials);%cat(1,all_conditions{alignment.conditions,1});
            end


            mouse_data{m,con} = aligned_imaging(trials_to_use,:,:); %use specified trials in the condition array
            mouse_data_behavior{m} = aligned_imaging_array(trials_to_use,:);
            mouse_data_conditions{m,con} = mouse_data{m,con};
        end
        
    end
        mean_mouse_data = cellfun(@(x) squeeze(mean(x,1)),mouse_data,'UniformOutput',false);
        mean_mouse_data ={};
        for m = 1:length(celltype)
            mean_mouse_data{m} = squeeze(mean(cat(1,mouse_data{m,:}),1));
        end
        nexttile
        hold on
        
        data_to_plot = cat(1,mean_mouse_data{1,:});%concatenated mouse data
        

        %find alignment event
        event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
        alignment_event_onset = event_onsets(1);

        %make heatmap of specific condition with alignment event onset
        %based on alignment type
        if isempty(sorting_id)
            make_heatmap(data_to_plot,plot_info,alignment_event_onset,event_onsets); 
        else
            make_heatmap_sorted(data_to_plot,plot_info,sorting_id,alignment_event_onset);
        end
        set(gca, 'box', 'off', 'xtick', [])
        set(gca,'fontsize', 12,'FontName','Arial')
        ylabel({alignment.title{ce};'Neurons'})
        hold off
    %end
else
    %find infor for each mouse and combine it
        for m = 1:length(celltype)
            imaging = imaging_st{1,m};
            [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
            celltypes_permouse = celltype{m};
            [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
            [aligned_imaging,imaging_array]= align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,celltypes_permouse);
            [aligned_imaging_array] = align_imaging_array (imaging_array,align_info,alignment_frames,left_padding,right_padding,alignment,extra_fields);
            mouse_data{m} = aligned_imaging(:,:,:); %use specified trials in the condition array
            mouse_data_behavior{m} = aligned_imaging_array;
        end
        mouse_data_conditions{m} = mouse_data{m};
        mean_mouse_data = cellfun(@(x) squeeze(mean(x,1)),mouse_data,'UniformOutput',false);

        nexttile
        hold on
        data_to_plot = cat(1,mean_mouse_data{1,:});%concatenated mouse data
        

        %find alignment event
        event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
        alignment_event_onset = event_onsets(1);

        %make heatmap of specific condition with alignment event onset
        %based on alignment type
        if isempty(sorting_id)
            make_heatmap(data_to_plot,plot_info,alignment_event_onset,event_onsets); 
        else
            make_heatmap_sorted(data_to_plot,plot_info,sorting_id,alignment_event_onset);
        end
        set(gca, 'box', 'off', 'xtick', [])
        set(gca,'fontsize', 12,'FontName','Arial')
        ylabel({alignment.title{ce};'Neurons'})
        
end
end

%% create grand avg plot!
binss = 1:bin_size:size(aligned_imaging,3)-bin_size;

%find event onsets if using bins
event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
new_onsets = find(histcounts(event_onsets,binss));

%find the mean across datasets for each celltype!

for m = 1:size(imaging_st,2)
    m
    for ce = 1:3
        celltype = {alignment.cells{ce,:}};
        imaging = imaging_st{1,m};
        [all_conditions, condition_array_trials] = divide_trials (imaging); %divide trials into all possible conditions   
        celltypes_permouse = celltype{m};
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info (imaging,30);
        [aligned_imaging] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,celltypes_permouse);

        for b = 1:length(binss)
            if length(alignment.conditions) >= 1
                binned_data(ce,b) = squeeze(mean(aligned_imaging(cat(1,all_conditions{alignment.conditions,1}),:,binss(b):binss(b)+bin_size-1),[1,2,3]));
            else
                binned_data(ce,b) = squeeze(mean(aligned_imaging(:,:,binss(b):binss(b)+bin_size-1),[1,2,3])); %mean across trials and celltypes
            end
        end
        
    end
    binned_data_all(m,:,:) = binned_data;
end


%make avg plot!

nexttile
hold on
for ce = 1:3

        data = squeeze(binned_data_all(:,ce,:));
        SEM= std(data)/sqrt(size(data,1));
        a(ce) = shadedErrorBar(1:size(data,2),mean(data,1), SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:),'LineWidth',1.5});
    
%     plot(squeeze(mean(binned_data_all(:,ce,:),1)),'LineWidth',1.5,'color',plot_info.colors_celltype(ce,:));

    for i = 1:length(new_onsets)
        xline(new_onsets(i),'--k','LineWidth',1.5)
    end
    ylabel({'Mean dF/F'})
    xlim([1 length(binss)])
    set(gca, 'box', 'off', 'xtick', [])
%     set(gcf,'Position',[23 453 683 133])
    set(gca,'fontsize', 12,'FontName','Arial')
    
end
hold off

%% find mean across field 
clear binned_data binned_data_all
for m = 1:size(imaging_st,2)
    m
    aligned_data = mouse_data_behavior{m};
    for b = 1:length(binss)
        binned_data(b) = squeeze(mean(aligned_data(:,binss(b):binss(b)+bin_size-1),[1,2],'omitnan'));
        
    end
    binned_data_all(m,:) = binned_data;
end


%make avg plot!

nexttile
hold on

data = squeeze(binned_data_all(:,:));
SEM= std(data)/sqrt(size(data,1));
shadedErrorBar(1:size(data,2),mean(data,1), SEM, 'lineProps',{'color', plot_info.colors_celltype(4,:),'LineWidth',1.5});

%     plot(squeeze(mean(binned_data_all(:,ce,:),1)),'LineWidth',1.5,'color',plot_info.colors_celltype(ce,:));

for i = 1:length(new_onsets)
xline(new_onsets(i),'--k','LineWidth',1.5)
end
ylabel(extra_fields)
xlim([1 length(binss)])
set(gca, 'box', 'off', 'xtick', [])
%     set(gcf,'Position',[23 453 683 133])
set(gca,'fontsize', 12,'FontName','Arial')
    

hold off

%%
set(gca,'xtick',new_onsets,'xticklabel',plot_info.xlabel_events,'xticklabelrotation',45);

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
    cd(save_data_directory)

    image_string = strcat('heatmaps_avgtrace_condition_',num2str(alignment.conditions,3),'_',extra_fields);
    saveas(90,[image_string '_datasets.svg']);
    saveas(90,[image_string '_datasets.fig']);
    saveas(90,[image_string '_datasets.png']);
end

