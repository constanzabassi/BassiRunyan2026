%% organizing pv, mchery, pyr cells
function [num_cells,sorted_cells,sorted_pv,sorted_som,sorted_pyr] = organize_pooled_celltypes(dff_st,all_celltypes)
%organizes cell types to have indices relative to all pooled datasets

sorted_pv = [];
sorted_som = [];
sorted_pyr = [];
num_cells = [];
sorted_cells = {};
%sorted_sig_cells_wilcoxon = [];

%get total cell nums per dataset
all_data_cell_num = [cellfun(@(x) length(x.pyr_cells),all_celltypes,'UniformOutput',false);cellfun(@(x) length(x.som_cells),all_celltypes,'UniformOutput',false);cellfun(@(x) length(x.pv_cells),all_celltypes,'UniformOutput',false)];


for dataset_index = 1:length(dff_st)
    if isfield(all_celltypes, 'stim')
        num_cells = [num_cells, size(dff_st{1,dataset_index}.stim,2)];
    else
        num_cells = [num_cells, sum([all_data_cell_num{:,dataset_index}])];
    end
    if dataset_index ==1
        sorted_som = [sorted_som ; all_celltypes{1,dataset_index}.som_cells];
        sorted_pyr = [sorted_pyr ; [all_celltypes{1,dataset_index}.pyr_cells]];
        sorted_pv = [sorted_pv ; all_celltypes{1,dataset_index}.pv_cells];
    else %add cellcount from previously to make sure they numbers make sense
        temp = sum(num_cells(1:dataset_index-1));
        sorted_som = [sorted_som ; (all_celltypes{1,dataset_index}.som_cells+temp)];
        sorted_pv = [sorted_pv ; (all_celltypes{1,dataset_index}.pv_cells+temp)];
        sorted_pyr = [sorted_pyr ; ([all_celltypes{1,dataset_index}.pyr_cells]+temp)];
    end
end
sorted_cells.pyr = sorted_pyr;
sorted_cells.som = sorted_som;
sorted_cells.pv = sorted_pv;