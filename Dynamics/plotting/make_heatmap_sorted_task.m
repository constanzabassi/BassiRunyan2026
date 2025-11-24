function make_heatmap_sorted_task(data,plot_info,sorting_ids,varargin)

data1= squeeze(data);

imagesc(data1(sorting_ids,:)); 
if nargin > 3
    for i = 1:length(varargin)
        xline(varargin{i},'-w')
    end
end
set(gca, 'YDir', 'reverse');

caxis([plot_info.min_max]);
colorbar;
xlim([0 size(data,2)]);
ylim([0 size(data,1)]);
xlabel(plot_info.xlabel);
ylabel(plot_info.ylabel);
yticks([1 size(data,1)]);

% axis square
box off
% utils.set_current_fig;