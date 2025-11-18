function lm_stats = plot_linear_regression_lines(lme,tbl,context_all,ylabel_string,save_dir,varargin)
%extract table variables
var_names = tbl.Properties.VariableNames;
slope = lme.Coefficients.Estimate(2)
pval_slope = lme.Coefficients.pValue(2);

% separate into contexts for plotting
tbl_active = tbl(context_all == 0,var_names);
tbl_passive = tbl(context_all == 1,var_names);

% % Predict using model (used when context was a separate predictor
% [yhat_active,  yci_active]  = predict(lme, tbl_active);
% [yhat_passive, yci_passive] = predict(lme, tbl_passive);


[yhat_active,  yci_active]  = predict(lme, tbl);
tbl_active = tbl(:,var_names);

% figure out which contexts were plotted
if all(context_all == 1 ) 
    contexts_to_plot = 2;
elseif all(context_all == 0) 
    contexts_to_plot = 1;
else
    contexts_to_plot = [1,2];
end
%% make plots!

positions = utils.calculateFigurePositions(1, 5, .5, []);

xvals = linspace(min(tbl{:,var_names{2}}), max(tbl{:,var_names{2}}), 100); %max value of the predictor axis (x)
% Passive line
pred_active = lme.Coefficients.Estimate(1) + ...
               lme.Coefficients.Estimate(2) * xvals;

figure(103); clf; hold on;
if isequal(contexts_to_plot,[1,2]) || isequal(contexts_to_plot,2)
    scatter(tbl{context_all==0,var_names{2}}, tbl{context_all==0,var_names{1}}, 5,'MarkerEdgeColor',[0.2 0.2 0.2], 'MarkerEdgeAlpha',.6)%[0.2 0.2 0.2], 'filled', 'MarkerFaceAlpha',1)
    scatter(tbl{context_all==1,var_names{2}}, tbl{context_all==1,var_names{1}}, 5,'MarkerEdgeColor',[0.8 0.8 0.8], 'MarkerEdgeAlpha',.6)%[0.8 0.8 0.8], 'filled', 'MarkerFaceAlpha',1)
else
    scatter(tbl{context_all==0,var_names{2}}, tbl{context_all==0,var_names{1}}, 5,'MarkerEdgeColor',[0.4 0.4 0.4], 'MarkerEdgeAlpha',.6)%[0.2 0.2 0.2], 'filled', 'MarkerFaceAlpha',1)
end

plot(xvals, pred_active, 'k', 'LineWidth', 2.2)


ylabel({ylabel_string;'(z-scored)'});

if nargin > 5
    xlabel({strcat(varargin{1,1},' Projection');'(z-scored)'})
    ylabel_string_updated = [ylabel_string varargin{1,1}];
else
    xlabel({'Engagement Projection';'(z-scored)'})
end

%set figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;
if nargin > 7 && ~isempty(varargin{1,3}) && ~isempty(varargin{1,4})
    xlim(varargin{1,3})
    ylim(varargin{1,4})
end
%include n, p value, r value, slope?
n_total = size(tbl,1);
% [r,p_val] = corr(table2array(tbl(:,1)),table2array(tbl(:,2)));
r = slope;
p_val = pval_slope;
default_position = 'topleft';
if nargin > 9
    default_position = varargin{1,5};
end
utils.place_text_labels({['n = ', num2str(n_total)]},'k',0,5,default_position,0.05)
utils.place_text_labels({['r = ', num2str(round(r,2))]},'k',0.1,5,default_position,0.05)
utils.place_text_labels({['p = ',num2str(p_val, '%.1e')]},'k',0.2,5,default_position,0.05)
if nargin > 6 && ~isempty(varargin{1,2})
    utils.place_text_labels({['r = ', num2str(round(varargin{1,2}(1),2)), 'p=',num2str(round(varargin{1,2}(2)))]},'k',0.1,5,'bottomleft',0.05)
end
utils.set_current_fig;

%save_stats
lm_stats.n = n_total;
lm_stats.r = r;
lm_stats.p_val = p_val;

% SECOND PLOT WITHOUT ANY SCATTER POINTS
% Plot in figure 103
figure(1003); clf; hold on;
% Use actual predictor values (x) for each context
x_passive = tbl_passive{:, var_names{2}};
x_active = tbl_active{:, var_names{2}};

% Sort x and corresponding predictions for clean fill plots
[x_active_sorted, idx_active] = sort(x_active);
yhat_active_sorted = yhat_active(idx_active);
yci_active_sorted = yci_active(idx_active, :);

% Plot passive trial predictions and CIs
if ismember(1,contexts_to_plot)
    fill([x_active_sorted; flipud(x_active_sorted)], ...
         [yci_active_sorted(:,1); flipud(yci_active_sorted(:,2))], ...
         [0.3 0.3 0.3], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    plot(x_active_sorted, yhat_active_sorted, 'k','LineWidth', 2);
else
    fill([x_active_sorted; flipud(x_active_sorted)], ...
         [yci_active_sorted(:,1); flipud(yci_active_sorted(:,2))], ...
         [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    plot(x_active_sorted, yhat_active_sorted,'Color', [0.6 0.6 0.6],'LineWidth', 2);
end

% Plot active trial predictions and CIs (if model includes context)

ylabel({ylabel_string;'(z-scored)'});
if nargin > 5
    xlabel({strcat(varargin{1,1},' Projection');'(z-scored)'})
    ylabel_string_updated = [ylabel_string varargin{1,1}];
else
    ylabel_string_updated = ylabel_string;
    xlabel({'Engagement Projection';'(z-scored)'})
end
%set figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
ax = gca;
ax.XLabel.FontSize = ax.FontSize;
ax.YLabel.FontSize = ax.FontSize;

% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(103,strcat('scatter_linear_regression_contexts',num2str(contexts_to_plot),num2str(ylabel_string_updated),'.fig'));
    exportgraphics(figure(103),strcat('scatter_linear_regression_contexts',num2str(contexts_to_plot),num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');

    saveas(1003,strcat('linear_lineonly_regression_contexts',num2str(contexts_to_plot),num2str(ylabel_string_updated),'.fig'));
    exportgraphics(figure(1003),strcat('linear_lineonly_regression_contexts',num2str(contexts_to_plot),num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');
    
    save(strcat('stats_lm_contexts',num2str(contexts_to_plot),num2str(ylabel_string_updated)),'lm_stats');
end
