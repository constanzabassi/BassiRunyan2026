function celltypes = load_cell_classifications(server, dataset)
%load cell types (pyr, mcherry(SOM), tdtom(PV))
    celltype_path = fullfile(server, 'Connie', 'ProcessedData', dataset, 'red_variables');
    celltypes = struct();
    
    if ~isfolder(celltype_path)
        return;
    end
    
    celltypes.pyr_cells = load_mat_file(celltype_path, 'pyr_cells.mat')'; %transform to be same organization as others
    celltypes.som_cells = load_mat_file(celltype_path, 'mcherry_cells.mat');
    celltypes.pv_cells = load_mat_file(celltype_path, 'tdtom_cells.mat');
end