min_balanced = {};
for active_passive = 1:2
    alignment.active_passive = active_passive;
    for opto_trials = 1:2
        for m = 1:length(info.mouse_date)
                m
                % load imaging data!
                if alignment.active_passive == 1
                    base_imaging = strcat(num2str(info.serverid{1,m}), '\Connie/ProcessedData/',num2str(info.mouse_date{1,m}),'/VR/');
                else
                    base_imaging = strcat(num2str(info.serverid{1,m}), '\Connie/ProcessedData/',num2str(info.mouse_date{1,m}),'/passive/');
                end
                load(strcat(base_imaging,'/imaging.mat'));
    
                %eliminate long trials
                imaging_st{1,1} = imaging;
                [imaging_st,~] = eliminate_trials(imaging_st,7,800);
                imaging = imaging_st{1,1};
    
        
                    ex_imaging = imaging;%%imaging_st{1,m};
    
                    % divide trials into opto or not BEFORE balancing! 
                    selected_trials = get_specified_field_trials (m,active_passive,ex_imaging,[opto_trials-1]); %4th field is opto!
                    ex_imaging = ex_imaging(selected_trials);
                if alignment.active_passive == 1
                    [selected_trials_balanced,~,~] = get_balanced_field_trials(ex_imaging,[2,3]);
                else
                    [selected_trials_balanced,~,~] = get_balanced_field_trials(ex_imaging,[3]);
                end
                    min_balanced{active_passive,opto_trials,m} = length(find(selected_trials_balanced));
    
        end
    end
end

%% GET SMALLEST SET SIZE WHICH WOULD HAVE TO COME FROM ACTIVE TRIALS
active_trials = squeeze(cell2mat(min_balanced(1,:,:)));
smallest_set_size =  min(active_trials)/4;


dataset_with_enough_trials = find(smallest_set_size >= 4);
save('dataset_with_enough_trials','dataset_with_enough_trials');
save('smallest_set_size','smallest_set_size');
% NOTE DATASET 20 IS NOT 11 SHOULD BE 8!/2 should be 7 (ONLY ONE FROM PASSIVE)
