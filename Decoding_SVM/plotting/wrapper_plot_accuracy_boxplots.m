function wrapper_plot_accuracy_boxplots(svm_mat, svm_mat2, event_onsets,mdl_param, savepath, onset_id, bins_to_include,celltype_peak_comparison, ylims)
    input_param{1,1}{1} = mdl_param;
plot_info = default_plot_info(input_param);
plot_info.event_onsets =  event_onsets;

plot_info.labels = {'Pyr','SOM','PV','All','Top Pyr'}; %{'Active'};

[acc_peaks,acc_peaks_shuff,acc_peaks_stats] = find_decoding_acc_peaks(svm_mat, 1:bins_to_include);
    save('acc_peaks_results','acc_peaks','acc_peaks_shuff','acc_peaks_stats');

    comp_window = 0; 
    plot_svm_across_datasets_barplots(svm_mat, plot_info, acc_peaks(celltype_peak_comparison,1), comp_window, ...
        [mdl_param.data_type], savepath, ylims);

    comp_window = 4; %onset+4 is about 500ms
    plot_svm_across_datasets_barplots(svm_mat, plot_info, onset_id, comp_window, ...
        [mdl_param.data_type], savepath, ylims);

    if ~isempty(svm_mat2)
        [acc_peaks_pass,acc_peaks_shuff_pass,acc_peaks_stats_pass] = find_decoding_acc_peaks(svm_mat2, 1:bins_to_include);
                save('acc_peaks_results_pass','acc_peaks_pass','acc_peaks_shuff_pass','acc_peaks_stats_pass');
        plot_svm_across_datasets_barplots(svm_mat2, plot_info, acc_peaks_pass(celltype_peak_comparison,1), comp_window, ...
            [mdl_param.data_type '_passive'], savepath, ylims);

            comp_window = 4; %onset+4 is about 500ms
        plot_svm_across_datasets_barplots(svm_mat2, plot_info, onset_id, comp_window, ...
            [mdl_param.data_type '_passive'], savepath, ylims);
    end
end
