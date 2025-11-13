function [sig_test] = plot_performance(performance,save_data_directory,mouseID)
[r,c] = determine_num_tiles(size(performance,2));
figure(5555);clf;
% tiledlayout(r,c)
unique_mice = unique(mouseID);
n_mice = length(unique_mice);
correct_per_mouse_opto = [];
left_per_mouse_opto = [];
sec_to_turn_per_mouse_opto = [];
correct_per_mouse_ctrl = [];
left_per_mouse_ctrl = [];
sec_to_turn_per_mouse_ctrl = [];

for m = 1:n_mice
    curr_mouse = unique_mice(m);
    mouse_datasets = find(mouseID == curr_mouse);
    d = mouse_datasets;
    correct_per_mouse_opto = [correct_per_mouse_opto,mean([performance(d).correct_opto])];
    left_per_mouse_opto = [left_per_mouse_opto,mean([performance(d).left_opto])];
    sec_to_turn_per_mouse_opto = [sec_to_turn_per_mouse_opto,mean([performance(d).turn_onset_opto])];

    correct_per_mouse_ctrl = [correct_per_mouse_ctrl,mean([performance(d).correct_ctrl])];
    left_per_mouse_ctrl = [left_per_mouse_ctrl,mean([performance(d).left_ctrl])];
    sec_to_turn_per_mouse_ctrl = [sec_to_turn_per_mouse_ctrl,mean([performance(d).turn_onset_ctrl])];
    
end

sig_test.correct_opto = utils.get_basic_stats(correct_per_mouse_opto);
sig_test.left_per_mouse_opto = utils.get_basic_stats(left_per_mouse_opto);
sig_test.sec_to_turn_opto = utils.get_basic_stats(sec_to_turn_per_mouse_opto);
sig_test.correct_ctrl = utils.get_basic_stats(correct_per_mouse_ctrl);
sig_test.left_per_mouse_ctrl = utils.get_basic_stats(left_per_mouse_ctrl);
sig_test.sec_to_turn_ctrl = utils.get_basic_stats(sec_to_turn_per_mouse_ctrl);


%% % CORRECT
subplot(1,3,1)
hold on
bar(1, mean(correct_per_mouse_opto)*100,'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(correct_per_mouse_ctrl)*100,'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

for m = 1:n_mice
    plot([ [correct_per_mouse_opto(m)],[correct_per_mouse_ctrl(m)]]*100 ,'-','color','k', 'MarkerFaceColor', 'k');
end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Stim','Ctrl'})
ylabel('% correct')

[sig_test.p_correct, h1] = signrank([correct_per_mouse_opto],[correct_per_mouse_ctrl]);
utils.plot_pval_star(0,max([correct_per_mouse_opto])*100, sig_test.p_correct,[1 2],.15); %yl(2)+3

utils.set_current_fig;
set(gca,'FontSize',7);
%% % LEFT TURNS
subplot(1,3,2)
hold on
bar(1, mean(left_per_mouse_opto)*100,'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(left_per_mouse_ctrl)*100,'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

for m = 1:n_mice

plot([ [left_per_mouse_opto(m)], [left_per_mouse_ctrl(m)]]*100 ,'-','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Stim','Ctrl'})
ylabel('% left')
ylim([0 75])

[sig_test.p_left, h1] = signrank([left_per_mouse_opto],[left_per_mouse_ctrl]);
utils.plot_pval_star(0,max([left_per_mouse_opto])*100, sig_test.p_left,[1 2],.15); %yl(2)+3

utils.set_current_fig;
set(gca,'FontSize',7);
%% TIME TO COMPLETE TURN
subplot(1,3,3)
hold on
bar(1, mean(sec_to_turn_per_mouse_opto),'FaceColor',[0.9 0.6 0],'LineStyle','none')
bar(2, mean(sec_to_turn_per_mouse_ctrl),'FaceColor',[0.8 0.8 0.8],'LineStyle','none')

temp = [];
for m = 1:n_mice

plot([[sec_to_turn_per_mouse_opto(m)],[sec_to_turn_per_mouse_ctrl(m)]] ,'-','color','k', 'MarkerFaceColor', 'k');

end
set(gca, 'XLimMode', 'manual', 'XLim', [0 3]);
xticks([1 2])
xticklabels({'Stim','Ctrl'})
ylabel({'seconds to'; 'turn onset'})

[sig_test.p_turn_onset, h1] = signrank(sec_to_turn_per_mouse_opto,sec_to_turn_per_mouse_ctrl);
% utils.plot_pval_star(0,max(cellfun(@mean,{performance.turn_onset_opto})), sig_test.p_turn_onset,[1 2],.15); %yl(2)+3
utils.plot_pval_star(0,max([sec_to_turn_per_mouse_opto]), sig_test.p_turn_onset,[1 2],.15); %yl(2)+3

utils.set_current_fig;
set(gca,'FontSize',7);
% %% perform statistical analysis
% [sig_test.p_correct, h1] = signrank([performance.correct_opto],[performance.correct_ctrl]);
% [sig_test.p_left, h1] = signrank([performance.left_opto],[performance.left_ctrl]);
% [sig_test.p_turn_onset, h1] = signrank(temp(:,1),temp(:,2));
sig_test.test = 'signrank';
%% save figures

if ~isempty(save_data_directory)
    mkdir(save_data_directory)
%     cd(save_data_directory)

    image_string = strcat('paired_opto_ctrl_performance_dots_',num2str(size(performance,2)));
    saveas(5555,fullfile([save_data_directory image_string '_datasets.svg']));
    saveas(5555,fullfile([save_data_directory image_string '_datasets.fig']));
    exportgraphics(figure(5555),fullfile([save_data_directory image_string '_datasets.pdf']), 'ContentType', 'vector');
end