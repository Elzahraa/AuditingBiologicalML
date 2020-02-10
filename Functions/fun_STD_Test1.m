function Stat_Ts  = fun_STD_Test1(ESTIMATES_Ts,posts,negts,PosLabel,NegLabel,posclass)
%fun_STD_Test1 reports standard summary statistics for a classifier
% performance given test performance

%% Generate the testing labels
TsLabel=[PosLabel*ones(size(posts,1),1);NegLabel*ones(size(negts,1),1)];
predicted_label = ESTIMATES_Ts;
threshold = (PosLabel+NegLabel)/2;
if PosLabel>NegLabel
    predicted_label( predicted_label>= threshold) = PosLabel;
    predicted_label( predicted_label< threshold)  = NegLabel;
else
    predicted_label( predicted_label>= threshold) = NegLabel;
    predicted_label( predicted_label< threshold)  = PosLabel;
end

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