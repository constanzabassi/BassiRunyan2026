% make heatmap and cdf across contexts
function mouse_vel_context = speed_cdf_across_contexts(save_dir,mouse_vel,plot_info,stim_trials_context,ctrl_trials_context,chosen_mice,frames,varargin)

nContexts = length(stim_trials_context{1,1});
for dataset_id = 1:length(chosen_mice)
    current_dataset = chosen_mice(dataset_id);
    for context = 1:nContexts
        mouse_vel_context{current_dataset,context}.stim = mouse_vel(current_dataset).both_opto(stim_trials_context{1,current_dataset}{1,context},frames);
        if nargin > 7
            mouse_vel_context{current_dataset,context}.ctrl = varargin{1,1};
        end
        mouse_vel_context{current_dataset,context}.ctrl = mouse_vel(current_dataset).both_control(ctrl_trials_context{1,current_dataset}{1,context},frames);
    end
end
binss = ([-10:5:90]);
figure(95);clf
%t = tiledlayout(1,1,'TileSpacing','Compact','Padding','Compact');

for context = 1:nContexts
    mice_vel_context = cat(1,mouse_vel_context{:,context});% cat(1,mice_vel_context.stim);
    [stim_cdf,p1] = make_cdf(mean(cat(1,mice_vel_context.stim),2),binss);%make_cdf(mean(mouse_vel_context{1,c}.stim,2),binss); %find(ismember(sorted_sig_cells,sorted_pyr)
    [ctrl_cdf,p4] = make_cdf(mean(cat(1,mice_vel_context.ctrl),2),binss);

    %make plots
    hold on
    a(context) = plot(binss,stim_cdf);
    set( a(context), 'LineWidth', 1.5, 'LineStyle', plot_info.lineStyles_contexts{context}, 'color',plot_info.colors_stimctrl(1,:));%linecolors(2,:));

    b(context) = plot(binss,ctrl_cdf);
    set( b(context), 'LineWidth', 1.5, 'LineStyle', plot_info.lineStyles_contexts{context}, 'color',plot_info.colors_stimctrl(2,:));%linecolors(2,:));
end

hold off
grid on
legend(a, [plot_info.behavioral_contexts{1,:}],'Location', 'southeast'); %'Task','Passive','Spont'
ylim([0 1])
xlim([-10 90])
ylabel('Cumulative Fraction')
xlabel('Running Speed prior to Stim(cm/s)')
set(gca,'fontsize',14)

%%
if ~isempty(save_dir)
    mkdir(strcat(save_dir,'/running'))
    cd(strcat(save_dir,'/running'))
    saveas(95,strcat('speed_cdf_across_contexts_',num2str(frames(1)),'-',num2str(frames(end)),'frames_',num2str(length(chosen_mice)),'_datasets.svg'));
    saveas(95,strcat('speed_cdf_across_contexts_',num2str(frames(1)),'-',num2str(frames(end)),'frames_',num2str(length(chosen_mice)),'_datasets.fig'));
end