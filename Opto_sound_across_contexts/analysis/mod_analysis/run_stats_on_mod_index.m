function evoked_stats = run_stats_on_mod_index(mean_traces, dataset_ids, celltypes,param_labels,field)
    % mean_traces: cell array {1,i} with {ct,cx} subcells
    % dataset_ids: cell array {1,i} with {ct,cx} subcells (may be empty)

    if isempty(param_labels)
        param_labels = {'mod_index'};
    end
    num_params = numel(mean_traces);
        param_label = param_labels{1};
        traces_mean = mean_traces;

        if ~isempty(dataset_ids)
            for ce = celltypes
                current_datasets{ce} = traces_mean(ce,1).valid_datasets;
            end
            fprintf('Using LME model (dataset info provided)\n');
            [tbl,mean_stats] = prepare_lme_data(traces_mean, traces_mean, celltypes,field);
            lme = fitlme(tbl, 'Response ~ CellType * Context + (1|Dataset)');
%             disp(anova(lme));
            [p, tbl, ~] =anova(lme);
            evoked_stats.(param_label).anova.p = p;
            evoked_stats.(param_label).anova.tbl = tbl;
            evoked_stats.(param_label).stats = mean_stats;
        else
            fprintf('Using ANOVA model (no dataset info)\n');
            [p, tbl, ~,mean_stats] = run_anova(traces_mean, celltypes,field);
%             disp(tbl);
            evoked_stats.(param_label).anova.p = p;
            evoked_stats.(param_label).anova.tbl = tbl;
            evoked_stats.(param_label).stats = mean_stats;
        end

end


%% -------------------------------------------------------------------------
function [p, tbl, stats,mean_stats] = run_anova(traces_mean, celltypes,field)
    % Standard 2-way ANOVA (no random effects)
    celltypes = celltypes;
    contexts = {'Active', 'Passive'};
    celltype_labels = {};
    context_labels = {};
    responses = [];
    mean_stats = {};
    for ct = 1:numel(celltypes)
        fieldname = ['celltype_' num2str(ct)];
        for cx = 1:numel(contexts)
            these_vals =traces_mean(ct,cx).(field);
            responses = [responses; these_vals(:)];
            celltype_labels = [celltype_labels; repmat(celltypes(ct), numel(these_vals), 1)];
            context_labels = [context_labels; repmat(contexts(cx), numel(these_vals), 1)];
            
            fieldname2 = ['context_' num2str(cx)];
            mean_stats.(fieldname).(fieldname2) = get_basic_stats(these_vals);
        end
        [p_val, diff, eff_size] = permutationTest_updatedcb(traces_mean(ct,1).(field), traces_mean(ct,2).(field), 10000, 'paired', 1);
        mean_stats.(fieldname).p = p_val;
        mean_stats.(fieldname).effect_size = eff_size;
        mean_stats.(fieldname).observeddiff = diff;
        mean_stats.(fieldname).test = 'paired permutation across datasets';
    end

    [p, tbl, stats] = anovan(responses, {celltype_labels, context_labels}, ...
        'model', 'interaction', 'varnames', {'CellType', 'Context'});
end


%% -------------------------------------------------------------------------
function [tbl,mean_stats] = prepare_lme_data(traces_mean, dataset_ids, celltypes,field)
    % Prepares data for LME model (includes random effect by dataset)
    celltypes = celltypes;
    contexts = {'Active', 'Passive'};
    responses = [];
    celltype_labels = {};
    context_labels = {};
    dataset_labels = [];

    for ct = 1:numel(celltypes)
        fieldname = ['celltype_' num2str(ct)];

        for cx = 1:numel(contexts)
            these_vals = traces_mean(ct,cx).(field);
            n_datasets = length(dataset_ids{ct,cx});
            responses = [responses; these_vals(:)];
            celltype_labels = [celltype_labels; repmat(celltypes(ct), n_datasets, 1)];
            context_labels = [context_labels; repmat(contexts(cx), n_datasets, 1)];
            dataset_labels = [dataset_labels, dataset_ids{ct,cx}];
            fieldname2 = ['context_' num2str(cx)];
            mean_stats.(fieldname).(fieldname2) = get_basic_stats(these_vals);
        end
        [p_val, diff, eff_size] = permutationTest_updatedcb(traces_mean(ct,1).(field), traces_mean(ct,2).(field), 10000, 'paired', 1);
        mean_stats.(fieldname).p = p_val;
        mean_stats.(fieldname).effect_size = eff_size;
        mean_stats.(fieldname).observeddiff = diff;
        mean_stats.(fieldname).test = 'paired permutation across datasets';

    end

    tbl = table(responses, categorical(celltype_labels), ...
        categorical(context_labels), dataset_labels', ...
        'VariableNames', {'Response', 'CellType', 'Context', 'Dataset'});
end
