function [stats] = plot_performance_all(performance,save_data_directory, mouseID)
[r,c] = determine_num_tiles(size(performance,2));
figure(5556);clf;
rng(1);
% tiledlayout(r,c)

%% 1) get means across mouse_indices
unique_mice = unique(mouseID);
n_mice = length(unique_mice);
correct_per_mouse = [];
left_per_mouse = [];
sec_to_turn_per_mouse = [];

for m = 1:n_mice
    curr_mouse = unique_mice(m);
    mouse_datasets = find(mouseID == curr_mouse);
    d = mouse_datasets;
    correct_per_mouse = [correct_per_mouse,mean([performance(d).correct_all])];
    left_per_mouse = [left_per_mouse,mean([performance(d).left_all])];
    sec_to_turn_per_mouse = [sec_to_turn_per_mouse,mean([performance(d).turn_onset_all])];
   
end

stats.correct = utils.get_basic_stats(correct_per_mouse);
stats.left_per_mouse = utils.get_basic_stats(left_per_mouse);
stats.sec_to_turn = utils.get_basic_stats(sec_to_turn_per_mouse);

%2) get symbols if given
if n_mice > 20
    mouse_symbols = cell(1,n_mice);
    mouse_symbols(1:n_mice) = {'.'};
else
    mouse_symbols = cell(1,n_mice);
    mouse_symbols = {'>','o','d','s','p','v'};
    
end

%% % CORRECT
subplot(1,3,1)
hold on
bar(1, mean(correct_per_mouse)*100,'FaceColor',[0.5 .5 .5],'LineStyle','none')
% bar(1, mean(correct_per_mouse)*100,'FaceColor',[1 1 1],'EdgeColor',[0.5 0.5 0.5])

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    plot(1+jitter, [correct_per_mouse(m)]*100  ,mouse_symbols{m},'color','k', 'MarkerEdgeColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
xticks([1])
xticklabels({['Imaging Sessions']})
ylabel('% correct')

% [sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
% plot_pval_star(0,max([performance.correct_opto])*100, sig_test.p_correct,[1 2],.15); %yl(2)+3

utils.set_current_fig;
set(gca,'FontSize',7);
%% % LEFT TURNS
subplot(1,3,2)
hold on
bar(1, mean(left_per_mouse)*100,'FaceColor',[0.5 0.5 0.5],'LineStyle','none')

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    plot(1+jitter, [left_per_mouse(m)]*100  ,mouse_symbols{m},'color','k', 'MarkerEdgeColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
xticks([1])
xticklabels({['Imaging Sessions']})
ylabel('% left')
ylim([0 75])

% [sig_test.p_left, h1] = signrank([performance.left_opto],[performance.left_ctrl]);
% plot_pval_star(0,max([performance.left_opto])*100, sig_test.p_left,[1 2],.15); %yl(2)+3

utils.set_current_fig;
set(gca,'FontSize',7);
%% TIME TO COMPLETE TURN
subplot(1,3,3)
hold on
bar(1, mean(sec_to_turn_per_mouse),'FaceColor',[0.5 0.5 0.5],'LineStyle','none')

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    plot(1+jitter, [sec_to_turn_per_mouse(m)]  ,mouse_symbols{m},'color','k', 'MarkerEdgeColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
xticks([1])
xticklabels({['Imaging Sessions']})
ylabel({'seconds to'; 'turn onset'})

% [sig_test.p_turn_onset, h1] = signrank(temp(:,1),temp(:,2));
% plot_pval_star(0,max(cellfun(@mean,{performance.turn_onset_opto}))/30, sig_test.p_turn_onset,[1 2],.15); %yl(2)+3

utils.set_current_fig;
set(gca,'FontSize',7);
% %% perform statistical analysis
% [sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
% [sig_test.p_left, h1] = signrank([performance.left_opto],[performance.left_ctrl]);
% [sig_test.p_turn_onset, h1] = signrank(temp(:,1),temp(:,2));

figure(5557);clf;
[pos] = utils.calculateFigurePositions(6,2,.5,[],[]);
% subplot(1,3,1)
hold on
bar(1, mean(correct_per_mouse)*100,'FaceColor',[0.5 .5 .5],'LineStyle','none')
% bar(1, mean(correct_per_mouse)*100,'FaceColor',[1 1 1],'EdgeColor',[0.5 0.5 0.5])

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    plot(1+jitter, [correct_per_mouse(m)]*100  ,mouse_symbols{m},'color','k', 'MarkerEdgeColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
set(gca,'fontsize',7,'box','off','Units','Points','Position',[100,100,50,100],'FontName','Arial');

xticks([1])
labelArray = {'Imaging'; 'Sessions'}; 
xticklabels(strtrim(sprintf('%s\\newline%s\n', labelArray{:})));
% xticklabels({['Imaging Sessions']})
ylabel('% correct')

% [sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
% plot_pval_star(0,max([performance.correct_opto])*100, sig_test.p_correct,[1 2],.15); %yl(2)+3

% utils.set_current_fig;
% pos(:,4) = pos(:,4)+1;


% figure(5558);clf;
% 
% subplot(1,3,1)
% hold on
% % Violin({ [correct_per_mouse]*100 },1,'QuartileStyle','none','ShowMedian',logical(0),'ViolinColor', {[0,0,0;1,1,1]},'QuartileStyle','shadow','ViolinAlpha',{0.0});hold off
% Violin({ [correct_per_mouse]*100 },1,'QuartileStyle','none','ShowMedian',logical(0),'ViolinColor', {[0,0,0;1,1,1]},'EdgeColor',[0,0,0], 'QuartileStyle','boxplot');hold off
% 
% box off
% 
% set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
% xticks([1])
% xticklabels({['Imaging Sessions']})
% ylabel('% correct')
% ylim([50,100])
% % [sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
% % plot_pval_star(0,max([performance.correct_opto])*100, sig_test.p_correct,[1 2],.15); %yl(2)+3
% 
% utils.set_current_fig;
% set(gca,'FontSize',7);
%% boxplot
figure(5558);clf;
[pos] = utils.calculateFigurePositions(6,2,.5,[],[]);
hold on
h = boxplot((correct_per_mouse)*100, 'position', 1, 'width', 0.5, 'colors', [0.5,0.5,0.5],'symbol', 'o');
% set(findobj(gca, 'Type', 'Line'), 'LineWidth', 1);
hh = findobj('LineStyle','--','LineWidth',0.5); 
set(h(1:6), 'LineStyle','-','LineWidth',1.3);

for m = 1:n_mice
    jitter = (rand-.5) *.8;
    scatter(1 + jitter, correct_per_mouse(m) * 100, 20, ...
    'Marker', 'o', ...
    'MarkerEdgeColor', 'none', ...
    'MarkerFaceColor', [0.5 0.5 0.5], ...
    'MarkerFaceAlpha', 0.5);
end

set(gca, 'XLimMode', 'manual', 'XLim', [0 2]);
set(gca,'fontsize',7,'box','off','Units','Points','Position',[100,100,50,100]);

xticks(1)                 % ensure a tick exists where you want it
xticklabels({''})         % hide default tick label
xlabel({'Imaging','Sessions'}, 'FontSize', 7, 'FontWeight', 'normal','FontName','Arial');
ax = gca;
ax.XLabel.VerticalAlignment = 'top';   % push label closer to ticks if needed

xtickangle(0)
ylabel('% Correct')
ylim([50,100])


%% save figures

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
%     cd(save_data_directory)

    image_string = strcat('all_performance_dots_',num2str(size(performance,2)));
    saveas(5556,fullfile([save_data_directory image_string '_datasets.svg']));
    saveas(5556,fullfile([save_data_directory image_string '_datasets.fig']));
    exportgraphics(figure(5556),fullfile([save_data_directory image_string '_datasets.pdf']), 'ContentType', 'vector');
    exportgraphics(figure(5557),fullfile([save_data_directory image_string '_datasets_correct_only.pdf']), 'ContentType', 'vector');
    exportgraphics(figure(5558),fullfile([save_data_directory image_string '_datasets_correct_only_boxplot.pdf']), 'ContentType', 'vector');

end