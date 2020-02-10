function [ESTIMATES_Ts,Stat_Ts,X,Y,T ,XYTOP ]=fun_STDsvmTest1(MODEL,posts,negts,StTest,PosLabel,NegLabel,posclass)
%fun_STDsvmTest1 reports standard summary statistics for a LibSVM classifier
% performance given a model and a test set

%% Generate the testing labels
TsLabel=[PosLabel*ones(size(posts,1),1);NegLabel*ones(size(negts,1),1)];

%% Test the test set using the model
[predicted_label,~,ESTIMATES_Ts] = svmpredict(TsLabel, sparse(double(StTest)), MODEL);

%% Performance summary 
% Accuracy, sensitivity, specificity, MCC, Ts_Size
Stat_Ts(1,1:5) = fun_Stats_Prediction(TsLabel,predicted_label);
% AUC
[X,Y,T,Stat_Ts(1,6),OP]=perfcurve(TsLabel, ESTIMATES_Ts, posclass);
TH=T(find(X==OP(1) & Y==OP(2)));
XYTOP=[OP,TH];
% AUPR
[~,~,~,Stat_Ts(1,7)] = perfcurve(TsLabel, ESTIMATES_Ts, posclass, 'xCrit', 'reca', 'yCrit', 'prec');

end