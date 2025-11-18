function [output, output_relative,index_context1_all,index_context2_all] = union_sig_cells(sig_mod_boot_thr, sig_mod_boot_thr2, mod_indexm, varargin)
    % Initialize outputs
    output = {};
    output_relative = [];
    index_context1_all = [];
    index_context2_all = [];
    % Determine the length of datasets and cumulative number of cells
    length_datasets = length(sig_mod_boot_thr);
    numcells = cumsum(cellfun(@(x) length(x), mod_indexm(1:length_datasets)));
    numcells = [0, numcells];
    % Check if additional inputs are provided
    if nargin < 4
        % Union of the two input thresholds
        for m = 1:length(sig_mod_boot_thr)
            if isempty(sig_mod_boot_thr2{1, m}) && ~isempty(sig_mod_boot_thr{1, m})
                output{m} = sig_mod_boot_thr{1, m};
            elseif isempty(sig_mod_boot_thr{1, m}) && ~isempty(sig_mod_boot_thr2{1, m})
                output{m} = sig_mod_boot_thr2{1, m};
            else
                [output{m},index_context1,index_context2] = union(sig_mod_boot_thr{1, m}, sig_mod_boot_thr2{1, m});
                index_context1_all = [index_context1_all;index_context2];
                index_context2_all = [index_context2_all;index_context2];

            end
            output_relative = [output_relative, output{m} + numcells(m)];
        end
    else
        % If additional inputs are provided
        for m = 1:length(sig_mod_boot_thr)
            %assuming third input is never empty...
            if isempty(sig_mod_boot_thr2{1, m}) && ~isempty(sig_mod_boot_thr{1, m})
                temp = sig_mod_boot_thr{1, m};
            elseif isempty(sig_mod_boot_thr{1, m}) && ~isempty(sig_mod_boot_thr2{1, m})
                temp = sig_mod_boot_thr2{1, m};
            else
                temp = union(sig_mod_boot_thr{1, m}, sig_mod_boot_thr2{1, m});
            end
            
            for k = 1:length(varargin)
                temp = union(temp, varargin{1, k}{1, m});
            end
            output{m} = temp;
            output_relative = [output_relative, output{m} + numcells(m)];
        end
    end
end