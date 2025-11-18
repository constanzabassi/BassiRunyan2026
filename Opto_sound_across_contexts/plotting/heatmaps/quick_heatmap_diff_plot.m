all_means = {}; all_means2 = {}; 
for ctx = 1:2
    temp = []; temp2= [];
    for dataset = 1:24
        temp = [temp; squeeze(mean(context_data.dff{ctx,dataset}.stim,1))];
        temp2 = [temp; squeeze(mean(context_data.dff{ctx,dataset}.ctrl,1))];
%         temp2 = [temp2; squeeze(mean(context_data.dff{ctx,dataset}.z_ctrl,1))];
        
    end
    all_means{ctx} = temp;
    all_means2{ctx} = temp2;
end

data1 = all_means2{1,1}; %trial_avg{1, 1}.left.neuron_mean; %active
data2 = all_means2{1,2}; %trial_avg{1, 2}.left.neuron_mean; %passive

frames_to_sort = [50:59];
%%

data11 = all_means{1,1}; %trial_avg{1, 1}.left.neuron_mean; %active
data22 = all_means{1,2}; %trial_avg{1, 2}.left.neuron_mean; %passive
[y_axis,inds] = max([data11(:,frames_to_sort)-data22(:,frames_to_sort)],[],2);
[~,value] = sort(y_axis,'descend');

figure(2);clf;colormap redblue
imagesc(data11(value,:)-data22(value,:)); caxis([-.2,.2]);
xline(61,'w','LineWidth',2)
title('Active - Passive','FontWeight','normal');
xlabel('Time (s)');
ylabel('Neuron #');
% Add time axis in seconds
[xticks_in, xticks_lab] = utils.x_axis_sec_aligned(...
    61, size(data11,2), 1);
xticks(xticks_in);
xticklabels(xticks_lab);
utils.set_current_fig; 
cb = colorbar;
cb.Label.String = 'Difference ΔF/F';
cb.Label.Rotation = 270;
curr_position =  cb.Label.Position;
cb.Label.Position = [curr_position(1)+.5,curr_position(2:3)];
set(gcf, 'Position', [100 100 190 190]);
exportgraphics(gcf,fullfile('W:\Connie\results\Bassi2025\fig3\pre_engagement\','avg_difference_stim_trials.pdf'), 'ContentType', 'vector');

diff  = mean(data11(:,frames_to_sort)-data22(:,frames_to_sort),2);
figure(3);clf;
% hist(diff)
histogram(diff,'BinWidth',0.05,'FaceColor',[0.5,0.5,0.5],'Normalization','probability'); 
xlabel('Difference Pre Active vs Passive')
ylabel('Fraction Neurons')
set(gcf, 'Position', [100 100 250 200]);

%%
% %sort based on activity in the pre period
% [y_axis,inds] = max(data1(:,frames_to_sort),[],2);
% [~,value] = sort(y_axis,'descend');
% r= 1:length(inds);
% r(value) = r;
% r=r';
% 
% figure(1);clf;
% colormap viridis
% caxis_lims = [-.5 1]; %caxis([-.25 .9])
% subplot(1,2,1); 
% imagesc(data1(value,:)); caxis(caxis_lims);
% xline(61,'w','LineWidth',2)
% % Format plot
% title('Active','FontWeight','normal');
% xlabel('Time (s)');
% ylabel('Neuron #');
% % Add time axis in seconds
% [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(...
%     61, size(data1,2), 1);
% xticks(xticks_in);
% xticklabels(xticks_lab);
% colorbar
% utils.set_current_fig; 
%                
% subplot(1,2,2); 
% imagesc(data2(value,:));caxis(caxis_lims);
% colorbar
% xline(61,'w','LineWidth',2);
% title('Passive','FontWeight','normal');
% xlabel('Time (s)');
% ylabel('Neuron #');
% % Add time axis in seconds
% [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(...
%     61, size(data1,2), 1);
% xticks(xticks_in);
% xticklabels(xticks_lab);
% utils.set_current_fig; 
% set(gcf, 'Position', [100 100 500 300]);
% 
% data11 = all_means{1,1}; %trial_avg{1, 1}.left.neuron_mean; %active
% data22 = all_means{1,2}; %trial_avg{1, 2}.left.neuron_mean; %passive
% [y_axis,inds] = max([data11(:,frames_to_sort)-data22(:,frames_to_sort)],[],2);
% [~,value] = sort(y_axis,'descend');
% 
