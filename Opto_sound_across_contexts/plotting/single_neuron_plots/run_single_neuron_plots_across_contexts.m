
dataset_to_plot= 21;
sig_neurons_to_plot = [];
 modulation_type =1;
 plot_params = params.plot_info;
 plot_params.plot_mode = 'both';% stim ctrl or both
 plot_params.plot_avg = 0; %overall average (when using both)
 %plot active and passive averages
 plot_params.line_colors = [0,0.5,1;0.8,.1,.5];%[0.5,0.5,0.5;0,0,0]; %plotting passive then active
 plot_params.avg_traces = 1;
mod_index_results = load('W:\Connie\results\Bassi2025\fig3\mod\pre_engagement\simple\mod_index_results.mat').results;

wrapper_mod_index_single_plots_across_contexts(params.info, dff_st, stim_trials_context, ctrl_trials_context, mod_index_results, dataset_to_plot, sig_neurons_to_plot, modulation_type, 'engagement_pre_ctrl', plot_params)
