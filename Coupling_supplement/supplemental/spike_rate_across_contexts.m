function overall_spike_rate = spike_rate_across_contexts(info, save_string)
    % Save string for identifying the folder where the results will be saved.
    % save_string = 'GLM_3nmf_pre';
    
    % Number of folds used in cross-validation (normally 10).
    num_folds = 10;
    
    % List of dataset indices to process.
    testing_datasets = 1:25;
    
    % Sampling rate of the calcium imaging data (30 Hz).
    sampling_rate = 30; % Hz
    
    % Initialize variables to store the spike rate data across contexts.
    overall_spike_rate = [];
    
    % Loop over each dataset in the testing datasets.
    for m = testing_datasets
        mm = info.mouse_date(m);
        m
        mm = mm{1,1};
        ss = info.serverid(m);
        ss = ss{1,1};
        
        % Create base folder path where results will be saved.
        base2 = strcat(num2str(ss), '/Connie/ProcessedData/', num2str(mm), '/', save_string);
        
        % Load the red cell IDs.
        load(strcat(num2str(ss), '/Connie/ProcessedData/', num2str(mm), '/red_variables/pyr_cells.mat'));
        load(strcat(num2str(ss), '/Connie/ProcessedData/', num2str(mm), '/red_variables/tdtom_cells.mat')); % PV cells
        load(strcat(num2str(ss), '/Connie/ProcessedData/', num2str(mm), '/red_variables/mcherry_cells.mat')); % SOM cells
        
        temp = [];
        
        % Loop over each fold for cross-validation.
        for splits = 1:num_folds
            % Define the directory path for the current fold.
            %this gives the training data
            dir_base = [base2 '/prepost trial cv 73 #' num2str(splits) '/'];
            cd([base2 '/prepost trial cv 73 #' num2str(splits) '/']);
            
            % Load the combined response data.
            load('combined_response.mat');

            test = load(strcat(dir_base,'test/combined_response.mat'));
            
            %concatentate train and test
            combined_all = [combined_response,test.combined_response];
            
            % Calculate the number of frames in the data.
            num_frames = size(combined_all, 2);
            
            % Calculate the duration in seconds.
            duration_seconds = num_frames / sampling_rate;
            
            % Sum the deconvolved activity over time for each cell type.
            total_spikes_pv = nansum(combined_all(tdtom_cells, :), 2);
            total_spikes_som = nansum(combined_all(mcherry_cells, :), 2);
            total_spikes_pyr = nansum(combined_all(pyr_cells, :), 2);
            
            % Calculate inferred spike rate as total spikes over duration (spikes/sec).
            spike_rate_pv = mean(total_spikes_pv / duration_seconds);
            spike_rate_som = mean(total_spikes_som / duration_seconds);
            spike_rate_pyr = mean(total_spikes_pyr / duration_seconds);
            
            % Store the inferred spike rate for the current fold.
            temp = [spike_rate_pyr, spike_rate_som, spike_rate_pv];
            overall_spike_rate(splits, m, :) = temp;
        end
    end
end
