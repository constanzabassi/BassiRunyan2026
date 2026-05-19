function [passive_data, active_data] = load_sound_data(path)
%sound context data includes trial indices for control, opto, and sound
%only trials relative to bad_frames

    % Load passive context data
    passive_data = load_sound_context_data('passive',path);
    
    % Load active context data
    active_data = load_sound_context_data('active',path);
end
