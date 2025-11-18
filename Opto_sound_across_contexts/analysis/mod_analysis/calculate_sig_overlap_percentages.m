function percent_cells = calculate_sig_overlap_percentages(sig_mod_boot, mod_indexm, contexts)
% CALCULATE_SIG_overlap_PERCENTAGES computes the percentages of significant neurons
% across the specified contexts.
%
%   Inputs:
%       sig_mod_boot - Cell array of significant cell indices (from bootstrap),
%                      organized as {dataset x context}. Each element is a vector of
%                      local indices that are significant.
%       mod_indexm   - Cell array of modulation indices (organized as {dataset x context})
%                      used to determine the number of cells in each dataset.
%       contexts     - Vector of context indices to compare (e.g., [1 2] or [1 2 3]).
%
%   Output:
%       percent_cells - A vector of percentages.
%                       For 2 contexts, returns [Only_Context1, Only_Context2, Both].
%                       For 3 contexts, returns [Only_Context1, Only_Context2, Only_Context3, All_Combined].

    % Number of contexts to compare.
    total_contexts_to_compare = numel(contexts);
    % Use the first context to obtain total cell counts for each dataset.
    total_cells_per_dataset = cellfun(@length, mod_indexm(:, contexts(1)));
    if total_contexts_to_compare == 2
        % Define context indices.
        context1 = contexts(1);
        context2 = contexts(2);

        % Compute the intersection of significant cells across context1 and context2.
        % (Assumes intersect_sig_cells returns a cell array of intersected indices per dataset.)
        [combined_sig_cells, ~] = intersect_sig_cells(sig_mod_boot(:, context1)', sig_mod_boot(:, context2)', mod_indexm);

        % Convert local indices to global indices using the total cell counts.
        sig_all_combined = convert_indices_local_to_global(combined_sig_cells, total_cells_per_dataset);
        sig_all_context_1 = convert_indices_local_to_global(sig_mod_boot(:, context1)', total_cells_per_dataset);
        sig_all_context_2 = convert_indices_local_to_global(sig_mod_boot(:, context2)', total_cells_per_dataset);

        % Count the cells in each category.
        total_sig_cells_intersect = length(sig_all_combined);
        total_only_context1 = length(setdiff(sig_all_context_1, sig_all_combined));
        total_only_context2 = length(setdiff(sig_all_context_2, sig_all_combined));

        % Total count is the sum of all significant cells reported in each context.
        total_all = length(union(sig_all_context_1, sig_all_context_2));

        % Calculate percentages.
        percent_context1_only = total_only_context1 / total_all;
        percent_context2_only = total_only_context2 / total_all;
        percent_both = total_sig_cells_intersect / total_all;

        % Return as a 1x3 vector.
        percent_cells = [percent_context1_only, percent_context2_only, percent_both];
    elseif total_contexts_to_compare == 3
        % Define context indices.
        context1 = contexts(1);
        context2 = contexts(2);
        context3 = contexts(3);

        % Compute the intersection across three contexts.
        [combined_sig_cells, ~] = intersect_sig_cells(sig_mod_boot(:, context1)', sig_mod_boot(:, context2)', mod_indexm, sig_mod_boot(:, context3)');

        % Convert local indices to global indices.
        sig_all_combined = convert_indices_local_to_global(combined_sig_cells, total_cells_per_dataset);
        sig_all_context_1 = convert_indices_local_to_global(sig_mod_boot(:, context1)', total_cells_per_dataset);
        sig_all_context_2 = convert_indices_local_to_global(sig_mod_boot(:, context2)', total_cells_per_dataset);
        sig_all_context_3 = convert_indices_local_to_global(sig_mod_boot(:, context3)', total_cells_per_dataset);

        % Count the cells in each category.
        total_sig_cells_intersect = length(sig_all_combined);
        total_only_context1 = length(setdiff(sig_all_context_1, sig_all_combined));
        total_only_context2 = length(setdiff(sig_all_context_2, sig_all_combined));
        total_only_context3 = length(setdiff(sig_all_context_3, sig_all_combined));

        % Total significant cells (across contexts) is the sum from all three contexts.
        temp_union = union(sig_all_context_1, sig_all_context_2);
        total_all = length(union(temp_union,sig_all_context_3));

        % Calculate percentages.
        percent_context1_only = total_only_context1 / total_all;
        percent_context2_only = total_only_context2 / total_all;
        percent_context3_only = total_only_context3 / total_all;
        percent_combined = total_sig_cells_intersect / total_all;

        % Return as a 1x4 vector.
        percent_cells = [percent_context1_only, percent_context2_only, percent_context3_only, percent_combined];
    else
        error('Only 2 or 3 contexts are supported.');
    end
end