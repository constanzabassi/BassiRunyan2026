function plot_sig_cells_perdataset(dff_st,sig_mod_boot,all_celltypes,mouse_date)
all_celltypes2=[];only_pv=[];only_som=[];pyramidal= [];
for m = 1:size(dff_st,2)
    all_celltypes2 = [all_celltypes2,length(sig_mod_boot{1,m})/size(dff_st{1,m}.stim,2)];
    only_pv = [only_pv,length(all_celltypes{1,m}.pv_cells)];%/size(dff_st{1,m}.stim,2)];
    only_som = [only_som,length(all_celltypes{1,m}.som_cells)];%/size(dff_st{1,m}.stim,2)];
    pyramidal = [pyramidal,length(all_celltypes{1,m}.pyr_cells)];%/size(dff_st{1,m}.stim,2)];
end
figure(25);clf
b = bar(all_celltypes2,'FaceColor','flat'); 
% for k= 1:length(y)
%     b(k).FaceColor = colors_bar(k,:);
% end
set(gca, 'XTickLabel',mouse_date);
ylabel('% significant cells');

figure(26);clf
cels = [pyramidal;only_pv;only_som]';
hold on
b = bar(cels,'FaceColor','flat'); 

% for k= 1:length(y)
%     b(k).FaceColor = colors_bar(k,:);
% end
xticks([1:1:length(cels)])
set(gca, 'XTickLabel',mouse_date);
ylabel('# cells');
legend('PYR','PV','SOM')
hold off