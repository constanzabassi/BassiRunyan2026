%% compare cellypes during active context
event_names = {'sound_category','choice','outcome'};
do_passive = 0;
for event = 2:length(event_names)
    %full population plots
    
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\full_population\' event_names{event} '\']; 
    plot_final_svm_traces_boxplots('full',event_names{event},do_passive,savepath);
    
    %nmatch population plots
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\' event_names{event} '\']; %['V:\Connie\results\SVM_1_wtop\active_passive\' info.task_event_type '\'];%['V:\Connie\results\SVM_1\' info.task_event_type '\'];
    plot_final_svm_traces_boxplots('nmatch',event_names{event},do_passive,savepath);

end

%% compare active/passive stim/ctrl

% 'W:\Connie\results\Bassi2025\fig2\SVM_1\opto_ctrl'
event_names = {'sound_category'};
do_passive = 1;
for event = 1:length(event_names)
    %nmatch population plots (comaparing active and passive)
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\' event_names{event} '\'];
    plot_final_svm_traces_boxplots('nmatch',event_names{event},do_passive,savepath); %plots the All population
    
    %comparing stim vs control!
    savepath = ['W:\Connie\results\Bassi2025\fig2\SVM_1\opto_ctrl'];
    plot_final_svm_traces_boxplots('stimctrl',event_names{event},do_passive,savepath); %plots the All population
end
%% get ns used (min celltype)
% load('V:\Connie\results\opto_sound_2025\context\data_info\all_celltypes.mat')

load('V:\Connie\results\opto_2024\context\data_info\info.mat');
event_names = {'sound_category','choice','outcome'};
min_n_nmatch_svm = {};
for event = 1:length(event_names)
    info.task_event_type = event_names{event};
    %code below to find these numbers although should be the same each time!
    [current_mice,onset_id, active_events, passive_events] = default_data_info(info.task_event_type);
    info.chosen_mice = current_mice;
    %get model outputs
    all_model_outputs = load_SVM_results(info, 'GLM_3nmf_pre', info.task_event_type, 'all_model_outputs', '_1');
    min_n_nmatch_svm.(event_names{event}) = utils.get_basic_stats(cellfun(@(x) length(x{1}.mdl_cells), all_model_outputs));
end

%save into a table
table_min_n_nmatch_svm = struct2table_recursive(unwrap_cells_in_struct(min_n_nmatch_svm),'',{'bootstat'});
save(fullfile('W:\Connie\results\Bassi2025\fig2\SVM_1\', strcat('table_min_n_nmatch_svm.mat')), 'table_min_n_nmatch_svm');
writetable(table_min_n_nmatch_svm, fullfile('W:\Connie\results\Bassi2025\fig2\SVM_1\', strcat('table_min_n_nmatch_svm.csv')));
