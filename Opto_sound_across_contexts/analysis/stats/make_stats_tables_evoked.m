function table_fig3_evoked = make_stats_tables_evoked(traces_mean, traces_mean2, save_subfolder, celltype_names,frames, savepath)
% MAKE_EVOKED_STATS
% Runs evoked response stats on traces, creates tables, and saves results.
%
% Usage:
%   table_fig3_evoked = make_evoked_stats(traces_mean, traces_mean2, '\sig_neurons\', {'PYR','SOM','PV'}, savepath)
%
% Inputs:
%   traces_mean     - structure or cell array of mean traces
%   traces_mean2    - (optional) second set of mean traces for difference analysis
%   save_subfolder  - subfolder (string), e.g. '\sig_neurons\'
%   celltype_names  - cell array of strings, e.g. {'PYR','SOM','PV'}
%   savepath        - base directory where results are saved
%
% Output:
%   table_fig3_evoked - combined table of stats

    if nargin < 2 || isempty(traces_mean2)
        traces_mean2 = [];
    end
    if nargin < 3 || isempty(save_subfolder)
        save_subfolder = '';
    end
    if nargin < 4 || isempty(celltype_names)
        celltype_names = {'PYR','SOM','PV'};
    end
    if nargin < 5
        error('Please provide savepath');
    end

    % Ensure save directory exists
    full_save_dir = fullfile(savepath, save_subfolder);
    if ~exist(full_save_dir, 'dir')
        mkdir(full_save_dir);
    end

    if isempty(frames)
        frames = 63:92;
    end

    % --- Run stats ---
    evoked_stats = run_stats_on_traces(traces_mean, [], frames, celltype_names, []);
    if ~isempty(traces_mean2)
        evoked_stats_diff = run_stats_on_traces(traces_mean2, [], frames, celltype_names, []);
    else
        evoked_stats_diff = struct();
    end

    % --- Convert to tables ---
    table_ = struct2table_recursive(unwrap_cells_in_struct(evoked_stats), '', {'bootstat'});
    if ~isempty(traces_mean2)
        table_2 = struct2table_recursive(unwrap_cells_in_struct(evoked_stats_diff), 'diff', {'bootstat'});
        table_fig3_evoked = [table_; table_2];
    else
        table_fig3_evoked = table_;
    end

    % --- Save outputs ---
    save(fullfile(full_save_dir, 'evoked_stats.mat'), 'evoked_stats');
    if ~isempty(traces_mean2)
        save(fullfile(full_save_dir, 'evoked_stats_diff.mat'), 'evoked_stats_diff');
    end

    save(fullfile(full_save_dir, 'table_fig3_evoked.mat'), 'table_fig3_evoked');
    writetable(table_fig3_evoked, fullfile(full_save_dir, 'table_fig3_evoked.csv'));

    fprintf('Saved evoked stats and tables in %s\n', full_save_dir);
end
