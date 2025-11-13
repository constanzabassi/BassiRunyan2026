function data_to_plot = include_nans(data_to_plot,num_nans, nan_onsets)
nans_inserted = 0;  % track how many NaNs we added
if ~isempty(nan_onsets)
    % Insert NaNs at desired points
    nancols = nan(size(data_to_plot,1),num_nans); % create 2 NaN columns
    data_new = data_to_plot(:, 1:nan_onsets(1)-1);  % start with data up to first onset

    for i = 1:length(nan_onsets)
        % insert nancols
        data_new = [data_new, nancols];
        nans_inserted = nans_inserted + num_nans;
        % determine start and end indices for next data segment
        if i < length(nan_onsets)
            start_idx = nan_onsets(i) + 1;
            end_idx = nan_onsets(i+1) - 1;%num_nans;
        else
            start_idx = nan_onsets(i) + 1;
            end_idx = size(data_to_plot,2);
        end
    
        % append next data segment
        data_new = [data_new, data_to_plot(:, start_idx:end_idx)];
    end
else
    data_new = data_to_plot;
end
data_to_plot = data_new;  % overwrite original if needed
