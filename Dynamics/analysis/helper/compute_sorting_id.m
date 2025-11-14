function sorting_id = compute_sorting_id(sort_data_cell)
% compute_sorting_id
%
% sort_data_cell: cell array where each entry is either:
%   - trials × neurons × time   (raw trials), OR
%   - neurons × time            (already averaged over trials)
%
% Returns:
%   sorting_id : index vector sorting neurons by the time of peak response
%                (ascending peak time).
%
% This matches your original logic where you did, e.g.:
%   mean_mouse_data_sort = cellfun(@(x) squeeze(mean(x,1)), mouse_data_sort, ...);
%   sorting_data = cat(1, mean_mouse_data_sort{:});   % neurons × time
%   [~, sorting_id] = max(sorting_data, [], 2);
%   [~, sorting_id] = sort(sorting_id, 'ascend');
if isempty(sort_data_cell)
    sorting_id = [];
    return;
end
mean_per_mouse = {};
for k = 1:numel(sort_data_cell)
    X = sort_data_cell{k};
    if isempty(X)
        continue;
    end
    % If it's trials × neurons × time, average over trials -> neurons × time
    if ndims(X) == 3
        % X: trials × neurons × time
        mresp =squeeze(mean(X,1));  % neurons × time
    % If it's 2D, assume neurons × time (like mean_mouse_data_sort)
    elseif ismatrix(X)
        % X: neurons × time
        mresp = X;
    else
        error('compute_sorting_id:UnsupportedDims', ...
              'Expected trials×neurons×time or neurons×time per cell element.');
    end
    mean_per_mouse{end+1,1} = mresp; %#ok<AGROW>
end
% If everything was empty, bail out
if isempty(mean_per_mouse)
    sorting_id = [];
    return;
end
% Concatenate neurons across mice: neurons_all × time
sorting_data = cat(1, mean_per_mouse{:});
% Peak time of each neuron
[~, peak_time] = max(sorting_data, [], 2);
% Sort neurons by peak time
[~, sorting_id] = sort(peak_time, 'ascend');
end