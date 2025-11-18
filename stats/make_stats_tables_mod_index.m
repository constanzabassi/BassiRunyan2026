function table_fig3 = make_stats_tables_mod_index(mod_index_stats, mod_index_stats_datasets, save_dir)
%MAKE_STATS_TABLES Create and save stats tables for figure 3.
%
%   table_fig3 = MAKE_STATS_TABLES(mod_index_stats, mod_index_stats_datasets, save_dir)
%
%   INPUTS:
%       mod_index_stats            - structure containing single-cell stats
%       mod_index_stats_datasets   - structure containing dataset-level stats
%       save_dir                   - directory where results are saved
%
%   OUTPUT:
%       table_fig3                 - combined table of single-cell and dataset stats
%
%   This function:
%       1) unwraps cells in mod_index_stats_datasets
%       2) converts both structures to tables
%       3) concatenates them into one combined table
%       4) saves the result as .mat and .csv in save_dir

    % --- 1) unwrap nested cells
    S = unwrap_cells_in_struct(mod_index_stats_datasets);

    % --- 2) convert to tables
    table_1 = struct2table_recursive(mod_index_stats, 'single_cells', {'bootstat'});
    table_2 = struct2table_recursive(S, 'datasets', {'bootstat'});

    % --- 3) concatenate
    table_fig3 = [table_1; table_2];

    % --- 4) save outputs
    save(fullfile(save_dir, 'table_fig3.mat'), 'table_fig3');
    writetable(table_fig3, fullfile(save_dir, 'table_fig3.csv'));

    fprintf('Saved table_fig3 to:\n%s\n', save_dir);
end
