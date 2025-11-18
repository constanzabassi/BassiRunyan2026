dynamics_params.save_path = [params.info.savepath '\dynamics'];
info_str = 'deconv_all'; %data/ running trial data/ mod index sign
dynamics_params.name_string = 'sig_sound_cells_deconv5559';%'0104_pos_54-59trials3060_1sec' %include threshold, frames used, bins used (based on running speed)

dynamics_params.threshold_single_side = 1; %0 or 1
dynamics_params.mod_threshold  = 0.5;
dynamics_params.chosen_mice = [1:24];

sig_mod_boot_thr = get_thresholded_sig_cells(params.info, dynamics_params, mod_indexm, sig_mod_boot, sorted_cells, [],0);
[combined_sig_cells_dynamics, ~] = union_sig_cells(sig_mod_boot_thr(:,1)', sig_mod_boot_thr(:,2)', mod_indexm);
dynamics_params.sig_mod_boot_thr = opto_only_cells';%combined_sig_cells_dynamics; %combined_sig_cells_dynamics; %non_sig_cells;


%deconv_response{context,mouse,cel}.stim
%can change first value to context.dff or context.deconv_interp
[deconv_response,~] = unpack_context_mouse_celltypes(context_data.deconv_interp,dynamics_params.sig_mod_boot_thr,all_celltypes,[1:24]);

str = num2str(dynamics_params.mod_threshold);
if length(str) > 3
    str = [str(1) str(3) str(13) str(15)];
elseif length(str) == 0 
    str = 'all'
else
    str = [str(1) str(3)];
end
ylims = ([0 0.04])

mean_across_celltypes = celltypes_dynamics_traces(deconv_response,plot_info.colors_celltypes_3contexts,plot_info.lineStyles_contexts,plot_info.celltype_names,1:122,[60,62],params.info.savepath,[ str info_str],ylims);

frame_window = 63:92;%63:72;%64:84;%54:59;%70:75;% %%initially doing this 70:74 or 55:59; %90ms before photostim
% ylims = [0,.02]; %or [0,0.4]; [0,.22]

[spike_trial_cel_mouse,spike_context_celltype] = calc_spike_rate_across_context_celltype_choosetrials(deconv_response,frame_window,stim_trials_context, ctrl_trials_context);

plot_info.behavioral_contexts =  {"Active","Passive","Spont"};
dynamics_params.spike_stats = bar_spikes_context_celltype_grouped(spike_context_celltype,plot_info,dynamics_params.save_path,dynamics_params.name_string,[0,.4],'Est. Firing Rates (Hz)');
