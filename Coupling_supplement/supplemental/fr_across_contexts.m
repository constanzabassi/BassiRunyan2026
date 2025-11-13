function overall_fr = fr_across_contexts(info,save_string)
%save_string = 'GLM_3nmf_pre';
num_folds = 10; %normally 10
testing_datasets = [1:25];%[2,18,13]; %HA11 04/13 and HA2 06/27 -both are 69% correct, HA11 05/01 low red cells
%load('V:\Connie\results\glm\testing_nmf\mouse.mat'); %r2 defined ranks


overall_fr = [];
dataset_fr = [];
dataset_celltype = [];
for m = testing_datasets;
    mm = info.mouse_date(m);
    m
    mm = mm{1,1};
    ss = info.serverid(m);
    ss = ss {1,1};

    %create base2 folder where things will be save!
    base2 = strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/',save_string);

        %load the red cell IDs
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/pyr_cells.mat'));
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/tdtom_cells.mat')); %PV
    load(strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/red_variables/mcherry_cells.mat')); %SOM
    temp = [];
    for splits = 1:num_folds %normally ten
        dir_base = [base2 '/prepost trial cv 73 #' num2str(splits) '/'];
        cd([base2 '/prepost trial cv 73 #' num2str(splits) '/']);
        load('combined_response.mat');

        test = load(strcat(dir_base,'test/combined_response.mat'));
            
        %concatentate train and test
        combined_all = [combined_response,test.combined_response];

        mean_pv = nanmean(combined_all(tdtom_cells,:));
        mean_som = nanmean(combined_all(mcherry_cells,:));
        mean_pyr = nanmean(combined_all(pyr_cells,:));
        temp = [mean(mean_pyr),mean(mean_som), mean(mean_pv)];
        overall_fr(splits,m,:) = temp; %dataset_fr(m,:)
         
    end
    
end