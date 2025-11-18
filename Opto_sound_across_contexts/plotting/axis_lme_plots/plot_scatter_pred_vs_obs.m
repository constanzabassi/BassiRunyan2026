function plot_scatter_pred_vs_obs(lme,axis_type,save_dir,varargin)

positions = utils.calculateFigurePositions(1, 5, .5, []);

residuals_values = lme.Residuals.Raw; %residuals(lme);
fitted_values = lme.Fitted; %fitted(lme);
figure(803);clf;
scatter(fitted_values, residuals_values,5,[0.4 0.4 0.4], 'filled', 'MarkerFaceAlpha',1)
xlabel('Fitted Values');
ylabel('Residuals');
% title('Residuals vs. Fitted');
h = refline(0,0);  % horizontal line at 0
h.LineWidth = 2;
h.Color = 'k';
%adjust figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;


figure(802);clf;
predicted_var= lme.Variables{:,1};
scatter(predicted_var, fitted_values,5,[0.4 0.4 0.4], 'filled', 'MarkerFaceAlpha',1)
xlabel(sprintf('Observed %s Proj', axis_type));
ylabel(sprintf('Predicted %s Proj', axis_type));
h = refline(1,0);  % ideal fit
h.LineWidth = 2;
h.Color = 'k';

%adjust figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;
utils.place_text_labels({['R² = ' num2str(round(lme.Rsquared.Adjusted,2))]},'k',.05,7,'topleft')


if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    if nargin > 3
        axis_type = varargin{1,1};
    end
    saveas(803,['scatter_residuals_vs_fitted_' axis_type '.fig']);
    exportgraphics(figure(803),['scatter_residuals_vs_fitted_' axis_type '.pdf'], 'ContentType', 'vector');

    saveas(802,['scatter_ob_vs_pred_' axis_type '.fig']);
    exportgraphics(figure(802),['scatter_ob_vs_pred_' axis_type '.pdf'], 'ContentType', 'vector');
%     save(strcat('hist_stats_n',num2str(length(chosen_datasets))),'hist_stats');
end