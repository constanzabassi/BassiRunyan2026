function [mean_all ,all_stats] = plot_fr_distributions(fr1,fr2,fr3, plot_info,string,save_dir)

mean_fr = [];
behavioral_contexts = plot_info.behavioral_contexts;
colors_celltypes = plot_info.colors_celltypes;
numcells = size(fr1,3);
%1) calculate mean across folds!
mean_fr(1,:,:) = squeeze(mean(fr1,1,'omitnan'));
num_contexts = 1;
if ~isempty(fr2)
    mean_fr(2,:,:) = squeeze(mean(fr2,1,'omitnan'));
    num_contexts = 2;
end

if ~isempty(fr3)
    mean_fr(3,:,:) = squeeze(mean(fr3,1,'omitnan')); %context, dataset, cell type!
    num_contexts = 3;
end

positions = utils.calculateFigurePositions(1,9,.2,[]);


figure(999);clf;
% t = tiledlayout(1,numcells);%,'TileSpacing','Compact','Padding','Compact' %need enough space to plot by celltypes not context!

for ce = 1:numcells
%     nexttile
    subplot(1,numcells,ce)
    bar_context =[];SEM_cells = [];
    for ct = 1:num_contexts
        mean_all(ct,ce) = squeeze(mean(mean_fr(ct,:,ce),2));
        std_all = std(mean_all(ct,ce), 0, 2);
        stats{ct,ce} = get_basic_stats(squeeze(mean_fr(ct,:,ce)));

        bar_context = [bar_context; mean_all(ct,ce)];
        SEM = std(squeeze(mean_fr(ct,:,ce)),'omitnan')/sqrt(length(mean_fr(ct,:,ce)));
        SEM_cells = [SEM_cells; SEM];
        all_stats.stats(ct,ce) = get_basic_stats(squeeze(mean_fr(ct,:,ce)));

    end
     hold on
        for c = 1:num_contexts %by context?
            b = bar([c],bar_context(c),'FaceColor',[1,1,1],'EdgeColor',colors_celltypes(ce,:),'LineWidth' , 1.);
            xtips = b.XEndPoints;
            ytips = b.YEndPoints;
            errorbar(xtips,ytips,SEM_cells(c),'color',colors_celltypes(ce,:),'LineWidth',1.);
    
        end 
        xticks([1:length(behavioral_contexts)])
        xticklabels([behavioral_contexts])


    [KW_Test.context_p_val,KW_Test.context_tbl, KW_Test.context_stats_cell] = kruskalwallis(squeeze(mean_fr(:,:,ce))',[1:length(behavioral_contexts)],'off');
    possible_tests = nchoosek(1:length(behavioral_contexts),2);
        yl = ylim;    
        cct = 0;
            for t = 1:size(possible_tests,1)
                [p_stim(t,ce), observeddifference, effectsize_context] = permutationTest_updatedcb(mean_fr(possible_tests(t,1),:,ce), mean_fr(possible_tests(t,2),:,ce), 10000,'paired',1);
                if p_stim(t,ce) < 0.05/numcells && KW_Test.context_p_val < 0.05/numcells
                    xline_vars(1) = possible_tests(t,1); 
                    xline_vars(2) = possible_tests(t,2); 
                    xval = 0;  
                    plot_pval_star(xval, (yl(2)-0.03)+cct, p_stim(t,ce), xline_vars,0.01)
                    cct = cct+yl(2)*.2;%0.05;
%                 else
%                     xline_vars(1) = possible_tests(t,1); 
%                     xline_vars(2) = possible_tests(t,2); 
%                     x_val = 0;
%                     y_val = (yl(2)+0.01)+cct;
%                     sig_symbol = 'n.s.';
%                     y_val_line_diff = 0.01;
%                     yMax = y_val;%max(max(whiskerplot([data1; data2])));
%                     text_height = yMax;
%                     text(x_val+mean([xline_vars(1),xline_vars(2)]), text_height, sig_symbol,'HorizontalAlignment', 'center', 'Color', 'k','FontSize',14);
%                     line([x_val+xline_vars(1), x_val+xline_vars(2)], [y_val-y_val_line_diff, y_val-y_val_line_diff], 'Color', 'k', 'LineWidth', 0.5);
%                     cct = cct+yl(2)*.2;
                end
            end
    
    
    % Customize the plot
    set(gca, 'XTickLabel', behavioral_contexts,'XTickLabelRotation',45);
    if ce == 1
        ylabel(string);
    end
    set_current_fig;
    xlim([0 length(behavioral_contexts)+1])
    all_stats.KW{ce} = KW_Test;
    set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(ce, :));
end

all_stats.pval = p_stim;
all_stats.ptest = 'paired permutation';
all_stats.possible_tests =possible_tests;
% set(gcf,'units','points','position',[10,100,(500/3*length(behavioral_contexts)),200])


if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
%     saveas(gcf,strcat(['bar_' string '_contexts.svg']));
    exportgraphics(gcf,strcat(['bar_' string '_contexts.pdf']), 'ContentType', 'vector');
    saveas(gcf,strcat(['bar_' string '_contexts.fig']));
    save(['all_stats_' string],'all_stats')
end