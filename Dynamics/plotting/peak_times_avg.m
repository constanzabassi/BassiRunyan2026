function [max_cel_avg,new_onsets,binss,original_onsets] = peak_times_avg (imaging_st,alignment,dynamics_info,active_passive )

for m = 1:length(imaging_st)
    m
    %peak_times_all = [];
    ex_imaging = imaging_st{1,m};
    if active_passive == 1
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30);
    else
        [align_info,alignment_frames,left_padding,right_padding] = find_align_info_updated (ex_imaging,30,2);
    end
    [aligned_imaging,~,~] = align_behavior_data (ex_imaging,align_info,alignment_frames,left_padding,right_padding,alignment);

    if ~isempty(dynamics_info.conditions)
        [all_conditions,~] = divide_trials_updated (ex_imaging,alignment.field_to_separate);
        aligned_imaging =  aligned_imaging(vertcat(all_conditions{dynamics_info.conditions,1}),:,:);
    end
    
    bin_size = dynamics_info.bin_size;
    binss = 1:bin_size:size(aligned_imaging,3)-bin_size;
    binned_data =[];
    for cel = 1:size(aligned_imaging,2)
        
    for b = 1:length(binss)
        if strcmp(alignment.data_type,'deconv')
            binned_data(:,cel,b) = sum(aligned_imaging(:,cel,binss(b):binss(b)+bin_size-1),3); %bin data
        else
            binned_data(:,cel,b) = mean(aligned_imaging(:,cel,binss(b):binss(b)+bin_size-1),3); %bin data
        end
    end
            


        % Load or generate your data
        aligned_trials = squeeze(binned_data(:,cel,:));
        % Number of trials
        num_trials = size(aligned_trials, 1);
        % Preallocate array to store peak times
%         peak_times = zeros(num_trials, 1);
%         for i = 1:num_trials
            mean_across_trials = mean(aligned_trials, 1);
            [~, peak_index] = max(mean_across_trials);
%             % Store the peak time
%             peak_times(i) = peak_index;
%         end
%         peak_times_all(cel,:) = mode(peak_times);
%         [max_cel_avg{m,cel},freq{m,cel}] = mode([max_cel{m,:,cel}]);
%         max_cel_avg{m,cel} = round(mean([max_cel{m,:,cel}],2));
        max_cel_avg{m,cel} = peak_index;%mode(peak_times);

% %         %alternative take mode across trials
% %                 % Preallocate array to store peak times
% %         peak_times = zeros(num_trials, 1);
% %         for i = 1:num_trials
% %             mean_across_trials = mean(aligned_trials, 1);
% %             [~, peak_index] = max(mean_across_trials);
% % %             % Store the peak time
% %             peak_times(i) = peak_index;
% %         end
% %         peak_times_all(cel,:) = mode(peak_times);
% %         [max_cel_avg{m,cel},freq{m,cel}] = mode([max_cel{m,:,cel}]);
% %         max_cel_avg{m,cel} = round(mean([max_cel{m,:,cel}],2));

    end
    
end
event_onsets = determine_onsets(left_padding,right_padding,alignment.number);
new_onsets = find(histcounts(event_onsets,binss));
original_onsets = event_onsets;