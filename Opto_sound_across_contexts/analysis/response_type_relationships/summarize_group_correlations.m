function summary_table = summarize_group_correlations(index_updated, index2_updated, all_celltypes)
% summarize_group_correlations - computes correlation and SEM for each group
%
% INPUTS:
%   index_updated   - cell array of baseline vectors (from scatter func)
%   index2_updated  - cell array of delta vectors (from scatter func)
%   all_celltypes   - cell array of structs with group field names
%
% OUTPUT:
%   summary_table   - MATLAB table with Group, Correlation, SEM, and N

    n_groups = length(index_updated);
    group_names = fields(all_celltypes{1});
    
    Group = strings(n_groups, 1);
    Correlation = NaN(n_groups, 1);
    SEM = NaN(n_groups, 1);
    N = zeros(n_groups, 1);
    
    for i = 1:n_groups
        x = index_updated{i};
        y = index2_updated{i};
        
        % Ensure column vectors
        x = x(:);
        y = y(:);

        % Remove NaNs
        valid_idx = ~isnan(x) & ~isnan(y);
        x = x(valid_idx);
        y = y(valid_idx);
        
        if ~isempty(x) && std(x) > 0 && std(y) > 0
            r = corr(x, y);
            sem = std(x) / sqrt(length(x));  % SEM of baseline for now
        else
            r = NaN;
            sem = NaN;
        end
        
        Group(i) = group_names{i};
        Correlation(i) = r;
        SEM(i) = sem;
        N(i) = length(x);
    end
    
    summary_table = table(Group, Correlation, SEM, N);
end
