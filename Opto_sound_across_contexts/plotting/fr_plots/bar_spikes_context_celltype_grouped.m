function all_stats = bar_spikes_context_celltype_grouped(spike_context_celltype,plot_info,savepath,name_string,ylims, ystring)
%plot_info.colors_celltypes,plot_info.behavioral_contexts,plot_info.celltype_names
colors_celltypes = plot_info.colors_celltypes;
behavioral_contexts = plot_info.behavioral_contexts;
celltype_names = plot_info.celltype_names;

figure(999);clf;
t = tiledlayout(1,size(spike_context_celltype,2));%,'TileSpacing','Compact','Padding','Compact' %need enough space to plot by celltypes not context!
for celtype = 1:size(spike_context_celltype,2)
    if ~isempty(spike_context_celltype{1,celtype}.stim)
        nexttile
        bar_context =[];SEM_cells = [];
        for context = 1:size(spike_context_celltype,1)
            bar_context = [bar_context; mean(spike_context_celltype{context,celtype}.stim,'omitnan')];
            SEM = std(spike_context_celltype{context,celtype}.stim,'omitnan')/sqrt(length(spike_context_celltype{context,celtype}.stim(~isnan(spike_context_celltype{context,celtype}.stim))));
            SEM_cells = [SEM_cells; SEM];
            all_stats.stats(context,celtype) = get_basic_stats(spike_context_celltype{context,celtype}.stim);
        end
        hold on
        for c = 1:size(spike_context_celltype,1) %by context?
    %         b(c).FaceColor = [1 1 1];%colors_celltypes(celtype,:);
    %         b(c).EdgeColor = colors_celltypes(celtype,:);
    %         b(c).LineWidth = 1.5;
            b = bar([c],bar_context(c),'FaceColor',[1,1,1],'EdgeColor',colors_celltypes(celtype,:),'LineWidth' , 1.5);
            xtips = b.XEndPoints;
            ytips = b.YEndPoints;
            errorbar(xtips,ytips,SEM_cells(c),'color',colors_celltypes(celtype,:),'LineWidth',1.5);
    
        end 
        xticks([1:length(behavioral_contexts)])
        xticklabels([behavioral_contexts])
        if celtype == 1 %only label the y axis once
            ylabel(ystring)
        end
        possible_tests = nchoosek(1:length(behavioral_contexts),2);
        yl = ylim;    
        if yl < 0.8
            yl = yl+0.04;%yl+0.06;
        end
            ct = 0;
            %perform kruskal wallis test to see if there are significant
            %differences!
            matrix_to_comp =[];
            for context = 1:size(spike_context_celltype,1)
                if context == 1
                    spike_context_celltype{context,celtype}.stim = spike_context_celltype{context,celtype}.stim';
                end
                matrix_to_comp(:,context) = spike_context_celltype{context,celtype}.stim;
            end
            [KW_Test.stimcontext_p_val,KW_Test.stimcontext_tbl, KW_Test.stimcontext_stats_cell] = kruskalwallis(matrix_to_comp(:,1:length(behavioral_contexts)),[1:length(behavioral_contexts)],'off');


            for t = 1:size(possible_tests,1)
                %[p_stim(t,celtype),h_stim(t)] = signrank(spike_context_celltype{possible_tests(t,1),celtype}.stim, spike_context_celltype{possible_tests(t,2),celtype}.stim);
                [p_stim(t,celtype), observeddifference, effectsize_context(t)] = permutationTest_updatedcb(spike_context_celltype{possible_tests(t,1),celtype}.stim, spike_context_celltype{possible_tests(t,2),celtype}.stim, 10000,'paired',1);
                if length(possible_tests) == 2 %pairwise so no need for kw test
                    if p_stim(t,celtype) < 0.05 
                        xline_vars(1) = possible_tests(t,1); 
                        xline_vars(2) = possible_tests(t,2); 
                        xval = 0;  
                        plot_pval_star(xval, (yl(2)-0.03)+ct, p_stim(t,celtype), xline_vars,0.01)
                        ct = ct+yl(2)*.2;%0.05;
                    end
                else
                    if p_stim(t,celtype) < 0.05 && KW_Test.stimcontext_p_val < 0.05
                        xline_vars(1) = possible_tests(t,1); 
                        xline_vars(2) = possible_tests(t,2); 
                        xval = 0;  
                        plot_pval_star(xval, (yl(2)-0.03)+ct, p_stim(t,celtype), xline_vars,0.01)
                        ct = ct+yl(2)*.2;%0.05;
                    end
                end
            end
        if ~isempty(ylims)
            ylim(ylims)
        end
        set_current_fig;
        hold off
    end
    all_stats.KW{celtype} = KW_Test;
    xlim([0,length(behavioral_contexts)+1])
end
set(gcf,'units','points','position',[10,100,(500/3*length(behavioral_contexts)),200])
% set(gcf,'units','points','position',[10,100,500,200])

all_stats.pval = p_stim;
all_stats.ptest = 'paired permutation';
all_stats.possible_tests =possible_tests;
all_stats.name = name_string; 

% c_count = 1;
% hold on
% for celtype = 1:size(spike_context_celltype,2)
%     bar_context =[];SEM_cells = [];
%     for context = 1:size(spike_context_celltype,1)
%         bar_context = [bar_context; mean(spike_context_celltype{context,celtype}.stim)];
%         SEM = std(spike_context_celltype{context,celtype}.stim)/sqrt(length(spike_context_celltype{context,celtype}.stim));
%         SEM_cells = [SEM_cells; SEM];
%         
%     end
%     b = bar(c_count,bar_context);
%     for c = 1:size(spike_context_celltype,2)
%         b(c).FaceColor = [1 1 1];%colors_celltypes(celtype,:);
%         b(c).EdgeColor = colors_celltypes(celtype,:);
%         b(c).LineWidth = 1.5;
%         xtips = b(c).XEndPoints;
%         ytips = b(c).YEndPoints;
%         errorbar(xtips,ytips,SEM_cells(c),'color',colors_celltypes(celtype,:),'LineWidth',1.5);
%     end
%     c_count = c_count+1;
%     
% end
% legend(celltype_names,'Location','northeast')
if ~isempty(savepath)
    mkdir(savepath)
    cd(savepath)
    saveas(999,strcat('bar_spikes_context_celltype_grouped',name_string,'.svg'));%,num2str(length(chosen_mice)),'_datasets.svg'));
    saveas(999,strcat('bar_spikes_context_celltype_grouped',name_string,'.fig'));%,num2str(length(chosen_mice)),'_datasets.fig'));
    save(strcat('all_stats',name_string), "all_stats");
end