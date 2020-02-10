% Node degree learning
% 11.07.2019
% Data Auditing for Frequency learning
% For each of the three data sets, train a model on its frequencies
% to compare its performance to the best model found given the data


clear

%% Paramters
PosLabel= 1;
NegLabel= -1;
posclass = PosLabel;

for DataSet = 1:3
    %% Data
    switch DataSet
        case 1
            load MarcotteHH.mat
        case 2
            load VidalHH_RedRed.mat
            NEGtr = NEGtrR;
        case 3
            load PanHH.mat
    end
    
    %% Run experiment
    
    for k = 1:10
        k
        %% Prepare Current Sets
        postr=POStr{k};
        negtr=NEGtr{k};
        poscv=POSCV{k};
        negcv=NEGCV{k};
        
        Tr=[postr;negtr];
        CV=[poscv;negcv];
        
        
        if DataSet ~=3
            posc1=POStsC1{k};
            negc1=NEGtsC1{k};
            C1=[posc1;negc1];
            posc2=POStsC2{k};
            negc2=NEGtsC2{k};
            C2=[posc2;negc2];
            posc3=POStsC4{k};
            negc3=NEGtsC4{k};
            C3=[posc3;negc3];
        end
        
        %% Features
        CountTr = fun_countOccInTr(postr,negtr,Tr);
        CountCV = fun_countOccInTr(postr,negtr,CV);
        
        if DataSet ~=3
            CountC1 = fun_countOccInTr(postr,negtr,C1);
            CountC2 = fun_countOccInTr(postr,negtr,C2);
            CountC3 = fun_countOccInTr(postr,negtr,C3);
        end
        %% Labels
        TrLabels{DataSet,k} = [ones(length(postr),1); -1*ones(length(negtr),1)];
        CVLabels{DataSet,k} = [ones(length(poscv),1); -1*ones(length(negcv),1)];
        
        if DataSet ~=3
            C1Labels{DataSet,k} = [ones(length(posc1),1); -1*ones(length(negc1),1)];
            C2Labels{DataSet,k} = [ones(length(posc2),1); -1*ones(length(negc2),1)];
            C3Labels{DataSet,k} = [ones(length(posc3),1); -1*ones(length(negc3),1)];
        end
        
        %% Training
        Options = struct('ShowPlots',false, 'Verbose',0);
        mdl = fitrensemble(CountTr,TrLabels{DataSet,k},...
            'OptimizeHyperparameters','all','HyperparameterOptimizationOptions',Options);
        
        %% Training Performance
        ESTIMATES_Tr{DataSet, k} = predict(mdl,CountTr);
        Stat_Tr(k,:)  = fun_STD_Test1(ESTIMATES_Tr{DataSet,k}, postr,negtr,PosLabel,NegLabel,posclass);
        AUCtr(DataSet,k) =  Stat_Tr(k,6)
        
        %% CV performance
        ESTIMATES_TsCV{DataSet,k} =  predict(mdl, CountCV);
        Stat_CV(k,:)      = fun_STD_Test1(ESTIMATES_TsCV{DataSet,k} ,poscv,negcv,PosLabel,NegLabel,posclass);
        AUCcv(DataSet,k) = Stat_CV(k,6)
        
        %% Test performance
        if DataSet ~=3
            ESTIMATES_TsC1{DataSet,k} =  predict(mdl, CountC1);
            Stat_C1(k,:)      = fun_STD_Test1(ESTIMATES_TsC1{DataSet,k} ,posc1,negc1,PosLabel,NegLabel,posclass);
            AUCc1(DataSet,k) = Stat_C1(k,6)
            
            ESTIMATES_TsC2{DataSet,k} =  predict(mdl, CountC2);
            Stat_C2(k,:)      = fun_STD_Test1(ESTIMATES_TsC2{DataSet,k} ,posc2,negc2,PosLabel,NegLabel,posclass);
            AUCc2(DataSet,k) = Stat_C2(k,6)
            
            
            ESTIMATES_TsC3{DataSet,k} =  predict(mdl, CountC3);
            Stat_C3(k,:)      = fun_STD_Test1(ESTIMATES_TsC3{DataSet,k} ,posc3,negc3,PosLabel,NegLabel,posclass);
            AUCc3(DataSet,k) = Stat_C3(k,6)
        end
        
    end
    
    %% Rest
    clear POStr NEGtr POSCV NEGCV
    if DataSet ~=3
        clear POStsC1 NEGtsC1 POStsC2 NEGtsC2 POStsC4 NEGtsC4
    end
end


%% save results
save NodeDegreeLearning.mat AUCcv AUCc1 AUCc2 AUCc3 AUCtr ...
    ESTIMATES_Tr ESTIMATES_TsCV  ESTIMATES_TsC1 ESTIMATES_TsC2 ESTIMATES_TsC3...
    CVLabels TrLabels C1Labels C2Labels C3Labels



