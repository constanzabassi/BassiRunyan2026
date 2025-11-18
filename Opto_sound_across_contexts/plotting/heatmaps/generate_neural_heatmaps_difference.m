function generate_neural_heatmaps_difference(neural_structure, stim_trials_context, ctrl_trials_context,sig_mod_boot, chosen_mice, params,type, context_to_plot,difference_params,varargin)
 %     % Generate heatmaps from neural_structure using z-scored data
%     %
%     % Inputs:
%     %   neural_structure - Structure with .stim and .ctrl fields [trials x neurons x frames]
%     %   trial_info      - Structure with trial conditions
%     %   current_dataset - Index of current dataset
%     %   context        - Context index (1=active, 2=passive)
%     %   params         - Plotting parameters
%     %   difference_params - take the specified difference
%  
nContexts = length(context_to_plot); %size(stim_trials_context{1,1},2);

% Store data across contexts
data_by_context = cell(1,nContexts);  % To store for each context
data_by_context_ctrl = cell(1,nContexts);  % To store 

params = get_heatmap_params();
positions = utils.calculateFigurePositions(1, 7, .5, []);

if nargin > 9
    minmax = varargin{1,1};
else
    minmax = [-.1,.5];
end

% Plot each context with specified sorting
context_count = 0;
for context = context_to_plot
    context_count = context_count+1;
    
    temp = [];temp2 = [];
    for dataset_index = chosen_mice
        cellCount = size(neural_structure{1,dataset_index}.z_stim,2);
        if ~isempty(sig_mod_boot)
            mod_cells = sig_mod_boot{1,dataset_index}; %
            save_name = 'sig_cells';
        else
            mod_cells = 1:cellCount;
            save_name = 'all_cells';
        end
        %get mean across trials
        temp = [temp;squeeze(mean(neural_structure{1,dataset_index}.stim(stim_trials_context{1,dataset_index}{1,context},mod_cells,:)))];
        temp2 = [temp2;squeeze(mean(neural_structure{1,dataset_index}.ctrl(ctrl_trials_context{1,dataset_index}{1,context},mod_cells,:)))];

    end

    % Compute differences based on difference_params
    switch difference_params.type
        case 'stim_sub_ctrl_all'
            data_diff = temp - mean(temp2,2);%temp2;
            frames_used = 'all';
        
        case 'stim_sub_ctrl_post'
%             stim_pre = mean(temp(:,difference_params.post_frames),2);
%             stim_post = mean(temp(:,difference_params.post_frames),2);
            ctrl_post = mean(temp2(:,difference_params.post_frames),2);
            frames_used = num2str([difference_params.post_frames(1),difference_params.post_frames(end)]);
            data_diff = temp - ctrl_post;
    
        case 'stim_sub_pre'
            stim_pre = mean(temp(:,difference_params.pre_frames),2);
%             stim_post = mean(temp(:,difference_params.post_frames),2);
            frames_used = num2str([difference_params.pre_frames(1),difference_params.pre_frames(end)]);
            data_diff = temp - stim_pre;
    
        case 'ctrl_sub_pre'
            ctrl_pre = mean(temp2(:,difference_params.pre_frames),2);
%             ctrl_post = mean(temp2(:,difference_params.post_frames),2);
            frames_used = num2str([difference_params.pre_frames(1),difference_params.pre_frames(end)]);
            data_diff = temp2 - ctrl_pre;
    
        otherwise
            error('Unknown difference type specified.');
    end

    data_by_context{context_count} = squeeze(data_diff); % average across trials

    %sort by first context
    if context_count == 1
        % Get sorting index if specified in params
        sort_data = data_diff;      
        
        % Get reference data for sorting
        [sorted_idx, ~] = sort_neurons(sort_data, params);
    end
    
end

figure(1);clf;
%PLOT BASIC HEATMAPS (STIM)
for context = 1:nContexts
    % Plot using consistent sorting
    subplot(1,nContexts,context)

    plot_single_direction_heatmap(data_by_context{context}, sorted_idx, [params.context_labels{context_to_plot(context)}], params);
    utils.set_current_fig;
    caxis(minmax);
    colorbar('off');

    % Add common colorbar and save
    if context == nContexts
    cb = colorbar;
%     cb.Position = [0.92 0.1 0.02 0.8];
    cb.Label.String = 'Difference ΔF/F';
    cb.Label.Rotation = 270;
    curr_position =  cb.Label.Position;
    cb.Label.Position = [curr_position(1)+.5,curr_position(2:3)];
    caxis(minmax);
    end
    set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(context, :));

    %adjust label position again after resizing plot
    if context == nContexts
    curr_position =  cb.Label.Position;
    if nContexts == 1
        to_add = 6;
    else
        to_add = 4;
    end
    cb.Label.Position = [curr_position(1)+to_add,curr_position(2:3)];
    end

end
if isfield(params, 'savepath')
    % Define the filename
    ctx_str = sprintf('%d', context_to_plot);
    save_fname = sprintf('heatmap_difference_%s_%s_%s_%s_%s.png', difference_params.type,frames_used, type, save_name, ctx_str);

    saveas(gcf, fullfile(params.savepath, save_fname));

    save_fname = sprintf('heatmap_difference_%s_%s_%s_%s_%s.pdf',difference_params.type,frames_used, type, save_name, ctx_str);
    exportgraphics(gcf,fullfile(params.savepath, save_fname), 'ContentType', 'vector','BackgroundColor', 'none');
end

end
