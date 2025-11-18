function S = unwrap_cells_in_struct(S)
% Recursively unwraps cells inside a structure.
% Converts cell arrays like S.field{r,c} → S.field_rX_cY
% Handles struct arrays safely, even if fields differ.

if ~isstruct(S)
    return;
end

fn = fieldnames(S);

for i = 1:numel(fn)
    f = fn{i};
    val = S.(f);

    % --- Handle cell arrays ---
    if iscell(val)
        [nRows, nCols] = size(val);

        if numel(val) == 1
            val = val{1};
        else
            % Expand each cell into its own field
            for r = 1:nRows
                for c = 1:nCols
                    subval = val{r, c};
                    if isempty(subval)
                        continue;
                    end

                    new_field = sprintf('%s_r%d_c%d', f, r, c);

                    % Recursively unwrap deeper content
                    if isstruct(subval)
                        subval = unwrap_cells_in_struct(subval);
                    elseif iscell(subval)
                        tmp = struct('tmp', subval);
                        tmp = unwrap_cells_in_struct(tmp);
                        if isfield(tmp, 'tmp')
                            subval = tmp.tmp;
                        end
                    end

                    S.(new_field) = subval;
                end
            end

            % Remove the original cell field
            S = rmfield(S, f);
            continue;
        end
    end

    % --- Handle struct or struct array ---
    if isstruct(val)
        % Use cell array to avoid mismatched struct assignment
        newVal = cell(1, numel(val));
        for j = 1:numel(val)
            newVal{j} = unwrap_cells_in_struct(val(j));
        end

        % Try to convert back to struct array only if consistent
        try
            S.(f) = [newVal{:}];
        catch
            % Keep as cell array if fields differ
            S.(f) = newVal;
        end
    else
        % Non-struct, non-cell value
        S.(f) = val;
    end
end

% % % Recursively unwrap cells inside a structure.
% % % Converts fields like S.field{1,1}.subfield → S.field.subfield
% % % Handles struct arrays and nested cells safely.
% % 
% % if ~isstruct(S)
% %     return; % nothing to do
% % end
% % 
% % fn = fieldnames(S);
% % 
% % for i = 1:numel(fn)
% %     f = fn{i};
% %     val = S.(f);
% % 
% %     % --- If it's a cell array ---
% %     if iscell(val)
% %         % Unwrap one level if it's a single cell
% %         if numel(val) == 1
% %             val = val{1};
% %         end
% % 
% %         % If it's now a struct or struct array
% %         if isstruct(val)
% %             % Recursively unwrap each element in case it's an array
% %             for j = 1:numel(val)
% %                 val(j) = unwrap_cells_in_struct(val(j));
% %             end
% % 
% %             % If it's scalar, merge its fields into S.(f)
% %             if isscalar(val)
% %                 subfields = fieldnames(val);
% %                 for k = 1:numel(subfields)
% %                     new_field = [f '_' subfields{k}];
% %                     S.(new_field) = val.(subfields{k});
% %                 end
% %                 S = rmfield(S, f);
% %                 continue;
% %             end
% %         end
% %     end
% % 
% %     % --- If it's a struct or struct array ---
% %     if isstruct(val)
% %         for j = 1:numel(val)
% %             val(j) = unwrap_cells_in_struct(val(j));
% %         end
% %         S.(f) = val; % safe even for arrays
% %     else
% %         S.(f) = val; % reassign cleaned value
% %     end
% % end

% % % % % UNWRAP_CELLS_IN_STRUCT Recursively unwraps single-cell contents of structs.
% % % % % 
% % % % % Example:
% % % % %   S.pos_percents{1,1} = struct('mean', 0.5, 'sd', 0.1);
% % % % %   S = unwrap_cells_in_struct(S);
% % % % %   % Now:
% % % % %   % S.pos_percents.mean = 0.5
% % % % %   % S.pos_percents.sd   = 0.1
% % % % 
% % % %     fields = fieldnames(S);
% % % %     for i = 1:numel(fields)
% % % %         f = fields{i};
% % % %         val = S.(f);
% % % % 
% % % %         % 🔹 If value is a cell with a single struct inside, unwrap it
% % % %         if iscell(val) && numel(val) == 1 && isstruct(val{1})
% % % %             % Replace the cell with the struct
% % % %             S.(f) = val{1};
% % % %             % Recurse into that struct in case it has cells inside too
% % % %             S.(f) = unwrap_cells_in_struct(S.(f));
% % % % 
% % % %         % 🔹 If value is a cell array of structs (e.g., {1xN})
% % % %         elseif iscell(val) && all(cellfun(@(x) isstruct(x), val))
% % % %             % Merge cell structs into indexed subfields
% % % %             tmp = struct();
% % % %             for j = 1:numel(val)
% % % %                 subname = sprintf('entry%d', j);
% % % %                 tmp.(subname) = unwrap_cells_in_struct(val{j});
% % % %             end
% % % %             S.(f) = tmp;
% % % % 
% % % %         % 🔹 If it’s a struct itself, go deeper recursively
% % % %         elseif isstruct(val)
% % % %             S.(f) = unwrap_cells_in_struct(val);
% % % %         end
% % % %     end
% % % % end
