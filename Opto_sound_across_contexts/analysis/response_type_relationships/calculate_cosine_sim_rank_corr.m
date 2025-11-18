function [cosine_similarity,rho] = calculate_cosine_sim_rank_corr(index,sig_mod_boot,all_celltypes)
%calculate cosine similarity and rank correlations across contexts
celltype_fields = fields(all_celltypes{1});
n_celltypes = length(celltype_fields);
for cell_type = 1:n_celltypes
        
        for dataset_index = 1:length(all_celltypes)
            dataset_index
            if ~isempty(sig_mod_boot) %use signficant neurons
                selected_cells = sig_mod_boot{dataset_index}(ismember(sig_mod_boot{dataset_index}, ...
                    all_celltypes{dataset_index}.(celltype_fields{cell_type})));
            else
                selected_cells = all_celltypes{dataset_index}.(celltype_fields{cell_type});
            end
            active_data = index{dataset_index,1}(selected_cells); %active
            passive_data = index{dataset_index,2}(selected_cells); %passive

            if length(active_data) < 2 || length(passive_data) < 2
                cosine_similarity{dataset_index,1,cell_type} = nan;
                rho{dataset_index,1,cell_type} = nan;
                continue;
            end

            %calculate stuff below
            cosine_similarity{dataset_index,1,cell_type} = dot(active_data,passive_data)/(norm(active_data)*norm(passive_data));
            rho{dataset_index,1,cell_type} = corr(active_data',passive_data','type','Spearman');
        end
end