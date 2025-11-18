function plot_fixed_effects(lme, lme2, save_dir, colors, labels, varargin)

% Extract fixed effects from both models
fe1 = lme.Coefficients;
fe2 = lme2.Coefficients;

% Ensure they have the same fixed effect names
fe_names = fe1.Name;
% assert(isequal(fe_names, fe2.Name), 'Fixed effect names do not match between models.')
if ~isempty(labels)
    fe_names = labels;
end
% Extract estimates and SEs
fe_est1 = fe1.Estimate;
fe_se1  = fe1.SE;
fe_est2 = fe2.Estimate;
fe_se2  = fe2.SE;

% Bar width and group offset
n_bars = length(fe_est1);
x = 1:n_bars;
if size(colors,1) > 1
    bar_width = 0.35;
    offset = 0.2;
    save_string = 'single';
else
    bar_width = 0.5;
    offset = 0;
    save_string = 'double';
end
if nargin > 5
    save_string = varargin{1,1};
end


% Function to get star label
% getStar = @(p) ...
%     (p < 0.0001) * "****" + ...
%     (p >= 0.0001) & (p < 0.001) * "***" + ...
%     ((p >= 0.001) & (p < 0.01)) * "**" + ...
%     ((p >= 0.01) & (p < 0.05)) * "*" + ...
%     "";


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

% Bars for model 2
if size(colors,1) > 1
    b2 = bar(x + offset, fe_est2, bar_width, 'FaceColor', 'w','EdgeColor',colors(2,:),'LineWidth',1, 'DisplayName', 'Model 2');
%     errorbar(x + offset, fe_est2, fe_se2, 'k.', 'CapSize', 2);
    xtips2 = b2.XEndPoints;
    ytips2 = b2.YEndPoints;
    for i = 1:length(xtips2)
        errorbar(xtips2(i), ytips2(i), fe_se2(i), 'color', colors(2,:), 'LineWidth', 1, 'CapSize', 2);
    end
end

%add pvalue stars
% Extract p-values
pvals1 = fe1.pValue;
pvals2 = fe2.pValue;
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

    % Model 2 (if used)
    if size(colors,1) > 1
        if ~isempty(pvals2)
            if ytips2(i) > 0
                utils.plot_pval_star(xtips2(i),ytips2(i) + fe_se2(i) + 0.02,pvals2(i),[0,0],0,colors(2,:));
            else
                utils.plot_pval_star(xtips2(i),ytips2(i) - fe_se2(i) - 0.06,pvals2(i),[0,0],0,colors(2,:));
            end

        end
    end
end

% Formatting
set(gca, 'XTick', x, 'XTickLabel', fe_names, 'XTickLabelRotation', 45)
ylabel('Beta Coefficients')
yline(0, '--k')
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
    saveas(107, strcat('bar_fixed_effects_',save_string,'_vs_engagement_axis.fig'));
    exportgraphics(figure(107), strcat('bar_fixed_effects_',save_string,'_vs_engagement_axis.pdf'), 'ContentType', 'vector');
end

% % Fixed effects from your models
% %           Intercept     Engagement  Context     Interaction
% sound_coef = [0.43493,    -0.01485,   -0.36989,    0.03398];
% sound_se   = [0.08576,     0.03412,    0.05224,    0.06140];
% stim_coef  = [0.82799,    -0.1538,     0.12935,    0.02981];
% stim_se    = [0.18338,     0.03248,    0.05096,    0.05083];
% % Combine into matrices
% coefs = [sound_coef; stim_coef];
% ses   = [sound_se; stim_se];
% % Labels
% labels = {'Intercept', 'Engagement', 'Context', 'Eng*Ctx'};
% % Plot
% figure; clf
% hold on
% x = 1:4;  % 4 fixed effects
% bar(x-0.15, coefs(1,:), 0.3, 'FaceColor', [0.6 0.6 0.6], 'DisplayName', 'Sound');
% bar(x+0.15, coefs(2,:), 0.3, 'FaceColor', [0.2 0.2 0.2], 'DisplayName', 'Stim');
% % Error bars
% errorbar(x-0.15, coefs(1,:), ses(1,:), 'k.', 'CapSize', 10)
% errorbar(x+0.15, coefs(2,:), ses(2,:), 'k.', 'CapSize', 10)
% % Labels
% set(gca, 'XTick', x, 'XTickLabel', labels)
% ylabel('Coefficient Estimate')
% title('Fixed Effects Estimates (± SE)')
% legend('Location', 'best')
% yline(0, '--k')
% box on