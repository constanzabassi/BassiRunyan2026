%% make scatter plots like chengcheng
%0) load data
%opto
opto_sig_mod_boot_thr = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot_thr.mat').sig_mod_boot_thr;
opto_sig_mod_boot = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot.mat').sig_mod_boot;
opto_mod = load('V:\Connie\results\opto_sound_2025\context\mod\ctrl\separate\mod_indexm.mat').mod_indexm;
opto_mod_prepost = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\mod_indexm.mat').mod_indexm;
opto_mod_prepost_num = load('V:\Connie\results\opto_sound_2025\context\mod\prepost_num\separate\mod_indexm.mat').mod_indexm;
opto_mod_num = load('V:\Connie\results\opto_sound_2025\context\mod\ctrl_num\separate\mod_indexm.mat').mod_indexm; %numerator


opto_mod_results = load('V:\Connie\results\opto_sound_2025\context\mod\ctrl\separate\mod_index_results.mat').results;
opto_sig_cells = opto_sig_mod_boot_thr(:,3); %from spontaneous context
opto_average = load('V:\Connie\results\opto_sound_2025\context\avg\trial_averaged_results.mat').avg_results;

%sound
sound_sig_mod_boot_thr = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot_thr.mat').sig_mod_boot_thr;
sound_sig_mod_boot = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot.mat').sig_mod_boot;
sound_mod = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_indexm.mat').mod_indexm;
sound_mod_num = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound_num\separate\mod_indexm.mat').mod_indexm;

sound_mod_results = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_index_results.mat').results;
[sound_sig_cells, ~] = union_sig_cells(sound_sig_mod_boot_thr(:,1)', sound_sig_mod_boot_thr(:,2)', sound_mod);
sound_average = load('V:\Connie\results\opto_sound_2025\context\sounds\avg\trial_averaged_results_sounds.mat').avg_results_sounds;
sound_stim_average = load('V:\Connie\results\opto_sound_2025\context\sounds\avg\trial_averaged_results_sounds_stim.mat').avg_results;
%%
%1) use modulation index and plot that across active and passive
save_dir = 'V:\Connie\results\opto_sound_2025\context\scatter_plots'
modl_fit = scatter_index_sigcells(opto_sig_cells, all_celltypes, [{opto_mod{:,1}}',{opto_mod{:,2}}'], plot_info, save_dir, 'Active Stim Mod', 'Passive Stim Mod');
modl_fit = scatter_index_sigcells(opto_sig_cells, all_celltypes, [{opto_mod_num{:,1}}',{opto_mod_num{:,2}}'], plot_info, save_dir, 'Active (stim+sound) - sound', 'Passive (stim+sound) - sound');

modl_fit = scatter_index_sigcells(sound_sig_cells, all_celltypes, [{sound_mod{:,1}}',{sound_mod{:,2}}'], plot_info, save_dir, 'Active Sound Mod', 'Passive Sound Mod');
modl_fit = scatter_index_sigcells(sound_sig_cells, all_celltypes, [{sound_mod_num{:,1}}',{sound_mod_num{:,2}}'], plot_info, save_dir, 'Active post-pre (sound)', 'Passive post-pre (sound)');

%%
%look at sound neurons in sound vs stim+sound to see if suppressed
modl_fit = scatter_index_sigcells(sound_sig_cells, all_celltypes, [{opto_mod_prepost{:,1}}',{sound_mod{:,1}}'], plot_info, save_dir, 'Active Stim+Sound Mod', 'Active Sound Mod');
modl_fit = scatter_index_sigcells(sound_sig_cells, all_celltypes, [{opto_mod_prepost{:,2}}',{sound_mod{:,2}}'], plot_info, save_dir, 'Passive Stim+Sound Mod', 'Passive Sound Mod');
modl_fit = scatter_index_sigcells(sound_sig_cells, all_celltypes, [{opto_mod_prepost_num{:,1}}',{sound_mod_num{:,1}}'], plot_info, save_dir, 'Active Stim+Sound Num', 'Active Sound Num');
modl_fit = scatter_index_sigcells(sound_sig_cells, all_celltypes, [{opto_mod_prepost_num{:,2}}',{sound_mod_num{:,2}}'], plot_info, save_dir, 'Passive Stim+Sound Num', 'Passive Sound Num');
[p_val_mod] = histogram_diff_index_sig_cells([], all_celltypes,   [{sound_mod{:,1}}',{opto_mod_prepost{:,1}}'], plot_info, save_dir, '|Active Sound Mod| - |Active Stim+Sound Mod|',1,[-.3,.3]);
[p_val_mod2] = histogram_diff_index_sig_cells([], all_celltypes,   [{sound_mod{:,2}}',{opto_mod_prepost{:,2}}'], plot_info, save_dir, '|Passive Sound Mod| - |Passive Stim+Sound Mod|',1,[-.3,.3]);

%% plot same thing but separating into sound/opto/sound+opto
save_dir = 'V:\Connie\results\opto_sound_2025\context\scatter_plots\pools';

plot_info.colors_celltypes = [0.3,0.2,0.6 ; 1,0.7,0; 0.3,0.8,1; 0.5,0.5,0.5]; %0.9/0.6/0.2 or 1,0.7,0
opto_only_sig_cells = setdiff_sig_cells(opto_sig_cells', sound_sig_cells,opto_mod);
sound_only_sig_cells = setdiff_sig_cells(sound_sig_cells(1,1:24),opto_sig_cells', opto_mod);
opto_sound_sig_cells = intersect_sig_cells(opto_sig_cells', sound_sig_cells,opto_mod);
all_cells =[cellfun(@(x) x.pyr_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.som_cells,all_celltypes,'UniformOutput',false);cellfun(@(x) x.pv_cells,all_celltypes,'UniformOutput',false)];
num_cells = cellfun(@length, all_cells );

pooled_cell_types = {};
for dataset = 1:24
    current_sig_cells = [sound_only_sig_cells{dataset}, opto_only_sig_cells{dataset}, opto_sound_sig_cells{dataset}];
%     pooled_cell_types{dataset}.unmodulated = setdiff(1:sum(num_cells(:,dataset)),current_sig_cells);
    pooled_cell_types{dataset}.sound = sound_only_sig_cells{dataset};
    pooled_cell_types{dataset}.opto = opto_only_sig_cells{dataset};
    pooled_cell_types{dataset}.both = opto_sound_sig_cells{dataset};

end

%look at sound neurons in sound vs stim+sound to see if suppressed
modl_fit = scatter_index_sigcells([], pooled_cell_types, [{opto_mod_prepost{:,1}}',{sound_mod{:,1}}'], plot_info, save_dir, 'Active Stim+Sound Mod', 'Active Sound Mod');
modl_fit = scatter_index_sigcells([], pooled_cell_types, [{opto_mod_prepost{:,2}}',{sound_mod{:,2}}'], plot_info, save_dir, 'Passive Stim+Sound Mod', 'Passive Sound Mod');
modl_fit = scatter_index_sigcells([], pooled_cell_types, [{opto_mod_prepost_num{:,1}}',{sound_mod_num{:,1}}'], plot_info, save_dir, 'Active Stim+Sound Num', 'Active Sound Num');
modl_fit = scatter_index_sigcells([], pooled_cell_types, [{opto_mod_prepost_num{:,2}}',{sound_mod_num{:,2}}'], plot_info, save_dir, 'Passive Stim+Sound Num', 'Passive Sound Num');
[p_val_mod] = histogram_diff_index_sig_cells([], pooled_cell_types,   [{sound_mod{:,1}}',{opto_mod_prepost{:,1}}'], plot_info, save_dir, '|Active Sound Mod| - |Active Stim+Sound Mod|',1,[-.3,.3]);
[p_val_mod2] = histogram_diff_index_sig_cells([], pooled_cell_types,   [{sound_mod{:,2}}',{opto_mod_prepost{:,2}}'], plot_info, save_dir, '|Passive Sound Mod| - |Passive Stim+Sound Mod|',1,[-.3,.3]);
[p_val_mod3] = histogram_diff_index_sig_cells([], pooled_cell_types,   [{sound_mod_num{:,1}}',{opto_mod_prepost_num{:,1}}'], plot_info, save_dir, '|Active Sound Num| - |Active Stim+Sound Num|',1,[-.3,.3]);
[p_val_mod4] = histogram_diff_index_sig_cells([], pooled_cell_types,   [{sound_mod_num{:,2}}',{opto_mod_prepost_num{:,2}}'], plot_info, save_dir, '|Passive Sound Num| - |Passive Stim+Sound Num|',1,[-.3,.3]);


modl_fit = scatter_index_sigcells([], pooled_cell_types, [{opto_mod{:,1}}',{sound_mod{:,1}}'], plot_info, save_dir, 'Active Delta Stim Mod', 'Active Sound Mod');
modl_fit = scatter_index_sigcells([], pooled_cell_types, [{opto_mod{:,2}}',{sound_mod{:,2}}'], plot_info, save_dir, 'Passive Delta Stim Mod', 'Passive Sound Mod');
[p_val_mod5] = histogram_diff_index_sig_cells([], pooled_cell_types,   [{sound_mod{:,1}}',{opto_mod{:,1}}'], plot_info, save_dir, '|Active Sound Mod| - |Active Delta Stim Mod|',1,[-.3,.3]);
[p_val_mod6] = histogram_diff_index_sig_cells([], pooled_cell_types,   [{sound_mod{:,2}}',{opto_mod{:,2}}'], plot_info, save_dir, '|Passive Sound Mod| - |Passive Delta Stim Mod|',1,[-.3,.3]);
