function make_heatmap_sorted(data,plot_info,varargin)

if isfield('colormap',plot_info)
    colormap viridis%redblue
else
    colors = plot_info.colormap;
    colormap redblue
end
data_to_plot= squeeze(data);

if nargin > 2
    imagesc(data_to_plot(varargin{1,1},:)); 
else
    imagesc(data_to_plot); 
end

if nargin > 3
        for i = 1:length(varargin{1,2})
            xline(varargin{1,2}(i),'--w','LineWidth',1)
        end
end

% clim(ylims);
% % xlim([0 size(data,2)]);
% % ylim([0 size(data,1)]);
% if length(x_label) > 1
%     xticks([1:size(data,2)]);
%     xticklabels(x_label);
% else
%     xlabel(x_label);
% end
% ylabel(y_label);

caxis([plot_info.min_max]);
colorbar;
xlim([1 size(data,2)]);
ylim([1 size(data,1)]);
if length(plot_info.xlabel) > 1
    xticks([1:size(data,2)]);
    xlim([0.5 size(data,2)+0.5]);
    xtickangle(45);
    xticklabels(plot_info.xlabel);

else
    xlabel(plot_info.xlabel);
end
ylabel(plot_info.ylabel);