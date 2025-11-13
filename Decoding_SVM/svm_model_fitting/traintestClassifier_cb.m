function [trainedClassifier, validationAccuracy,classification, accuracytraining] = traintestClassifier_cb(trainingData, response,class_names,class_type,varargin)
%UPDATED JAN 2025- THIS CODE WILL USE INPUTS THE SAME WAY THE GLM MODEL
%SEPARATED DATA (10 SPLITS EACH WITH 70/30 TRAIN/TEST)
% ** varargin relates only to using decay  

% Returns a trained classifier and its accuracy. This code recreates the
% classification model trained in Classification Learner app. Use the
% generated code to automate training the same model with new data, or to
% learn how to programmatically train models.
%
%  Input:
%      trainingData: A matrix with the same number of columns and data type
%       as the matrix imported into the app.
%
%      responseData: A vector with the same data type as the vector
%       imported into the app. The length of responseData and the number of
%       rows of trainingData must be equal.
%
%  Output:
%      trainedClassifier: A struct containing the trained classifier. The
%       struct contains various fields with information about the trained
%       classifier.
%
%      trainedClassifier.predictFcn: A function to make predictions on new
%       data.
%
%      validationAccuracy: A double containing the accuracy as a
%       percentage. In the app, the Models pane displays this overall
%       accuracy score for each model.
%
% Use the code to train the model with new data. To retrain your
% classifier, call the function from the command line with your original
% data or new data as the input arguments trainingData and responseData.
%
% For example, to retrain a classifier trained with the original data set T
% and response Y, enter:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T, Y)
%
% To make predictions with the returned 'trainedClassifier' on new data T2,
% use
%   yfit = trainedClassifier.predictFcn(T2)
%
% T2 must be a matrix containing only the predictor columns used for
% training. For details, enter:
%   trainedClassifier.HowToPredict



% Train a classifier
% This code specifies all the classifier options and trains the classifier.
if strcmp(class_type,'SVM')
    classification = fitcsvm(...
        trainingData, ...
        response, ...
        'KernelFunction', 'linear', ...
        'KernelScale', 'auto', ...
        'BoxConstraint', 1);%, ...
%         'ClassNames', class_names);
elseif strcmp(class_type,'LDA')
    delete_id=[];
  for id_var_chk=1:size(trainingData,2)
      if(var(trainingData(:,id_var_chk))<.001)
             delete_id=[delete_id,id_var_chk]; 
      end
  end
  trainingData(:,delete_id)=[];
  classification = fitcdiscr(trainingData,response); 
elseif strcmp(class_type,'NBayes')
  delete_id=[];
  for id_var_chk=1:size(trainingData,2)
      if(var(trainingData(:,id_var_chk))<.001)
             delete_id=[delete_id,id_var_chk]; 
      end
  end
  trainingData(:,delete_id)=[]; 
    classification = fitcnb(trainingData,response); 
elseif strcmp(class_type,'Bagged Trees')
    classification=TreeBagger(40,trainingData,response); 
elseif strcmp(class_type,'1v1')
    template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'BoxConstraint', 1);
    
    classification = fitcecoc(...
    trainingData, ...
    response, ...
    'Learners', template, ...
    'Coding', 'onevsone');

end

% Create the result struct with predict function
svmPredictFcn = @(x) predict(classification, x);
trainedClassifier.Classification = classification;
% Evaluate the classifier on the testing data 
testingData = varargin{1,1}{1,1};
testingResponse = varargin{1,1}{1,2};
predictedLabels = svmPredictFcn(testingData); 
% Calculate accuracy 
accuracy = mean(predictedLabels == testingResponse); 
% Store results for this split 
validationAccuracy = accuracy;

%training accuracy
predictedLabelstraining = svmPredictFcn(trainingData); 
accuracytraining = mean(predictedLabelstraining == response);




% results(i).model = classification; 
% results(i).predictions = predictedLabels; 
% results(i).accuracy = accuracy;

% trainedClassifier.predictFcn = @(x) svmPredictFcn(x);
% 
% % Add additional fields to the result struct
% trainedClassifier.Classification = classification;
% 
% % Extract predictors and response
% % This code processes the data into the right shape for training the
% % model.
% %% Convert input to table
%  % * GO HERE FOR TRAINING ON OTHER CLASSIFIERS 
% % Perform cross-validation
% partitionedModel = crossval(trainedClassifier.Classification,'Leaveout','on');
% 
% % Compute validation predictions
% [validationPredictions, validationScores] = kfoldPredict(partitionedModel);
% 
% % Compute validation accuracy
% validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
