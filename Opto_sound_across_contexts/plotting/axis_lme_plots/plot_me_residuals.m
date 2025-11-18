function pval = plot_me_residuals(tbl,proj_type,save_dir,varargin)
positions = utils.calculateFigurePositions(1, 5, .5, []);

if nargin > 3
    default_res = varargin{1,1};
    y_string = varargin{1,1};
else
    default_res = 'Context';
    y_string = 'Engagement';

end
% Get residuals
mdl_eng = fitlm(tbl.(default_res), tbl.EngagementProj);
mdl_snd = fitlm(tbl.(default_res), tbl.(strcat(proj_type,'Proj')));
eng_resid  = mdl_eng.Residuals.Raw;
proj_resid = mdl_snd.Residuals.Raw;

% Compute Spearman correlation
[rho, pval] = corr(eng_resid, proj_resid, 'Type', 'Spearman');


figure(101); clf; hold on;
scatter(eng_resid, proj_resid, 10, tbl.Context)
xlabel(['Residual ' y_string])
ylabel(['Residual ' proj_type ]) %' Projection'
colormap([0.6 0.6 0.6; 0 0 0])
% legend({'Passive','Active'})
% title('Partial regression: Engagement vs Sound after Context')

% Add Spearman rho annotation
% if pval < 0.05
rho_text = sprintf('\\rho = %.2f, p = %.3g', rho, pval);
text(0.05, 1.2, rho_text, 'Units', 'normalized', ...
    'FontSize', 7, 'VerticalAlignment', 'top', 'FontWeight', 'normal');
% end
%set figure
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;

% Save results
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(101,strcat('me_residuals_axis_',num2str(proj_type),'_',default_res,'.fig'));
    exportgraphics(figure(101),strcat('me_residuals_axis_',num2str(proj_type),'_',default_res,'.pdf'), 'ContentType', 'vector');
end