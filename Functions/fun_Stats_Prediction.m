function Stat_Ts = fun_Stats_Prediction(Testing_Label,predicted_label)
%Stats_Prediction returns classification performance statisitcs with a
%fixed labels (1: positive, -1: negative)

   CM=confusionmat(Testing_Label,predicted_label,'order',[1 -1]);
    TP=CM(1,1);
    TN=CM(2,2);
    FN=CM(1,2);
    FP=CM(2,1);
    Sens=TP/(TP+FN);
    Spec=TN/(FP+TN);
    Acc=(TP+TN)/sum(sum(CM));
    MCC=(TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
    Ts_Size=length(Testing_Label);
   
    %% Result Output
    % Accuracy, sensitivity, specificity, MCC, Ts_Size
    Stat_Ts=[Acc,Sens,Spec,MCC,Ts_Size];
    
end

