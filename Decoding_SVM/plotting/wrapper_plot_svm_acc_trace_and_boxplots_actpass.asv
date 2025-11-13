function acc_peaks_stats = wrapper_plot_svm_acc_trace_and_boxplots_actpass(svm_mat, mdl_param, save_string,savepath, ylims,svm_mat2,event_onsets, celltypes_to_comp,celltype_peak_comparison,varargin)
%wrapper to plot active and passive together!!
%create time series plots of svm accuracy across celltypes    
input_param{1,1}{1} = mdl_param;
plot_info = default_plot_info(input_param);
plot_info.event_onsets =  event_onsets;

mapped_labels = {'Pyr','SOM','PV','All','Top Pyr'}; %{'Active'};

updated_svm_mat_active = svm_mat(:,celltypes_to_comp);
updated_svm_mat_passive = svm_mat2(:,celltypes_to_comp);
%concatenate them together and save labels
concatenated_svm_mat = [updated_svm_mat_active,updated_svm_mat_passive];
%adjust plotting variables
% Generate labels for plotting
active_labels = cellfun(@(x) sprintf('Active %s', x), mapped_labels(celltypes_to_comp), 'UniformOutput', false);
passive_labels = cellfun(@(x) sprintf('Passive %s', x), mapped_labels(celltypes_to_comp), 'UniformOutput', false);

if nargin > 9
    active_labels = cellfun(@(x) sprintf(strcat(varargin{1,1}{1},' %s'), x), mapped_labels(celltypes_to_comp), 'UniformOutput', false);
    passive_labels = cellfun(@(x) sprintf(strcat(varargin{1,1}{2},' %s'), x), mapped_labels(celltypes_to_comp), 'UniformOutput', false);
end
plot_info.labels = [active_labels, passive_labels];  % Combine into single cell array
% adjust colors (make passive colors lighter)
% Get selected colors
active_colors = plot_info.colors_celltype(celltypes_to_comp, :);
% Create lighter passive versions (blend with white)
passive_colors = active_colors * 0.5 + 0.5;
% Combine active and passive colors
plot_info.colors_celltype = [active_colors; passive_colors];

% 1) plot trace across active and passive
bins_to_include = 32;
plot_info.xlims = [1,bins_to_include];
plot_svm_across_datasets(concatenated_svm_mat,plot_info,plot_info.event_onsets,mdl_param,[save_string '_concat_celltypes' num2str(celltypes_to_comp)],savepath,ylims,bins_to_include);
movegui(gcf,'center');%

%2) plot boxplot across contexts
[acc_peaks,acc_peaks_shuff,acc_peaks_stats] = find_decoding_acc_peaks(concatenated_svm_mat, 1:bins_to_include);

comp_window = 0; 
plot_svm_across_datasets_barplots(concatenated_svm_mat, plot_info, acc_peaks(celltype_peak_comparison,1), comp_window, ...
    [mdl_param.data_type save_string '_concat_celltypes' num2str(celltypes_to_comp)], savepath, ylims,[1:bins_to_include]);

comp_window = 9; %13 frames total for sound
plot_svm_across_datasets_barplots(concatenated_svm_mat, plot_info,3, comp_window, ...
    [mdl_param.data_type save_string '_concat_celltypes' num2str(celltypes_to_comp) '_1sec_window'], savepath, ylims,[1:bins_to_include]);

comp_window = 4; %13 frames total for sound
plot_svm_across_datasets_barplots(concatenated_svm_mat, plot_info,3, comp_window, ...
    [mdl_param.data_type save_string '_concat_celltypes' num2str(celltypes_to_comp) '_500ms_window'], savepath, ylims,[1:bins_to_include]);

%second sound
comp_window = 4; %13 frames total for sound
plot_svm_across_datasets_barplots(concatenated_svm_mat, plot_info,event_onsets(2), comp_window, ...
    [mdl_param.data_type save_string '_concat_celltypes' num2str(celltypes_to_comp) '_500ms_window'], savepath, ylims,[1:bins_to_include]);

%second sound
comp_window = 4; %13 frames total for sound
plot_svm_across_datasets_barplots(concatenated_svm_mat, plot_info,event_onsets(3), comp_window, ...
    [mdl_param.data_type save_string '_concat_celltypes' num2str(celltypes_to_comp) '_500ms_window'], savepath, ylims,[1:bins_to_include]);


