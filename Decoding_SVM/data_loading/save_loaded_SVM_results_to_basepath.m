function save_loaded_SVM_results_to_basepath( ...
    loaded_svm_result, info, model_type, task_event_type, ...
    svm_result_name, new_base_dir, varargin)

% Optional:
%   'svm_subdir' : string appended after 'SVM' (e.g. '_shuffle')

p = inputParser;
addParameter(p, 'svm_subdir', '', @ischar);
parse(p, varargin{:});

svm_subdir = p.Results.svm_subdir;

for n = 1:length(info.chosen_mice)

    % Mouse/date
    mm = info.mouse_date(info.chosen_mice(n));
    mm = mm{1};

    % Build public path
    save_dir = fullfile( ...
        new_base_dir, mm, model_type, 'decoding', ['SVM' svm_subdir]);

    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    % Filename
    filename = sprintf('%s_%s.mat', task_event_type, svm_result_name);
    filepath = fullfile(save_dir, filename);

    % Variable name preserved for compatibility
%     eval([svm_result_name ' = loaded_svm_result{n};']);
%     save(filepath, svm_result_name, '-v7.3');

    svm_result = loaded_svm_result{n};
    save(filepath, 'svm_result', '-v7.3');


end
end
