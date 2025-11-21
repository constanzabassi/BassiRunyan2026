function plot_example_opto_task_trial(sync_dir,opto_color,timepoints,save_dir, addscale, addlegend,spont,chan)
[files,sync_rate] = abfload(sync_dir); %'V:\Connie\RawData\HA10-1L\wavesurfer\2023-04-10\01_VR_2locs_wstim_0000.abf'
figure(722);clf
hold on;
if spont == 1
    plot(rescale(files(timepoints,5),-0.058,1),'color',opto_color,'LineWidth', 1.5);
    if addlegend
        legend('Photostim', 'Box', 'off','Location','southeast')
    end
else
    plot(rescale(files(timepoints,chan),-1,1),'-k','LineWidth', 1.2);
    plot(rescale(files(timepoints,5),-0.058,1),'color',opto_color,'LineWidth', 1.5);
    if addlegend
        legend('Sounds','Photostim', 'Box', 'off','Location','southeast')
    end
end


aa = gca;
if addscale 
    xlims = xlim;
    addScaleBar(aa, 1/sync_rate*1e6, '1 s', [], [],'XOffsetFrac', -0.43,'LabelOffsetFrac', .025,'XEndData',[xlims(2)*5/6]);
end
% set box property to off and remove background color
set(aa,'box','off','color','none','xtick',[],'ytick',[]);
aa.YAxis.Visible = 'off';
aa.XAxis.Visible = 'off';



if ~isempty(save_dir)
    % full folder path
p = sync_dir;
% --- 1) Normalize file separators
p = strrep(p, '/', filesep);
% --- 2) Split into parts
parts = strsplit(p, filesep);
% Expected structure:
% {'V:' 'Connie' 'RawData' 'HA10-1L' 'wavesurfer' '2023-04-10' ''}
mouse = parts{4};        % 'HA10-1L'
date_str = parts{6};     % '2023-04-10'
% --- 3) Make lowercase mouse name without the "-1L" if needed
mouse_base = lower( regexp(mouse, '^[A-Za-z0-9]+', 'match','once') );
% mouse_base = 'ha10'
% --- 4) Build final filename
save_name = sprintf('example_sound_opto_trace-%s-%s', mouse_base, date_str);

mkdir(save_dir)
% saveas(722,'example_sound_opto_trace-ha10-2023-04-10.svg');
saveas(722,fullfile(save_dir,[save_name '.pdf']));
saveas(722,fullfile(save_dir,[save_name '.fig']));
end