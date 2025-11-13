function analyze_beta_stability(beta, all_celltypes, bin_id, plot_info, svm_info)
% beta: folds x datasets x bins (each element is [n_neurons x 1])
% all_celltypes: {1 x n_datasets} cell with fields 'pyr', 'som', 'pv'
% bin_id: scalar bin index
% plot_info: struct with .colors_celltype
% svm_info: struct with .savepath and .savestr

[n_folds, n_datasets, ~] = size(beta);
possible_celltypes = fieldnames(all_celltypes{1});

mean_corrs = zeros(n_datasets, 1);
mean_spearman = zeros(n_datasets, 1);
mean_jaccard = zeros(n_datasets, 1);
CVs_all = cell(n_datasets, 1);

for d = 1:n_datasets
    % Extract beta for each fold for dataset d and bin bin_id
    beta_fold = cell(n_folds, 1);
    for f = 1:n_folds
        b = beta{f, d, bin_id};
        beta_fold{f} = b / norm(b); % normalize to unit length
    end
    
    % --- Vector correlations ---
    r_vals = [];
    for f1 = 1:n_folds-1
        for f2 = f1+1:n_folds
            r = corr(beta_fold{f1}, beta_fold{f2});
            r_vals(end+1) = r;
        end
    end
    mean_corrs(d) = mean(r_vals);
    
    % --- Per-neuron CV ---
    beta_mat = cell2mat(reshape(beta_fold, [1, n_folds]))'; % folds x neurons
    CV = std(beta_mat, 0, 1) ./ abs(mean(beta_mat, 1));
    CV(isnan(CV)) = 0;
    CVs_all{d} = CV;
    
    % --- Rank-based stability ---
    ranks = zeros(n_folds, size(beta_mat,2));
    for f = 1:n_folds
        [~, idx] = sort(abs(beta_mat(f,:)), 'descend');
        ranks(f, idx) = 1:length(idx);
    end
    spearmans = [];
    for f1 = 1:n_folds-1
        for f2 = f1+1:n_folds
            rho = corr(ranks(f1,:)', ranks(f2,:)', 'Type', 'Spearman');
            spearmans(end+1) = rho;
        end
    end
    mean_spearman(d) = mean(spearmans);
    
    % --- Top-k Jaccard ---
    k = round(0.1 * size(beta_mat, 2)); % top 10%
    topk_sets = cell(n_folds,1);
    for f = 1:n_folds
        [~, idx] = sort(abs(beta_mat(f,:)), 'descend');
        topk_sets{f} = idx(1:k);
    end
    jaccards = [];
    for f1 = 1:n_folds-1
        for f2 = f1+1:n_folds
            inter = intersect(topk_sets{f1}, topk_sets{f2});
            union1 = union(topk_sets{f1}, topk_sets{f2});
            jaccards(end+1) = numel(inter) / numel(union1);
        end
    end
    mean_jaccard(d) = mean(jaccards);
end

% --- Plot CV distribution by cell type ---
figure; hold on;
for c = 1:length(possible_celltypes)
    ct = possible_celltypes{c};
    all_CV_ct = [];
    for d = 1:n_datasets
        ids = all_celltypes{1,d}.(ct);
        all_CV_ct = [all_CV_ct, CVs_all{d}(ids)];
    end
    histogram(all_CV_ct, 'FaceColor', plot_info.colors_celltype(c,:), ...
        'DisplayName', ct, 'Normalization', 'probability');
end
legend; title('CV of weights by cell type');
xlabel('CV'); ylabel('Proportion');


saveas(gcf, fullfile(svm_info.savepath, ['CV_distribution_' svm_info.savestr '.png']));

% --- Save summary stats ---
save(fullfile(svm_info.savepath, ['stability_summary_' svm_info.savestr '.mat']), ...
    'mean_corrs', 'mean_spearman', 'mean_jaccard', 'CVs_all');

end

