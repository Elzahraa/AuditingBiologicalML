function Stat_Ts = fun_Stats_Prediction2(Testing_Label,ESTIMATES_Ts,poslabel, neglabel,posclass,TH)
%Stats_Prediction2 returns classification performance statisitcs with
%flexible pos and neg labels 

%% Sorting out labels
predicted_label = ESTIMATES_Ts;
if poslabel>neglabel
    predicted_label(predicted_label>=TH)=poslabel;
    predicted_label(predicted_label< TH)=neglabel;
else
    predicted_label(predicted_label>=TH)=neglabel ;
    predicted_label(predicted_label< TH)=poslabel;
    
end

%% Performance stats
CM=confusionmat(Testing_Label,predicted_label,'order',[poslabel neglabel]);
TP=CM(1,1);
TN=CM(2,2);
FN=CM(1,2);
FP=CM(2,1);
Sens=TP/(TP+FN);
Spec=TN/(FP+TN);
Acc=(TP+TN)/sum(sum(CM));
MCC=(TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
Ts_Size=length(Testing_Label);
% Accuracy, sensitivity, specificity, MCC, Ts_Size
Stat_Ts(1,1:5) = [Acc,Sens,Spec,MCC,Ts_Size];
% AUC
[X,Y,T,Stat_Ts(1,6),OP]=perfcurve(Testing_Label, ESTIMATES_Ts, posclass);
TH=T(find(X==OP(1) & Y==OP(2)));
XYTOP=[OP,TH];
% AUPR
[~,~,~,Stat_Ts(1,7)] = perfcurve(Testing_Label, ESTIMATES_Ts, posclass, 'xCrit', 'reca', 'yCrit', 'prec');

end

