%Valid_Pan_M5_v3
% Process: Generalizability Auditor I
% Data: Pan dataset
% Framework: M5 (F5)
% Manipulation: Testing on independent examples from Vidal dataset,
% yet the test examples follow the in-network criteria (C1) w.r.t. the
% training examples
%05.11.2019


clear
training_rounds = 10;

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))

%% Training data
%load PanHH.mat
load PanHH_reduced.mat POStr POScv POSts NEGtr NEGcv NEGts %sequence redundancy reduced
POSCV = POScv;
NEGCV = NEGcv;

%% Testing data
load Valid_Panv3.mat TestPos TestNeg

%% Output
TKs='08';
TaskTitle='Validation3';
Model='M5';
Dataset='PanHH';
OutputFileHeader=['TK',TKs,'_',TaskTitle,'_', Model,'_', Dataset]

%% Features
load Features_M4_PanHH.mat Features

%% Parameter search space
Trees = [10, 50, 100, 500,1000, 5000];
MinLeafSizes = [1, 5, 10, 50];
NumPredictorstoSample = [5,10,50,100,150,200];

Paramters = fun_multiplex(Trees,MinLeafSizes,NumPredictorstoSample);

%% Load the optimized model parameters
SumFileIn=['TK', num2str('01'),'Summary','_','ParamterOpt','_', Model,'_', Dataset]
load(SumFileIn)
SUMAUC = SummaryAUC.CVAUC;
% Exclude models not in the reduced paramter set
ParameterExclude = find(Paramters(:,3)~=50)';
SUMAUC(ParameterExclude)=0;

[~,BestPar] = max(SUMAUC);

%% Validation rounds
rng(1); % For reproducibility
for paramterSet=BestPar
    paramterSet
    
    crntTrees = Paramters(paramterSet,1);
    crntMinLeafSize = Paramters(paramterSet,2);
    crntNumPredictors = Paramters(paramterSet,3);
    
    OutputFile=[OutputFileHeader,'.mat'];
    
    %% Training rounds
    ESTIMATES_Tr = cell(training_rounds,1);
    Stat_Tr = zeros(training_rounds,7);
    ESTIMATES_TsCV = cell(training_rounds,1);
    Stat_CV = zeros(training_rounds,7);
    SVr = zeros(training_rounds,1);
    TIMEs = zeros(training_rounds,1);
    
    ESTIMATES_TsC1 = cell(training_rounds,1);
    Stat_C1 = zeros(training_rounds,7);
    %     ESTIMATES_TsC2 = cell(training_rounds,1);
    %     Stat_C2 = zeros(training_rounds,7);
    %     ESTIMATES_TsC3 = cell(training_rounds,1);
    %     Stat_C3 = zeros(training_rounds,7);
    %
    
    ESTIMATES_Ts = cell(training_rounds,1);
    Stat_Ts = zeros(training_rounds,7);
    
    for k=1:training_rounds
        k
        tic
        
        %% Training and validation sets
        postr=POStr{k};
        negtr=NEGtr{k};
        poscv=POSCV{k};
        negcv=NEGCV{k};
        
        Tr=[postr;negtr];
        CV=[poscv;negcv];
        
        %% Independent test sets
        posts = TestPos{k};
        negts = TestNeg{k};
        Ts = [posts;negts];
        
        %% Test sets
        posc1 = POSts{k};
        %         posc2 = POStsC2{k};
        %         posc3 = POStsC4{k};
        % negc1 = NEGts;%{k};
        negc1 = NEGts{k};
        %         negc2 = NEGtsC2{k};
        %         negc3 = NEGtsC4{k};
        %
        C1 = [posc1;negc1];
        %         C2 = [posc2;negc2];
        %         C3 = [posc3;negc3];
        
        %% Prepare training and testing matrices
        CrntPosMatTr=[Features(postr(:,1),:),...
            Features(postr(:,2),:)];
        CrntNegMatTr=[Features(negtr(:,1),:),...
            Features(negtr(:,2),:)];
        
        CrntPosMatCV=[Features(poscv(:,1),:),...
            Features(poscv(:,2),:)];
        CrntNegMatCV=[Features(negcv(:,1),:),...
            Features(negcv(:,2),:)];
        
        % Standardized
        % [StTrain,StCV,~,~] = fun_Standarize_TrTs_MSD(...
        %     [CrntPosMatTr;CrntNegMatTr],[CrntPosMatCV;CrntNegMatCV]);
        
        % Non-standardized
        StTrain=[CrntPosMatTr;CrntNegMatTr];
        StCV=[CrntPosMatCV;CrntNegMatCV];
        
        % C1
        
        CrntPosMatC1=[Features(posc1(:,1),:),...
            Features(posc1(:,2),:)];
        CrntNegMatC1=[Features(negc1(:,1),:),...
            Features(negc1(:,2),:)];
        StC1 = [CrntPosMatC1;CrntNegMatC1];
        
        %
        %              %C2
        %         CrntPosMatC2=[Features(posc2(:,1),:),...
        %             Features(posc2(:,2),:)];
        %         CrntNegMatC2=[Features(negc2(:,1),:),...
        %             Features(negc2(:,2),:)];
        %         StC2 = [CrntPosMatC2;CrntNegMatC2];
        %
        %             %C4
        %         CrntPosMatC3=[Features(posc3(:,1),:),...
        %             Features(posc3(:,2),:)];
        %         CrntNegMatC3=[Features(negc3(:,1),:),...
        %             Features(negc3(:,2),:)];
        %         StC3 = [CrntPosMatC3;CrntNegMatC3];
        
        % Independent test
        CrntPosMatTs=[Features(posts(:,1),:),...
            Features(posts(:,2),:)];
        CrntNegMatTs=[Features(negts(:,1),:),...
            Features(negts(:,2),:)];
        % No-Standardized
        StTs = [CrntPosMatTs;CrntNegMatTs];
        
        %% Train
        PosLabel = 1;
        NegLabel = -1;
        posclass = PosLabel;
        
        TrLabel = [PosLabel*ones(length(postr),1); NegLabel*ones(length(negtr),1)];
        
        randomForest = TreeBagger(crntTrees,double(StTrain),TrLabel,...
            'Method','regression',...
            'MinLeafSize',crntMinLeafSize,'NumPredictorstoSample',crntNumPredictors);
        
        %% Train performance
        ESTIMATES_Tr{k} = predict(randomForest, double(StTrain));
        Stat_Tr(k,:)  = fun_STD_Test1(ESTIMATES_Tr{k}, postr,negtr,PosLabel,NegLabel,posclass);
        
        %% CV performance
        ESTIMATES_TsCV{k} =  predict(randomForest, double(StCV));
        Stat_CV(k,:)      = fun_STD_Test1(ESTIMATES_TsCV{k} ,poscv,negcv,PosLabel,NegLabel,posclass);
        
        %% Test performance
        ESTIMATES_TsC1{k} =  predict(randomForest, double(StC1));
        %         ESTIMATES_TsC2{k} =  predict(randomForest, double(StC2));
        %         ESTIMATES_TsC3{k} =  predict(randomForest, double(StC3));
        %
        Stat_C1(k,:)      = fun_STD_Test1(ESTIMATES_TsC1{k} ,posc1,negc1,PosLabel,NegLabel,posclass);
        %         Stat_C2(k,:)      = fun_STD_Test1(ESTIMATES_TsC2{k} ,posc2,negc2,PosLabel,NegLabel,posclass);
        %         Stat_C3(k,:)      = fun_STD_Test1(ESTIMATES_TsC3{k} ,posc3,negc3,PosLabel,NegLabel,posclass);
               
        %% Independent test performance
        if ~isempty(posts)
            ESTIMATES_Ts{k} =  predict(randomForest, double(StTs));
            Stat_Ts(k,:)      = fun_STD_Test1(ESTIMATES_Ts{k} ,posts,negts,PosLabel,NegLabel,posclass);
        end
        
        %% Save results
        TIMEs(k,1)=toc;
        toc
        
        save(OutputFile,'crntTrees','crntMinLeafSize','crntNumPredictors',...
            '-regexp','^ESTIMATES_','^Stat_',...
            'TIMEs','-v7.3')
        
    end
end


