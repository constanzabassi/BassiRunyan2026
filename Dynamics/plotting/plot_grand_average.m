function plot_grand_average(ax, binned_data_all, plot_info, adjusted_onsets, nan_positions, num_nans, xlim_bins,alignment)
% binned_data_all: mice × celltype × time
% draws shaded mean±SEM, vertical lines at onsets & NaN gaps
hold on;
axes(ax); 
num_celltypes = size(binned_data_all,2);
for ce = 1:num_celltypes
    if iscell(binned_data_all)
        data = squeeze(binned_data_all{ce});         % mice x time
    else
        data = squeeze(binned_data_all(:,ce,:));         % mice × time
    end
    SEM  = std(data,0,1,'omitnan') ./ sqrt(size(data,1));
    data_plot = include_nans(data, num_nans, nan_positions);
    SEM_plot  = include_nans(SEM,  num_nans, nan_positions);
    shadedErrorBar(1:size(data_plot,2), mean(data_plot,1,'omitnan'), SEM_plot, ...
        'lineProps', {'color', plot_info.colors_celltype(ce,:), 'LineWidth', 1.2});
end
% alignment markers
for i = 1:length(adjusted_onsets)
    xline(adjusted_onsets(i),'--k','LineWidth',.5,'Alpha',1);
end
% NaN gap visualization
for i = 1:length(nan_positions)
    for n = 1:num_nans
        xline(nan_positions(i)+n-1,'-w','LineWidth',1);
    end
end
if strcmp(alignment.data_type,'z_dff')
    ylabel({'Mean ΔF/F';'(z-scored)'});
else
    ylabel({'Mean';'ΔF/F'});
end
if exist('xlim_bins','var') && ~isempty(xlim_bins)
    xlim(xlim_bins);
end
set(gca,'box','off');
utils.set_current_fig(7);
hold(ax,'off');
end