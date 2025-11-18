function [axis_stability, mean_stability] = compute_axis_stability(projection, celltype, axis_type)
%check stability of axis across splits! (want high numbers)

n_splits   = size(projection,1);
n_datasets = size(projection,2);
% axis_stability(split1, split2, dataset)
axis_stability = NaN(n_splits, n_splits, n_datasets);
for d = 1:n_datasets
    % collect normalized axes for this dataset
    axes_all = cell(n_splits,1);
    for split = 1:n_splits
        if isfield(projection{split, d, celltype}, axis_type)
            ax = projection{split, d, celltype}.(axis_type);
            axes_all{split} = ax ./ norm(ax); % normalize for cosine similarity
        else
            warning('No axis field "%s" for dataset %d, split %d', axis_type, d, split);
            continue;
        end
    end
    % pairwise cosine similarity across splits
    for s1 = 1:n_splits
        for s2 = 1:n_splits
            if ~isempty(axes_all{s1}) && ~isempty(axes_all{s2})
                axis_stability(s1,s2,d) = dot(axes_all{s1}, axes_all{s2});
            end
        end
    end
end
% summarize: mean off-diagonal similarity per dataset
mean_stability = NaN(n_datasets,1);
for d = 1:n_datasets
    mat = squeeze(axis_stability(:,:,d));
    if ~all(isnan(mat(:)))
        mean_stability(d) = mean(mat(tril(true(n_splits),-1)),'omitnan');
    end
end
% print results
for d = 1:n_datasets
    fprintf('Dataset %d: mean axis stability = %.3f\n', d, mean_stability(d));
end
end