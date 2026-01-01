%% set up files
P = decoding_paths(); % User-specific roots (EDIT ONCE PER MACHINE)
data_root = P.data_root;
fig_root  = P.fig_root;

active_decoding_dir        = fullfile(data_root, 'Active_decoding', 'SVM');
active_passive_decoding_dir= fullfile(data_root, 'Active_Passive_decoding', 'SVM');
% Optional: warn if missing (don’t hard fail)
if ~exist(active_decoding_dir,'dir')
    warning('Active decoding dir not found: %s', active_decoding_dir);
end
if ~exist(active_passive_decoding_dir,'dir')
    warning('Active_Passive decoding dir not found: %s', active_passive_decoding_dir);
end
%% compare cellypes during active context
savepath = [];
stim_ctrl_labels = {};
event_names = {'sound_category','choice','outcome'};
do_passive = 0;
saved_decoding_dir = active_decoding_dir;
for e = 1:numel(event_names)
    ev = event_names{e};
    %full population across cell types in active (main figure)
    if ~isempty(fig_root); savepath = fullfile(fig_root, 'full', ev);end % or fullfile(fig_root, ev, 'active_passive')
    if ~exist(savepath,'dir') && ~isempty(fig_root), mkdir(savepath); end
    plot_final_svm_traces_boxplots_updated('full', ev, do_passive, savepath, stim_ctrl_labels, info, saved_decoding_dir);
    
    %n-match population across cell types in active (supplemental figure)
    if ~isempty(fig_root); savepath = fullfile(fig_root, 'nmatch', ev);end % or fullfile(fig_root, ev, 'active_passive')
    if ~exist(savepath,'dir') && ~isempty(fig_root), mkdir(savepath); end
    plot_final_svm_traces_boxplots_updated('nmatch', ev, do_passive, savepath, stim_ctrl_labels, info, saved_decoding_dir);
end
%% compare active/passive stim/ctrl
stim_ctrl_labels = {'Stim','No Stim'};
event_names = {'sound_category'};
do_passive = 1;
savepath = [];
saved_decoding_dir = active_passive_decoding_dir;

for e = 1:numel(event_names)
    ev = event_names{e};
    %sound active vs passive decoding (supplemental figure)
    if ~isempty(fig_root); savepath = fullfile(fig_root, 'nmatch_active_passive', ev);end % or fullfile(fig_root, ev, 'active_passive')
    if ~exist(savepath,'dir') && ~isempty(fig_root), mkdir(savepath); end
    plot_final_svm_traces_boxplots_updated('nmatch', ev, do_passive, savepath, stim_ctrl_labels, info, saved_decoding_dir);
    
    %stim vs control sound decoding (supplemental figure)
    if ~isempty(fig_root); savepath = fullfile(fig_root, 'opto_ctrl_active_passive', ev);end % or fullfile(fig_root, ev, 'active_passive')
    if ~exist(savepath,'dir') && ~isempty(fig_root), mkdir(savepath); end
    plot_final_svm_traces_boxplots_updated('stimctrl', ev, do_passive, savepath, stim_ctrl_labels, info, saved_decoding_dir);
end