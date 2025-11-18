function [stats] = mod_index_violin_across_celltypes_datasets(save_dir, mod_index_by_dataset, plot_info, varargin)

figure(97);clf
% t = tiledlayout(1,n_celltypes,'TileSpacing','Compact','Padding','Compact');
positions = utils.calculateFigurePositions(1, 6, .5, []);

% Get number of datasets
n_datasets = length(mod_index_by_dataset);
n_celltypes = size( mod_index_by_dataset,3);
if nargin > 4
    num_contexts = varargin{1,2};
else
    num_contexts = 2;
end

%initialize plotting variables
behavioral_contexts = plot_info.behavioral_contexts;
colors = plot_info.colors_celltypes;
cell_type_names = plot_info.celltype_names;
p_stim = [];

for cel_type = 1:n_celltypes
    %     nexttile
    subplot(1,n_celltypes,cel_type)
    title(cell_type_names{cel_type},'FontSize',8,'FontName','arial','FontWeight','normal');
    for context = 1:num_contexts

        stats.stats{cel_type} = get_basic_stats(cellfun(@mean ,{mod_index_by_dataset{:,context,cel_type}}));
        %make plots
        hold on

        %make sure there is data
        if all(~isnan(stats.stats{cel_type}.ci(:,1)))
            a(context) = Violin({cellfun(@nanmean ,{mod_index_by_dataset{:,context,cel_type}})},context,'ViolinColor',[{colors(cel_type,:)}],'EdgeColor',colors(cel_type,:),'QuartileStyle','boxplot'); %,'ViolinAlpha',{0.0, 0.8}
        end
        
        if cel_type == 1
            ylabel('Modulation Index')
        elseif cel_type == 2
%             xlabel('Modulation Index')
        end

        stim_contexts{context} = cellfun(@nanmean ,{mod_index_by_dataset{:,context,cel_type}});
    end

    %permutation test
    if num_contexts > 2
        possible_tests = nchoosek(1:num_contexts,2);
        
        ct = 0;
        
        for t = 1:size(possible_tests,1)
            [p_stim(t), observeddifference, effectsize] = permutationTest_updatedcb([mod_index_by_dataset{:,possible_tests(t,1),cel_type}], [mod_index_by_dataset{:,possible_tests(t,2),cel_type}], 10000,'paired',1);

            if p_stim(t) < 0.05/n_celltypes
                xline_vars(1) = possible_tests(t,1); 
                xline_vars(2) = possible_tests(t,2); 
                xval = 0;  
                utils.plot_pval_star(xval, .3+ct, p_stim(t), xline_vars,0.01)
                ct = ct+0.1;
            end

        end
    end

    if nargin >3
        ylim(varargin{1,1});
    else
        ylim([-.5 1.2]);
    end
    xticks([1:num_contexts])
    xticklabels(behavioral_contexts)

    set(gca,'fontsize',12,'Units','Inches','Position',positions(cel_type,:));
    stats.p_all{cel_type} = p_stim;
    utils.set_current_fig;
end

hold off
% set(gcf,'units','points','position',[10,100,400,200])


%make boxplot!
w = 0.5
figure(98);clf
% t = tiledlayout(1,n_celltypes,'TileSpacing','Compact','Padding','Compact');
for cel_type = 1:n_celltypes
    subplot(1,n_celltypes,cel_type)
    title(cell_type_names{cel_type},'FontSize',8,'FontName','arial','FontWeight','normal');
    for context = 1:num_contexts

        %make plots
        hold on
        h = boxplot(cellfun(@nanmean ,{mod_index_by_dataset{:,context,cel_type}}), 'position', context, 'width', w, 'colors', colors(cel_type,:),'symbol', 'o');
        %set line width
        out_line = findobj(h, 'Tag', 'Outliers');
        set(out_line, 'Visible', 'off');
        hh = findobj('LineStyle','--','LineWidth',1); 
        set(h(1:6), 'LineStyle','-','LineWidth',1.5);
        
        if cel_type == 1
            ylabel('Modulation Index')
        elseif cel_type == 2
            %xlabel('Modulation Index')
        end

        stim_contexts{context} = cellfun(@nanmean ,{mod_index_by_dataset{:,context,cel_type}});
    end

    %permutation test
    if num_contexts > 2
        possible_tests = nchoosek(1:num_contexts,2);
        
        ct = 0;
        
        for t = 1:size(possible_tests,1)
            [p_stim(t), observeddifference, effectsize] = permutationTest_updatedcb([mod_index_by_dataset{:,possible_tests(t,1),cel_type}], [mod_index_by_dataset{:,possible_tests(t,2),cel_type}], 10000,'paired',1);

            if p_stim(t) < 0.05/n_celltypes
                xline_vars(1) = possible_tests(t,1); 
                xline_vars(2) = possible_tests(t,2); 
                xval = 0;  
                utils.plot_pval_star(xval, .3+ct, p_stim(t), xline_vars,0.01)
                ct = ct+0.1;
            end

        end
    end

    if nargin >3
        ylim(varargin{1,1});
    else
        ylim([-.5 1.2]);
    end
    xticks([1:num_contexts])
    xticklabels(behavioral_contexts)
    xlim([0 num_contexts+1])
    set(gca,'fontsize',12,'box','off','Units','Inches','Position',positions(cel_type,:));
    stats.p_all{cel_type} = p_stim;
    utils.set_current_fig;
end

hold off


if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    saveas(97,strcat('mod_index_violin_across_celltypes_by_dataset_',num2str(n_datasets),'_datasets.svg'));
    saveas(97,strcat('mod_index_violin_across_celltypes_by_dataset_',num2str(n_datasets),'_datasets.fig'));
    exportgraphics(figure(97),[strcat('mod_index_violin_across_celltypes_by_dataset_',num2str(n_datasets),'_datasets.pdf')], 'ContentType', 'vector');
    
    saveas(98,strcat('mod_index_boxplot_across_celltypes_by_dataset_',num2str(n_datasets),'_datasets.svg'));
    saveas(98,strcat('mod_index_boxplot_across_celltypes_by_dataset_',num2str(n_datasets),'_datasets.fig'));
    exportgraphics(figure(98),strcat('mod_index_boxplot_across_celltypes_by_dataset_',num2str(n_datasets),'_datasets.pdf'), 'ContentType', 'vector');

    
    save('mod_index_contexts_distribution_stats','stats')
end