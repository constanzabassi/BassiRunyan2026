% Function to create matrices representing trial x cells x frames
function [stim_matrix, ctrl_matrix, z_stim_matrix, z_ctrl_matrix] = make_tr_cel_time(allcells,is_dff)
% allcells: Array of cell structures, where each cell structure contains opto and control data
% is_dff: A flag indicating whether dF/F data should be used (1) or deconvolved data (0)

cellCount = length(allcells);  % Get the number of cells

% Initialize matrices to hold stimulus and control data (with size: trials x cells x frames)
stim_matrix = zeros(size(allcells(1).opto,1), cellCount, size(allcells(2).opto,2)); 
z_stim_matrix = zeros(size(allcells(1).opto,1), cellCount, size(allcells(2).opto,2));

% Check if dF/F data is to be used
if is_dff == 1
    % Loop through each cell and extract the stimulus (opto) and z-scored stimulus (z_opto) data
    for cel  = 1:cellCount
        for trial = 1:size(allcells(1).opto,1)  % Iterate through each trial
            stim_matrix(trial, cel, :) = allcells(cel).opto(trial, :);  % Store opto data for each trial, cell, and frame
            z_stim_matrix(trial, cel, :) = allcells(cel).z_opto(trial, :);  % Store z-scored opto data for each trial, cell, and frame
        end
    end
    
    % Initialize control matrices with appropriate size (trials x cells x frames)
    ctrl_matrix = zeros(size(allcells(1).control,1), cellCount, size(allcells(2).control,2)); 
    z_ctrl_matrix = zeros(size(allcells(1).control,1), cellCount, size(allcells(2).control,2)); 
    
    % Loop through each cell and extract control (control) and z-scored control (z_control) data
    for cel  = 1:cellCount
        for trial = 1:size(allcells(1).control,1)  % Iterate through each trial
            ctrl_matrix(trial, cel, :) = allcells(cel).control(trial, :);  % Store control data for each trial, cell, and frame
            z_ctrl_matrix(trial, cel, :) = allcells(cel).z_control(trial, :);  % Store z-scored control data for each trial, cell, and frame
        end
    end
    
else
    % If deconvolved data is used (when is_dff == 0), follow the same process but with deconvolved data
    for cel  = 1:cellCount
        for trial = 1:size(allcells(1).opto,1)
            stim_matrix(trial, cel, :) = allcells(cel).opto_deconv(trial, :);  % Store deconvolved opto data
            z_stim_matrix(trial, cel, :) = allcells(cel).z_opto(trial, :);  % Store z-scored opto data
        end
    end
    
    % Initialize control matrices with deconvolved control data
    ctrl_matrix = zeros(size(allcells(1).control,1), cellCount, size(allcells(2).control,2)); 
    for cel  = 1:cellCount
        for trial = 1:size(allcells(1).control,1)
            ctrl_matrix(trial, cel, :) = allcells(cel).control_deconv(trial, :);  % Store deconvolved control data
            z_ctrl_matrix(trial, cel, :) = allcells(cel).z_control(trial, :);  % Store z-scored control data
        end
    end
end

