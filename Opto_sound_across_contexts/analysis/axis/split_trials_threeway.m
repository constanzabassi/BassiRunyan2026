function [trainA_idx, trainB_idx, test_idx] = split_trials_threeway(total_trials)
% Randomly split total_trials into 3 disjoint sets: trainA, trainB, and test

    % Shuffle all trial indices
    shuffled = randperm(total_trials);
    
    % Compute sizes
    nA = round(0.33 * total_trials);
    nB = round(0.33 * total_trials);
    nTest = total_trials - nA - nB; % remaining goes to test

    % Split
    trainA_idx = shuffled(1:nA);
    trainB_idx = shuffled(nA+1:nA+nB);
    test_idx   = shuffled(nA+nB+1:end);
end
