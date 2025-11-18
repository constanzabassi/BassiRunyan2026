function [cv_mod_index, bootstrapResults] = calc_simple_mod_index_cv(...
    data1, data2, response_range, mod_type, nRepeats, nShuffles)
% calc_simple_mod_index_cv computes a cross-validated modulation index for simple
% comparisons between two datasets without left/right distinctions
%
%   Inputs:
%     data1          - 3D array of first condition responses 
%                      [nTrials x nNeurons x nFrames]
%     data2          - 3D array of second condition responses
%                      [nTrials x nNeurons x nFrames]
%     response_range - Cell array of frame indices for averaging
%     mod_type      - String: 'ctrl', 'influence', or 'prepost'
%     nRepeats      - (Optional) Number of CV repeats (default: 10)
%     nShuffles     - (Optional) Number of bootstrap shuffles (default: 0)
%
%   Outputs:
%     cv_mod_index    - 1 x nNeurons vector of modulation indices
%     bootstrapResults - Structure with bootstrap results (if nShuffles > 0)

% Set defaults
if nargin < 5 || isempty(nRepeats)
    nRepeats = 1;
end
nRepeats = 1;

if nargin < 6 || isempty(nShuffles)
    nShuffles = 0;
end

% Initialize
nNeurons = size(data1, 2);
cv_mod_all = zeros(nRepeats, nNeurons);
bootstrapResults = [];

    
% Compute averages across folds
% using mod_type to decide what to take the average of
[avg_data1, avg_data2] = utils.compute_fold_averages(data1, data2, response_range, mod_type); %fold 1

% Compute modulation indices
mod1 = compute_mod_index(avg_data1, avg_data2, mod_type);

% Final cross-validated index
cv_mod_index =mod1;

% Bootstrap if requested
if nShuffles > 0
    bootstrapResults.pVals = bootstrap_mod_index_cv(data1, data2, response_range, nShuffles, mod_type);
end

end
% function [cv_mod_index, bootstrapResults] = calc_simple_mod_index_cv(...
%     data1, data2, response_range, mod_type, nRepeats, nShuffles)
% % calc_simple_mod_index_cv computes a cross-validated modulation index for simple
% % comparisons between two datasets without left/right distinctions
% %
% %   Inputs:
% %     data1          - 3D array of first condition responses 
% %                      [nTrials x nNeurons x nFrames]
% %     data2          - 3D array of second condition responses
% %                      [nTrials x nNeurons x nFrames]
% %     response_range - Cell array of frame indices for averaging
% %     mod_type      - String: 'ctrl', 'influence', or 'prepost'
% %     nRepeats      - (Optional) Number of CV repeats (default: 10)
% %     nShuffles     - (Optional) Number of bootstrap shuffles (default: 0)
% %
% %   Outputs:
% %     cv_mod_index    - 1 x nNeurons vector of modulation indices
% %     bootstrapResults - Structure with bootstrap results (if nShuffles > 0)
% 
% % Set defaults
% if nargin < 5 || isempty(nRepeats)
%     nRepeats = 10;
% end
% if nargin < 6 || isempty(nShuffles)
%     nShuffles = 0;
% end
% 
% % Initialize
% nNeurons = size(data1, 2);
% cv_mod_all = zeros(nRepeats, nNeurons);
% bootstrapResults = [];
% 
% % Cross-validation loop
% for reps = 1:nRepeats
%     % Split data randomly into two folds
%     [fold1_data1, fold2_data1] = split_data(data1); %stim/left sound
%     [fold1_data2, fold2_data2] = split_data(data2);
%     
%     % Compute averages across folds
%     % using mod_type to decide what to take the average of
%     [avg_data1_fold1, avg_data2_fold1] = utils.compute_fold_averages(fold1_data1, fold1_data2, response_range, mod_type); %fold 1
%     [avg_data1_fold2, avg_data2_fold2] = utils.compute_fold_averages(fold2_data1, fold2_data2, response_range, mod_type); %fold 2
%     
%     % Compute modulation indices
%     mod1 = compute_mod_index(avg_data1_fold1, avg_data2_fold1, mod_type);
%     mod2 = compute_mod_index(avg_data1_fold2, avg_data2_fold2, mod_type);
%     
%     % Average the two folds
%     cv_mod_all(reps, :) = (mod1 + mod2) / 2;
% end
% 
% % Final cross-validated index
% cv_mod_index = mean(cv_mod_all, 1);
% 
% % Bootstrap if requested
% if nShuffles > 0
%     bootstrapResults.pVals = bootstrap_mod_index_cv(data1, data2, response_range, nShuffles, mod_type);
% end
% 
% end




