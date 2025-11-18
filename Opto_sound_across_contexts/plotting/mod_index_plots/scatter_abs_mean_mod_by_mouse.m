function mod_stats = scatter_abs_mean_mod_by_mouse(save_dir, mod_index_by_dataset, mouseID, plot_info, version, varargin)
    % Plot absolute modulation index with individual mouse data points
    % Inputs:
    %   save_dir - directory to save results
    %   mod_index_by_dataset - cell array {dataset, context, celltype}
    %   mouseID - array indicating mouse ID for each dataset
    %   plot_info - structure with plotting parameters
    %   version - 1: contexts together, 2: contexts separated by celltype
    
    figure(6000);clf
    
    num_contexts = 2; %length(plot_info.behavioral_contexts);
    unique_mice = unique(mouseID);
    n_mice = length(unique_mice);
    n_celltypes =  size( mod_index_by_dataset,3);
    mean_cell_all = [];

    dataset_means_all = zeros(n_mice,num_contexts,n_celltypes);

    
    if nargin > 5
        ylims = varargin{1,1};
    end
    
    if version == 1
        x_lines = 0:num_contexts+1;
        
        for context = 1:num_contexts
            for celltype = 1:n_celltypes
                hold on
                % Initialize array for mouse means
                mouse_means = zeros(n_mice, 1);
                
                % Calculate mean for each mouse
                for m = 1:n_mice
                    curr_mouse = unique_mice(m);
                    mouse_datasets = find(mouseID == curr_mouse);
                    
                    % Average across datasets for this mouse
                    mouse_data = [];
                    for d = mouse_datasets
                        curr_data = abs(mod_index_by_dataset{d,context,celltype});
                        mouse_data = [mouse_data; curr_data(:)];
                    end
                    mouse_means(m) = nanmean(mouse_data);
                    
                    % Plot individual mouse point with jitter
                    scatter(x_lines(context+1) + (rand-0.5)*0.2, mouse_means(m), 30, ...
                        plot_info.colors_celltypes(celltype,:), 'o', 'filled', ...
                        'MarkerFaceAlpha', 0.4)
                end
                
                % Calculate and plot mean ± SEM across mice
%                 mean_cel = nanmean(mouse_means);
%                 err = std(mouse_means, 'omitnan') / sqrt(sum(~isnan(mouse_means)));
                valid_data = curr_means(~isnan(mouse_means));
                if ~isempty(valid_data)
                    mean_cel = mean(valid_data);
                    err = std(valid_data) / sqrt(length(valid_data));
                    
                    % Store stats with number of valid datasets
                    mod_stats.stats(celltype,context).valid_means = valid_data;
                    mod_stats.stats(celltype,context).mean = mean_cel;
                    mod_stats.stats(celltype,context).sem = err;
                    mod_stats.stats(celltype,context).n_valid_datasets = length(valid_data);
                    dataset_means_all(:,context,celltype) = valid_data;
                end
                
                % Plot error bar
                errorbar(x_lines(context+1), mean_cel, err, 'o', ...
                    'Color', plot_info.colors_celltypes(celltype,:), ...
                    'LineWidth', 1.5, 'MarkerSize', 7)%'MarkerFaceColor', 'w'
                
                mean_cell_all = [mean_cell_all, mean_cel];
            end
        end
        
        % Format plot
        xlim([x_lines(1) x_lines(end)])
        xticks(x_lines(1)+1:x_lines(end)-1)
        xticklabels(plot_info.behavioral_contexts)
        ylabel('Absolute Modulation Index')
        
        % Statistical testing across mice
        ct = 0;
        possible_tests = nchoosek(1:num_contexts,2);
        y_val = max(mean_cell_all)+0.05;
        
        for celltype = 1:n_celltypes
            for t = 1:size(possible_tests,1)
                data1 = mod_stats.stats(celltype,possible_tests(t,1)).valid_means;
                data2 = mod_stats.stats(celltype,possible_tests(t,2)).valid_means;
                
                [p_val_mod(t,celltype), ~, effectsize(t,celltype)] = permutationTest_updatedcb(...
                    data1, data2, 10000, 'paired', 1);
                
                if p_val_mod(t,celltype) < 0.05/n_celltypes
                    xline_vars = possible_tests(t,:);
                    ct = ct+.03;
                    utils.plot_pval_star(0, y_val+ct, p_val_mod(t,celltype), xline_vars, ...
                        0.01, plot_info.colors_celltypes(celltype,:))
                end
            end
        end
        
    % In the same function, add this to the else condition:

    else  % version 2
        count = 0;
        x_lines = 0:num_contexts*n_celltypes+1;
        
        for celltype = 1:n_celltypes
            mean_cell_all = [];
            for context = 1:num_contexts
                count = count + 1;
                hold on
                
                % Initialize array for mouse means
                mouse_means = zeros(n_mice, 1);
                
                % Calculate mean for each mouse
                for m = 1:n_mice
                    curr_mouse = unique_mice(m);
                    mouse_datasets = find(mouseID == curr_mouse);
                    
                    % Average across datasets for this mouse
                    mouse_data = [];
                    for d = mouse_datasets
                        curr_data = abs(mod_index_by_dataset{d,context,celltype});
                        mouse_data = [mouse_data; curr_data(:)];
                    end
                    mouse_means(m) = nanmean(mouse_data);
                    
                    % Plot individual mouse point with jitter
                    scatter(x_lines(count+1) + (rand-0.5)*0.2, mouse_means(m), 30, ...
                        plot_info.colors_celltypes(celltype,:), 'o', 'filled', ...
                        'MarkerFaceAlpha', 0.4)
                end
                
                % Calculate and plot mean ± SEM across mice
%                 mean_cel = nanmean(mouse_means);
%                 err = std(mouse_means, 'omitnan') / sqrt(sum(~isnan(mouse_means)));
                valid_data = mouse_means(~isnan(mouse_means));
                if ~isempty(valid_data)
                    mean_cel = mean(valid_data);
                    err = std(valid_data) / sqrt(length(valid_data));
                    
                    % Store stats with number of valid datasets
                    mod_stats.stats(celltype,context).valid_means = valid_data;
                    mod_stats.stats(celltype,context).mean = mean_cel;
                    mod_stats.stats(celltype,context).sem = err;
                    mod_stats.stats(celltype,context).n_valid_datasets = length(valid_data);
                    mod_stats.stats(celltype,context).valid_datasets = find(~isnan(mouse_means));
                end
                    
                
                % Plot error bar
                errorbar(x_lines(count+1), mean_cel, err, 'o', ...
                    'Color', plot_info.colors_celltypes(celltype,:), ...
                    'LineWidth', 1.5, 'MarkerSize', 7) %,'MarkerFaceColor', 'w'
                
                mean_cell_all = [mean_cell_all, mean_cel];
            end
            
            % Statistical testing for this cell type
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
                
                [p_val_mod(t,celltype), ~, effectsize(t,celltype)] = permutationTest_updatedcb(...
                        data1, data2, 10000, 'paired', 1);
                if size(possible_tests,1) == 1 && size(mod_stats.stats,1) == 1 && celltype > 1%assume only pyr has valid stuff
                    p_val_mod(t,celltype) = 1;
                end
                
                
                if p_val_mod(t,celltype) < 0.05/n_celltypes
                    xline_vars = possible_tests(t,:) + ((celltype-1)*num_contexts);
                    ct = ct + 0.03;
                    utils.plot_pval_star(0, y_val+ct, p_val_mod(t,celltype), xline_vars, ...
                        0.01, plot_info.colors_celltypes(celltype,:))
                end
            end
        end
        
        % Format plot
        xlim([x_lines(1) x_lines(end)])
        xticks(x_lines(1)+1:x_lines(end)-1)
        xticklabels(repmat(plot_info.behavioral_contexts, 1, n_celltypes))
        ylabel({'Absolute Modulation';'Index'})
        
        % Set figure properties
        set(gca,'FontSize',14);
        set(gcf,'Color','w')
        set(gca,'FontName','Arial')
        set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})
        xtickangle(45)
        set(gcf,'units','points','position',[10,100,(500/n_celltypes*num_contexts),200])
    end
    
    % Final formatting
    if nargin > 5
        ylim(varargin{1,1});
    end
    set(gcf,'units','points','position',[10,100,600,250])
    utils.set_current_fig;
    
    % Store statistics
    mod_stats.tests = possible_tests;
    mod_stats.p_test = 'paired permutation across mice';
    mod_stats.p_val_mod = p_val_mod;
    mod_stats.effectsize = effectsize;
    mod_stats.n_mice = n_mice;
    
    % Save results
    if ~isempty(save_dir)
        mkdir(save_dir)
        cd(save_dir)
        saveas(6000,strcat('abs_mod_index_scatter_n',num2str(n_mice),'.svg'));
        saveas(6000,strcat('abs_mod_index_scatter_n',num2str(n_mice),'.fig'));
        save(strcat('abs_mod_index_stats_scatter_n',num2str(n_mice)),'mod_stats');
    end
end