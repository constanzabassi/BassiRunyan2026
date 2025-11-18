function mod_stats = scatter_abs_mean_mod(save_dir,stim_mod,plot_info,celltypes_ids,chosen_mice,version,varargin)
figure(600);clf %('Name','n/n running mod w subsampled trials');clf

num_bin = length(plot_info.behavioral_contexts);

if nargin > 8
    stim_mod = stim_mod; %no abs
else
    stim_mod = abs(stim_mod);
end
x_lines = 0:num_bin+1;
mean_cell_all =[];
positions = utils.calculateFigurePositions(1, 5, .5, []);
if nargin > 6
     ylims = varargin{1,1};
end

if version == 1
for bin = 1:num_bin
    for c = 1:length(celltypes_ids) %celltypes
    hold on
    mean_cel = nanmean(stim_mod(celltypes_ids{1,c},bin),[1]); %overall mean for cell
    err = std(stim_mod(celltypes_ids{1,c},bin)) / sqrt(size(stim_mod(celltypes_ids{1,c},bin),1)); %SEM across subsamples
    mod_stats.stats(c,bin) = get_basic_stats(stim_mod(celltypes_ids{1,c},bin));
    errorbar(x_lines(bin+1),mean_cel,err,"o",'markeredgecolor',plot_info.colors_celltypes(c,:),'color',plot_info.colors_celltypes(c,:),'LineWidth',1,'MarkerSize', 2)

%     below to use 95% confidence interval instead
%     errorbar(x_lines(bin+1)+0.2*c,mean_cel,run_stats.stats(c,bin).ci(2,1),run_stats.stats(c,bin).ci(1,1),"o",'markeredgecolor',plot_info.colors_celltypes(c,:),'color',plot_info.colors_celltypes(c,:),'LineWidth',1.5)
    mean_cell_all = [mean_cell_all,mean_cel];
    end
end
xlim([x_lines(1) x_lines(end)])
xticks(x_lines(1)+1:x_lines(end)-1)
xticklabels(plot_info.behavioral_contexts)
ylabel('Absolute Modulation Index')
if nargin > 7
    ylabel(varargin{1,2})
end


%[KW_Test.stimvctrl_p_val,KW_Test.stimvctrl_tbl, KW_Test.stimvctrl_stats_cell] = kruskalwallis([stim_mod,ctrl_mod],[1:3,1:3]);
% Perform Kruskal-Wallis test for celltypes!

ct = 0;
possible_tests = nchoosek(1:num_bin,2);
y_val = max(mean_cell_all)+0.05;
for ce = 1:length(celltypes_ids)%length(possible_tests)
    for t = 1:size(possible_tests,1)
        [p_val_mod(t,ce), observeddifference, effectsize(t,ce)] = permutationTest_updatedcb(stim_mod(celltypes_ids{1,ce},possible_tests(t,1)), stim_mod(celltypes_ids{1,ce},possible_tests(t,2)), 10000,'paired',1);

%     [p_val_mod(t,ce),h(t,ce)] = signrank(stim_mod(celltypes_ids{1,ce},possible_tests(t,1)), stim_mod(celltypes_ids{1,ce},possible_tests(t,2)),'alpha',0.05/length(possible_tests));
    
        if p_val_mod(t,ce) < 0.05/length(possible_tests)
            xline_vars = possible_tests(t,:);   
            ct = ct+.03;
            utils.plot_pval_star(0, y_val+ct, p_val_mod(t,ce), xline_vars,0.01,plot_info.colors_celltypes(ce,:))
        end
    end
end
yli = ylim;
ylim([0,yli(2)])
if nargin > 6
        ylim(varargin{1,1});
end
xlim([x_lines(1) x_lines(end)])
xticks(x_lines(1)+1:x_lines(end)-1)
xticklabels([plot_info.behavioral_contexts])
ylabel({'Absolute Modulation'}, {'Index'})
if nargin > 7
    ylabel(varargin{1,2})
end
set(gcf,'units','points','position',[10,100,600,250])
utils.set_current_fig;

for ce = 1:length(celltypes_ids)
    [KW.p_val(ce),KW.tbl{ce}, KW.stats_cell{ce}] = kruskalwallis([stim_mod(celltypes_ids{1,ce},:)],[1:3],'off');
end

else
count=0;
x_lines = 0:num_bin*length(celltypes_ids)+1;
for c = 1:length(celltypes_ids) %celltypes
    mean_cell_all =[];
    for bin = 1:num_bin
    count = count+1;
    hold on
    mean_cel = nanmean(stim_mod(celltypes_ids{1,c},bin),[1]); %overall mean for cell
    err = std(stim_mod(celltypes_ids{1,c},bin)) / sqrt(size(stim_mod(celltypes_ids{1,c},bin),1)); %SEM across subsamples
    mod_stats.stats(c,bin) = get_basic_stats(stim_mod(celltypes_ids{1,c},bin));
    errorbar(x_lines(count+1),mean_cel,err,"o",'markeredgecolor',plot_info.colors_celltypes(c,:),'color',plot_info.colors_celltypes(c,:),'LineWidth',1,'MarkerSize', 2)

%     below to use 95% confidence interval instead
%     errorbar(x_lines(bin+1)+0.2*c,mean_cel,run_stats.stats(c,bin).ci(2,1),run_stats.stats(c,bin).ci(1,1),"o",'markeredgecolor',plot_info.colors_celltypes(c,:),'color',plot_info.colors_celltypes(c,:),'LineWidth',1.5)
    mean_cell_all = [mean_cell_all,mean_cel];

    end
    ct = 0;
    possible_tests = nchoosek(1:num_bin,2);
    if max(mean_cell_all) > 0.1
    y_val = max(mean_cell_all)+0.03;
    else
          y_val = max(mean_cell_all);
    end
    ce= c;
    for t = 1:size(possible_tests,1)
    [p_val_mod(t,ce), observeddifference, effectsize(t,ce)] = permutationTest_updatedcb(stim_mod(celltypes_ids{1,ce},possible_tests(t,1)), stim_mod(celltypes_ids{1,ce},possible_tests(t,2)), 10000,'paired',1);
        if p_val_mod(t,ce) < 0.05/length(celltypes_ids)
            xline_vars = possible_tests(t,:)+((c-1)*length(plot_info.behavioral_contexts));  
            ct = ct+.03;
            utils.plot_pval_star(0, y_val+ct, p_val_mod(t,ce), xline_vars,0.01,plot_info.colors_celltypes(ce,:))
        end
    end

end
xlim([x_lines(1) x_lines(end)])
xticks(x_lines(1)+1:x_lines(end)-1)
xticklabels([plot_info.behavioral_contexts,plot_info.behavioral_contexts,plot_info.behavioral_contexts])
% ylabel('Absolute Modulation Index')
ylabel({'Absolute Modulation';'Index'})
if nargin > 7
    ylabel(varargin{1,2})
end
yli = ylim;
ylim([0,yli(2)])
if nargin > 6
        ylim(varargin{1,1});
end

set(gcf,'Color','w')
set(gca,'FontName','Arial')
%set(gca,'Color','k'b)
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})
xtickangle(45)
% set(gcf,'units','points','position',[10,100,500,200])
% set(gcf,'units','points','position',[10,100,(350/length(celltypes_ids)*length(plot_info.behavioral_contexts)),160])
set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(1, :));
utils.set_current_fig;
% for ce = 1:length(celltypes_ids)
%     [KW.p_val(ce),KW.tbl{ce}, KW.stats_cell{ce}] = kruskalwallis([stim_mod(celltypes_ids{1,ce},:)],[1:length(plot_info.behavioral_contexts)],'off');
% end
[KW.p_val_acrosscontexts,KW.tbl, KW.stats_cell] = kruskalwallis(stim_mod,[1:size(stim_mod,2)],'off');
end
mod_stats.tests = possible_tests;
mod_stats.p_test = 'paired permutation - PermutationTest_updatedcb';
mod_stats.p_val_run_mod = p_val_mod;
mod_stats.effectsize =effectsize;
mod_stats.KW = KW;
hold off
% set(gca,'fontsize',12)
% axis square
if ~isempty(save_dir)
    mkdir(save_dir)
    cd(save_dir)
    if nargin > 7
            save_string = varargin{1,2};
            save_string = strrep(save_string, '\', '');
            save_string = strrep(save_string, '/', '');
            save_string = strrep(save_string, '(', '');
            save_string = strrep(save_string, ')', '');
            if any(contains(save_string,'Δ')) || any(contains(save_string,'elta'))
                save_string = [save_string 'deltastim']
            end
    end
%     saveas(600,strcat('abs_mod_index_scatter_across_allcelltypes_',num2str(length(chosen_mice)),'_datasets.svg'));
    saveas(600,strcat('abs_mod_index_scatter_across_allcelltypes_',num2str(length(chosen_mice)),'_datasets_',save_string,'.fig'));
    exportgraphics(figure(600),strcat('abs_mod_index_scatter_across_allcelltypes_',num2str(length(chosen_mice)),'_datasets_',save_string,'.pdf'), 'ContentType', 'vector');
    save('abs_mod_index_stats_scatter','mod_stats');
end