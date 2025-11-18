function plot_avg_traces_baseline_subtracted_nosem(deconv_response, colors, lineStyles_contexts, celltypes_ids, frames, stim_frame, save_dir, average_over_neurons,type,plot_info)

if nargin < 9
    average_over_neurons = false;
end

lineStyles_contexts = {'-','--','-.'}
positions = utils.calculateFigurePositions(1, 6, .4, []);
contexts = {'active', 'passive'};
data_modes = {'raw', 'bs'};

for fig_idx = 1:2  % Only 2: raw and bs
    figure(fig_idx); clf;

    for celtype = 1:size(deconv_response,3)
        subplot(1, size(deconv_response, 3), celtype);
        hold on;

        for context = 1:size(deconv_response,1)
            for stim_ctrl = 1:2  % 1 = stim, 2 = ctrl
                all_traces = [];
                mouse_means = [];

                for mouse = 1:size(deconv_response,2)
                    dat_struct = deconv_response{context,mouse,celtype};
                    if isempty(dat_struct)
                        continue
                    end

                    if stim_ctrl == 1
                        if ~isfield(dat_struct, 'stim') || isempty(dat_struct.stim)
                            continue
                        end
                        if length(size(dat_struct.stim))>2
                        dat = squeeze(mean(dat_struct.stim));
    %                         if contains(type,'deconv')
    %                             frame_window = 1:size(dat_struct.stim,3);
    %                             dat = squeeze(squeeze(sum(dat_struct.stim(:,:,frame_window),1))/(length(frame_window)/30));
    %                         end
                        else
                            dat = dat_struct.stim;
                        end
                    else
                        if ~isfield(dat_struct, 'ctrl') || isempty(dat_struct.ctrl)
                            continue
                        end
                        if length(size(dat_struct.stim))>2
                            dat = squeeze(mean(dat_struct.ctrl));
                        else
                            dat = dat_struct.ctrl;
                        end                    
                    end

                    if isnan(dat)
                        continue
                    end

                    dat = dat(:, frames);

                    if strcmp(data_modes{fig_idx}, 'bs')
                        baseline = mean(dat(:, 31:60), 2);
                        dat = dat - baseline;
                    end

                    if average_over_neurons
                        all_traces = [all_traces; dat];
                    else
                        mean_trace = mean(dat, 1);
                        mouse_means = [mouse_means; mean_trace];
                    end
                end
                
                if stim_ctrl == 1
                    stim_ctrl_to_add = 0; %change to change ctrl to some other color
                else
                    stim_ctrl_to_add = 2; %change to change ctrl to some other color
                end
                if average_over_neurons && ~isempty(all_traces)
%                     plot(mean(all_traces,1), ...
%                         'LineWidth', 1, ...
%                         'LineStyle', lineStyles_contexts{stim_ctrl}, ...
%                         'Color', colors((celtype-1)*4 + context+stim_ctrl, :));%(celtype-1)*2+context,:)

                    shadedErrorBar([], mean(all_traces,1), ...
                    std(all_traces,[],1)/sqrt(size(all_traces,1)), ...
                    'lineprops', {'LineWidth', 1.2, 'LineStyle', lineStyles_contexts{stim_ctrl}, ...
                    'Color',  colors((celtype-1)*4 + context+stim_ctrl, :)});
                elseif ~isempty(mouse_means)
%                     plot(mean(mouse_means,1), ...
%                         'LineWidth', 1, ...
%                         'LineStyle', lineStyles_contexts{stim_ctrl}, ...
%                         'Color', colors((celtype-1)*4 + context+stim_ctrl, :));

                    shadedErrorBar([], mean(mouse_means,1), ...
                    std(mouse_means,[],1)/sqrt(size(mouse_means,1)), ...
                    'lineprops', {'LineWidth', 1.2, 'LineStyle', lineStyles_contexts{stim_ctrl}, ...
                    'Color', colors((celtype-1)*4 + context+stim_ctrl, :)});
                end
            end
        end

        xlim([31 91]);
        xticks([31 61 91]);
        xticklabels([-1 0 1]);

        title(celltypes_ids{celtype}, 'FontSize', 8, 'FontName', 'arial','FontWeight','normal');
        set(gca, 'FontSize', 8, 'Units', 'inches', 'Position', positions(celtype, :));

        % Use dynamic ylim after plotting
        yli = ylim;
        for f = 1:size(stim_frame,1)
            if contains(type,'opto')
                color_onset = [1 0.8 0.3];
            else
                color_onset = [.5 .5 .5];
            end
            rectangle('Position', [stim_frame(f,1), yli(1), stim_frame(f,2)-stim_frame(f,1), yli(2)-yli(1)], ...
                      'FaceColor', color_onset, 'EdgeColor', 'none');
        end
    end

    if ~isempty(save_dir)
        fig_suffix = {'raw_combined','bs_combined'};
        mkdir(fullfile(save_dir, 'avg_traces'));
        saveas(fig_idx, fullfile(save_dir, 'avg_traces', ...
            strcat('avg_traces_nosem_', fig_suffix{fig_idx}, '_', type, '.fig')));
        exportgraphics(gcf, fullfile(save_dir, 'avg_traces', ...
            strcat('avg_traces_nosem_', fig_suffix{fig_idx}, '_', type, '.pdf')), 'ContentType', 'vector');
    end
end