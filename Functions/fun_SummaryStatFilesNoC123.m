function [ Summary , SummaryAUC] = fun_SummaryStatFilesNoC123( Paramters, Stat_Tr, SVr, ...
    OutputFileHeader, SumFile, TIMEs)
%fun_SummaryStatFilesNoC123 summarizes training and validation performances
%from multiple rounds of training PPI prediction models (M1-M7)

%% Reset
clear Stat_Tr
clear SVr
clear TIMEs

%% Summary table
N = length(Paramters);
isM7 = ~isempty(strfind(OutputFileHeader,'M7'));
for f=1:N
    
    OutputFile=[OutputFileHeader,'_', num2str(f)  , '.mat'];
    load(OutputFile)
    
    % Paramters
    if size(Paramters,2)==1 % C models
        C(f,1)=Paramters(f,1);
        
    elseif size(Paramters,2)==2 & ~isM7 % C and Gamma models
        C(f,1)=Paramters(f,1);
        Gamma(f,1)=Paramters(f,2);
        
    elseif size(Paramters,2)==2 & isM7 % M7 (HiddenSize and Regularize)
        HiddenSize(f,1)=Paramters(f,1);
        Regularize(f,1)=Paramters(f,2);
        
    elseif size(Paramters,2)==3 % Tree models
        Trees(f,1)= Paramters(f,1);
        MinLeafSize(f,1)= Paramters(f,2);
        NumPredictors(f,1)= Paramters(f,3);
    end
    
    % Account for NaNs
    NanCount(f,1)=length(find(isnan(Stat_Tr(:,6))));
    NotNan=find(~isnan(Stat_Tr(:,6)));
    
    % Training performance
    if  size(Paramters,2)~=3 & ~isM7
        SVratio(f,1)=mean(SVr(NotNan));
    end
    TrSize(f,1)=mean(Stat_Tr(NotNan,5));
    TrSens(f,1)=mean(Stat_Tr(NotNan,2));
    TrSpec(f,1)=mean(Stat_Tr(NotNan,3));
    TrAUC(f,1)=mean(Stat_Tr(NotNan,6));
    Time(f,1)=mean(TIMEs);
    
    % Validation performance
    CVSens(f,1)=mean(Stat_CV(NotNan,2));
    CVSpec(f,1)=mean(Stat_CV(NotNan,3));
    CVAUC(f,1)=mean(Stat_CV(NotNan,6));
    CVpos(f,1)=round(mean(Stat_CV(NotNan,5)));
    
end

%% Summary output

if size(Paramters,2)==2 & ~isM7
    
    Summary=table(C,Gamma, SVratio, ...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        ... C1Sens, C1Spec, C1AUC, C1pos, ...
        ...    C2Sens, C2Spec, C2AUC, C2pos, ...
        ...    C3Sens, C3Spec, C3AUC, C3pos, ...
        NanCount);
    SummaryAUC=table(C,Gamma, SVratio,TrAUC, CVAUC, Time, NanCount);% C1AUC, C2AUC, C3AUC
    
elseif size(Paramters,2)==2 & isM7
    
    Summary=table(HiddenSize,Regularize, ...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        ... C1Sens, C1Spec, C1AUC, C1pos, ...
        ... C2Sens, C2Spec, C2AUC, C2pos, ...
        ... C3Sens, C3Spec, C3AUC, C3pos, ...
        NanCount);
    SummaryAUC=table(HiddenSize,Regularize,TrAUC, CVAUC,Time, NanCount);% C1AUC, C2AUC, C3AUC,
    
    
elseif size(Paramters,2)==1
    Summary=table(C, SVratio, ...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        ...  C1Sens, C1Spec, C1AUC, C1pos, ...
        ...  C2Sens, C2Spec, C2AUC, C2pos, ...
        ...  C3Sens, C3Spec, C3AUC, C3pos, ...
        NanCount);
    SummaryAUC=table(C, SVratio,TrAUC, CVAUC, Time, NanCount);%, C1AUC, C2AUC, C3AUC
    
elseif size(Paramters,2)==3
    Summary=table(Trees, MinLeafSize, NumPredictors, ...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        ...        C1Sens, C1Spec, C1AUC, C1pos, ...
        ... C2Sens, C2Spec, C2AUC, C2pos, ...
        ...  C3Sens, C3Spec, C3AUC, C3pos, ...
        NanCount);
    SummaryAUC=table(Trees, MinLeafSize, NumPredictors,TrAUC, CVAUC, Time, NanCount);%, C1AUC, C2AUC, C3AUC
    
end

%% If No iterations, just summary of a single file
if isempty(Paramters)
    f=1;
    load(OutputFileHeader)
    
    % Account for NaNs
    NanCount(f,1)=length(find(isnan(Stat_Tr(:,6))));
    NotNan=find(~isnan(Stat_Tr(:,6)));
    
    % Training performance
    TrSize(f,1)=mean(Stat_Tr(NotNan,5));
    TrSens(f,1)=mean(Stat_Tr(NotNan,2));
    TrSpec(f,1)=mean(Stat_Tr(NotNan,3));
    TrAUC(f,1)=mean(Stat_Tr(NotNan,6));
    Time(f,1)=mean(TIMEs);

    % Validation performance    
    CVSens(f,1)=mean(Stat_CV(NotNan,2));
    CVSpec(f,1)=mean(Stat_CV(NotNan,3));
    CVAUC(f,1)=mean(Stat_CV(NotNan,6));
    CVpos(f,1)=round(mean(Stat_CV(NotNan,5)));
    
    % Summary 
    Summary=table(...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        NanCount);
    
    SummaryAUC=table(TrAUC, CVAUC, Time, NanCount);
 
end

%% Save file
save(SumFile,'SummaryAUC', 'Summary')

end
