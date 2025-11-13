function [betas, betas2] = get_SVM_betas_across_datasets(info,beta,varargin)
% This script computes the mean beta values across iterations for each 
% split, dataset, and bin, and organizes the result into a new structure:
% betas{split, dataset_idx, bin}

num_datasets = size(beta, 2);
num_splits = size(beta{1}, 1);
num_iters = size(beta{1}, 2);
num_bins = size(beta{1}, 3);

% Initialize new structure
betas = cell(num_splits, num_datasets, num_bins);
for d = 1:num_datasets
    for s = 1:num_splits
        for b = 1:num_bins
            % Collect all iterations for this split and bin
            iter_betas = cell(num_iters, 1);
            for i = 1:num_iters
                iter_betas{i} = beta{1,d}{s, i, b};
            end

            % Stack and take mean across iterations
            % assuming each is a row vector or column vector of same length
            stacked = cat(2, iter_betas{:}); % dimensions: [num_cells x num_iters]
            mean_beta = mean(stacked, 2);    % mean across iterations

            % Store in final structure
            betas{s, d, b} = mean_beta;
        end
    end
end

if nargin > 2
    
    beta2 = vertcat(varargin{1,1}{1,1});
    num_datasets = size(beta2, 2);
    num_splits = size(beta2{1}, 1);
    num_iters = size(beta2{1}, 2);
    num_bins = size(beta2{1}, 3);
    % Initialize new structure
    betas2 = cell(num_splits, num_datasets, num_bins);
    for d = 1:num_datasets
        for s = 1:num_splits
            for b = 1:num_bins
                % Collect all iterations for this split and bin
                iter_betas = cell(num_iters, 1);
                for i = 1:num_iters
                    iter_betas{i} = beta2{1,d}{s, i, b};
                end
    
                % Stack and take mean across iterations
                % assuming each is a row vector or column vector of same length
                stacked = cat(2, iter_betas{:}); % dimensions: [num_cells x num_iters]
                mean_beta = mean(stacked, 2);    % mean across iterations
    
                % Store in final structure
                betas2{s, d, b} = mean_beta;
            end
        end
    end
else
    betas2 = [];
end