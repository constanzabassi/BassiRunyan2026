function cv_splits = get_threeway_cv(total_trials)
% Create 3-way cross-validation splits
% OUTPUT: cv_splits is a struct array with fields:
%   .trainA, .trainB, .test

    [trainA_idx, trainB_idx, test_idx] = split_trials_threeway(total_trials);
    folds = {trainA_idx, trainB_idx, test_idx};

    for f = 1:3
        test_idx = folds{f};
        train_idx = [folds{setdiff(1:3,f)}]; % the other 2 folds
        % For symmetry, split train into A and B
        half = floor(numel(train_idx)/2);
        cv_splits(f).trainA = train_idx(1:half);
        cv_splits(f).trainB = train_idx(half+1:end);
        cv_splits(f).test   = test_idx;
    end
end
