
info.chosen_mice = [24];
context_to_plot = 3;
sig_neurons_to_plot = [382,236,151]%[141,81];


dataset_to_plot= 21;
context_to_plot= 1:2;
sig_neurons_to_plot = [315,315];
 modulation_type =[];
 plot_params = params.plot_info;
 plot_params.plot_mode = 'ctrl';% stim ctrl or both
 plot_params.plot_avg = 1;


wrapper_mod_index_single_plots(params.info, dff_st_combined, stim_trials_context, ctrl_trials_context, mod_indexm, dataset_to_plot, context_to_plot, sig_neurons_to_plot, modulation_type, 'test', plot_params)
