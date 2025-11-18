function plot_me_regression_lines(lme,tbl,context_all,ylabel_string,save_dir,varargin)
%extract table variables
var_names = tbl.Properties.VariableNames;

% separate into contexts for plotting
tbl_active = tbl(context_all == 0,var_names);
tbl_passive = tbl(context_all == 1,var_names);

% Predict using model
[yhat_active,  yci_active]  = predict(lme, tbl_active, 'Conditional', false);
[yhat_passive, yci_passive] = predict(lme, tbl_passive, 'Conditional', false);

if length(lme.Coefficients) == 2 %if context is not separated keep them together
    [yhat_active,  yci_active]  = predict(lme, tbl, 'Conditional', false);
    tbl_active = tbl(:,var_names);
end

%% make plots!

positions = utils.calculateFigurePositions(1, 5, .5, []);

xvals = linspace(min(tbl{:,var_names{2}}), max(tbl{:,var_names{2}}), 100); %max value of the predictor axis (x)
% Passive line
pred_active = lme.Coefficients.Estimate(1) + ...
               lme.Coefficients.Estimate(2) * xvals;
if length(lme.Coefficients) > 2
    % Active line
    pred_passive = (lme.Coefficients.Estimate(1) + lme.Coefficients.Estimate(3)) + ...
                   (lme.Coefficients.Estimate(2) + lme.Coefficients.Estimate(4)) * xvals;
end
figure(103); clf; hold on;
scatter(tbl{context_all==0,var_names{2}}, tbl{context_all==0,var_names{1}}, 5,'MarkerEdgeColor',[0.2 0.2 0.2], 'MarkerEdgeAlpha',.8)%[0.2 0.2 0.2], 'filled', 'MarkerFaceAlpha',1)
scatter(tbl{context_all==1,var_names{2}}, tbl{context_all==1,var_names{1}}, 5,'MarkerEdgeColor',[0.8 0.8 0.8], 'MarkerEdgeAlpha',.8)%[0.8 0.8 0.8], 'filled', 'MarkerFaceAlpha',1)

plot(xvals, pred_active, 'k', 'LineWidth', 2.2)
if length(lme.Coefficients) > 2
    plot(xvals, pred_passive, 'Color',[0.6 0.6 0.6], 'LineWidth', 2.2)
end


ylabel(ylabel_string)

if nargin > 5
    xlabel(strcat(varargin{1,1},' Projection'))
    ylabel_string_updated = [ylabel_string varargin{1,1}];
else
    xlabel('Engagement Projection')
end

%set figure
set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

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
fill([x_active_sorted; flipud(x_active_sorted)], ...
     [yci_active_sorted(:,1); flipud(yci_active_sorted(:,2))], ...
     [0.3 0.3 0.3], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
plot(x_active_sorted, yhat_active_sorted, 'k','LineWidth', 2);

% Plot active trial predictions and CIs (if model includes context)
if length(lme.Coefficients) > 2
    [x_passive_sorted, idx_passive] = sort(x_passive);
    yhat_passive_sorted = yhat_passive(idx_passive);
    yci_passive_sorted = yci_passive(idx_passive, :);

    fill([x_passive_sorted; flipud(x_passive_sorted)], ...
         [yci_passive_sorted(:,1); flipud(yci_passive_sorted(:,2))], ...
         [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.4);
    plot(x_passive_sorted, yhat_passive_sorted, 'Color', [0.6 0.6 0.6],'LineWidth', 2)
end

ylabel(ylabel_string);
if nargin > 5
    xlabel(strcat(varargin{1,1},' Projection'))
    ylabel_string_updated = [ylabel_string varargin{1,1}];
else
    ylabel_string_updated = ylabel_string;
    xlabel('Engagement Projection')
end
%set figure
set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(103,strcat('me_regression_',num2str(ylabel_string_updated),'.fig'));
    exportgraphics(figure(103),strcat('me_regression_',num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');

    saveas(1003,strcat('me_lineonly_regression_',num2str(ylabel_string_updated),'.fig'));
    exportgraphics(figure(1003),strcat('me_lineonly_regression_',num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');

end

% function plot_me_regression_lines(lme,engagement_proj_all,sound_proj_all,context_all,ylabel_string,save_dir,varargin)
% % Create prediction table for both contexts
% xvals = linspace(min(engagement_proj_all), max(engagement_proj_all), 100)';
% response_var = strcat(ylabel_string, 'Proj');  % e.g., 'SoundProj'
% 
% % Ensure Context is categorical and matches levels (active=0, passive=1)
% % Use numeric context values (match model definition)
% context_passive = ones(size(xvals));  % Context = 1 (passive)
% context_active  = zeros(size(xvals)); % Context = 0 (active)
% 
% % Add dummy AnimalID for random effect group (required)
% % dummy_id = repmat("dummy", size(xvals));  % or categorical("dummy")
% dummy_id = categorical(repmat("dummy", size(xvals)));
% 
% tbl_passive = table(xvals, context_passive, dummy_id, ...
%     'VariableNames', {'EngagementProj', 'Context', 'AnimalID'});
% tbl_active  = table(xvals, context_active,  dummy_id, ...
%     'VariableNames', {'EngagementProj', 'Context', 'AnimalID'});
% 
% 
% 
% % Predict using model
% [yhat_active,  yci_active]  = predict(lme, tbl_active, 'Conditional', false);
% [yhat_passive, yci_passive] = predict(lme, tbl_passive, 'Conditional', false);
% 
% %% make plots!
% 
% positions = utils.calculateFigurePositions(1, 5, .5, []);
% 
% xvals = linspace(min(engagement_proj_all), max(engagement_proj_all), 100);
% % Passive line
% pred_active = lme.Coefficients.Estimate(1) + ...
%                lme.Coefficients.Estimate(2) * xvals;
% % Active line
% pred_passive = (lme.Coefficients.Estimate(1) + lme.Coefficients.Estimate(3)) + ...
%                (lme.Coefficients.Estimate(2) + lme.Coefficients.Estimate(4)) * xvals;
% figure(103); clf; hold on;
% scatter(engagement_proj_all(context_all==0), sound_proj_all(context_all==0), 5,[0.2 0.2 0.2], 'filled', 'MarkerFaceAlpha',1)
% scatter(engagement_proj_all(context_all==1), sound_proj_all(context_all==1), 5,[0.8 0.8 0.8], 'filled', 'MarkerFaceAlpha',1)
% 
% % scatter(engagement_proj_all(context_all==0), sound_proj_all(context_all==0), 5,[0.3000    0.2000    0.6000],  'MarkerEdgeAlpha',0.3)
% % scatter(engagement_proj_all(context_all==1), sound_proj_all(context_all==1), 5,[0.7000    0.6000    1.000],  'MarkerEdgeAlpha',0.3)
% plot(xvals, pred_active, 'k', 'LineWidth', 2.2)
% plot(xvals, pred_passive, 'Color',[0.6 0.6 0.6], 'LineWidth', 2.2)
% 
% 
% ylabel(ylabel_string)
% 
% if nargin > 5
%     xlabel(strcat(varargin{1,1},' Projection'))
%     ylabel_string_updated = [ylabel_string varargin{1,1}];
% else
%     xlabel('Engagement Projection')
% end
% 
% %set figure
% set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
% utils.set_current_fig;
% 
% % SECOND PLOT WITHOUT ANY SCATTER POINTS
% % Plot in figure 103
% xvals = linspace(min(engagement_proj_all), max(engagement_proj_all), 100)';
% 
% figure(1003);clf; hold on;
% fill([xvals; flipud(xvals)], [yci_passive(:,1); flipud(yci_passive(:,2))], ...
%      [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.4)
% fill([xvals; flipud(xvals)], [yci_active(:,1); flipud(yci_active(:,2))], ...
%      [0.3 0.3 0.3], 'EdgeColor', 'none', 'FaceAlpha', 0.3)
% 
% plot(xvals, yhat_passive, 'Color',[0.6 0.6 0.6], 'LineWidth', 2)
% plot(xvals, yhat_active, 'k', 'LineWidth', 2)
% ylabel(ylabel_string)
% 
% if nargin > 5
%     xlabel(strcat(varargin{1,1},' Projection'))
%     ylabel_string_updated = [ylabel_string varargin{1,1}];
% else
%     ylabel_string_updated = ylabel_string;
%     xlabel('Engagement Projection')
% end
% %set figure
% set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(1, :));
% utils.set_current_fig;
% 
% % Save results
% if ~isempty(save_dir)
%     mkdir(save_dir)
%     cd(save_dir)
%     saveas(103,strcat('me_regression_',num2str(ylabel_string_updated),'.fig'));
%     exportgraphics(figure(103),strcat('me_regression_',num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');
% 
%     saveas(1003,strcat('me_lineonly_regression_',num2str(ylabel_string_updated),'.fig'));
%     exportgraphics(figure(1003),strcat('me_lineonly_regression_',num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');
% 
% end
