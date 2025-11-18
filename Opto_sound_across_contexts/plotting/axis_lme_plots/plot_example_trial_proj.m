ctx = 1;
celltype = 4;
for dataset = 9
    data = proj{dataset, celltype, ctx}.sound; %data = proj{dataset,celltype,ctx}.stim;%proj{dataset,celltype,ctx}.stim;%proj_ctrl{dataset, celltype, ctx}.sound; %proj{dataset,celltype,ctx}.stim;%proj{dataset,celltype,ctx}.stim%proj_ctrl{dataset, celltype, ctx}.sound;
    data2 = proj{dataset, celltype, ctx}.stim; %data = proj{dataset,celltype,ctx}.stim;%proj{dataset,celltype,ctx}.stim;%proj_ctrl{dataset, celltype, ctx}.sound; %proj{dataset,celltype,ctx}.stim;%proj{dataset,celltype,ctx}.stim%proj_ctrl{dataset, celltype, ctx}.sound;
end
figure(1);clf;
trial_lines = {'-','--','-.','-','--','-.','-','--','-.'}
hold on
count = 0;
for trials = 1:2
    count = count+1;
    plot(smooth(data(trials,:),3,'boxcar'),'Color',[0.3,0.2,0.6],'LineStyle',trial_lines{count},'LineWidth',1); %[0.3,0.2,0.6 ; 1,0.7,0]
    plot(smooth(data2(trials,:),3,'boxcar'),'Color',[1,0.7,0],'LineStyle',trial_lines{count},'LineWidth',1);
%     plot(data(trials,:),'Color',[0.3,0.2,0.6],'LineStyle',trial_lines{count},'LineWidth',.5); %[0.3,0.2,0.6 ; 1,0.7,0]
%     plot(data2(trials,:),'Color',[1,0.7,0],'LineStyle',trial_lines{count},'LineWidth',.5);
end
xline(61,'--','Color',[0.5,0.5,0.5],'LineWidth',1.5);
xlim([1,122])

set(gcf,'units','points','position',[100,100,20,80])
axis off
exportgraphics(figure(gcf),strcat('W:\Connie\results\Bassi2025\fig5\','example_trials_schematic_datasets9.pdf'), 'ContentType', 'vector');



