function bar_plot_coefficients(lme, lme2, save_dir, colors, labels,xlabels, save_string,varargin)
% bar_plot_coefficients(lme, lme2, save_dir, colors, labels, save_string)
% Handles one or multiple LMEs (in cell array form).
% If multiple LMEs are passed (e.g., {lme1, lme2}), they will be concatenated.

% If lme is a cell array, handle accordingly
if iscell(lme)
    if numel(lme) > 1
        % Concatenate all fixed effects from provided models
        all_coeffs = cell(size(lme));
        for k = 1:numel(lme)
            t = lme{k}.Coefficients(2:end,:);        % ignore intercept
            % put the rownames into a column so they are preserved
            t.Feature = t.Properties.RowNames;
            % optionally label which model each row came from
            t.Model = repmat({sprintf('model%d',k)}, height(t), 1);
            % clear row names so vertcat won't complain
            t.Properties.RowNames = {};
            all_coeffs{k} = t;
        end
        fe1 = vertcat(all_coeffs{:});
    else
        % Single model inside a cell array
        fe1 = lme{1}.Coefficients(2:end,:);
    end
else
    % lme is a single model (not in a cell)
    fe1 = lme.Coefficients(2:end,:);
end

% Do the same for lme2
if nargin >= 2 && ~isempty(lme2)
    if iscell(lme2)
        if numel(lme2) > 1
            all_coeffs = cell(size(lme2));
        for k = 1:numel(lme2)
            t = lme2{k}.Coefficients(2:end,:);        % ignore intercept
            % put the rownames into a column so they are preserved
            t.Feature = t.Properties.RowNames;
            % optionally label which model each row came from
            t.Model = repmat({sprintf('model%d',k)}, height(t), 1);
            % clear row names so vertcat won't complain
            t.Properties.RowNames = {};
            all_coeffs{k} = t;
        end
        fe2 = vertcat(all_coeffs{:});
        else
            fe2 = lme2{1}.Coefficients(2:end,:);
        end
    else
        fe2 = lme2.Coefficients(2:end,:);
    end
else
    fe2 = [];
end

% % Extract fixed effects from both models
% fe1 = lme.Coefficients(2,:); %ignore the first one which is the intercept
% fe2 = lme2.Coefficients(2,:); %ignore the first one which is the intercept

% Ensure they have the same fixed effect names
if ~isempty(labels)
    ylabels = labels;
end
% Extract estimates and SEs
fe_est1 = fe1.Estimate;
fe_se1  = fe1.SE;
fe_est2 = fe2.Estimate;
fe_se2  = fe2.SE;

% Bar width and group offset
n_bars = length(fe_est1);%+length(fe_est2);
x = 1:n_bars;
if size(colors,1) > 1
    bar_width = 0.35;
    offset = 0.2;
else
    bar_width = 0.5;
    offset = 0;
end


xticks_tracker = [];
% Plot
figure(107); clf; hold on;

    % Bars for model 1
    b1 = bar(x - offset, fe_est1, bar_width, 'FaceColor', 'w','EdgeColor', colors(1,:),'LineWidth',1, 'DisplayName', 'Model 1');
    
    % Error bars
    % errorbar(x - offset, fe_est1, fe_se1, 'k.', 'CapSize', 2);
    xtips = b1.XEndPoints;
    ytips = b1.YEndPoints;
    for i = 1:length(xtips)
        errorbar(xtips(i), ytips(i), fe_se1(i), 'color', colors(1,:), 'LineWidth', 1, 'CapSize', 2);
    end

    %add pvalue stars
    % Extract p-values
    pvals1 = fe1.pValue;
    bar_stats.(xlabels{1}).p_val = pvals1;
    bar_stats.(xlabels{1}).est = fe_est1;
    bar_stats.(xlabels{1}).se = fe_se1;
    % Add significance stars
    for i = 1:length(x)
        % Model 1
    %     star1 = getStar(pvals1(i));
        if ~isempty(pvals1(i))
            if ytips(i) > 0
                utils.plot_pval_star(xtips(i),ytips(i) + fe_se1(i) + 0.02,pvals1(i),[0,0],0,colors(1,:));
            else
                utils.plot_pval_star(xtips(i),ytips(i) - fe_se1(i) - 0.06,pvals1(i),[0,0],0,colors(1,:));
            end
        end
    
    end
    xticks_tracker = [xticks_tracker,x - offset];



if ~isempty(fe2 )
nbars2 = length(fe_est2);
%do model 2
x = [1:nbars2]+n_bars;
    % Bars for model 2
    b2 = bar(x + offset, fe_est2, bar_width, 'FaceColor', 'w','EdgeColor',colors(2,:),'LineWidth',1, 'DisplayName', 'Model 2');
    %     errorbar(x + offset, fe_est2, fe_se2, 'k.', 'CapSize', 2);
    xtips2 = b2.XEndPoints;
    ytips2 = b2.YEndPoints;
    for i = 1:length(xtips2)
        errorbar(xtips2(i), ytips2(i), fe_se2(i), 'color', colors(2,:), 'LineWidth', 1, 'CapSize', 2);
    end
    
    
    %add pvalue stars
    % Extract p-values
    pvals2 = fe2.pValue;
    bar_stats.(xlabels{2}).p_val = pvals2;
    bar_stats.(xlabels{2}).est2 = fe_est2;
    bar_stats.(xlabels{2}).se2 = fe_se2;
    % Add significance stars
    for i = 1:length(x)
        % Model 2 (if used)
    
        if ~isempty(pvals2)
            if ytips2(i) > 0
                utils.plot_pval_star(xtips2(i),ytips2(i) + fe_se2(i) + 0.02,pvals2(i),[0,0],0,colors(2,:));
            else
                utils.plot_pval_star(xtips2(i),ytips2(i) - fe_se2(i) - 0.06,pvals2(i),[0,0],0,colors(2,:));
            end
    
        end
        
    end
    xticks_tracker = [xticks_tracker,x + offset];
end
% Formatting
ylabel(ylabels)
yline(0, '--k')
if nargin > 7
    ylim(varargin{1,1})
end
set(gca, 'XTick', xticks_tracker, 'XTickLabel', repmat(xlabels,1,length(x)), 'XTickLabelRotation', 45)

% legend([b1 b2], {'Model 1', 'Model 2'}, 'Location', 'Best')
% Layout
positions = utils.calculateFigurePositions(1, 5, .5, []);
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
if n_bars == 1 %if only two bars make it half width
    % Keep center constant
    old_center = positions(1,1) + positions(1,3)/2;
    positions(1,3) = positions(1,3) * 0.5;
    positions(1,1) = old_center - positions(1,3)/2;
    set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
else
    utils.set_current_fig;
end

% Save
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(107, strcat('bar_coefficients_',save_string,'_vs_engagement_axis.fig'));
    exportgraphics(figure(107), strcat('bar_coefficients_',save_string,'_vs_engagement_axis.pdf'), 'ContentType', 'vector');
    save(strcat('stats_bar_coefficients_',save_string,'_vs_engagement_axis'),'bar_stats');
end

%
% % Plot
% figure(107); clf; hold on;
% for plts = 1:n_bars
% % Bars for model 1
% b1 = bar(x - offset, fe_est1, bar_width, 'FaceColor', 'w','EdgeColor', colors(plts,:),'LineWidth',1, 'DisplayName', 'Model 1');
% 
% % Error bars
% % errorbar(x - offset, fe_est1, fe_se1, 'k.', 'CapSize', 2);
% xtips = b1.XEndPoints;
% ytips = b1.YEndPoints;
% for i = 1:length(xtips)
%     errorbar(xtips(i), ytips(i), fe_se1(i), 'color', colors(plts,:), 'LineWidth', 1, 'CapSize', 2);
% end
% 
% % Bars for model 2
% b2 = bar(x + offset, fe_est2, bar_width, 'FaceColor', 'w','EdgeColor',colors(plts,:),'LineWidth',1, 'DisplayName', 'Model 2');
% %     errorbar(x + offset, fe_est2, fe_se2, 'k.', 'CapSize', 2);
% xtips2 = b2.XEndPoints;
% ytips2 = b2.YEndPoints;
% for i = 1:length(xtips2)
%     errorbar(xtips2(i), ytips2(i), fe_se2(i), 'color', colors(plts,:), 'LineWidth', 1, 'CapSize', 2);
% end
% 
% 
% %add pvalue stars
% % Extract p-values
% pvals1 = fe1.pValue;
% pvals2 = fe2.pValue;
% % Add significance stars
% for i = 1:length(x)
%     % Model 1
% %     star1 = getStar(pvals1(i));
%     if ~isempty(pvals1(i))
%         if ytips(i) > 0
%             utils.plot_pval_star(xtips(i),ytips(i) + fe_se1(i) + 0.02,pvals1(i),[0,0],0,colors(plts,:));
%         else
%             utils.plot_pval_star(xtips(i),ytips(i) - fe_se1(i) - 0.06,pvals1(i),[0,0],0,colors(plts,:));
%         end
%     end
% 
%     % Model 2 (if used)
% 
%     if ~isempty(pvals2)
%         if ytips2(i) > 0
%             utils.plot_pval_star(xtips2(i),ytips2(i) + fe_se2(i) + 0.02,pvals2(i),[0,0],0,colors(plts,:));
%         else
%             utils.plot_pval_star(xtips2(i),ytips2(i) - fe_se2(i) - 0.06,pvals2(i),[0,0],0,colors(plts,:));
%         end
% 
%     end
% set(gca, 'XTick', [x - offset*2,x + offset], 'XTickLabel', repmat(xlabels,1,length(x)), 'XTickLabelRotation', 45)
% 
% end
