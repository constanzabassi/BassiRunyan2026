function make_heatmap(data,plot_info,sort_index,varargin)

data1= squeeze(data);


if plot_info.sorting_type == 1
    [y_axis,inds] = max(data1(:,sort_index:end),[],2);
    [~,value] = sort(inds,'ascend'); %sort(y_axis,'ascend');
    r= 1:length(inds);
    r(value) = r;
    r=r';
    imagesc(data1(value,:)); %by time
    if nargin > 3
        for i = 1:length(varargin)
            xline(varargin{i},'--w','LineWidth',1)
        end
    end
else
    [y_axis,inds] = max(data1(:,sort_index:end),[],2);
    [~,value] = sort(y_axis,'ascend');
    r= 1:length(inds);
    r(value) = r;
    r=r';
    imagesc(data1(value,:)); %by max val
    if nargin > 3
        for i = 1:length(varargin)
            xline(varargin{i},'--w','LineWidth',1)
        end
    end
end
caxis([plot_info.min_max]);
colorbar;
xlim([0 size(data,2)]);
ylim([0 size(data,1)]);
xlabel(plot_info.xlabel);
ylabel(plot_info.ylabel);

