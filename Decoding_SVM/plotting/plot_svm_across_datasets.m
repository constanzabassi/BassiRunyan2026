function plot_svm_across_datasets(svm_mat,plot_info,event_onsets,mdl_param,save_str,save_path,minmax,bins_to_include)
overall_mean = [];
overall_shuff = [];
num_nans = 1;
smoothing_factor = 1;

for ce = 1:size(svm_mat,2)
    mean_across_data = cellfun(@(x) mean(x.accuracy(:,1:bins_to_include),1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean(ce,:) = mean(mean_across_data,1);
    mean_data(ce,:,:) = mean_across_data;

    mean_across_data_shuff = cellfun(@(x) mean(x.shuff_accuracy(:,1:bins_to_include),1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data_shuff = vertcat(mean_across_data_shuff{1,:});
    overall_shuff(ce,:) = mean(mean_across_data_shuff,1);
    mean_data2(ce,:,:) = mean_across_data_shuff;

end


figure(100);clf;
legend_handles = []; % Initialize an array to collect handles for the legend
legend_labels = {}; % Initialize a cell array to collect labels for the legend

hold on; 
for ce = 1:size(svm_mat,2)
    
        %shadedErrorBar(1:size(time),mean(aross_subsamples gives
        %size(time))

    SEM= std(squeeze(mean_data(ce,:,:)))/sqrt(size(mean_data(ce,:,:),2)); %first number is observations (time)/ maybe datasets or subsamples
    %insert nans
    if size(overall_mean,2) > 33
        nan_insert_positions = 34; %[find(histcounts(101,dynamics_info.binss))];
        data_to_plot = include_nans(smooth(overall_mean(ce,:),smoothing_factor , 'boxcar'),num_nans, nan_insert_positions);
    else
        data_to_plot = smooth(overall_mean(ce,:),smoothing_factor , 'boxcar');
    end
    h1 = shadedErrorBar(1:size(overall_mean,2),data_to_plot, smooth(SEM,smoothing_factor , 'boxcar'), 'lineProps',{'LineWidth',1.2,'color', plot_info.colors_celltype(ce,:)});
    legend_handles(end+1) = h1.mainLine; % Collect the handle of the main line
    legend_labels{end+1} = plot_info.labels{ce}; % Collect the corresponding label


    SEM= std(squeeze(mean_data2(ce,:,:)))/sqrt(size(mean_data2(ce,:,:),2));
     %insert nans
    if size(overall_mean,2) > 33
        nan_insert_positions = 34; %[find(histcounts(101,dynamics_info.binss))];
        data_to_plot = include_nans(smooth(overall_shuff(ce,:),smoothing_factor , 'boxcar'),num_nans, nan_insert_positions);
    else
        data_to_plot = smooth(overall_shuff(ce,:),smoothing_factor , 'boxcar');
    end
    
    if size(svm_mat,2) >=4 && ce == 4
        shadedErrorBar(1:size(overall_mean,2),data_to_plot, smooth(SEM,smoothing_factor , 'boxcar'), 'lineProps',{'LineWidth',1.2,'color', [0.5 0.5 0.5]});
    elseif size(svm_mat,2) <4 && ce == size(svm_mat,2)
        shadedErrorBar(1:size(overall_mean,2),data_to_plot, smooth(SEM,smoothing_factor , 'boxcar'), 'lineProps',{'LineWidth',1.2,'color', [0.5 0.5 0.5]});
    end

    for i = 1:length(event_onsets)
        xline(event_onsets(i),'--k','LineWidth',.7)
%         if i == 4
%             xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
%         end
    end
yline(.5,'--k');

end
% % Create the legend using the collected handles and labels
% legend(legend_handles, legend_labels,'location','north','Box', 'off'); 

% Get current axis limits
x_range = xlim;
y_range = ylim;
y_offset_base = .1;
% Calculate base text position
if length(plot_info.labels{1}) > 7
    text_x = x_range(2) -.45 * diff(x_range);
else
    text_x = x_range(2) -.10 * diff(x_range);
end
if ~isempty(minmax)
    y_range(2) = minmax(2);
end
text_y = y_range(2) - .2 * diff(y_range);

% Auto-calculate evenly spaced y-offsets
num_labels = size(svm_mat,2);
y_offsets = linspace(0, 0.1 * (num_labels - 1), num_labels); % Adjusted scaling
% Place text labels
for i = 1:num_labels
    text(text_x, text_y - y_offsets(i) * diff(y_range), legend_labels{i}, ...
         'Color', plot_info.colors_celltype(i,:), 'FontSize', 7);
end


ylabel({'% Accuracy'})
% xlabel('Time (s)')
xlim([1 size(overall_mean,2)])
[second_ticks,second_labels] = x_axis_sec_onset(mdl_param);
xticks([second_ticks]);
xticklabels(second_labels);
if ~isempty(minmax)
    ylim([minmax(1) minmax(2)])
end
ax = gca;  % Get current axes
yticks = ax.YTick;  % Get current y-tick values
ax.YTickLabel = yticks * 100;  % Multiply by 100 and assign back

set(gca, 'box', 'off','xtick',[])

% legend([a(1).mainLine a(2).mainLine a(3).mainLine],'PYR','SOM','PV','Location','southeast','box','off');

set(gca,'xtick',event_onsets,'xticklabel',{'S1','S2','S3','T','R'},'xticklabelrotation',45);

% set_current_fig;
set(gca,'FontSize',7);
ax = gca;
ax.XLabel.FontSize = ax.FontSize;
ax.YLabel.FontSize = ax.FontSize;
% set(gcf,'position',[100,100,225,150])
set(gca, 'OuterPosition', [0,0,1,1]);

set(gcf,'position',[100,100,175,120])


if ~isempty(save_path)
    mkdir(save_path )
%     cd(save_path)
%     saveas(100,strcat('svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'.svg'));
%     saveas(100,strcat('svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'.png'));
    exportgraphics(gcf,fullfile(save_path,strcat('svm_alldatasets_',num2str(size(svm_mat,1)),save_str,'.pdf')), 'ContentType', 'vector');
end

