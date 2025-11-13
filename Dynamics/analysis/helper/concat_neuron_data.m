function out = concat_neuron_data(data_cell)
% CONCAT_NEURON_DATA Concatenate neuron data robustly
% Ensures the shared dimension across all matrices becomes dim2

    % Remove empty or NaN-only entries
    data_cell = data_cell(~cellfun('isempty', data_cell));
    data_cell = data_cell(~cellfun(@(x) all(isnan(x(:))), data_cell));

    if isempty(data_cell)
        out = [];
        return;
    end

    % Step 1: Find all sizes
    sizes = cellfun(@size, data_cell, 'UniformOutput', false);
    sizes = vertcat(sizes{:});  % Nx2 matrix

    % Step 2: Find the repeated size across matrices
    all_dims = sizes(:);
    repeated_size = mode(all_dims);  % the most common size

    % Step 3: Flip matrices if needed so repeated_size is in dim2
    for i = 1:numel(data_cell)
        sz = size(data_cell{i});
        if sz(1) == repeated_size && sz(2) ~= repeated_size
            data_cell{i} = data_cell{i}';  % flip
        elseif sz(1) ~= repeated_size && sz(2) ~= repeated_size
            error('Matrix %d does not contain the repeated size.', i);
        end
        % if dim2 already has repeated_size → do nothing
    end

    % Step 4: Concatenate along the variable dimension (dim1)
    out = cat(1, data_cell{:});
end
% % CONCAT_NEURON_DATA Concatenate neuron data across cells robustly
% %   Handles empty entries and ensures consistent orientation (neurons x time)
% %
% %   INPUT:
% %       data_cell - cell array, each cell containing neuron x time
% %                   or time x neuron data
% %
% %   OUTPUT:
% %       out - concatenated matrix [neurons_total x time]
% 
%     % remove empty entries
%     data_cell = data_cell(~cellfun('isempty', data_cell));
%     data_cell = data_cell(~cellfun(@(x) all(isnan(x(:))), data_cell));
%     
%     % standardize orientation
%     for i = 1:numel(data_cell)
%         d = data_cell{i};
%         if size(d,2) == 1 && size(d,1) > 1
%             % row vector → column
%             d = d';
%         elseif size(d,2) < size(d,1) && size(d,2) ~= 1
%             % time x neuron → transpose
%             d = d';
%         end
%         data_cell{i} = d;
%     end
%     
%     % concatenate
%     out = cat(1, data_cell{:});
% end
