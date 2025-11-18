function [stim_mod,chosen_pyr,chosen_mcherry,chosen_tdtom,celltypes_ids]= compute_mod_index_ctrl_contexts_celltypes(chosen_mice,range,rangeb,dff_st,sig_mod_boot,all_celltypes,stim_trials_context,ctrl_trials_context);
num_bins = size(stim_trials_context{1,1},2); %three contexts

%balance sound across opto and control trials
[sound_trials_stim,sound_trials_ctrl,left_stim,left_ctrl,right_stim,right_ctrl,left_stim_all,left_ctrl_all,right_stim_all,right_ctrl_all] = find_sound_trials(stim_trials_context,ctrl_trials_context);

mouse_stimmod ={};mouse_stimcat={}; chosen_pyr=[]; chosen_mcherry=[]; chosen_tdtom=[];
% excluded_mice = find(~ismember( 1:length(dff_st), chosen_mice));
h_thres = 0.1; l_thres = -0.1;

num_sig_cells =[]; previous_m = [];celltypes_ids ={};
for m = chosen_mice
    if ~isempty(sig_mod_boot)
        num_sig_cells = [num_sig_cells, length(sig_mod_boot{1,m})];%(all_mice{1,m}.allcells)];
    else
        num_sig_cells = [num_sig_cells, size(dff_st{1,m}.stim,2)];%(all_mice{1,m}.allcells)];
    end
end
for m = chosen_mice
    m
    cellCount = size(dff_st{1,m}.stim,2);
    if ~isempty(sig_mod_boot)
        mod_cells = sig_mod_boot{1,m}; %
    else
        mod_cells = 1:cellCount;
    end

    c_mod_stim = []; c_mod_ctrl = []; c_sel_mod = []; context_cat=[];
    stim_matrix = dff_st{1,m}.stim;
    ctrl_matrix = dff_st{1,m}.ctrl;

    
    for context = 1:num_bins
        %spont trials only?
        stim_trials = [left_stim{1,m}{1,context},right_stim{1,m}{1,context}];%stim_trials_context{1,m}{1,context}; %stim_trials_context{1,m}{1,context}; to use all trials regardless of sound
        ctrl_trials = [left_ctrl{1,m}{1,context},right_ctrl{1,m}{1,context}];%ctrl_trials_context{1,m}{1,context};
    
        response_tr = dff_st{1, m}.stim(stim_trials,mod_cells,:); % Stimulus responses
        response_tr_ctrl =dff_st{1, m}.ctrl(ctrl_trials,mod_cells,:); % Control responses
        % Compute mean responses
        mean_response = squeeze(mean(response_tr, 1)); % Mean across trials
        mean_response_ctrl = squeeze(mean(response_tr_ctrl, 1));

        %calculate mod index
%         mod_index = calc_mean_mod_ctrl(mean_response,mean_response_ctrl,range);
        [mod_index,~] = calc_influence_mod(dff_st{1, m}.stim(:,mod_cells,:), dff_st{1, m}.ctrl(:,mod_cells,:),left_stim{1,m}{1,context}, left_ctrl{1,m}{1,context}, right_stim{1,m}{1,context}, right_ctrl{1,m}{1,context}, range, 'separate');
        
        c_mod_stim(:,context) = mod_index;
    end
    
    mouse_stimmod{m} = c_mod_stim;

    if ~isempty(sig_mod_boot)
        if m==1
            chosen_pyr = [chosen_pyr, find(ismember(sig_mod_boot{1,m},all_celltypes{1,m}.pyr_cells))] ;
            chosen_mcherry = [chosen_mcherry, find(ismember(sig_mod_boot{1,m},all_celltypes{1,m}.som_cells))] ;
            chosen_tdtom = [chosen_tdtom, find(ismember(sig_mod_boot{1,m},all_celltypes{1,m}.pv_cells))] ;
        else
            temp =sum( num_sig_cells(previous_m));
            chosen_pyr = [chosen_pyr, find(ismember(sig_mod_boot{1,m},all_celltypes{1,m}.pyr_cells))+temp] ;
            chosen_mcherry = [chosen_mcherry, find(ismember(sig_mod_boot{1,m},all_celltypes{1,m}.som_cells))+temp] ;
            chosen_tdtom = [chosen_tdtom, find(ismember(sig_mod_boot{1,m},all_celltypes{1,m}.pv_cells))+temp] ;
        end
    else
        if m==1
            chosen_pyr = [chosen_pyr, all_celltypes{1,m}.pyr_cells'] ;
            chosen_mcherry = [chosen_mcherry, all_celltypes{1,m}.som_cells'] ;
            chosen_tdtom = [chosen_tdtom, all_celltypes{1,m}.pv_cells'] ;
        else
            temp =sum( num_sig_cells(previous_m));
            chosen_pyr = [chosen_pyr, all_celltypes{1,m}.pyr_cells'+temp] ;
            chosen_mcherry = [chosen_mcherry, all_celltypes{1,m}.som_cells'+temp] ;
            chosen_tdtom = [chosen_tdtom, all_celltypes{1,m}.pv_cells'+temp] ;
        end
    end

    previous_m = [previous_m,m];
    
end
celltypes_ids{1} = chosen_pyr;
celltypes_ids{2} = chosen_mcherry;
celltypes_ids{3} = chosen_tdtom;

stim_mod = cat(1,mouse_stimmod{1,:});

% ctrl_mod = cat(1,mouse_ctrlmod{1,:});
% sel_mod = cat(1,mouse_sel{1,:});
