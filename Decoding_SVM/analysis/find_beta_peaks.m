function [beta_peaks,beta_peaks_shuff] = find_beta_peaks(svm_mat)
beta_peaks = [];
beta_peaks_shuff = [];
total_celltypes = size(svm_mat,2);

for ce = 1:total_celltypes
    mean_across_data = cellfun(@(x) mean(x.accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean(ce,:) = mean(mean_across_data,1,'omitnan');
    mean_data(ce,:,:) = mean_across_data;

    mean_across_data_shuff = cellfun(@(x) mean(x.shuff_accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data_shuff = vertcat(mean_across_data_shuff{1,:});
    overall_shuff(ce,:) = mean(mean_across_data_shuff,1,'omitnan');
    mean_data2(ce,:,:) = mean_across_data_shuff;

end