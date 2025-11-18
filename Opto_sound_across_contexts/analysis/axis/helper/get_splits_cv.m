function cv_splits = get_splits_cv(total_trials, divisions,random_or_not, splits)
% Create cross-validation or random splits
%
% INPUTS:
%   total_trials   - total number of trials
%   divisions      - # of folds (if random_or_not==0) or test fraction denominator
%   random_or_not  - 0 = cross-validated folds, 1 = random splits
%   splits         - number of random splits (only used if random_or_not==1)
%
% OUTPUT:
%   cv_splits is a struct array with fields:
%       .train, .test
rng(5)
if random_or_not == 0
        % --------- CROSS-VALIDATED FOLDS ------------
        shuffled = randperm(total_trials);
        fold_sizes = floor(total_trials/divisions) * ones(1,divisions);
        remainder = total_trials - sum(fold_sizes);
        % Distribute leftover trials across first few folds
        fold_sizes(1:remainder) = fold_sizes(1:remainder) + 1;

        idx = 1;
        for f = 1:divisions
            test_idx = shuffled(idx:idx+fold_sizes(f)-1);
            train_idx = setdiff(shuffled, test_idx);
            cv_splits(f).train = train_idx;
            cv_splits(f).test  = test_idx;
            idx = idx + fold_sizes(f);
        end

    else
        % --------- RANDOM SPLITS --------------------
        test_size = round(total_trials/divisions); % fraction of trials in test
        for f = 1:splits
            shuffled = randperm(total_trials);
            test_idx = shuffled(1:test_size);
            train_idx = setdiff(1:total_trials, test_idx);
            cv_splits(f).train = train_idx;
            cv_splits(f).test  = test_idx;
        end
end

% %     % Shuffle all trial indices
% %     shuffled = randperm(total_trials);
% % 
% %     
% %     % Compute sizes
% %     nA = round(1/divisions * total_trials);
% %     nTrain = total_trials - nA; % remaining goes to train
% % 
% %     % Split
% %     trainA_idx = shuffled(1:nTrain);
% %     test_idx   = shuffled(nTrain+1:end);
% % 
% %     folds = {test_idx, trainA_idx};
% % 
% %     if random_or_not == 0 %make sure test trials in this fold are not test in other folds!
% %         for f = 1:divisions
% %             test_idx = folds{f};
% %             train_idx = [folds{setdiff(1:divisions,f)}]; % the other 2 folds
% %             half = floor(numel(train_idx)/2);
% %             cv_splits(f).train = train_idx;
% %             cv_splits(f).test   = test_idx;
% %         end
% %     else %randomly assign without folding them independently
% %         for f = 1:splits
% %             test_idx = folds{f};
% %             train_idx = ; % the other 2 folds
% %             cv_splits(f).train = train_idx;
% %             cv_splits(f).test   = test_idx;
% %         end
% %     end
% % end
