function T = struct2table_recursive(S, prefix, exclude_fields)
if nargin < 2, prefix = ''; end
if nargin < 3, exclude_fields = {}; end

field_names = {};
data = {};

names = fieldnames(S);
for i = 1:numel(names)
    field = names{i};
    fullfield = field;
    if ~isempty(prefix)
        fullfield = [prefix '.' field];
    end

    % Skip excluded fields
    if any(cellfun(@(x) contains(fullfield, x), exclude_fields))
        continue;
    end

    val = S.(field);

    % --- Handle struct arrays ---
    if isstruct(val)
        for j = 1:numel(val)
            subfield_prefix = fullfield;
            if numel(val) > 1
                subfield_prefix = sprintf('%s_%d', fullfield, j);
            end
            subT = struct2table_recursive(val(j), subfield_prefix, exclude_fields);
            field_names = [field_names; subT.FieldName];
            data = [data; subT.Value];
        end
        continue;
    end

    % --- Handle nested cells ---
    while iscell(val) && numel(val) == 1
        val = val{1};
    end

    % If still a struct after unwrapping, recurse
    if isstruct(val)
        subT = struct2table_recursive(val, fullfield, exclude_fields);
        field_names = [field_names; subT.FieldName];
        data = [data; subT.Value];
    else
        % Otherwise store normally
        field_names{end+1,1} = fullfield;
        data{end+1,1} = val;
    end
end

T = table(field_names, data, 'VariableNames', {'FieldName','Value'});
end

%% good version for most
%     if nargin < 2
%         prefix = '';
%     end
%     if nargin < 3
%         exclude_fields = {};
%     end
%     
%     names = fieldnames(S);
%     data = {};
%     field_names = {};
%     
%     for i = 1:numel(names)
%         field = names{i};
%         fullfield = field;
%         if ~isempty(prefix)
%             fullfield = [prefix '.' field];
%         end
%         
%         % Check if this field matches any exclusion
%         is_excluded = any(cellfun(@(x) contains(fullfield, x), exclude_fields));
%         if is_excluded
%             continue; % skip this field
%         end
%         
%         if isstruct(S.(field)) && ~contains(field,'p_')
%             % Recursively process sub-structure
%             subT = struct2table_recursive(S.(field), fullfield, exclude_fields);
%             field_names = [field_names; subT.FieldName];
%             data = [data; subT.Value];
%         elseif startsWith(field, 'p_val') 
%             value = S.(field);
%             % Handle different shapes of p_vals matrices
%             [r, c] = size(value);
% 
%             if numel(value) == 1
%                 % Case ① single p-value
%                 field_names{end+1,1} = fullfield;
%                 data{end+1,1} = value;
% 
%             elseif r == 2
%                 % Case ② two rows: first = p-values, second = comparisons
%                 p_vals = value(1,:);
%                 comps  = value(2,:);
%                 for j = 1:numel(p_vals)
%                     if j <= numel(comps)-1
%                         name_suffix = sprintf('_%d_%d', comps{j});
%                     else
%                         name_suffix = sprintf('_%d', j);
%                     end
%                     field_names{end+1,1} = [fullfield name_suffix];
%                     data{end+1,1} = p_vals{j};
%                 end
% 
%             elseif r == 1 && c > 2
%                 % Case ③ single row of multiple p-values
%                 for j = 1:c
%                     field_names{end+1,1} = sprintf('%s_%d', fullfield, j);
%                     data{end+1,1} = value{j};
%                 end
% 
%             elseif r > 2
%                 % Case ④ multi-row matrix with last row = comparison indices
%                 p_vals = value(1:end-1,:);
%                 comps  = value(end,:);
%                 num_sets = size(p_vals,1);
%                 for s = 1:num_sets
%                     for j = 1:numel(comps)-1
%                         name_suffix = sprintf('_%d_%d_%d', comps{j}, s);
%                         field_names{end+1,1} = [fullfield name_suffix];
%                         data{end+1,1} = p_vals{s,j};
%                     end
%                 end
% 
%             else
%                 % Fallback case
%                 field_names{end+1,1} = fullfield;
%                 data{end+1,1} = value;
%             end
%         else
%             % Store field name and value
%             field_names{end+1,1} = fullfield;
%             data{end+1,1} = S.(field);
% 
%     end
%     
%     T = table(field_names, data, 'VariableNames', {'FieldName', 'Value'});
% 
% end

% function T = struct2table_recursive(S, prefix, exclude_fields)
%     if nargin < 2
%         prefix = '';
%     end
%     if nargin < 3
%         exclude_fields = {};
%     end
%     
%     names = fieldnames(S);
%     data = {};
%     field_names = {};
%     
%     for i = 1:numel(names)
%         field = names{i};
%         fullfield = field;
%         if ~isempty(prefix)
%             fullfield = [prefix '.' field];
%         end
%         
%         % Check if this field matches any exclusion
%         is_excluded = any(cellfun(@(x) contains(fullfield, x), exclude_fields));
%         if is_excluded
%             continue; % skip this field
%         end
%         
%         if isstruct(S.(field)) && ~contains(field,'p_va')
%             % Recursively process sub-structure
%             subT = struct2table_recursive(S.(field), fullfield, exclude_fields);
%             field_names = [field_names; subT.FieldName];
%             data = [data; subT.Value];
%         elseif startsWith(field, 'p_val') 
%             value = S.(field);
%             % Handle different shapes of p_vals matrices
%             [r, c] = size(value);
% 
%             if numel(value) == 1
%                 % Case ① single p-value
%                 field_names{end+1,1} = fullfield;
%                 data{end+1,1} = value;
% 
%             elseif r == 2
%                 % Case ② two rows: first = p-values, second = comparisons
%                 p_vals = value(1,:);
%                 comps  = value(2,:);
%                 for j = 1:numel(p_vals)
%                     if j <= numel(comps)-1
%                         name_suffix = sprintf('_%d_%d', comps{j});
%                     else
%                         name_suffix = sprintf('_%d', j);
%                     end
%                     field_names{end+1,1} = [fullfield name_suffix];
%                     data{end+1,1} = p_vals{j};
%                 end
% 
%             elseif r == 1 && c > 2
%                 % Case ③ single row of multiple p-values
%                 for j = 1:c
%                     field_names{end+1,1} = sprintf('%s_%d', fullfield, j);
%                     data{end+1,1} = value{j};
%                 end
% 
%             elseif r > 2
%                 % Case ④ multi-row matrix with last row = comparison indices
%                 p_vals = value(1:end-1,:);
%                 comps  = value(end,:);
%                 num_sets = size(p_vals,1);
%                 for s = 1:num_sets
%                     for j = 1:numel(comps)-1
%                         name_suffix = sprintf('_%d_%d_%d', comps{j}, s);
%                         field_names{end+1,1} = [fullfield name_suffix];
%                         data{end+1,1} = p_vals{s,j};
%                     end
%                 end
% 
%             else
%                 % Fallback case
%                 field_names{end+1,1} = fullfield;
%                 data{end+1,1} = value;
%             end
%         else
%             % Store field name and value
%             field_names{end+1,1} = fullfield;
% %             data{end+1,1} = S.(field);
%             % Regular field
%             val = S.(field);
%             % 🔹 If it's a single-cell container, unwrap recursively
%             while iscell(val) && numel(val) == 1
%                 val = val{1};
%             end
% 
%             % 🔹 If unwrapped value is a struct, recurse into it
%             if isstruct(val)
%                 subT = struct2table_recursive(val, '', exclude_fields);
%                 field_names = [field_names; subT.FieldName];
%                 data = [data; subT.Value];
%             else
%                 % Otherwise, store as normal
%                 field_names{end+1,1} = fullfield;
%                 data{end+1,1} = val;
%             end
%         end
%     end
%     
% %     T = table(field_names, data, 'VariableNames', {'FieldName', 'Value'});
% % 🔹 Safety check before creating table
%     if numel(field_names) ~= numel(data)
%         warning('struct2table_recursive:Mismatch', ...
%             'Field count (%d) and data count (%d) do not match. Truncating.', ...
%             numel(field_names), numel(data));
%         
%         % Trim to smallest size to prevent error
%         min_len = min(numel(field_names), numel(data));
%         field_names = field_names(1:min_len);
%         data = data(1:min_len);
%     end
%     
%     T = table(field_names, data, 'VariableNames', {'FieldName', 'Value'});
% 
% end
