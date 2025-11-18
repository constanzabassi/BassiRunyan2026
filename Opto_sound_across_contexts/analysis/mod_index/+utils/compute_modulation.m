function mod_index = compute_modulation(stim_avg, ctrl_avg, mod_type)
switch mod_type
    case 'ctrl'
        mod_index = compute_mod_index_ctrl(stim_avg, ctrl_avg);
    case 'influence'
        mod_index = compute_mod_index_influence(stim_avg, ctrl_avg);
    case {'prepost', 'prepost_sound'}
        mod_index = compute_mod_index_prepost(stim_avg, ctrl_avg);
    otherwise
        error('Invalid mod_type. Choose from ''ctrl'', ''influence'', ''prepost'', or ''prepost_sound''.');
end
end