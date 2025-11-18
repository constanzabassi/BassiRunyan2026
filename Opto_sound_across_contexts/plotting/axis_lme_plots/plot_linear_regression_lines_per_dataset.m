function plot_linear_regression_lines(correlations,ylabel_string,save_dir,varargin)

% correlations is size [splits x datasets]
% plots correlation coefficient per dataset (mean ± SEM across splits)
%% Prep data
n_datasets = size(correlations,2);
% Mean and SEM across splits
mean_corr = mean(correlations,1,'omitnan');       % 1 x n_datasets
sem_corr  = std(correlations,[],1,'omitnan') ./ sqrt(size(correlations,1));
%% Make plot
positions = utils.calculateFigurePositions(1, 5, .5, []);
figure(103); clf; hold on;
% Plot one point per dataset at its mean correlation, with SEM
errorbar(mean_corr, zeros(1,n_datasets), sem_corr, sem_corr, 'o', ...
    'horizontal', 'MarkerFaceColor',[0.2 0.2 0.8], 'MarkerEdgeColor','k', ...
    'CapSize',0, 'LineWidth',1);
% Labels
xlabel('Correlation coefficient (r)');
ylabel({ylabel_string; '(z-scored)'});
% Formatting
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1,:));
ylim([-0.5 0.5]); % keep dots visible along y
yticks([]);       % hide y-axis since it’s not meaningful here
xlim([min(mean_corr - sem_corr) - 0.05, max(mean_corr + sem_corr) + 0.05]);

%pearson correlations is size splits x datasets - want one dot with SEM per
%dataset
% %% make plots!
% 
% positions = utils.calculateFigurePositions(1, 5, .5, []);
% 
% xvals = linspace(min(#), max(#), 100); %max value of the predictor axis (x)
% % Passive line
% pred_active = lme.Coefficients.Estimate(1) + ...
%                lme.Coefficients.Estimate(2) * xvals;
% 
% figure(103); clf; hold on;
% scatter(tbl{context_all==0,var_names{2}}, tbl{context_all==0,var_names{1}}, 5,'MarkerEdgeColor',[0.2 0.2 0.2], 'MarkerEdgeAlpha',.8)%[0.2 0.2 0.2], 'filled', 'MarkerFaceAlpha',1)
% 
% ylabel({ylabel_string;'(z-scored)'});
% 
% if nargin > 5
%     xlabel({strcat(varargin{1,1},' Projection');'(z-scored)'})
%     ylabel_string_updated = [ylabel_string varargin{1,1}];
% else
%     xlabel({'Engagement Projection';'(z-scored)'})
% end

%set figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
%include n, p value, r value, slope?
if nargin > 6
    utils.place_text_labels({['r = ', num2str(round(varargin{1,2}(1),2)), 'p=',num2str(round(varargin{1,2}(2)))]},'k',0.1,5,'bottomleft',0.05)
end
utils.set_current_fig;

% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(103,strcat('scatter_linear_regression',num2str(ylabel_string_updated),'.fig'));
    exportgraphics(figure(103),strcat('scatter_linear_regression',num2str(ylabel_string_updated),'.pdf'), 'ContentType', 'vector');

end
