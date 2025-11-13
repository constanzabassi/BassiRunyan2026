addpath(genpath('C:\Code\Github\BassiRunyan2025'));
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

cd('W:\Connie\results\Bassi2025\glm_coupling\glm_coupling\supplemental');
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
temp = load('W:\Connie\results\Bassi2025\glm_coupling\glm_coupling\supplemental\mean_nmf_var_GLM_3nmf_pre.mat');
temp2 = load('W:\Connie\results\Bassi2025\glm_coupling\glm_coupling\supplemental\mean_nmf_var_GLM_3nmf_passive.mat');
mean_var_all(1,:,:) = temp.mean_var; %context 1 is active
mean_var_all(2,:,:) = temp2.mean_var; %context 1 is passive
num_contexts = 2;
behavioral_contexts = {'Active','Passive'};
%%
addpath(genpath('C:\Code\Github\BassiRunyan2025'));
figure(999);clf;
t = tiledlayout(1,3);%,'TileSpacing','Compact','Padding','Compact' %need enough space to plot by celltypes not context!
string = 'Var. Explained';

for ce = 1:3
    nexttile
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
            b = bar([c],bar_context(c),'FaceColor',[1,1,1],'EdgeColor',plot_info.colors_celltype(ce,:),'LineWidth' , 1);
            xtips = b.XEndPoints;
            ytips = b.YEndPoints;
            errorbar(xtips,ytips,SEM_cells(c),'color',plot_info.colors_celltype(ce,:),'LineWidth',1);
    
        end 
        xticks([1:length(behavioral_contexts)])
        xticklabels([behavioral_contexts])
        xlim([0 length(behavioral_contexts)+1])


%     [KW_Test.context_p_val,KW_Test.context_tbl, KW_Test.context_stats_cell] = kruskalwallis(squeeze(mean_var_all(:,:,ce))',[1:length(behavioral_contexts)],'off');
    possible_tests = nchoosek(1:length(behavioral_contexts),2);
        yl = ylim;  
        
        cct = 0;
            for t = 1:size(possible_tests,1)
                [p_stim(t,ce), observeddifference, effectsize_context] = permutationTest_updatedcb(mean_var_all(possible_tests(t,1),:,ce), mean_var_all(possible_tests(t,2),:,ce), 10000,'paired',1);
                if p_stim(t,ce) < 0.05/4 %&& KW_Test.context_p_val < 0.05/4
                    xline_vars(1) = possible_tests(t,1); 
                    xline_vars(2) = possible_tests(t,2); 
                    xval = 0;  
                    utils.plot_pval_star(xval, (yl(2)-0.01)+cct, p_stim(t,ce), xline_vars,0.01)
                    cct = cct+yl(2)*.2;%0.05;

                end
            end
    
    
    % Customize the plot
    set(gca, 'XTickLabel', behavioral_contexts);
    if ce == 1
        ylabel(string);
    end
    utils.set_current_fig;

%     all_stats.KW{ce} = KW_Test;
end

all_stats.pval = p_stim;
all_stats.ptest = 'paired permutation';
all_stats.possible_tests =possible_tests;
% set(gcf,'units','points','position',[10,100,(500/3*length(behavioral_contexts)),200])
set(gcf,'units','points','position',[10,10,220,220])
set(gca,'FontSize',8)


exportgraphics(gcf,strcat(['bar_' string '_contexts.pdf']), 'ContentType', 'vector');
saveas(gcf,strcat(['bar_' string '_contexts.fig']));
save(['all_stats_' string],'all_stats')
