% Helper functions
function [fold1, fold2] = split_data(data)
    nTrials = size(data, 1);
    perm = randperm(nTrials);
    half = floor(nTrials/2);
    fold1 = data(perm(1:half), :, :);
    fold2 = data(perm(half+1:end), :, :);
end