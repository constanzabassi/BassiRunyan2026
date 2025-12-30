function [percent_cells,per_dataset,stats] = calculate_sig1_vs_sig2_overlap(sig1, sig2, mod_indexm, contexts, varargin)
% CALCULATE_SIG1_VS_SIG2_OVERLAP computes the overlap percentages between two sets of significant neurons.
%
% Inputs:
%   sig1       - Cell array {dataset} of significant cell indices (e.g., overall modulated neurons).
%   sig2       - Cell array {dataset, context} of context-specific significant cell indices.
%   mod_indexm - Cell array {dataset, context} to determine total number of cells per dataset.
%   contexts   - Vector of context indices to include from sig2.
%
% Output:
%   percent_cells - 1x4 vector of percentages:
%                   [sig1_only, sig2_only, both_sig1_and_sig2, neither]
%   per_dataset -  percentages per single datasets!
%   STATS- stats per functional type

% ---- Parse optional input ----
    p = inputParser;
    addParameter(p, 'IncludeUnmodulated', true, @(x) islogical(x) || isnumeric(x));
    parse(p, varargin{:});
    includeUnmod = logical(p.Results.IncludeUnmodulated);

    num_datasets = numel(sig1);
    total_sig1_only = 0;
    total_sig2_only = 0;
    total_both = 0;
    total_neither = 0;

    per_dataset = zeros(num_datasets, 4); % [sig1_only, sig2_only, both, neither]

    for i = 1:num_datasets
        % Get total number of cells in this dataset from one context (they should match)
        % --- Define universe of cells ---
        if includeUnmod
            total_cells = length(mod_indexm{i, contexts(1)});
            all_cells   = 1:total_cells;
        end

        sig1_cells = sig1{i};
        sig2_cells =sig2{i}; % unique([sig2{i, contexts}]);

        both = intersect(sig1_cells, sig2_cells);
        only_sig1 = setdiff(sig1_cells, sig2_cells);
        only_sig2 = setdiff(sig2_cells, sig1_cells);

        if includeUnmod
            neither = setdiff(all_cells, union(sig1_cells, sig2_cells));
            total   = numel(all_cells);
        else
            neither = [];
            total   = numel(union(sig1_cells, sig2_cells));
        end

%         neither = setdiff(all_cells, union(sig1_cells, sig2_cells));
% 
%         % Store per dataset percentages
%         total = total_cells;

        per_dataset(i, :) = [...
            length(only_sig1)/total, ...
            length(only_sig2)/total, ...
            length(both)/total, ...
            length(neither)/total ...
        ];


        % Accumulate counts
        total_sig1_only = total_sig1_only + length(only_sig1);
        total_sig2_only = total_sig2_only + length(only_sig2);
        total_both = total_both + length(both);
        total_neither = total_neither + length(neither);
    end

    total_all = total_sig1_only + total_sig2_only + total_both + total_neither;

    percent_cells = [...
        total_sig1_only / total_all, ...
        total_sig2_only / total_all, ...
        total_both / total_all, ...
        total_neither / total_all ...
    ];

    stats.sig1 = utils.get_basic_stats(per_dataset(:,1)*100);
    stats.sig2 = utils.get_basic_stats(per_dataset(:,2)*100);
    stats.both = utils.get_basic_stats(per_dataset(:,3)*100);
    stats.unmod = utils.get_basic_stats(per_dataset(:,4)*100);
end
