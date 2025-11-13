%load info
info = load('V:\Connie\results\opto_sound_2025\context\data_info\info.mat').params.info;
addpath(genpath('C:\Code\Github\BassiRunyan2025\figure_coupling\supplemental'))
%% 1) get mean activity (uses only test)
overall_fr_pre = fr_across_contexts(info,'GLM_3nmf_pre');
overall_fr_passive = fr_across_contexts(info,'GLM_3nmf_passive');
% overall_fr_iti = fr_across_contexts(info,'GLM_3nmf_iti');

% cd('Y:\Connie\Code\GLM\coupling')
% 1.5) get inferred firing rates
overall_spike_rate_pre = spike_rate_across_contexts(info,'GLM_3nmf_pre');
% overall_spike_rate_iti = spike_rate_across_contexts(info,'GLM_3nmf_iti');
overall_spike_rate_passive = spike_rate_across_contexts(info,'GLM_3nmf_passive');

%%
plot_info.behavioral_contexts = {"Active","Passive"}; %{"Active","Active ITI","Passive"};

plot_info.colors_celltypes = [0.37 0.75 0.49 %light green
                            0.17 0.35 0.8  %blue
                            0.82 0.04 0.04]; % red  

%%
save_results = 'W:\Connie\results\Bassi2025\glm_coupling\supplemental\firing_rates';
% [mean_all ,stats] = plot_fr_distributions(overall_fr_pre,overall_fr_iti,overall_fr_passive, plot_info,'Mean Activity',save_results);
% [mean_all ,stats] = plot_fr_distributions(overall_spike_rate_pre,overall_spike_rate_iti,overall_spike_rate_passive, plot_info,'Est. Firing Rates',save_results);

plot_info.behavioral_contexts = {"Active","Passive"};
[mean_all ,stats] = plot_fr_distributions(overall_spike_rate_pre,overall_spike_rate_passive,[], plot_info,'Mean Activity',save_results);
[mean_all ,stats] = plot_fr_distributions(overall_spike_rate_pre,overall_spike_rate_passive,[], plot_info,'Est Firing Rates',save_results);
