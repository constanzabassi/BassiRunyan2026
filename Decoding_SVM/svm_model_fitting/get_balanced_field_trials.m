function [selected_trials,lc_selected,rc_selected,smallest_set_size,lc,li,rc,ri] = get_balanced_field_trials(imaging,selected_field_num,varargin)
lc_selected =[]; rc_selected = []; lc=[];li=[];rc=[];ri=[];
fieldss = fieldnames(imaging(1).virmen_trial_info);
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!


selected_trials = false(1, length(good_trials));
virmen_trial_info = [imaging(good_trials).virmen_trial_info];

if length(selected_field_num)==1
    condition = [virmen_trial_info.(fieldss{selected_field_num})];
    
    unique_cond = unique(condition);
    for c = 1:length(unique_cond)
        conds{c} = find(condition == unique_cond(c));
    end
    
    
    % make sure that each of these groups is equally represented in
    % the training trials, to ensure that stimulus category and
    % behavioural choice are uncorrelated.
    if nargin > 2
        smallest_set_size = varargin{1,1};
        lc_selected = randsample(conds{1}, smallest_set_size);
        rc_selected = randsample(conds{2}, smallest_set_size);
        selected_trials(lc_selected) = true;
        selected_trials(rc_selected) = true;
    else
        smallest_set_size = min(cellfun(@length ,conds));
        lc_selected = randsample(conds{1}, smallest_set_size);
        rc_selected = randsample(conds{2}, smallest_set_size);
        selected_trials(lc_selected) = true;
        selected_trials(rc_selected) = true;
    end
    smallest_set_size
elseif length(selected_field_num)==2
    if strcmp(fieldss{selected_field_num(1)},'condition')
        condition = rem([virmen_trial_info.(fieldss{selected_field_num(1)})],2);
        condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
    elseif strcmp(fieldss{selected_field_num(2)},'condition')
        condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
        condition2 = rem([virmen_trial_info.(fieldss{selected_field_num(2)})],2);
    else
        condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
        condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
    end
    
    lc = condition & condition2;% [1,1]
    li = condition & ~condition2;% [1,0]
    rc = ~condition & condition2;% [0,1]
    ri = ~condition & ~condition2;% [0,0]
    
    % make sure that each of these groups is equally represented in
    % the training trials, to ensure that stimulus category and
    % behavioural choice are uncorrelated.
    if nargin > 2
        smallest_set_size = varargin{1,1};
        condition_combo = {lc, li, rc, ri};
        condition_selected = [];
        for i = 1:length(condition_combo)
            condition_selected = [condition_selected, randsample(find(condition_combo{i}), smallest_set_size)];
        end
    else
        smallest_set_size = min([nnz(lc), nnz(li), nnz(rc), nnz(ri)]);
        
        condition_combo = {lc, li, rc, ri};
        condition_selected = [];
        for i = 1:length(condition_combo)
            condition_selected = [condition_selected, randsample(find(condition_combo{i}), smallest_set_size)];
        end
    end
    smallest_set_size
    selected_trials(condition_selected) = true;

elseif length(selected_field_num)==3
     if strcmp(fieldss{selected_field_num(1)},'condition')
        condition = rem([virmen_trial_info.(fieldss{selected_field_num(1)})],2);
        condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
        condition3 = [virmen_trial_info.(fieldss{selected_field_num(3)})];
    elseif strcmp(fieldss{selected_field_num(2)},'condition')
        condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
        condition2 = rem([virmen_trial_info.(fieldss{selected_field_num(2)})],2);
        condition3 = [virmen_trial_info.(fieldss{selected_field_num(3)})];
     elseif strcmp(fieldss{selected_field_num(3)},'condition')
        condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
        condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
        condition3 = rem([virmen_trial_info.(fieldss{selected_field_num(3)})],2);

    else
        condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
        condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
        condition3 = [virmen_trial_info.(fieldss{selected_field_num(3)})];
    end
    
    lc = condition & condition2 & condition3;% [1,1,1]
    li = condition & ~condition2 & condition3;% [1,0,1]
    rc = ~condition & condition2 & condition3;% [0,1,1]
    ri = ~condition & ~condition2 & condition3;% [0,0,1]

    lcs = condition & condition2 & ~condition3;% [1,1,0]
    lis = condition & ~condition2 & ~condition3;% [1,0,0]
    rcs = ~condition & condition2 & ~condition3;% [0,1,0]
    ris = ~condition & ~condition2 & ~condition3;% [0,0,0]
    
    % make sure that each of these groups is equally represented in
    % the training trials, to ensure that stimulus category and
    % behavioural choice are uncorrelated.
    if nargin > 2 %if half of them are zero I am assuming there is another dataset that has more trials so the smallest set needs to be multiplied by 2
        smallest_set_size = varargin{1,1};
        nonzero_array = [nnz(lc), nnz(li), nnz(rc), nnz(ri),nnz(lcs), nnz(lis), nnz(rcs), nnz(ris)];
        nonzero_ind = find(nonzero_array);
        if length(nonzero_ind) == 4
            smallest_set_size = smallest_set_size*2;
        end
        condition_combo = {lc, li, rc, ri, lcs, lis, rcs, ris};
        condition_selected = [];
        for i = nonzero_ind
            condition_selected = [condition_selected, randsample(find(condition_combo{i}), smallest_set_size)];
        end
    else
        if length(find([nnz(lc), nnz(li), nnz(rc), nnz(ri),nnz(lcs), nnz(lis), nnz(rcs), nnz(ris)])) == 8 %there are non zero trials for each condition
            smallest_set_size = min([nnz(lc), nnz(li), nnz(rc), nnz(ri),nnz(lcs), nnz(lis), nnz(rcs), nnz(ris)]); 

            condition_combo = {lc, li, rc, ri, lcs, lis, rcs, ris};
            condition_selected = [];
            for i = 1:length(condition_combo)
                condition_selected = [condition_selected, randsample(find(condition_combo{i}), smallest_set_size)];
            end
        else
            nonzero_array = [nnz(lc), nnz(li), nnz(rc), nnz(ri),nnz(lcs), nnz(lis), nnz(rcs), nnz(ris)];
            nonzero_ind = find(nonzero_array);
            smallest_set_size = min([nonzero_array(nonzero_ind)]); 
            condition_combo = {lc, li, rc, ri, lcs, lis, rcs, ris};
            condition_selected = [];
            for i = nonzero_ind
                condition_selected = [condition_selected, randsample(find(condition_combo{i}), smallest_set_size)];
            end
        end
    
    end

    smallest_set_size
    selected_trials(condition_selected) = true;

end

end
% % fieldss = fieldnames(imaging(1).virmen_trial_info);
% % empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
% % good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
% % 
% % 
% % selected_trials = false(1, length(good_trials));
% % virmen_trial_info = [imaging(good_trials).virmen_trial_info];
% % 
% % if length(selected_field_num)==1
% %     condition = [virmen_trial_info.(fieldss{selected_field_num})];
% %     
% %     unique_cond = unique(condition);
% %     for c = 1:length(unique_cond)
% %         conds{c} = find(condition == unique_cond(c));
% %     end
% %     
% %     
% %     % make sure that each of these groups is equally represented in
% %     % the training trials, to ensure that stimulus category and
% %     % behavioural choice are uncorrelated.
% %     if nargin > 2
% %     smallest_set_size = varargin{1,1};
% %     lc_selected = randsample(conds{1}, smallest_set_size);
% %     rc_selected = randsample(conds{2}, smallest_set_size);
% %     selected_trials(lc_selected) = true;
% %     selected_trials(rc_selected) = true;
% %     else
% %     smallest_set_size = min(cellfun(@length ,conds));
% %     lc_selected = randsample(conds{1}, smallest_set_size);
% %     rc_selected = randsample(conds{2}, smallest_set_size);
% %     selected_trials(lc_selected) = true;
% %     selected_trials(rc_selected) = true;
% %     end
% %     smallest_set_size
% % elseif length(selected_field_num)==2
% %     if strcmp(fieldss{selected_field_num(1)},'condition')
% %         condition = rem([virmen_trial_info.(fieldss{selected_field_num(1)})],2);
% %         condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
% %     elseif strcmp(fieldss{selected_field_num(2)},'condition')
% %         condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
% %         condition2 = rem([virmen_trial_info.(fieldss{selected_field_num(2)})],2);
% %     else
% %         condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
% %         condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
% %     end
% %     
% %     lc = condition & condition2;% [1,1]
% %     li = condition & ~condition2;% [1,0]
% %     rc = ~condition & condition2;% [0,1]
% %     ri = ~condition & ~condition2;% [0,0]
% %     
% %     % make sure that each of these groups is equally represented in
% %     % the training trials, to ensure that stimulus category and
% %     % behavioural choice are uncorrelated.
% %     if nargin > 2
% %     smallest_set_size = varargin{1,1};
% %     lc_selected = randsample(find(lc), smallest_set_size);
% %     li_selected = randsample(find(li), smallest_set_size);
% %     rc_selected = randsample(find(rc), smallest_set_size);
% %     ri_selected = randsample(find(ri), smallest_set_size);
% %     else
% %     smallest_set_size = min([nnz(lc), nnz(li), nnz(rc), nnz(ri)]);
% %     
% %     lc_selected = randsample(find(lc), smallest_set_size);
% %     li_selected = randsample(find(li), smallest_set_size);
% %     rc_selected = randsample(find(rc), smallest_set_size);
% %     ri_selected = randsample(find(ri), smallest_set_size);
% %     end
% %     smallest_set_size
% %     selected_trials(lc_selected) = true;
% %     selected_trials(li_selected) = true;
% %     selected_trials(rc_selected) = true;
% %     selected_trials(ri_selected) = true;
% % else length(selected_field_num)==3
% %      if strcmp(fieldss{selected_field_num(1)},'condition')
% %         condition = rem([virmen_trial_info.(fieldss{selected_field_num(1)})],2);
% %         condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
% %         condition3 = [virmen_trial_info.(fieldss{selected_field_num(3)})];
% %     elseif strcmp(fieldss{selected_field_num(2)},'condition')
% %         condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
% %         condition2 = rem([virmen_trial_info.(fieldss{selected_field_num(2)})],2);
% %         condition3 = [virmen_trial_info.(fieldss{selected_field_num(3)})];
% %      elseif strcmp(fieldss{selected_field_num(3)},'condition')
% %         condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
% %         condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
% %         condition3 = rem([virmen_trial_info.(fieldss{selected_field_num(3)})],2);
% % 
% %     else
% %         condition = [virmen_trial_info.(fieldss{selected_field_num(1)})];
% %         condition2 = [virmen_trial_info.(fieldss{selected_field_num(2)})];
% %         condition3 = [virmen_trial_info.(fieldss{selected_field_num(3)})];
% %     end
% %     
% %     lc = condition & condition2 & condition3;% [1,1,1]
% %     li = condition & ~condition2 & condition3;% [1,0,1]
% %     rc = ~condition & condition2 & condition3;% [0,1,1]
% %     ri = ~condition & ~condition2 & condition3;% [0,0,1]
% % 
% %     lcs = condition & condition2 & ~condition3;% [1,1,0]
% %     lis = condition & ~condition2 & ~condition3;% [1,0,0]
% %     rcs = ~condition & condition2 & ~condition3;% [0,1,0]
% %     ris = ~condition & ~condition2 & ~condition3;% [0,0,0]
% %     
% %     % make sure that each of these groups is equally represented in
% %     % the training trials, to ensure that stimulus category and
% %     % behavioural choice are uncorrelated.
% %     if nargin > 2
% %     smallest_set_size = varargin{1,1};
% %     lc_selected = randsample(find(lc), smallest_set_size);
% %     li_selected = randsample(find(li), smallest_set_size);
% %     rc_selected = randsample(find(rc), smallest_set_size);
% %     ri_selected = randsample(find(ri), smallest_set_size);
% % 
% %     lcs_selected = randsample(find(lcs), smallest_set_size);
% %     lis_selected = randsample(find(lis), smallest_set_size);
% %     rcs_selected = randsample(find(rcs), smallest_set_size);
% %     ris_selected = randsample(find(ris), smallest_set_size);
% %     else
% %         if length(find([nnz(lc), nnz(li), nnz(rc), nnz(ri),nnz(lcs), nnz(lis), nnz(rcs), nnz(ris)])) > 8 %there are non zero trials for each condition
% %             smallest_set_size = min([nnz(lc), nnz(li), nnz(rc), nnz(ri),nnz(lcs), nnz(lis), nnz(rcs), nnz(ris)]); 
% % 
% %             lc_selected = randsample(find(lc), smallest_set_size);
% %             li_selected = randsample(find(li), smallest_set_size);
% %             rc_selected = randsample(find(rc), smallest_set_size);
% %             ri_selected = randsample(find(ri), smallest_set_size);
% %         
% %             lcs_selected = randsample(find(lcs), smallest_set_size);
% %             lis_selected = randsample(find(lis), smallest_set_size);
% %             rcs_selected = randsample(find(rcs), smallest_set_size);
% %             ris_selected = randsample(find(ris), smallest_set_size);
% %         else
% %             nonzero_array = [nnz(lc), nnz(li), nnz(rc), nnz(ri),nnz(lcs), nnz(lis), nnz(rcs), nnz(ris)];
% %             nonzero_ind = find(nonzero_array);
% %             smallest_set_size = min([nonzero_array(nonzero_ind)]); 
% %             condition_combo = {lc, li, rc, ri, lcs, lis, rcs, ris};
% %             condition_selected = [];
% %             for i = nonzero_ind
% %                 condition_selected = [condition_selected, randsample(find(condition_combo{i}), smallest_set_size)];
% %             end
% %         end
% %     
% %     end
% % 
% %     smallest_set_size
% %     selected_trials(lc_selected) = true;
% %     selected_trials(li_selected) = true;
% %     selected_trials(rc_selected) = true;
% %     selected_trials(ri_selected) = true;
% % 
% %     if length(selected_field_num)==3
% %         selected_trials(lcs_selected) = true;
% %         selected_trials(lis_selected) = true;
% %         selected_trials(rcs_selected) = true;
% %         selected_trials(ris_selected) = true;
% %     end
% % 
% % end
% % 
% % end