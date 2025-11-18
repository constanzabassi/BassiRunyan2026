function proj_out = concat_splits_proj(proj)
% CONCAT_SPLITS_PROJ Concatenate trials across splits
% for each dataset, celltype, and context.
%
% If proj has 4 dimensions (splits × datasets × celltype × context),
% it merges across splits so final output is proj{dataset, celltype, context}.
%
% Each proj{s,d,c,ctx} is expected to be a struct where fields
% are [nTrials × nFrames] arrays. Fields are concatenated across splits.
%
% If proj is already 3D, it is returned unchanged.

    nd = ndims(proj);

    if nd == 4
        [nSplits, nDatasets, nCelltypes, nContexts] = size(proj);

        % Initialize output
        proj_out = cell(nDatasets, nCelltypes, nContexts);

        for d = 1:nDatasets
            for c = 1:nCelltypes
                for ctx = 1:nContexts

                    % Get fieldnames from first split
                    fnames = fieldnames(proj{1,d,c,ctx});

                    % Create empty struct to store concatenated fields
                    merged = struct();

                    % Loop through fields
                    for f = 1:numel(fnames)
                        fname = fnames{f};
                        all_trials = [];

                        % Loop over splits and concatenate trials
                        for s = 1:nSplits
                            if isfield(proj{s,d,c,ctx}, fname)
                                all_trials = [all_trials; proj{s,d,c,ctx}.(fname)];
                            end
                        end

                        merged.(fname) = all_trials;
                    end

                    proj_out{d,c,ctx} = merged;
                end
            end
        end

    elseif nd == 3
        proj_out = proj; % Already concatenated
    else
        error('proj must be 3D or 4D (got %dD)', nd);
    end
end