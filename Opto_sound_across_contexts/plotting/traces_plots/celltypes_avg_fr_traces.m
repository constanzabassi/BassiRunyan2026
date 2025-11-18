function mean_across_celltype = celltypes_avg_fr_traces(deconv_response,colors,lineStyles_contexts,celltypes_ids,frames,stim_frame,save_dir,thrs,ylims,varargin)
f1 = figure(96);clf
t = tiledlayout(1,size(deconv_response,3),'TileSpacing','Compact','Padding','Compact');

for celtype = 1:size(deconv_response,3)
    
    nexttile
    for context = 1:size(deconv_response,1) 
        mean_across_cells_mice = [];
        mean_across_cells_mice_ctrl =[];
        for mouse = 1:size(deconv_response,2)
            cellCount = size(deconv_response{context,mouse,celtype}.stim,2);
            if size(deconv_response{context,mouse,celtype}.stim,1)>1 && size(deconv_response{context,mouse,celtype}.ctrl,1)>1
                mean_across_cells = mean(deconv_response{context,mouse,celtype}.stim); %gives mean across trials (cells x frames)
                mean_across_cells_ctrl = mean(deconv_response{context,mouse,celtype}.ctrl);
                
                if ~isnan(mean_across_cells)
                    mean_across_cells_mice = [mean_across_cells_mice;squeeze(mean_across_cells(1,:,frames))];
                    mean_across_cells_mice_ctrl = [mean_across_cells_mice_ctrl;squeeze(mean_across_cells_ctrl(1,:,frames))];
                    mean_across_celltype{context,celtype} = mean_across_cells_mice;
                end
            end
        end
        
        set(0, 'CurrentFigure', f1)
        title(celltypes_ids{celtype},'FontSize',12,'FontName','arial','FontWeight','normal');
        hold on
        b(context) = plot(mean(mean_across_cells_mice_ctrl));
        if length(unique(lineStyles_contexts))>1
            set( b(context), 'LineWidth', 1.5, 'LineStyle', lineStyles_contexts{context}, 'color',[0.5 0.5 0.5]);%linecolors(2,:));
        else
            set( b(context), 'LineWidth', 1.5, 'LineStyle', lineStyles_contexts{context}, 'color',[0.2+(context*.2) 0.2+(context*.2) 0.2+(context*.2)]);%linecolors(2,:));
        end

        a(context) = plot(mean(mean_across_cells_mice));
        if length(unique(lineStyles_contexts))>1
            set( a(context), 'LineWidth', 1.5, 'LineStyle', lineStyles_contexts{context}, 'color',colors(celtype,:));
        else
            set( a(context), 'LineWidth', 1.5, 'LineStyle', lineStyles_contexts{context}, 'color',colors((celtype-1)*3+context,:)); %(i-1)*3 + 1
        end

        %plotting 1 sec before and after?
        xlim([31 91])
        xticks([31 61 91])
        xticklabels([-1 0 1])

        [xticks_in, xticks_lab] = utils.x_axis_sec_aligned(stim_frame(1,1), length([31:91]));
        xticks(xticks_in);
        xticklabels(xticks_lab);

        hold off
    end




        yli = [0 ,max(mean(mean_across_cells_mice))+.01];
        if ~isempty(ylims)
            yli = ylims;
        end
%         grid on
    if ~isnan(yli(2))
        for f = 1:size(stim_frame,1)
            rectangle('Position', [stim_frame(f,1), yli(1), stim_frame(f,2)-stim_frame(f,1), yli(2)-yli(1)], 'FaceColor', [1 0.8 0.3 ], 'EdgeColor', 'none');
        end
    end
    utils.set_current_fig;


end

if ~isempty(save_dir)
    mkdir([save_dir '\avg_traces'])
    cd([save_dir '\avg_traces'])
    saveas(96,strcat('avg_traces_',(thrs),'.svg'));
    saveas(96,strcat('avg_traces_',(thrs),'.fig'));
end
