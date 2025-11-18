function sig_cells = get_significant_neurons(sig_mod_boot,mod_index,mode)
%inputs: sig_mod_boot (datasets,contexts) cell ids of significantly
%modulated neurons

%goal: decide which contexts to use to define significant neurons

%if sound union of active and passive
if strcmp(mode,'union')
    [sig_cells, ~] = union_sig_cells(sig_mod_boot(:,1)', sig_mod_boot(:,2)', mod_index);
elseif strcmp(mode,'spont')
    sig_cells = sig_mod_boot(:,3)'; %from spontaneous context
else
    sig_cells = sig_mod_boot;
end
