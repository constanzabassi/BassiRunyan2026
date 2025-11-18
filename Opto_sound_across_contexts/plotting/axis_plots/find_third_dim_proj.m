function num_with_stim = find_third_dim_proj(proj, field_name)
%helps find 3rd dimensions of uneven matrices (like proj_concat)
matrix = proj;
sz = size(matrix);
stim_exists = false(sz(3), 1);

for k = 1:sz(3)
    if ~isempty(matrix{1,1,k}) && isfield(matrix{1,1,k},  field_name)
        stim_exists(k) = true;
    end
end

% Find how many along 3rd dim actually have the 'stim' field
num_with_stim = sum(stim_exists);
