function [ Summary , SummaryAUC] = fun_SummaryStatFiles_trCV( Paramters, Stat_Tr, SVr, ...
    OutputFileHeader, SumFile, TIMEs)
%fun_SummaryStatFiles_trCV summarizes training and validation performances
%from multiple rounds of training PPI prediction models (M1-M6)

%% Summary table
N = length(Paramters);

for f=1:N
    
    OutputFile=[OutputFileHeader,'_', num2str(f)  , '.mat'];
    load(OutputFile)
    
    % Paramters
    if size(Paramters,2)==1 % C models
        C(f,1)=Paramters(f,1);
    elseif size(Paramters,2)==2 % C and Gamma models
        C(f,1)=Paramters(f,1);
        Gamma(f,1)=Paramters(f,2);
        
    elseif size(Paramters,2)==3 % Tree models
        Trees(f,1)= Paramters(f,1);
        MinLeafSize(f,1)= Paramters(f,2);
        NumPredictors(f,1)= Paramters(f,3);
        
    end
    
    % Account for NaNs
    NanCount(f,1)=length(find(isnan(Stat_Tr(:,6))));
    NotNan=find(~isnan(Stat_Tr(:,6)));
    
    % Training performance
    if  size(Paramters,1)~=3
        SVratio(f,1)=mean(SVr(NotNan));
    end
    TrSize(f,1)=mean(Stat_Tr(NotNan,5));
    TrSens(f,1)=mean(Stat_Tr(NotNan,2));
    TrSpec(f,1)=mean(Stat_Tr(NotNan,3));
    TrAUC(f,1)=mean(Stat_Tr(NotNan,6));
    Time(f,1)=mean(TIMEs);
    
    CVSens(f,1)=mean(Stat_CV(NotNan,2));
    CVSpec(f,1)=mean(Stat_CV(NotNan,3));
    CVAUC(f,1)=mean(Stat_CV(NotNan,6));
    CVpos(f,1)=round(mean(Stat_CV(NotNan,5)));
    
end

%% Summary output

if size(Paramters,2)==2 % C and Gamma models
    
    Summary=table(C,Gamma, SVratio, ...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        NanCount);
    SummaryAUC=table(C,Gamma, SVratio,TrAUC, CVAUC, Time, NanCount);
    
elseif size(Paramters,2)==1 % C models
    Summary=table(C, SVratio, ...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        NanCount);
    SummaryAUC=table(C, SVratio,TrAUC, CVAUC, Time, NanCount);
    
elseif size(Paramters,2)==3 % Tree models
    Summary=table(Trees, MinLeafSize, NumPredictors, ...
        TrSize, TrSens, TrSpec, TrAUC, Time, ...
        CVSens, CVSpec, CVAUC, CVpos, ...
        NanCount);
    
    SummaryAUC=table(Trees, MinLeafSize, NumPredictors,TrAUC, CVAUC, Time, NanCount);
    
end

%% If no iterations, report summary of a single file
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

