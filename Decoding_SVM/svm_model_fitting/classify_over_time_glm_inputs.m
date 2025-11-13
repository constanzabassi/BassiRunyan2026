function output = classify_over_time_glm_inputs(aligned_data,Y,mdl_param,test_aligned,Y_test)

%selected_frames = mdl_param.frames_around;
selected_frames = mdl_param.binns;

bin = mdl_param.bin;
ends=zeros(1,length(selected_frames))+bin;
timepoints=[selected_frames;ends];
for t = 1:length(mdl_param.binns)%(timepoints)
%     t
    %X = get_X (aligned_data, mdl_param,selected_frames(t));
    %X is trials x cells
    X = get_X_nooverlap (aligned_data, mdl_param,selected_frames(t));
    X_test = get_X_nooverlap (test_aligned, mdl_param,selected_frames(t));

    %Z-score the data
    mu = mean(X);
    sigma = std(X);
    sigma(sigma == 0) = 1;
    
    X = (X - mu) ./ sigma;
    X_test = (X_test - mu) ./ sigma;


    %call classifier model
    [~, accuracy(t),mdl{t},train_accuracy(t)] = traintestClassifier_cb(X, Y,[1;2],'SVM',{X_test,Y_test}); %accuracy(mouse,t)
    %repeat but with suffled Y labels
    Y_shuff=Y(randperm(length(Y)));
    [~, shuff_accuracy(t),shuff_mdl{t},shuff_train_accuracy(t)] = traintestClassifier_cb(X, Y_shuff,[1;2],'SVM',{X_test,Y_test}); 

end
%% STORE VARIABLES 
output.accuracy=accuracy; %in Christians accuracy is (datasets,bins)
output.shuff_accuracy=shuff_accuracy; 
%%% trying to make structure smaller...
output.mdl = mdl;
% output.shuff_mdl = shuff_mdl;
output.mdl_param = mdl_param;
output.shuff_train_accuracy = shuff_train_accuracy;
output.train_accuracy = train_accuracy;


