addpath(genpath('C:\Code\Github\GLM_inputs-main'));
load('V:\Connie\results\behavior_updated\data_info\all_celltypes.mat');
% load('V:\Connie\results\behavior_updated\data_info\imaging_st.mat');
load('V:\Connie\results\behavior_updated\data_info\plot_info.mat');
load('V:\Connie\results\behavior_updated\data_info\info.mat');


bins = 30; %in frames for binning data
coupling_method = 3; %1 = mean, 2= pca, 3 =nnmf
n_dims = 3; % used in pca or nnmf
% target_variance = 0.7; %was doing 0.65
model_type = 'GLM_3nmf_passive'; 

nmf_var = {};
for m =1:length(info.mouse_date)
    
    mm = info.mouse_date(m)
    mm = mm{1,1};
    ss = info.server(m);
    ss = ss {1,1};
    for splits = 1:10
    fprintf(['mouse/ date: ', num2str(mm),' || splits : '  num2str(splits) '\n']);
        base_dir = strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/',model_type);
        dir_base = [base_dir  '/prepost trial cv 73 #' num2str(splits) '/'];    
        load(strcat(dir_base,'combined_response.mat')); %neurons x frames
        response = combined_response;
    
    % first bin the data using 1 second overlapping bins and min max
    % normalize it!
    binned_response = bin_data_overlapping(response, bins); %bins of 30 frames gives neurons x frames
    if ~isempty(find(isnan(binned_response(:,1))))
        nan_cells = find(isnan(binned_response(:,1))); %not responsive results in nans after normalization
        binned_response(nan_cells,:) = 0;

    end
    

    frames = 1:length(binned_response);
    
    fn = fieldnames(all_celltypes{1,m});
    pca_output ={}; r_sq ={};
    for ce = 1:4;%length(fn)

        if ce == 4
            celltype = 1:size(binned_response,1);
        else
            celltype = all_celltypes{1,m}.(fn{ce});
        end
    
        %perform dim reduction
        % [ W,H,D ] = nmf
        %     [W,H,Dnmf] = nnmf(population_data',3); %W timepoints x rank, H rank x neurons, D = root squared mean residual/error

        [W,H,D] = nnmf(binned_response(celltype,frames),n_dims);
        X = H;
% 
%        %used for making matrices for GLM
%         [X,W] = get_coupling_matrix_binned(binned_response(celltype,frames),[], coupling_method,n_dims); %get coupling here so we don't have to redo over and over for each cell (redo only for celltype necessary!!)
%         H = X; %(but X is normalized)
        
        % Coefficient of Determination (R^2) - variance explained
    %     r_sq.pca_ranks(ce) = calc_r2(population_data',scores(:,1:num_dims)*eigVec(:,1:num_dims)'); %takes in real data, reconstructed data
        r_sq.nmf(ce) = calc_r2(binned_response(celltype,frames),W*H);
    
    %     [optimal_k(ce), max_explained_variance(ce),explained_variance_all{ce},Wnew{ce},Hnew{ce}] = find_optimal_k_explained_variance(population_data', 1:length(celltype), target_variance);
    
        numcels{ce} = length(celltype);
    end
    nmf_var{m,splits}.r_sq = r_sq;
    nmf_var{m,splits}.W = W;
    nmf_var{m,splits}.H = X;
    nmf_var{m,splits}.numcels = numcels;
    end

end
save_dir = 'W:\Connie\results\Bassi2025\glm_coupling\nmf_var_coupling';
cd(save_dir );
save(['nmf_var_' model_type],'nmf_var','-v7.3')
% save('mouse','mouse','-v7.3')
% save('neural','neural','-v7.3')

% calculate mean variance across splits
mean_var = zeros(length(info.mouse_date),4); %mouse x celltypes (where 4 is all cells together)
for m = 1:length(info.mouse_date)
    temp = [];
    for split = 1:10
        temp = [temp;nmf_var{m,split}.r_sq.nmf];
    end
    mean_var(m,:) = mean(temp,1);
end

save(['mean_nmf_var_' model_type],'mean_var');

%% make bar plots of mean variance explained across datasets active and passive
%load the data
temp = load('W:\Connie\results\Bassi2025\glm_coupling\nmf_var_coupling\mean_nmf_var_GLM_3nmf_pre.mat');
temp2 = load('W:\Connie\results\Bassi2025\glm_coupling\nmf_var_coupling\mean_nmf_var_GLM_3nmf_passive.mat');
mean_var_all(1,:,:) = temp.mean_var; %context 1 is active
mean_var_all(2,:,:) = temp2.mean_var; %context 1 is passive
num_contexts = 2;
behavioral_contexts = {'Active','Passive'};
%%
addpath(genpath('C:\Code\Github\Opto-analysis'));
figure(999);clf;
% t = tiledlayout(1,3);%,'TileSpacing','Compact','Padding','Compact' %need enough space to plot by celltypes not context!
string = 'Var. Explained';
positions = utils.calculateFigurePositions(1,9,.2,[]);
for ce = 1:3
    subplot(1,3,ce)
    bar_context =[];SEM_cells = [];
    for ct = 1:num_contexts
        mean_all(ct,ce) = squeeze(mean(mean_var_all(ct,:,ce),2));
        std_all = std(mean_all(ct,ce), 0, 2);
        stats{ct,ce} = get_basic_stats(squeeze(mean_var_all(ct,:,ce)));

        bar_context = [bar_context; mean_all(ct,ce)];
        SEM = std(squeeze(mean_var_all(ct,:,ce)),'omitnan')/sqrt(length(mean_var_all(ct,:,ce)));
        SEM_cells = [SEM_cells; SEM];
        all_stats.stats(ct,ce) = get_basic_stats(squeeze(mean_var_all(ct,:,ce)));

    end
     hold on
        for c = 1:num_contexts %by context?
            b = bar([c],bar_context(c),'FaceColor',[1,1,1],'EdgeColor',plot_info.colors_celltype(ce,:),'LineWidth' , 1.);
            xtips = b.XEndPoints;
            ytips = b.YEndPoints;
            errorbar(xtips,ytips,SEM_cells(c),'color',plot_info.colors_celltype(ce,:),'LineWidth',1.);
    
        end 
        xticks([1:length(behavioral_contexts)])
        xticklabels([behavioral_contexts])
        xlim([0 length(behavioral_contexts)+1])


    [KW_Test.context_p_val,KW_Test.context_tbl, KW_Test.context_stats_cell] = kruskalwallis(squeeze(mean_var_all(:,:,ce))',[1:length(behavioral_contexts)],'off');
    possible_tests = nchoosek(1:length(behavioral_contexts),2);
        yl = ylim;  
        
        cct = 0;
            for t = 1:size(possible_tests,1)
                [p_stim(t,ce), observeddifference, effectsize_context] = permutationTest_updatedcb(mean_var_all(possible_tests(t,1),:,ce), mean_var_all(possible_tests(t,2),:,ce), 10000,'paired',1);
                if p_stim(t,ce) < 0.05/4 %&& KW_Test.context_p_val < 0.05/4
                    xline_vars(1) = possible_tests(t,1); 
                    xline_vars(2) = possible_tests(t,2); 
                    xval = 0;  
                    plot_pval_star(xval, (yl(2)-0.01)+cct, p_stim(t,ce), xline_vars,0.01)
                    cct = cct+yl(2)*.2;%0.05;

                end
            end
    
    
    % Customize the plot
    set(gca, 'XTickLabel', behavioral_contexts,'XTickLabelRotation',45);
    if ce == 1
    ylabel(string);
    end
    utils.set_current_fig;

    all_stats.KW{ce} = KW_Test;
    set(gca, 'FontSize', 7, 'Units', 'inches', 'Position', positions(ce, :));
end

all_stats.pval = p_stim;
all_stats.ptest = 'paired permutation';
all_stats.possible_tests =possible_tests;
% set(gcf,'units','points','position',[10,100,(500/3*length(behavioral_contexts)),200])
% set(gcf,'units','points','position',[10,100,(500/3*length(behavioral_contexts)*1.5),200*1.5])

cd(save_dir );
exportgraphics(gcf,strcat(['bar_' string '_contexts.pdf']), 'ContentType', 'vector');
saveas(gcf,strcat(['bar_' string '_contexts.fig']));
save(['all_stats_' string],'all_stats')
% % %%
% % figure(25);clf
% % indices = [1:16,25,17:24]; %mouse info has to match across conditions
% % all_celltypes_updated = all_celltypes;% {all_celltypes{1,indices}};
% % 
% % cell_nums = [cellfun(@(x) length(x.pyr_cells),all_celltypes_updated,'UniformOutput',false);cellfun(@(x) length(x.som_cells),all_celltypes_updated,'UniformOutput',false);cellfun(@(x) length(x.pv_cells),all_celltypes_updated,'UniformOutput',false)];
% % cell_nums_sum = sum(cell2mat(cell_nums),1);
% % 
% % all_frames =[]; for f = 1:25; all_frames = [all_frames, mouse{1,f}.frames];end;
% % 
% %  
% % nmf_ranks_needeed = cellfun(@(x) x.nmf, {mouse{1,:}}, 'UniformOutput', false);
% % 
% % hold on; 
% % for c = 1:3;
% %     cat_nmf = [nmf_ranks_needeed{1,:}];
% %     celid = c:3:length(cat_nmf)
% %     b(c) = plot(cat_nmf(celid), 'color',plot_info.colors_celltype(c,:),'LineWidth',1); 
% %     if c == 3
% % %         a = plot((cellfun(@length, sig_mod_boot_thr(indices))./cell_nums_sum)*100,'k','LineWidth',1); 
% % %         plot(cellfun(@length, sig_mod_boot_thr(indices)),'k','LineWidth',1,'LineStyle','--'); 
% % %         c = plot(all_frames./2000,'m','LineWidth',1);
% % %         c = plot(cell_nums_sum./10,'m','LineWidth',1);
% % %         c = plot(cell2mat(cellfun(@(x) length(x.pyr_cells),all_celltypes_updated,'UniformOutput',false))./10,'m','LineWidth',1);
% %         c = plot(cell2mat(cellfun(@(x) x.numcels{1,1},{mouse{1,:}},'UniformOutput',false))./10,'m','LineWidth',1);
% % 
% % %         legend([b(1), b(2), b(3), a,c], 'PYR','SOM','PV','Percent Stim Modulated','Num PYR cell/10', 'location','best')
% %         legend([b(1), b(2), b(3),c], 'PYR','SOM','PV','Num PYR cell/10', 'location','best')
% %     end
% %     xticks([1:25])
% %     xticklabels(info.mouse_date)
% %     ylabel('Rank needed for R2 > 70%')
% %     
% % end
% % 
% % 
% % pca_ranks_needeed = cellfun(@(x) x.pca_output.dims_needed, {mouse{1,:}}, 'UniformOutput', false);
% % figure(26);clf;
% % hold on; 
% % for c = 1:3;
% %     cat_pca = [pca_ranks_needeed{1,:}];
% %     celid = c:3:length(cat_pca)
% %     b(c) = plot(cat_pca(c,:), 'color',plot_info.colors_celltype(c,:),'LineWidth',1); 
% %     if c == 3
% % %         c = plot(cell2mat(cellfun(@(x) length(x.pyr_cells),all_celltypes_updated,'UniformOutput',false))./10,'m','LineWidth',1);
% %         c = plot(cell2mat(cellfun(@(x) x.numcels{1,1},{mouse{1,:}},'UniformOutput',false))./10,'m','LineWidth',1);
% % 
% % %         legend([b(1), b(2), b(3), a,c], 'PYR','SOM','PV','Percent Stim Modulated','Num PYR cell/10', 'location','best')
% %         legend([b(1), b(2), b(3),c], 'PYR','SOM','PV','Num PYR cell/10', 'location','best')
% %     end
% %     xticks([1:25])
% %     xticklabels(info.mouse_date)
% %     ylabel('PCs needed to have > 70%')
% %     
% % end
% % saveas(25,'nmf_rank_datasets_pyrcells.png')
% % saveas(26,'pca_dims_datasets_pyrcells.png')
% % 
% % 
% % %% make cumulative variance plots across celltypes and datasets 
% % figure(100)
% % clf
% % tiledlayout(5,5)
% % for m = 1:25
% %     nexttile
% %     hold on
% %     for ce = 1:3
% %     plot(mouse{1,m}.pca_output.cumvar{1,ce},'o','MarkerEdgeColor',plot_info.colors_celltype(ce,:))
% %     end
% %     title(info.mouse_date{1,m})
% %     hold off
% % end
% % saveas(100,'pca_cumvar_datasets.png')
% % 
% % figure(101)
% % clf
% % tiledlayout(5,5)
% % for m = 1:25
% %     nexttile
% %     hold on
% %     for ce = 1:3
% %     plot(mouse{1,m}.nmf_variance{1,ce}*100,'o','MarkerEdgeColor',plot_info.colors_celltype(ce,:))
% %     end
% %     title(info.mouse_date{1,m})
% %     hold off
% % end
% % saveas(101,'nmf_cumvar_datasets.png')
% % 
% % %% plot weights for nmf across datasets look at H
% % ct = 3;% choose cell type
% % figure(102);clf;
% % tiledlayout(5,5)
% % for m = 1:25
% %     nexttile
% %     hold on
% %     for ce = ct%:3
% %         [y_axis,inds] = max(mouse{1,m}.H{1,ce},[],1);
% %         [~,value] = sort(y_axis,'descend');
% %         imagesc(mouse{1,m}.H{1,ce}(:,value))
% %         xlim([1,size(mouse{1,m}.H{1,ce},2)])
% %         ylim([0.5,size(mouse{1,m}.H{1,ce},1)])
% %         caxis([0,.5])
% %     end
% %     title(info.mouse_date{1,m})
% %     
% %     hold off
% % end
% % 
% % figure(103);clf;
% % tiledlayout(5,5)
% % for m = 1:25
% %     nexttile
% %     hold on
% %     for ce = ct%:3
% %         [y_axis,inds] = max(mouse{1,m}.pca_output.vec{1,ce}(:,1:mouse{1,m}.pca_output.dims_needed(ce))',[],1);
% %         [~,value] = sort(y_axis,'descend');
% %         pca_array = mouse{1,m}.pca_output.vec{1,ce}(:,1:mouse{1,m}.pca_output.dims_needed(ce))';
% %         imagesc(pca_array(:,value))
% %         xlim([1,size(mouse{1,m}.pca_output.vec{1,ce}(:,1:mouse{1,m}.pca_output.dims_needed(ce))',2)])
% %         ylim([0.5,size(mouse{1,m}.pca_output.vec{1,ce}(:,1:mouse{1,m}.pca_output.dims_needed(ce))',1)])
% %         caxis([-.1,.1])
% %     end
% %     title(info.mouse_date{1,m})
% %     
% %     hold off
% % end
% % %% explore datasets in detail
% % explored_dataset = 11; framestolook = 35000:40000; dims = 1;
% % 
% % figure(); tiledlayout(2,1)
% % 
% % nexttile
% % %sort neurons
% % data1 = neural{1,explored_dataset};
% % [y_axis,inds] = max(data1(:,framestolook),[],2);
% % [~,value] = sort(inds,'ascend'); %sort(y_axis,'ascend');
% % 
% % % imagesc(neural{1,explored_dataset}(value,framestolook));caxis([0 0.1]);
% % imagesc(neural{1,explored_dataset}(:,framestolook));caxis([0 0.05]);
% % 
% % 
% % 
% % nexttile
% % hold on
% % plot(rescale(behav{1,explored_dataset}.behav_the_matrix(1,framestolook),0,5),'color',[0.5 0.5 0.5],'LineWidth',1); %y position
% % plot(rescale(behav{1,explored_dataset}.behav_the_matrix(13,framestolook),0,5),'color',[0.8 0.5 0],'LineWidth',1); %photostim
% % % plot(rescale(behav{1,explored_dataset}.behav_the_matrix(6,framestolook),0,5),'color',[0.4 0.7 1],'LineWidth',1); %reward
% % plot(rescale(behav{1,explored_dataset}.behav_big_matrix(130,framestolook),0,5),'color',[0 0.4 1],'LineWidth',1); %no reward- pure tone-ITI onset %131 ,123
% % plot(rescale(behav{1,explored_dataset}.behav_big_matrix(123,framestolook),0,5),'color',[0.4 0.1 0.9],'LineWidth',1); %reward - ITI onset %131 ,123
% % 
% % 
% % 
% % % plot(mouse{1,explored_dataset}.pca_output.pcs{1,1}(framestolook,dims),'-k');
% % plot(mouse{1,explored_dataset}.W{1,1}(framestolook),'color',[0.37 0.75 0.49],'LineWidth',1.5);
% % plot(mouse{1,explored_dataset}.W{1,2}(framestolook),'color',[0.17 0.35 0.8],'LineWidth',1.5);
% % plot(mouse{1,explored_dataset}.W{1,3}(framestolook),'color',[0.82 0.04 0.04],'LineWidth',1.5);
% % xlim([1,length(framestolook)])
% % hold off
% % 
% % % nexttile
% % % 
