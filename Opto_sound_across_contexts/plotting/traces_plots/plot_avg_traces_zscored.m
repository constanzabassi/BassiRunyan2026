function zscored_means = plot_avg_traces_zscored(deconv_response, colors, lineStyles_contexts, ...
    celltypes_ids, frames, stim_frame, save_dir, type, plot_info)
%zscore traces across contexts, then plot them separated by dataset!

positions = utils.calculateFigurePositions(1, 6, .4, []);
if size(deconv_response,3) > 3
    positions = utils.calculateFigurePositions(1, 7, .3, []);
end

contexts = {'active','passive'}; 
stim_ctrl_idx = [1, 0]; % stim vs ctrl

%% === (1) Precompute z-scored traces per dataset/context ===
zscored_means = cell([2,size(deconv_response)]); % {stim or ctrl, context, mouse, celltype}

for stim_ctrl = 1:2
    for celtype = 1:size(deconv_response,3)
        for mouse = 1:size(deconv_response,2)
            mouse
            % --- collect data across contexts ---
            all_context_data = [];
            context_sizes = zeros(size(deconv_response,1),1);
    
            for context = 1:size(deconv_response,1)
                dat_struct = deconv_response{context,mouse,celtype};
                if isempty(dat_struct) && length( dat_struct.stim) > 1 && length( dat_struct.ctrl) > 1
                    continue
                end
    
                % choose stim if available, otherwise ctrl
                if stim_ctrl_idx(stim_ctrl) == 1 && isfield(dat_struct,'stim') && ~isempty(dat_struct.stim) && size( dat_struct.stim,2) > 1
                    dat = dat_struct.stim;
                elseif stim_ctrl_idx(stim_ctrl) == 0 && isfield(dat_struct,'ctrl') && ~isempty(dat_struct.ctrl) && size( dat_struct.ctrl,2) > 1
                    dat = dat_struct.ctrl;
                else
                    continue
                end
    
                if ndims(dat) > 2
                    dat = squeeze(mean(dat));
                end
                dat = dat(:, frames); % restrict to frames
    
                context_sizes(context) = size(dat,1);
                all_context_data = [all_context_data; dat];
            end
    
            % --- zscore across concatenated contexts ---
            if isempty(all_context_data)
                continue
            end
            all_context_data = zscore(all_context_data,0,2); % zscore per neuron
    
            % --- split back into contexts and compute averages ---
            idx_start = 1;
            for context = 1:size(deconv_response,1)
                if context_sizes(context) == 0, continue; end
                idx_end = idx_start + context_sizes(context) - 1;
                dat_context = all_context_data(idx_start:idx_end,:);
                mean_trace = mean(dat_context,1);
                zscored_means{stim_ctrl,context,mouse,celtype} = mean_trace;
                idx_start = idx_end + 1;
            end
        end
    end
end
%% === (2) Plotting ===
for stim_idx = 1:length(stim_ctrl_idx)
    figure(stim_idx); clf;

    for celtype = 1:size(deconv_response,3)
        subplot(1, size(deconv_response,3), celtype);
        hold on;

        for context = 1:size(deconv_response,1)
            mouse_means = [];

            for mouse = 1:size(deconv_response,2)
                dat = zscored_means{stim_idx,context,mouse,celtype};
                if isempty(dat), continue; end
                mouse_means = [mouse_means; dat];
            end

            if ~isempty(mouse_means)
                shadedErrorBar([], mean(mouse_means,1), ...
                    std(mouse_means,[],1)/sqrt(size(mouse_means,1)), ...
                    'lineprops', {'LineWidth',1.5, ...
                                  'LineStyle',lineStyles_contexts{context}, ...
                                  'Color',colors((celtype-1)*3+context,:)});
            end
        end

%         % formatting
%         xlim([31 91]);
%         xticks([31 61 91]);
%         xticklabels([-1 0 1]);
            xlimss = [1 60];
            xlim(xlimss );
            xticks([1 60]);
            xticklabels([-2 0]);

            if  isfield(plot_info,'trace_ylims') && ~isempty(plot_info.trace_ylims)
                ylim([plot_info.trace_ylims]);
            end

        yli = ylim;
%         for f = 1:size(stim_frame,1)
%             rectangle('Position', [stim_frame(f,1), yli(1), ...
%                 stim_frame(f,2)-stim_frame(f,1), yli(2)-yli(1)], ...
%                 'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
%         end
        title(celltypes_ids{celtype}, 'FontSize', 7, ...
              'FontName','arial','FontWeight','normal');
        set(gca,'FontSize',7,'Units','inches','Position',positions(celtype,:));
    end

    if ~isempty(save_dir)
        fig_suffix = {'zscored_stim','zscored_ctrl'};
        mkdir(fullfile(save_dir,'avg_traces'));
        saveas(gcf, fullfile(save_dir,'avg_traces', ...
            strcat('avg_traces_', fig_suffix{stim_idx},'_',type,'zscoreframes',num2str([frames(1),frames(end)]),'.fig')));
        exportgraphics(gcf, fullfile(save_dir,'avg_traces', ...
            strcat('avg_traces_', fig_suffix{stim_idx},'_',type,'zscoreframes',num2str([frames(1),frames(end)]),'.pdf')), ...
            'ContentType','vector');
    end
end
