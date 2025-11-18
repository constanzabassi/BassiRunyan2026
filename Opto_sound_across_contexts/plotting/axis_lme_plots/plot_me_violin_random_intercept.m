function plot_me_violin_random_intercept(sound_proj_all,context_all,lme, axis_type)
figure(100); clf; hold on;
% raw distributions
Violin({sound_proj_all(context_all==0)},1,'ViolinColor',{[0,0,0]},'EdgeColor',[0,0,0],'QuartileStyle','boxplot');
Violin({sound_proj_all(context_all==1)},2,'ViolinColor',{[0.5,0.5,0.5]},'EdgeColor',[0.5,0.5,0.5],'QuartileStyle','boxplot');

% predicted means
pred_active = lme.Coefficients.Estimate(1); % intercept
pred_passive  = lme.Coefficients.Estimate(1) + lme.Coefficients.Estimate(3); % intercept + context
errorbar(1, pred_active, lme.Coefficients.SE(1), 'r', 'LineWidth', 2)
errorbar(2, pred_passive, lme.Coefficients.SE(1), 'r', 'LineWidth', 2)

% Check if context main effect is significant
pval_context = lme.Coefficients.pValue(3);  % context main effect

% Add significance marker to figure 100
if pval_context < 0.05
    if pval_context < 0.05 && pval_context >= 0.01
        stars = '*';
    elseif pval_context < 0.01 && pval_context >= 0.001
        stars = '**';
    elseif pval_context < 0.001 && pval_context >= 0.0001
        stars = '***';
    else
        stars = '****';
    end
        

    text(1.5, max([pred_active pred_passive]) + 0.05, stars, 'FontSize', 8, 'HorizontalAlignment', 'center');
end


ylabel(strcat(axis_type,' Projection'))
% title(strcat('Effect size plot: Sound projections')
xticks([1:2])
xticklabels({'Active','Passive'})

%% random effects across mice
[~,~,stats] = randomEffects(lme);
figure(102); clf; hold on;
bar(categorical(1:24), stats.Estimate)
xlabel('Animal')
ylabel('Random Intercept')
title('Random intercepts across animals')
