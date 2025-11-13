function [acc_peaks,acc_peaks_shuff,stats] = find_decoding_acc_peaks(svm_mat,varargin)
total_celltypes = size(svm_mat,2);
acc_peaks = zeros(total_celltypes,2);
acc_peaks_shuff = zeros(total_celltypes,2);

for ce = 1:total_celltypes
    mean_across_data = cellfun(@(x) mean(x.accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    if nargin > 1
         mean_across_data = mean_across_data(:,varargin{1,1});
    else
         mean_across_data = mean_across_data;
    end

    overall_mean(ce,:) = mean(mean_across_data,1,'omitnan'); % datasets x bins
    [maxval,loc] = max(overall_mean(ce,:) );
    acc_peaks(ce,:) = [loc,maxval];
    stats.max_stats = get_basic_stats(max(mean_across_data'));
    [~,locs] = max(mean_across_data');
    stats.loc_stats = get_basic_stats(locs);

    mean_across_data_shuff = cellfun(@(x) mean(x.shuff_accuracy,1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data_shuff = vertcat(mean_across_data_shuff{1,:});
    if nargin > 1
        mean_across_data_shuff = mean_across_data_shuff(:,varargin{1,1});
    else
        mean_across_data_shuff = mean_across_data_shuff;
    end
    overall_shuff(ce,:) = mean(mean_across_data_shuff,1,'omitnan');
    mean_data2(ce,:,:) = mean_across_data_shuff;
    
    [maxval,loc] = max(overall_shuff(ce,:) );
    acc_peaks_shuff(ce,:) = [loc,maxval];

end

function basic_stats = get_basic_stats(data1)
basic_stats.mean = mean(data1,'omitnan');
basic_stats.sd = std(data1,'omitnan');
% basic_stats.ci = paramci(data1);
basic_stats.n = length(data1);
basic_stats.n_nonan = length(data1(~isnan(data1)));
if length(data1) > 1
    [ci,bootstat] = bootci(1000,@(x)[mean(x,'omitnan') std(x,'omitnan')],data1); %ci (:,1) lower and upper bounds of mean, ci (:,2) lower and uppder bounds of standard deviation
    basic_stats.ci = ci;
    basic_stats.bootstat = bootstat;
else
    basic_stats.ci = nan;
    basic_stats.bootstat = nan;
end
