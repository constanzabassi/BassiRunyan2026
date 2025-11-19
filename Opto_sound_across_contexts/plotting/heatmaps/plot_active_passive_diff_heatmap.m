function plot_active_passive_diff_heatmap(context_data, frames_to_sort, x_label, savepath)
% plot_active_passive_diff(context_data, frames_to_sort, savepath)
%
% Computes mean responses across datasets for active/passive contexts,
% plots the difference heatmap, and plots histogram of neuron differences.
%
% INPUTS:
%   context_data  - structure containing dff{ctx,dataset}.stim and .ctrl
%   frames_to_sort - vector of frames to compute sorting (e.g. 50:59)
%   xlabel - string to label the x axis
%   savepath       - folder to save the PDF output 
%
% OUTPUTS:
%   None (plots + saves figure)
%
% Connie Bassi / ChatGPT — 2025

%% ----------------------------------------------------------
% 1) Compute mean responses for each context across datasets
% ----------------------------------------------------------
all_means  = cell(1,2);
all_means2 = cell(1,2);

for ctx = 1:2
    temp  = [];
    temp2 = [];
    for dataset = 1:24
        temp  = [temp;  squeeze(mean(context_data.dff{ctx,dataset}.stim,1))];
        temp2 = [temp2; squeeze(mean(context_data.dff{ctx,dataset}.ctrl,1))];
        % If someday you want z_ctrl instead:
        % temp2 = [temp2; squeeze(mean(context_data.dff{ctx,dataset}.z_ctrl,1))];
    end
    all_means{ctx}  = temp;
    all_means2{ctx} = temp2;
end

%% ----------------------------------------------------------
% 2) Extract active and passive
% ----------------------------------------------------------
data1 = all_means2{1}; % active ctrl mean
data2 = all_means2{2}; % passive ctrl mean

data11 = all_means{1}; % active stim mean
data22 = all_means{2}; % passive stim mean

%% ----------------------------------------------------------
% 3) Sort neurons by active−passive difference in specific frames
% ----------------------------------------------------------
[y_axis, ~] = max(data11(:,frames_to_sort) - data22(:,frames_to_sort), [], 2);
[~, value] = sort(y_axis, 'descend');

%% ----------------------------------------------------------
% 4) Plot heatmap of Active - Passive
% ----------------------------------------------------------
figure(2); clf; colormap redblue
imagesc(data11(value,:) - data22(value,:)); 
caxis([-.2, .2]);

xline(61, 'w', 'LineWidth', 2)
title('Active - Passive', 'FontWeight', 'normal');
if ~isempty(x_label)
    xlabel(x_label);
else
    xlabel('Time (s)');
end
ylabel('Neuron #');

% time axis
[xticks_in, xticks_lab] = utils.x_axis_sec_aligned(61, size(data11,2), 1);
xticks(xticks_in);
xticklabels(xticks_lab);
yticks([1 size(data11,1)]);


cb = colorbar;
cb.Label.String = 'Difference ΔF/F';
cb.Label.Rotation = 270;
curr_position = cb.Label.Position;
cb.Label.Position = [curr_position(1)+.5, curr_position(2:3)];

set(gcf, 'Position', [100 100 190 190]);
utils.set_current_fig;

if exist('savepath', 'var') && ~isempty(savepath)
    exportgraphics(gcf, fullfile(savepath, 'avg_difference_stim_trials.pdf'), 'ContentType', 'vector');
end

%% ----------------------------------------------------------
% 5) Histogram of per-neuron differences
% ----------------------------------------------------------
diff = mean(data11(:,frames_to_sort) - data22(:,frames_to_sort), 2);

figure(3); clf;
histogram(diff, 'BinWidth', 0.05, 'FaceColor', [0.5,0.5,0.5], 'Normalization', 'probability');
xlabel('Difference Pre Active vs Passive');
ylabel('Fraction Neurons');

set(gcf, 'Position', [100 100 250 200]);

end
