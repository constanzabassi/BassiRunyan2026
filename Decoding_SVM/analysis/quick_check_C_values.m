%load all the values
current_mice = setdiff(1:25,[3,8,9,21,22,23]); %outcome


info.chosen_mice = current_mice;
info.task_event_type = 'outcome'; %'sound_category';

acc_active = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'acc','_1');
[svm_mat, ~] = get_SVM_across_datasets(info,acc_active,acc_active,plot_info,[]);
acc_active01 = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'acc','_01');
[svm_mat01, ~] = get_SVM_across_datasets(info,acc_active01,acc_active,plot_info,[]);
acc_active05 = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'acc','_05');
[svm_mat05, ~] = get_SVM_across_datasets(info,acc_active05,acc_active,plot_info,[]);
acc_active001 = load_SVM_results(info,'GLM_3nmf_pre',info.task_event_type,'acc','_001');
[svm_mat001, ~] = get_SVM_across_datasets(info,acc_active001,acc_active,plot_info,[]);


for ce = 4
    mean_across_data = cellfun(@(x) mean(x.accuracy(:,1:bins_to_include),1),{svm_mat{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean = mean(mean_across_data,1);

    mean_across_data = cellfun(@(x) mean(x.accuracy(:,1:bins_to_include),1),{svm_mat001{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean001= mean(mean_across_data,1);

    mean_across_data = cellfun(@(x) mean(x.accuracy(:,1:bins_to_include),1),{svm_mat01{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean01 = mean(mean_across_data,1);

    mean_across_data = cellfun(@(x) mean(x.accuracy(:,1:bins_to_include),1),{svm_mat05{:,ce}},'UniformOutput',false);
    mean_across_data = vertcat(mean_across_data{1,:});
    overall_mean05 = mean(mean_across_data,1);
end



C_values = [1, 0.5, 0.1, 0.01];
accuracy_per_C = [mean(overall_mean(55)), mean(overall_mean05(55)), mean(overall_mean01(55)), mean(overall_mean001(55))];  % Fill in your actual values

% Plotting
figure;
plot(log10(C_values), accuracy_per_C, '-o', 'LineWidth', 2);
xlabel('log_{10}(C)');
ylabel('Decoding Accuracy');
title('Elbow Plot for SVM Regularization Parameter C');
grid on;

% Optional: show C value on each point
for i = 1:length(C_values)
    text(log10(C_values(i)), accuracy_per_C(i), sprintf('C=%.3f', C_values(i)), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
