function [spike_context_matrix,spike_context_matrix_ctrl] = trial_mean_from_struc(spike_trial_cel_mouse,all_celltypes)


% spike_context_matrix = cell(size(spike_trial_cel_mouse, 2), size(spike_trial_cel_mouse, 1));       % [mouse x context]
% spike_context_matrix_ctrl = cell(size(spike_trial_cel_mouse, 2), size(spike_trial_cel_mouse, 1));  % same size
fieldss = fields(spike_trial_cel_mouse{1,1,1});
if ismember('stim',fieldss)
    fieldss = {'stim','ctrl'};
end

celltype_fields = fields(all_celltypes{1,1});

for mouse = 1:size(spike_trial_cel_mouse, 2)
    for context = 1:size(spike_trial_cel_mouse, 1)
        
        % Initialize arrays with NaNs to preserve indexing
%         stim_vector = nan(1, size(spike_trial_cel_mouse{context, mouse, :}.(fieldss{1}),length(celltype_fields)+1));
%         ctrl_vector = nan(1, size(spike_trial_cel_mouse{context, mouse, :}.(fieldss{2}),length(celltype_fields)+1));

        for celtype = 1:length(celltype_fields)+1
            if celtype == length(celltype_fields)+1
                temp = spike_trial_cel_mouse(context, mouse, :);  % Get the slice
                temp = temp(:);  % Convert to column vector for easy looping
                data = cellfun(@(x) x.(fieldss{1}), temp, 'UniformOutput', false);
                result = cell2mat(data(:)');
                stim = mean(result,2);  % [T X N]- take average across cells!

                temp = spike_trial_cel_mouse(context, mouse, :);  % Get the slice
                temp = temp(:);  % Convert to column vector for easy looping
                data = cellfun(@(x) x.(fieldss{2}), temp, 'UniformOutput', false);
                result = cell2mat(data(:)');
                ctrl =  mean(result,2); 
            else
                stim = mean(spike_trial_cel_mouse{context, mouse, celtype}.(fieldss{1}),2);  % [T x N]- take average across cells!
                ctrl =  mean(spike_trial_cel_mouse{context, mouse, celtype}.(fieldss{2}),2); 
            end
            



            % Assign ordered vectors
            spike_context_matrix{mouse, context,celtype} = stim;
            spike_context_matrix_ctrl{mouse, context,celtype} = ctrl;

        end

        
    end
end