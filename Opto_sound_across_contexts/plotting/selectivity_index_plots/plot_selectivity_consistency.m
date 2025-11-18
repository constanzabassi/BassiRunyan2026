function plot_selectivity_consistency(selectivity_results_all, savepath)
    pool_types = {'left', 'right', 'nonsel'};
    
    figure('Position', [100 100 600 400]);
    positions = utils.calculateFigurePositions(1,5,0.5,[]);
    
    
    for p_idx = 1:length(pool_types)
        pool = pool_types{p_idx};
        active_mods = selectivity_results_all.both.(pool).active_max_mod;
        passive_mods = selectivity_results_all.both.(pool).passive_max_mod;
        
        subplot(1, length(pool_types), p_idx);
        scatter(active_mods, passive_mods, 40, 'filled', 'MarkerFaceAlpha', 0.5,'MarkerFaceColor',[0.5,0.5,0.5]);
        hold on;
        plot([-1 1], [-1 1], 'k--');
        xlabel('Active Modulation');
        ylabel('Passive Modulation');
        title([upper(pool) ' Selective'],'FontWeight','normal');
        axis square;
        set(gca,'Units', 'inches', 'Position', positions(p_idx, :),'FontSize',7)
        
        % Add correlation
        r = corrcoef(active_mods, passive_mods);
        if length(r) > 1
            text(0.1, 0.9, sprintf('R = %.2f', r(1,2)), 'Units', 'normalized','FontSize',6);
        end
    end

    % Save figure if path provided
        if ~isempty(savepath)
            mkdir(savepath)
            saveas(gcf, fullfile(savepath, ...
                'scatter_modulation_comparison_across_selective.png'));
            saveas(gcf, fullfile(savepath, ...
                 'scatter_modulation_comparison_across_selective.fig'));
            exportgraphics(gcf,'scatter_modulation_comparison_across_selective.pdf', 'ContentType', 'vector');
        end
end