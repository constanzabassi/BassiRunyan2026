function T = struct2table_recursive(S, prefix, exclude_fields)
    if nargin < 2
        prefix = '';
    end
    if nargin < 3
        exclude_fields = {};
    end
    
    names = fieldnames(S);
    data = {};
    field_names = {};
    
    for i = 1:numel(names)
        field = names{i};
        fullfield = field;
        if ~isempty(prefix)
            fullfield = [prefix '.' field];
        end
        
        % Check if this field matches any exclusion
        is_excluded = any(cellfun(@(x) contains(fullfield, x), exclude_fields));
        if is_excluded
            continue; % skip this field
        end
        
        if isstruct(S.(field))
            % Recursively process sub-structure
            subT = struct2table_recursive(S.(field), fullfield, exclude_fields);
            field_names = [field_names; subT.FieldName];
            data = [data; subT.Value];
        else
            % Store field name and value
            field_names{end+1,1} = fullfield;
            data{end+1,1} = S.(field);
        end
    end
    
    T = table(field_names, data, 'VariableNames', {'FieldName', 'Value'});
end
