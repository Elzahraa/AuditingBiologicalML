function [StTrain,StTest,TrMean,TrSD] = fun_Standarize_TrTs_MSD(CrntTrain,CrntTest)
%Standarize_Testing standardizes training and testing sets

%% Paramters
TrMean=mean(CrntTrain,1);
TrSD=std(CrntTrain,1);
TrMeanMat=repmat(TrMean,size(CrntTrain,1),1);
TrSDMat=repmat(TrSD,size(CrntTrain,1),1);

%% Standardize Training set
StTrain=(CrntTrain-TrMeanMat)./TrSDMat;

%% Standardize Test set
TsMeanMat=repmat(TrMean,size(CrntTest,1),1);
TsSDMat=repmat(TrSD,size(CrntTest,1),1);
StTest=(CrntTest-TsMeanMat)./TsSDMat;

%% Remove NaNs
StTest(find(isnan(StTest)==1))=0;

%% Remove inf (created by scaling transfer to testing data)
StTest(find(isinf(StTest)==1))=0;

end

