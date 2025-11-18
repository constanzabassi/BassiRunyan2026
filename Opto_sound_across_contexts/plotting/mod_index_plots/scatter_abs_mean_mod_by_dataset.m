function mod_stats = scatter_abs_mean_mod_by_dataset(save_dir, mod_index_by_dataset, plot_info, version, varargin)
    % Plot absolute modulation index with error bars across datasets
    % mod_index_by_dataset: cell array {dataset, context, celltype}
    
    figure(600);clf
    
    if nargin > 6
        num_contexts = varargin{1,2};
    else
        num_contexts = 2;
    end
    x_lines = 0:num_contexts+1;
    mean_cell_all = [];
    p_val_mod = []; possible_tests = [];
    
    % Get number of datasets
    n_datasets = length(mod_index_by_dataset);
    n_celltypes =  size( mod_index_by_dataset,3);

    dataset_means_all = zeros(n_datasets,num_contexts,n_celltypes);
    
    if nargin > 5
        ylims = varargin{1,1};
    end
    
    if version == 1
        for context = 1:num_contexts
            for celltype = 1:n_celltypes
                hold on
                % Initialize arrays for this context and cell type
                dataset_means = zeros(n_datasets, 1);
                
                % Calculate mean for each dataset
                for d = 1:n_datasets
                    curr_data = abs(mod_index_by_dataset{d,context,celltype});
                    dataset_means(d) = nanmean(curr_data);
                    dataset_means_all(d,context,celltype) = dataset_means(d); %save dataset mean across contexts,celltypes
                end
                
                valid_data = dataset_means(~isnan(dataset_means));
                if ~isempty(valid_data)
                    mean_cel = mean(valid_data);
                    err = std(valid_data) / sqrt(length(valid_data));
                    
                    % Store stats with number of valid datasets
                    mod_stats.stats(celltype,context).valid_means = valid_data;
                    mod_stats.stats(celltype,context).mean = mean_cel;
                    mod_stats.stats(celltype,context).sem = err;
                    mod_stats.stats(celltype,context).n_valid_datasets = length(valid_data);
                end
                
                % Plot
                errorbar(x_lines(context+1), mean_cel, err, "o", ...
                    'markeredgecolor', plot_info.colors_celltypes(celltype,:), ...
                    'color', plot_info.colors_celltypes(celltype,:), ...
                    'LineWidth', 1.2)
                
                mean_cell_all = [mean_cell_all, mean_cel];
            end
        end
        
        % Format plot
        xlim([x_lines(1) x_lines(end)])
        xticks(x_lines(1)+1:x_lines(end)-1)
        xticklabels(plot_info.behavioral_contexts)
        ylabel('Absolute Modulation Index')
        
        % Statistical testing
        if num_contexts > 1
            ct = 0;
            possible_tests = nchoosek(1:num_contexts,2);
            y_val = max(mean_cell_all)+0.05;
            
            for celltype = 1:n_celltypes
                for t = 1:size(possible_tests,1)
                    % Get data for statistical test
                    data1 = zeros(n_datasets, 1);
                    data2 = zeros(n_datasets, 1);
                    
                    for d = 1:n_datasets
                        data1(d) = nanmean(abs(mod_index_by_dataset{d}{possible_tests(t,1)}(celltypes_ids{1,celltype})));
                        data2(d) = nanmean(abs(mod_index_by_dataset{d}{possible_tests(t,2)}(celltypes_ids{1,celltype})));
                    end
                    
                    % Perform statistical test
                    [p_val_mod(t,celltype), ~, effectsize(t,celltype)] = permutationTest_updatedcb(...
                        data1, data2, 10000, 'paired', 1);
                    
                    % Plot significance stars if applicable
                    if p_val_mod(t,celltype) < 0.05/length(possible_tests)
                        xline_vars = possible_tests(t,:);
                        ct = ct+.03;
                        utils.plot_pval_star(0, y_val+ct, p_val_mod(t,celltype), xline_vars, 0.01, plot_info.colors_celltypes(celltype,:))
                    end
                end
            end
        end
        % Final plot formatting
        yli = ylim;
        ylim([0,yli(2)])
        if nargin > 5
            ylim(varargin{1,1});
        end
        
        set(gcf,'units','points','position',[10,100,600,250])
        utils.set_current_fig;
        
        % Store statistics
        mod_stats.tests = possible_tests;
        mod_stats.p_test = 'paired permutation across datasets';
        mod_stats.p_val_mod = p_val_mod;
        mod_stats.effectsize = effectsize;
            % Save results if directory provided
            if ~isempty(save_dir)
                mkdir(save_dir)
                cd(save_dir)
                saveas(600,strcat('abs_mod_index_scatter_across_datasets.svg'));
                saveas(600,strcat('abs_mod_index_scatter_across_datasets.fig'));
                save('abs_mod_index_stats_scatter_by_dataset','mod_stats');
            end
    

    
    else  % version 2
        count = 0;
        n_datasets = length(mod_index_by_dataset);
        x_lines = 0:num_contexts*n_celltypes+1;
        
        for celltype = 1:n_celltypes
            mean_cell_all = [];
            for context = 1:num_contexts
                count = count + 1;
                hold on
                
                % Initialize array for dataset means
                dataset_means = zeros(n_datasets, 1);
                
                % Calculate mean for each dataset
                for d = 1:n_datasets
                    curr_data = abs(mod_index_by_dataset{d,context,celltype});
                    dataset_means(d) = nanmean(curr_data);
                    dataset_means_all(d,context,celltype) = dataset_means(d); %save dataset mean across contexts,celltypes
                end
                
                valid_data = dataset_means(~isnan(dataset_means));
                if ~isempty(valid_data)
                    mean_cel = mean(valid_data);
                    err = std(valid_data) / sqrt(length(valid_data));
                    
                    % Store stats with number of valid datasets
                    mod_stats.stats(celltype,context).valid_means = valid_data;
                    mod_stats.stats(celltype,context).mean = mean_cel;
                    mod_stats.stats(celltype,context).sem = err;
                    mod_stats.stats(celltype,context).n_valid_datasets = length(valid_data);
                    mod_stats.stats(celltype,context).valid_datasets = find(~isnan(dataset_means));
                end
                
                % Plot
                errorbar(x_lines(count+1), mean_cel, err, "o", ...
                    'markeredgecolor', plot_info.colors_celltypes(celltype,:), ...
                    'color', plot_info.colors_celltypes(celltype,:), ...
                    'LineWidth', 1)
                
                mean_cell_all = [mean_cell_all, mean_cel];
            end
            
            % Statistical testing for this cell type
            if num_contexts > 1             
                ct = 0;
                possible_tests = nchoosek(1:num_contexts,2);
                if max(mean_cell_all) > 0.1
                    y_val = max(mean_cell_all) + 0.03;
                else
                    y_val = max(mean_cell_all);
                end
                
                for t = 1:size(possible_tests,1)
                    ctx1 = possible_tests(t,1);
                    ctx2 = possible_tests(t,2);
    
                    % Get data for statistical test
                    % Skip if this celltype has no data for either context
                    if isempty(mod_stats.stats) || ...
                       celltype > size(mod_stats.stats,1) || ...
                       isempty(mod_stats.stats(celltype,ctx1).valid_means) || ...
                       isempty(mod_stats.stats(celltype,ctx2).valid_means)
                        continue;
                    end

                % Extract data
                data1 = mod_stats.stats(celltype,ctx1).valid_means;
                data2 = mod_stats.stats(celltype,ctx2).valid_means;

                % Align datasets if lengths differ (use intersection of valid datasets if available)
                if length(data1) ~= length(data2)
                    if isfield(mod_stats.stats(celltype,ctx1), 'valid_datasets') && ...
                       isfield(mod_stats.stats(celltype,ctx2), 'valid_datasets')
                       
                       % Intersect dataset indices from both contexts
                       common_datasets = intersect(mod_stats.stats(celltype,ctx1).valid_datasets, ...
                                                   mod_stats.stats(celltype,ctx2).valid_datasets);
            
                       [~, idx1] = ismember(common_datasets, mod_stats.stats(celltype,ctx1).valid_datasets);
                       [~, idx2] = ismember(common_datasets, mod_stats.stats(celltype,ctx2).valid_datasets);
            
                       data1 = data1(idx1);
                       data2 = data2(idx2);
                    else
                       % Skip if we can't align data
                       continue;
                    end
                end
                % Perform statistical test
                [p_val_mod(t,celltype), ~, effectsize(t,celltype)] = permutationTest_updatedcb(...
                    data1, data2, 10000, 'paired', 1);
                if size(possible_tests,1) == 1 && size(mod_stats.stats,1) == 1 && celltype > 1%assume only pyr has valid stuff
                    p_val_mod(t,celltype) = 1;
                end
                
                if p_val_mod(t,celltype) < 0.05/n_celltypes
                    xline_vars = possible_tests(t,:) + ((celltype-1)*num_contexts);
                    ct = ct + 0.03;
                    utils.plot_pval_star(0, y_val+ct, p_val_mod(t,celltype), xline_vars, 0.01, plot_info.colors_celltypes(celltype,:))
                end
                end
            end
        end
        
        % Format plot
        xlim([x_lines(1) x_lines(end)])
        xticks(x_lines(1)+1:x_lines(end)-1)
        xticklabels(repmat(plot_info.behavioral_contexts, 1, n_celltypes))
        ylabel({'Absolute Modulation';'Index'})
        
        yli = ylim;
        ylim([0,yli(2)])
        if nargin > 5
            ylim(varargin{1,1});
        end
        
        % Set figure properties
        set(gca,'FontSize',14);
        set(gcf,'Color','w')
        set(gca,'FontName','Arial')
        set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})
        xtickangle(45)
        set(gcf,'units','points','position',[10,100,(500/n_celltypes*num_contexts),200])
        
        % Modify the Kruskal-Wallis section
        % Initialize KW results structure
        KW.p_val_per_dataset = zeros(n_datasets, 1);
        KW.stats_per_dataset = cell(n_datasets, 1);
        
        % Perform KW test for each dataset
        for d = 1:n_datasets
            current_data = dataset_means_all(d,:,:); % [contexts x celltypes]
            if sum(~isnan(current_data(:))) > 0  % Only test if there's valid data
                [KW.p_val_per_dataset(d), ~, KW.stats_per_dataset{d}] = ...
                    kruskalwallis(current_data(:), [1:numel(current_data)], 'off');
            else
                KW.p_val_per_dataset(d) = NaN;
            end
        end
    end
    
    % Store statistics
    mod_stats.tests = possible_tests;
    mod_stats.p_test = 'paired permutation across datasets';
    mod_stats.p_val_run_mod = p_val_mod;
    mod_stats.effectsize = effectsize;
    mod_stats.KW = KW;
    
    % Save results
    if ~isempty(save_dir)
        mkdir(save_dir)
        cd(save_dir)
        saveas(600,strcat('abs_mod_index_scatter_by_dataset_',num2str(n_datasets),'.svg'));
        saveas(600,strcat('abs_mod_index_scatter_by_dataset_',num2str(n_datasets),'.fig'));
        save('abs_mod_index_stats_scatter_by_dataset','mod_stats');
    end
end
    