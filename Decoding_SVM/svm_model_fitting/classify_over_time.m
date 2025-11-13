function output = classify_over_time(aligned_data,Y,mdl_param)

%selected_frames = mdl_param.frames_around;
selected_frames = mdl_param.binns;

bin = mdl_param.bin;
ends=zeros(1,length(selected_frames))+bin;
timepoints=[selected_frames;ends];
for t = 1:length(mdl_param.binns)%(timepoints)
    %t
    %X = get_X (aligned_data, mdl_param,selected_frames(t));
    X = get_X_nooverlap (aligned_data, mdl_param,selected_frames(t));

    %Z-score the data
    mu = mean(X);
    sigma = std(X);
    sigma(sigma == 0) = 1;
    X = (X - mu) ./ sigma;


    %call classifier model
    [~, accuracy(t),mdl{t}] = trainClassifier_cb(X, Y,[1;2],'SVM'); %accuracy(mouse,t)
    %repeat but with suffled Y labels
    Y_shuff=Y(randperm(length(Y)));
    [~, shuff_accuracy(t),shuff_mdl{t}] = trainClassifier_cb(X, Y_shuff,[1;2],'SVM'); 

end
%% STORE VARIABLES 
output.accuracy=accuracy; %in Christians accuracy is (datasets,bins)
output.shuff_accuracy=shuff_accuracy; 
output.mdl = mdl;
output.shuff_mdl = shuff_mdl;
output.mdl_param = mdl_param;

