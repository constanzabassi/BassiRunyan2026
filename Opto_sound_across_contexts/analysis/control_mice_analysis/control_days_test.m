mouse_date={'HA12-00/2023-02-17','HA12-00/2023-02-24','HA12-00/2023-03-02','HA12-00/2023-03-17','HA12-00/2023-03-23','HA12-00/2023-04-11', ...
    'HA13-1L/2023-02-17','HA13-1L/2023-02-24','HA13-1L/2023-03-02','HA13-1L/2023-03-17','HA13-1L/2023-03-23','HA13-1L/2023-04-11', ...
    'GE4-1L/2022-10-06','GE4-1L/2022-10-11','GE4-1L/2022-10-18','GE4-1L/2022-10-20','GE4-1L/2022-10-25'};

% need to make all cells for 'HA13-1L/2023-03-13','HA12-00/2023-03-13'
server = 'U:'; %//Volumes/
mouse_num(1:6)= 1;
mouse_num(7:12) = 2;
mouse_num(13:18) = 3;
%chose frames to compare
bframes = 10;
aframes = 10;
stim_frame = 61;
% variable to fill
avg_neural_change = [];
avg_running_change = [];
count = 0
for m = 1:length(mouse_date)
    mm = mouse_date(m)
    mm = mm{1,1};
    mm
    try 
        load(strcat('U:/Connie/ProcessedData/',mm,'/spont_stim/60/allcells.mat'));
        load(strcat('U:/Connie/ProcessedData/',mm,'/vel_aligned.mat'));
    catch
        load(strcat('V:/Connie/ProcessedData/',mm,'/spont_stim/60/allcells.mat'));
        load(strcat('V:/Connie/ProcessedData/',mm,'/vel_aligned.mat'));
    end
    [stim_matrix, ctrl_matrix,mod_matrix,z_stim_matrix] = make_tr_cel_time(allcells)
    stim_matrix_cells = squeeze(mean(stim_matrix,2)); %mean across cells, gives trials vs time
    ctrl_matrix_cells = squeeze(mean(ctrl_matrix,2)); 
    [stim_diff,ctrl_diff] = difference_2event(stim_matrix_cells, ctrl_matrix_cells,stim_frame, bframes,aframes);
    se = std(stim_diff) / sqrt(size(stim_diff,1));
    if m < 7
        avg_neural_change(mouse_num(m), m,:) = [mean(stim_diff),se];
    elseif m<13
        avg_neural_change(mouse_num(m), m-6,:) = [mean(stim_diff),se];
    else
        avg_neural_change(mouse_num(m), m-12,:) = [mean(stim_diff),se];
    end
    

    [stim_diff_vel,ctrl_diff] = difference_2event(vel_aligned.opto,vel_aligned.control,stim_frame, bframes,aframes);
    se = std(stim_diff_vel) / sqrt(size(stim_diff_vel,1));
    if m < 7
        avg_running_change(mouse_num(m), m,:) = [mean(stim_diff_vel),se];
    elseif m<13
        avg_running_change(mouse_num(m), m-6,:) = [mean(stim_diff_vel),se];
    else
        avg_running_change(mouse_num(m), m-12,:) = [mean(stim_diff_vel),se];
    end
end


%%
colors_plot = [0 0.2 0.7; .7 0 .4; 0.3 0.6 0.5];
figure(); tiledlayout(2,1)
nexttile
hold on
for m =1:3
    %errorbar(1:6,avg_neural_change(m,:,1),avg_neural_change(m,:,2),'Color',colors_plot(m,:),'LineStyle','-','LineWidth',1.5);
    errorbar(1:5,avg_running_change(m,1:5,1),avg_running_change(m,1:5,2),'Color',colors_plot(m,:),'LineStyle','--','LineWidth',1.5);
end
hold off
xlabel('Days')
xticks([1:6])
ylabel('Speed change (post-pre)')
nexttile
hold on
for m =1:3
    errorbar(1:5,avg_neural_change(m,1:5,1),avg_neural_change(m,1:5,2),'Color',colors_plot(m,:),'LineStyle','-','LineWidth',1.5);
    %errorbar(1:6,avg_running_change(m,:,1),avg_running_change(m,:,2),'Color',colors_plot(m,:),'LineStyle','--','LineWidth',1.5);
end
hold off
xlabel('Days')
ylabel('Neural change (post-pre)')
xticks([1:6])
legend('Control mouse 1', 'Control mouse 2', 'Opto mouse')

% figure();
% hold on
% for m =1:2
%     scatter(avg_neural_change(m,:,1),avg_running_change(m,:,1),'MarkerEdgeColor',colors_plot(m,:),'LineWidth',1.5);
% end
% hold off
