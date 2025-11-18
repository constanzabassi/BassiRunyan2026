function pVals = bootstrap_mod_index_cv(data_subset1, data_subset2, response_range, nShuffles, mod_type)
% bootstrap_mod_index_cv performs a bootstrap procedure to generate a null
% distribution of the modulation index for each neuron and computes two-sided p-values.
%
%   Inputs:
%     data_subset1   - 3D array for group1 responses.
%                      For mod_type 'ctrl' or 'influence': stim_data_subset.
%                      For mod_type 'prepost': the "post" period from stim_data_subset.
%                      For mod_type 'prepost_sound': the "post" period from ctrl_data_subset.
%     data_subset2   - 3D array for group2 responses.
%                      For mod_type 'ctrl' or 'influence': ctrl_data_subset.
%                      For mod_type 'prepost': the "pre" period from stim_data_subset.
%                      For mod_type 'prepost_sound': the "pre" period from ctrl_data_subset.
%     response_range - Cell array of frame indices over which to average the response.
%                      For 'ctrl' and 'influence', only the first cell is used.
%                      For 'prepost' and 'prepost_sound', two cells are expected:
%                         {group1_window, group2_window}.
%     nShuffles      - Number of bootstrap iterations.
%     mod_type       - String specifying the modulation index calculation:
%                      'ctrl' or 'influence': compute mod index comparing group1 (stim) vs. group2 (ctrl).
%                      'prepost': compute mod index comparing group1 (post period) vs. group2 (pre period)
%                      'prepost_sound': similar to 'prepost' but using control data.
%
%   Output:
%     pVals - 1 x nNeurons vector of two-sided p-values.
%
% Procedure:
%   1. Average each trial's activity over the specified response_range(s), resulting in two groups.
%   2. Compute the observed modulation index using the appropriate function.
%   3. Combine the trial-averaged responses (group1 and group2) into one matrix.
%   4. For each bootstrap iteration, randomly permute the trial labels (preserving group sizes),
%      compute a "shuffled" modulation index, and store it.
%   5. For each neuron, compute the p-value as:
%          p = (number of shuffles with |shuffled_mod| >= |observed_mod| + 1) / (nShuffles + 1)
%
%   Author: CB, 9/22/25
    %%% Step 1: Compute Averages for Group1 and Group2 %%%
    if (strcmp(mod_type, 'prepost')|| strcmp(mod_type, 'prepost_num') || strcmp(mod_type, 'prepost_sound') || strcmp(mod_type,'prepost_abs')) && length(response_range) > 1
        % For prepost comparisons: use two different response windows.
        % using subset1 which is probably stim data
        group1 = mean(data_subset1(:, :, response_range{1}), 3);  % e.g., post period
        group2 = mean(data_subset1(:, :, response_range{2}), 3);  % e.g., pre period (for 'prepost')
        if strcmp(mod_type, 'prepost_sound') || strcmp(mod_type, 'prepost_sound_num') 
            % For 'prepost_sound', use control data for both groups.
            group1 = mean(data_subset2(:, :, response_range{1}), 3);
            group2 = mean(data_subset2(:, :, response_range{2}), 3);
        end
    elseif strcmp(mod_type, 'prepost_ctrl') || strcmp(mod_type, 'prepost_ctrl_abs') || strcmp(mod_type,'signed_ctrl')
        % Ensure your data is in double precision
            data_subset1 = double(data_subset1);
            data_subset2 = double(data_subset2);
            group1 = mean(data_subset1(:, :, response_range{1}), 3) - mean(data_subset1(:, :, response_range{2}), 3);
            group2 = mean(data_subset2(:, :, response_range{1}), 3) - mean(data_subset2(:, :, response_range{2}), 3);
    elseif strcmp(mod_type,'pre_engagement') || strcmp(mod_type,'pre_engagement_num')
            group1 = mean(data_subset1(:, :, response_range{2}), 3); %take mean across pre stim period!
            group2 = mean(data_subset2(:, :, response_range{2}), 3);
    else
        % For 'ctrl' and 'influence', use the first response_range:
        group1 = mean(data_subset1(:, :, response_range{1}), 3);  % from stim_data_subset
        group2 = mean(data_subset2(:, :, response_range{1}), 3);  % from ctrl_data_subset
    end

    %%% Step 2: Compute the Observed Modulation Index %%%
    if strcmp(mod_type, 'ctrl') || strcmp(mod_type, 'prepost_ctrl') || strcmp(mod_type, 'pre_engagement')
        observed_mod = compute_mod_index_ctrl(group1, group2);
    elseif strcmp(mod_type, 'ctrl_num') || strcmp(mod_type,'pre_engagement_num')
        observed_mod = compute_mod_index_ctrl_numerator(group1, group2);
    elseif strcmp(mod_type, 'influence')
        observed_mod = compute_mod_index_influence(group1, group2);
    elseif strcmp(mod_type, 'prepost') || strcmp(mod_type, 'prepost_sound')
        observed_mod = compute_mod_index_prepost(group1, group2);
    elseif strcmp(mod_type, 'prepost_num') || strcmp(mod_type, 'prepost_sound_num')
        observed_mod = compute_mod_index_prepost_numerator(group1, group2);
    elseif strcmp(mod_type, 'prepost_ctrl_abs')
        observed_mod = compute_mod_index_ctrl_abs(group1, group2);
    elseif strcmp(mod_type,'prepost_abs')
        observed_mod = compute_mod_index_prepost_abs(group1, group2);
    elseif strcmp(mod_type,'ctrl_abs')
        observed_mod = compute_mod_index_ctrl_abs(group1, group2);
    elseif strcmp(mod_type,'signed_ctrl')
        observed_mod = compute_signed_mod_index(group1, group2);
    else
        error('Invalid mod_type. Choose from ''ctrl'', ''influence'', ''prepost'', or ''prepost_sound''.');
    end
    %%% Step 3: Combine the Trial-Averaged Data %%%
    nTrials_group1 = size(group1, 1);
    nTrials_group2 = size(group2, 1);
    nNeurons = size(group1, 2);
    combined = [group1; group2];  % Combined data: [nTotal x nNeurons]
    nTotal = nTrials_group1 + nTrials_group2;
    
    %%% Step 4: Bootstrapping %%%
    bootMod = zeros(nShuffles, nNeurons);
    for shuff = 1:nShuffles
        permIdx = randperm(nTotal);
        simGroup1 = combined(permIdx(1:nTrials_group1), :);
        simGroup2 = combined(permIdx(nTrials_group1+1:end), :);

        %select appropriate calculation
        if strcmp(mod_type, 'ctrl') || strcmp(mod_type, 'prepost_ctrl') || strcmp(mod_type, 'pre_engagement')
            bootMod(shuff, :) = compute_mod_index_ctrl(simGroup1, simGroup2);
        elseif strcmp(mod_type, 'ctrl_num') || strcmp(mod_type,'pre_engagement_num')
            bootMod(shuff, :) = compute_mod_index_ctrl_numerator(simGroup1, simGroup2);
        elseif strcmp(mod_type, 'influence')
            bootMod(shuff, :) = compute_mod_index_influence(simGroup1, simGroup2);
        elseif strcmp(mod_type, 'prepost') || strcmp(mod_type, 'prepost_sound')
            bootMod(shuff, :) = compute_mod_index_prepost(simGroup1, simGroup2);
        elseif strcmp(mod_type, 'prepost_num') || strcmp(mod_type, 'prepost_sound_num')
            bootMod(shuff, :) = compute_mod_index_prepost_numerator(simGroup1, simGroup2);
        elseif strcmp(mod_type, 'prepost_ctrl_abs')
            bootMod(shuff, :) = compute_mod_index_ctrl_abs(simGroup1, simGroup2);
        elseif strcmp(mod_type,'prepost_abs')
            bootMod(shuff, :) = compute_mod_index_prepost_abs(simGroup1, simGroup2);
        elseif strcmp(mod_type,'ctrl_abs')
            bootMod(shuff, :) = compute_mod_index_ctrl_abs(simGroup1, simGroup2);
        elseif strcmp(mod_type,'signed_ctrl')
            bootMod(shuff, :) = compute_signed_mod_index(simGroup1, simGroup2);
        else
            error('Invalid mod_type in bootstrapping. Choose from ''ctrl'', ''influence'', ''prepost'', or ''prepost_sound''.');
        end
    end
    %%% Step 5: Compute p-values %%%
    pVals = zeros(1, nNeurons);
    for cel = 1:nNeurons
        countExtreme = sum(abs(bootMod(:, cel)) >= abs(observed_mod(cel)));
        pVals(cel) = (countExtreme + 1) / (nShuffles + 1);
    end
end