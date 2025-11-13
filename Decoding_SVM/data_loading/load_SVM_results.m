function loaded_svm_result = load_SVM_results(info,model_type,task_event_type,svm_result_to_load,varargin)
for n = 1:length(info.chosen_mice)
    mm = info.mouse_date(info.chosen_mice(n));
    mm = mm{1,1};
    mm
    ss = info.serverid(info.chosen_mice(n));
    ss = ss {1,1};
    if nargin > 4
        base = (strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/', model_type, '/decoding/SVM',varargin{1,1}, '/'));
    else
        base = (strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/', model_type, '/decoding/SVM/'));
    end
    filepath = ([base task_event_type '_' svm_result_to_load '.mat']);
    loaded_svm_result{n} = load(filepath).(svm_result_to_load);

end
% model_type = 'GLM_3nmf_passive';
% task_event_type = 'sound_category';
% model_type = 'GLM_3nmf_passive';
% missing_indices = [];
% for m = 1:length(info.mouse_date)
%     mm = info.mouse_date(m);
%     mm = mm{1,1};
%     ss = info.serverid(m);
%     ss = ss {1,1};
%     base = (strcat(num2str(ss),'/Connie/ProcessedData/',num2str(mm),'/', model_type, '/decoding/'));
%     filepath = ([base 'sound_category_svm_info.mat']);
%     if isfile(filepath)
%         load(filepath);
%     else
%         disp(['File missing for index: ' num2str(m)]);
%         missing_indices = [missing_indices; m-1]; % Record the index of the missing file
%     end
% end
% % Display all missing indices
% disp('Indices of datasets with missing files:');
% disp(missing_indices);
