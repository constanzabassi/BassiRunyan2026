%make comparison of indices
opto_sig = load('V:\Connie\results\opto_sound_2025\context\mod\prepost\separate\sig_mod_boot_thr.mat').sig_mod_boot_thr;
% sound_sig =  load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\sig_mod_boot_thr.mat').sig_mod_boot_thr;
load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\combined_sig_cells.mat')
%get union of active and passive significant across contexts
[combined_opto_cells] = opto_sig(1:24,3)';

only_sound_cells = setdiff_sig_cells(combined_sig_cells,combined_opto_cells,mod_indexm);
only_opto_cells = setdiff_sig_cells(combined_opto_cells,combined_sig_cells,mod_indexm);
opto_sound_cells = union_sig_cells(combined_opto_cells,combined_sig_cells,mod_indexm);

sound_mod = load('V:\Connie\results\opto_sound_2025\context\sounds\mod\prepost_sound\separate\mod_indexm.mat').mod_indexm;
opto_mod = load('V:\Connie\results\opto_sound_2025\context\mod\ctrl\separate\mod_indexm.mat').mod_indexm;

%% make scatter plots of the distinct populations!
save_dir = 'V:\Connie\results\opto_sound_2025\context\mod\comparisons_across_indices';

modl_fit = scatter_index_sigcells(combined_opto_cells, all_celltypes, [{opto_mod{1:24,1}}',{sound_mod{1:24,1}}'], plot_info, [save_dir '\Active\opto_all\'], 'Active Opto Index', 'Active Sound Index');
modl_fit = scatter_index_sigcells(only_opto_cells, all_celltypes, [{opto_mod{1:24,1}}',{sound_mod{1:24,1}}'], plot_info, [save_dir '\Active\opto_only\'], 'Active Opto Index', 'Active Sound Index');
modl_fit = scatter_index_sigcells(opto_sound_cells, all_celltypes, [{opto_mod{1:24,1}}',{sound_mod{1:24,1}}'], plot_info, [save_dir '\Active\opto_sound\'], 'Active Opto Index', 'Active Sound Index');
modl_fit = scatter_index_sigcells(combined_sig_cells, all_celltypes, [{opto_mod{1:24,1}}',{sound_mod{1:24,1}}'], plot_info, [save_dir '\Active\sound_all\'], 'Active Opto Index', 'Active Sound Index');
modl_fit = scatter_index_sigcells(only_sound_cells, all_celltypes, [{opto_mod{1:24,1}}',{sound_mod{1:24,1}}'], plot_info, [save_dir '\Active\sound_only\'], 'Active Opto Index', 'Active Sound Index');

%%
modl_fit = scatter_index_sigcells(combined_opto_cells, all_celltypes, [{opto_mod{1:24,2}}',{sound_mod{1:24,2}}'], plot_info, [save_dir '\Passive\opto_all\'], 'Passive Opto Index', 'Passive Sound Index');
modl_fit = scatter_index_sigcells(only_opto_cells, all_celltypes, [{opto_mod{1:24,2}}',{sound_mod{1:24,2}}'], plot_info,  [save_dir '\Passive\opto_only\'], 'Passive Opto Index', 'Passive Sound Index');
modl_fit = scatter_index_sigcells(opto_sound_cells, all_celltypes, [{opto_mod{1:24,2}}',{sound_mod{1:24,2}}'], plot_info, [save_dir '\Passive\opto_sound\'], 'Passive Opto Index', 'Passive Sound Index');
modl_fit = scatter_index_sigcells(combined_sig_cells, all_celltypes, [{opto_mod{1:24,2}}',{sound_mod{1:24,2}}'], plot_info, [save_dir '\Passive\sound_all\'], 'Passive Opto Index', 'Passive Sound Index');
modl_fit = scatter_index_sigcells(only_sound_cells, all_celltypes, [{opto_mod{1:24,2}}',{sound_mod{1:24,2}}'], plot_info, [save_dir '\Passive\sound_only\'], 'Passive Opto Index', 'Passive Sound Index');
