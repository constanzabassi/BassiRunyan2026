function plot_me_regression_lines_separate_ctx(lme,tbl,context,ylabel_string,save_dir,varargin)
%extract table variables
var_names = tbl.Properties.VariableNames;

% separate into contexts for plotting
tbl_active = tbl;

% Predict using model
[yhat_active,  yci_active]  = predict(lme, tbl_active, 'Conditional', false);

%% make plots!
positions = utils.calculateFigurePositions(1, 5, .5, []);
%get context colors
if context == 1
    colors_context = [0.4 0.4 0.4;0,0,0];
else
    colors_context = [0.7 0.7 0.7;0.4 0.4 0.4];
end
xvals = linspace(min(tbl{:,var_names{2}}), max(tbl{:,var_names{2}}), 100); %max value of the predictor axis (x)
% Passive line
pred_active = lme.Coefficients.Estimate(1) + ...
               lme.Coefficients.Estimate(2) * xvals;

figure(103); clf; hold on;
scatter(tbl{:,var_names{2}}, tbl{:,var_names{1}}, 5,'MarkerEdgeColor',colors_context(1,:), 'MarkerFaceAlpha',.8)%colors_context(1,:), 'filled', 'MarkerFaceAlpha',1) 
%plot slope
plot(xvals, pred_active, 'Color',colors_context(2,:), 'LineWidth', 2.2)
ylabel(ylabel_string)

if nargin > 5
    xlabel(strcat(varargin{1,1},' Projection'))
    ylabel_string_updated = [ylabel_string varargin{1,1}];
else
    xlabel('Engagement Projection')
end

%set figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

% SECOND PLOT WITHOUT ANY SCATTER POINTS
% Plot in figure 103
figure(1003); clf; hold on;
% Use actual predictor values (x) for each context
x_active = tbl_active{:, var_names{2}};

% Sort x and corresponding predictions for clean fill plots
[x_active_sorted, idx_active] = sort(x_active);
yhat_active_sorted = yhat_active(idx_active);
yci_active_sorted = yci_active(idx_active, :);

% Plot passive trial predictions and CIs
fill([x_active_sorted; flipud(x_active_sorted)], ...
     [yci_active_sorted(:,1); flipud(yci_active_sorted(:,2))], ...
     colors_context(1,:), 'EdgeColor', 'none', 'FaceAlpha', 0.3);
plot(x_active_sorted, yhat_active_sorted, 'Color',colors_context(2,:),'LineWidth', 2);


ylabel(ylabel_string);
if nargin > 5
    xlabel(strcat(varargin{1,1},' Projection'))
    ylabel_string_updated = [ylabel_string varargin{1,1}];
else
    ylabel_string_updated = ylabel_string;
    xlabel('Engagement Projection')
end
%set figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(103,strcat('me_regression_separate_ctx_',num2str(context),'_',num2str(ylabel_string_updated),'.fig'));
    exportgraphics(figure(103),strcat('me_regression_separate_ctx_',num2str(context),'_',num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');

    saveas(1003,strcat('me_lineonly_regression_separate_ctx_',num2str(context),'_',num2str(ylabel_string_updated),'.fig'));
    exportgraphics(figure(1003),strcat('me_lineonly_regression_separate_ctx_',num2str(context),'_',num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');

end