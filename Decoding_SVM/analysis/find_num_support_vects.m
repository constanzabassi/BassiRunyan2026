function sup_vects = find_num_support_vects(svm)
for it = 1:size(svm,1)
    it
    for m = 1:size(svm,2)
        count = 0;
        m
        for ce = 1:size(svm,3) %4th will be all cells together no subsamples!
            for b = 1:size(svm{1,1,1}.mdl,2)
                sup_vects{it,m,ce}.length(1,b) = length(svm{it,m,ce}.mdl{b}.SupportVectors);
                cels = svm{it,m,ce}.mdl_param.mdl_cells;
                sup_logic = find(svm{it,m,ce}.mdl{b}.IsSupportVector);%cels(find(svm{it,m,ce}.mdl{b}.IsSupportVector));
                %sup_vects{it,m,ce}.cells(1,b) = sup_logic;
            end
        end
    end
end

%make quick plots
plot_info.colors_celltype = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04 % red  
                            0 0 0.5]; %dark purple

figure(30);clf;
[rows,columns] = determine_num_tiles(size(svm,2)); %uses length of input
tiledlayout(rows,columns);

for m = 1:size(svm,2)
ex_mouse = m;
nexttile

for ce = 1:4
    hold on; 
    title(svm{1,1,1}.info.mouse_date{1,m})
    
    temp = [ sup_vects{1:size(svm,1),m,ce}];
    temp_mat{m,ce}.length = cell2mat({temp.length}'); %gives num subsample iterations x timepoints
    % find squared error from the mean
    SEM= std(temp_mat{m,ce}.length)/sqrt(size(temp_mat{m,ce}.length,1));
    shadedErrorBar(1:size(temp_mat{m,ce}.length,2),mean(temp_mat{m,ce}.length,1), SEM, 'lineProps',{'color', plot_info.colors_celltype(ce,:)});

%     plot(output{ex_mouse,ce}.accuracy,'color',plot_info.colors_celltypes(ce,:));
%     plot(output{ex_mouse,ce}.shuff_accuracy,'color',[0.2 0.2 0.2]*ce);


%     for i = 1:length(event_onsets)
%         xline(event_onsets(i),'--k','LineWidth',1.5)
%         if i == 4
%             xline(event_onsets(i),'--k',{'turn onset'},'LineWidth',1.5)
%         end
%     end
yline(.5,'--k');
end
end
hold off

