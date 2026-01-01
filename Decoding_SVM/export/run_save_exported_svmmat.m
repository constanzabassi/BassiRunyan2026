savepath = "W:\Connie\results\Bassi2025\data\Active_decoding\";
event_names = {'sound_category','choice','outcome'};
do_passive = 0;
for event = 1:length(event_names)
    %full population plots
    wrapper_save_svmmat('full',event_names{event},do_passive,savepath,stim_ctrl_labels,info);
    wrapper_save_svmmat('nmatch',event_names{event},do_passive,savepath,stim_ctrl_labels,info);

end

% save stim ctrl
savepath = "W:\Connie\results\Bassi2025\data\Active_Passive_decoding\";
stim_ctrl_labels = {'Stim','No Stim'};
event_names = {'sound_category'};
do_passive = 1;
for event = 1:length(event_names)
    %nmatch population plots (comaparing active and passive)
    wrapper_save_svmmat('nmatch',event_names{event},do_passive,savepath,stim_ctrl_labels,info);

    %comparing stim vs control!
    wrapper_save_svmmat('stimctrl',event_names{event},do_passive,savepath,stim_ctrl_labels,info);

end