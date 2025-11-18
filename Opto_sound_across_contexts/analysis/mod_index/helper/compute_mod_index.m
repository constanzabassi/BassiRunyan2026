function mod_index = compute_mod_index(avg1, avg2, mod_type)
%depending on mode computes modulatio index
    switch mod_type
        case 'ctrl'
            mod_index = compute_mod_index_ctrl(avg1, avg2);
        case 'pre_engagement'
            mod_index = compute_mod_index_ctrl(avg1, avg2); %stim is active, control is passive
        case 'ctrl_num'
            mod_index = compute_mod_index_ctrl_numerator(avg1, avg2);
        case 'pre_engagement_num'
            mod_index = compute_mod_index_ctrl_numerator(avg1, avg2);
        case 'prepost_ctrl'
            mod_index = compute_mod_index_ctrl(avg1, avg2);
        case 'prepost_ctrl_abs'
            mod_index = compute_mod_index_ctrl_abs(avg1, avg2);
        case 'influence'
            mod_index = compute_mod_index_influence(avg1, avg2);
        case 'prepost'
            mod_index = compute_mod_index_prepost(avg1, avg2); %post,pre
        case 'prepost_sound'
            mod_index = compute_mod_index_prepost(avg1, avg2); %post,pre 
        case 'prepost_num'
            mod_index = compute_mod_index_prepost_numerator(avg1, avg2); %post,pre
        case 'prepost_sound_num'
            mod_index = compute_mod_index_prepost_numerator(avg1, avg2); %post,pre
        case 'prepost_abs'
            mod_index = compute_mod_index_prepost_abs(avg1, avg2); %post,pre 
        case 'ctrl_abs'
            mod_index = compute_mod_index_ctrl_abs(avg1, avg2);
        case 'signed_ctrl'
            mod_index = compute_signed_mod_index(avg1, avg2);
        otherwise
            error('Invalid mod_type. Choose from ''ctrl'', ''influence'', or ''prepost''');
    end
end