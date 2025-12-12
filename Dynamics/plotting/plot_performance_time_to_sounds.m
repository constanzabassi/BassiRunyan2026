function [first_sound_stats] = plot_performance_time_to_sounds(performance,save_data_directory,mouseID)

% tiledlayout(r,c)
unique_mice = unique(mouseID);
n_mice = length(unique_mice);
time_to_first_sound = [];

for m = 1:n_mice
    curr_mouse = unique_mice(m);
    mouse_datasets = find(mouseID == curr_mouse);
    d = mouse_datasets;
    time_to_first_sound = [time_to_first_sound,mean([performance(d).time_to_first_sound])];
    
end
first_sound_stats = utils.get_basic_stats(time_to_first_sound);
first_sound_stats.data = time_to_first_sound;

%% % CORRECT
figure(5558);clf;
[pos] = utils.calculateFigurePositions(6,2,.5,[],[]);
hold on
h = boxplot(time_to_first_sound, 'position', 1, 'width', 0.5, 'colors', [0.5,0.5,0.5],'symbol', 'o');
% set(findobj(gca, 'Type', 'Line'), 'LineWidth', 1);
hh = findobj('LineStyle','--','LineWidth',0.5); 
set(h(1:6), 'LineStyle','-','LineWidth',1.3);

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    scatter(1 + jitter, time_to_first_sound(m), 20, ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'none', ...
    'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5);
end

set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
set(gca,'fontsize',7,'box','off','Units','Points','Position',[100,100,30,100]);

xticks(1)                 % ensure a tick exists where you want it
xticklabels({''})         % hide default tick label
xlabel({'Imaging','Sessions'}, 'FontSize', 7, 'FontWeight', 'normal','FontName','Arial');
ax = gca;
ax.XLabel.VerticalAlignment = 'top';   % push label closer to ticks if needed

xtickangle(0)
ylabel('Time to First Sound (s)')

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
%     cd(save_data_directory)

    image_string = strcat('time_to_first_sound_boxplot_dots_',num2str(size(performance,2)));
    saveas(5558,fullfile([save_data_directory image_string '_datasets.fig']));
    exportgraphics(figure(5558),fullfile([save_data_directory image_string '_datasets.pdf']), 'ContentType', 'vector');
    save(fullfile([save_data_directory image_string 'first_sound_stats.mat']),'first_sound_stats');
end