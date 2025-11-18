function evoked_stats = run_stats_on_traces(mean_traces, dataset_ids, frames, celltypes,param_labels)
    % mean_traces: cell array {1,i} with {ct,cx} subcells
    % dataset_ids: cell array {1,i} with {ct,cx} subcells (may be empty)

    if isempty(frames)
        frames = 63:92;
    end
    if isempty(param_labels)
        param_labels = {'positive','negative','all'};
    end
    num_params = numel(mean_traces);
    for i = 1:num_params
        fprintf('\n=== Running stats for parameter %d ===\n', i);
        param_label = param_labels{i};
        traces_mean = mean_traces{1,i};

        if ~isempty(dataset_ids) && ~isempty(dataset_ids{1,i})
            fprintf('Using LME model (dataset info provided)\n');
            [tbl,mean_stats] = prepare_lme_data(traces_mean, dataset_ids{1,i}, celltypes,frames);
            lme = fitlme(tbl, 'Response ~ CellType * Context + (1|Dataset)');
%             disp(anova(lme));
            [p, tbl, ~] =anova(lme);
            evoked_stats.(param_label).anova.p = p;
            evoked_stats.(param_label).anova.tbl = tbl;
            evoked_stats.(param_label).stats = mean_stats;
        else
            fprintf('Using ANOVA model (no dataset info)\n');
            [p, tbl, ~,mean_stats] = run_anova(traces_mean, celltypes,frames);
%             disp(tbl);
            evoked_stats.(param_label).anova.p = p;
            evoked_stats.(param_label).anova.tbl = tbl;
            evoked_stats.(param_label).stats = mean_stats;
        end
    end
end


%% -------------------------------------------------------------------------
function [p, tbl, stats,mean_stats] = run_anova(traces_mean, celltypes,frames)
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
            these_vals = mean(traces_mean{ct,cx}(:,frames),2);
            responses = [responses; these_vals(:)];
            celltype_labels = [celltype_labels; repmat(celltypes(ct), numel(these_vals), 1)];
            context_labels = [context_labels; repmat(contexts(cx), numel(these_vals), 1)];
            
            fieldname2 = ['context_' num2str(cx)];
            mean_stats.(fieldname).(fieldname2) = get_basic_stats(these_vals);
        end
        [p_val, diff, eff_size] = permutationTest_updatedcb(mean(traces_mean{ct,1}(:,frames),2), mean(traces_mean{ct,2}(:,frames),2), 10000, 'paired', 1);
        mean_stats.(fieldname).p = p_val;
        mean_stats.(fieldname).effect_size = eff_size;
        mean_stats.(fieldname).observeddiff = diff;
        mean_stats.(fieldname).test = 'paired permutation across datasets';
    end

    [p, tbl, stats] = anovan(responses, {celltype_labels, context_labels}, ...
        'model', 'interaction', 'varnames', {'CellType', 'Context'});
end


%% -------------------------------------------------------------------------
function [tbl,mean_stats] = prepare_lme_data(traces_mean, dataset_ids, celltypes,frames)
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
            these_vals = mean(traces_mean{ct,cx}(:,frames),2);
            n_datasets = length(dataset_ids{ct,cx});
            responses = [responses; these_vals(:)];
            celltype_labels = [celltype_labels; repmat(celltypes(ct), n_datasets, 1)];
            context_labels = [context_labels; repmat(contexts(cx), n_datasets, 1)];
            dataset_labels = [dataset_labels, dataset_ids{ct,cx}];
            fieldname2 = ['context_' num2str(cx)];
            mean_stats.(fieldname).(fieldname2) = get_basic_stats(these_vals);
        end
        [p_val, diff, eff_size] = permutationTest_updatedcb(mean(traces_mean{ct,1}(:,frames),2), mean(traces_mean{ct,2}(:,frames),2), 10000, 'paired', 1);
        mean_stats.(fieldname).p = p_val;
        mean_stats.(fieldname).effect_size = eff_size;
        mean_stats.(fieldname).observeddiff = diff;
        mean_stats.(fieldname).test = 'paired permutation across datasets';

    end

    tbl = table(responses, categorical(celltype_labels), ...
        categorical(context_labels), dataset_labels', ...
        'VariableNames', {'Response', 'CellType', 'Context', 'Dataset'});
end
