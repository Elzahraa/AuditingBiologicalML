%ParamterOpt_Vidal_M7
% Process: Benchmarking model on different paramters
% Data: Vidal dataset
% Framework: M7 (F7)
% Manipulation: None


clear
training_rounds = 10;

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))

%% Training and testing data
%load VidalHH.mat %For redundant data
load VidalHH_RedRed.mat %Redundancy reduced as in Marcotte dataset
NEGtr = NEGtrR;

%% Output
TKs='01';
TaskTitle='ParamterOpt';
Model='M7';
Dataset='VidalHH';
OutputFileHeader=['TK',TKs,'_',TaskTitle,'_', Model,'_', Dataset]
SumFile=['TK', num2str(TKs),'Summary','_',TaskTitle,'_', Model,'_', Dataset]

%% Paramters
NegLabel = 0;
TH = 0.5;
MaxEpochs1 = 700;
MaxEpochs3 = 300;

%% Parameter search space
hiddenSize  = [100:100:700]';
Regularize = [0.001, 0.005, 0.01, 0.05, 0.1]';
Paramters=[];
for c=1:length(hiddenSize)
    Paramters=[Paramters;repmat(hiddenSize(c),size(Regularize)),Regularize];
end

%% Features
load Features_M3_VidalHH Features

%% Parameter optimization rounds
for paramterSet=1:length(Paramters)
    paramterSet
    
    crntHiddenSize = Paramters(paramterSet,1);
    crntRegulariz = Paramters(paramterSet,2);
    
    OutputFile=[OutputFileHeader,'_', num2str(paramterSet)  , '.mat'];
    
    %% Training rounds
    ESTIMATES_Tr = cell(training_rounds,1);
    Stat_Tr = zeros(training_rounds,7);
    ESTIMATES_TsCV = cell(training_rounds,1);
    Stat_CV = zeros(training_rounds,7);
    SVr = zeros(training_rounds,1);
    TIMEs = zeros(training_rounds,1);
    
    ESTIMATES_TsC1 = cell(training_rounds,1);
    Stat_C1 = zeros(training_rounds,7);
    ESTIMATES_TsC2 = cell(training_rounds,1);
    Stat_C2 = zeros(training_rounds,7);
    ESTIMATES_TsC3 = cell(training_rounds,1);
    Stat_C3 = zeros(training_rounds,7);
    
    for k=1:training_rounds
        k
        tic
        MajorT = tic;
        
        %% Training and validation sets
        postr=POStr{k};
        negtr=NEGtr{k};
        poscv=POSCV{k};
        negcv=NEGCV{k};
        
        Tr=[postr;negtr];
        CV=[poscv;negcv];
        
        %% Test sets
        posc1 = POStsC1{k};
        posc2 = POStsC2{k};
        posc3 = POStsC4{k};
        negc1 = NEGtsC1{k};
        negc2 = NEGtsC2{k};
        negc3 = NEGtsC4{k};
        
        C1 = [posc1;negc1];
        C2 = [posc2;negc2];
        C3 = [posc3;negc3];
        
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
        
        %C1
        CrntPosMatC1=[Features(posc1(:,1),:),...
            Features(posc1(:,2),:)];
        CrntNegMatC1=[Features(negc1(:,1),:),...
            Features(negc1(:,2),:)];
        StC1 = [CrntPosMatC1;CrntNegMatC1];
        
        %C2
        CrntPosMatC2=[Features(posc2(:,1),:),...
            Features(posc2(:,2),:)];
        CrntNegMatC2=[Features(negc2(:,1),:),...
            Features(negc2(:,2),:)];
        StC2 = [CrntPosMatC2;CrntNegMatC2];
        
        %C4
        CrntPosMatC3=[Features(posc3(:,1),:),...
            Features(posc3(:,2),:)];
        CrntNegMatC3=[Features(negc3(:,1),:),...
            Features(negc3(:,2),:)];
        StC3 = [CrntPosMatC3;CrntNegMatC3];
        
        
        %% Train preparation
        PosLabel = 1;
        posclass = PosLabel;
        
        TrLabel = [PosLabel*ones(length(postr),1); NegLabel*ones(length(negtr),1)];
        CVLabel = [PosLabel*ones(length(poscv),1); NegLabel*ones(length(negcv),1)];
        
        %% Model
        % Autoencoder
        rng('default')
        T= tic;
        
        autoenc1 = trainAutoencoder(StTrain',crntHiddenSize,...
            'MaxEpochs',MaxEpochs1, ...
            'L2WeightRegularization',crntRegulariz, ... %no regularization in M7 paper
            'ScaleData', false);
        fprintf('Training Autoencoder 1: %d sec. \n',toc(T))
        
        % Input toSoftmax
        feat1 = encode(autoenc1,StTrain');
        
        % 1-layer model
        T = tic;
        softnet= trainSoftmaxLayer(feat1,TrLabel','MaxEpochs',MaxEpochs3);
        
        deepnet1 = stack(autoenc1,softnet);
        
        %% Train
        deepnet2 = train(deepnet1,StTrain',TrLabel');
        fprintf('Training the fine-tuned deepnet: %d sec. \n',toc(T))
        
        %% Train performance
        ESTIMATES_Tr{k} = deepnet2(StTrain');
        Stat_Tr(k,:) = fun_Stats_Prediction2(TrLabel,ESTIMATES_Tr{k},PosLabel,NegLabel,posclass,TH)
        
        %% CV performance
        ESTIMATES_TsCV{k} = deepnet2(StCV');
        Stat_CV(k,:)= fun_Stats_Prediction2(CVLabel,ESTIMATES_TsCV{k},PosLabel,NegLabel,posclass,TH)
        
        %% Test performance
        C1Label = [PosLabel*ones(length(posc1),1); NegLabel*ones(length(negc1),1)];
        C2Label = [PosLabel*ones(length(posc2),1); NegLabel*ones(length(negc2),1)];
        C3Label = [PosLabel*ones(length(posc3),1); NegLabel*ones(length(negc3),1)];
        
        ESTIMATES_TsC1{k} = deepnet2(StC1');
        Stat_C1(k,:)= fun_Stats_Prediction2(C1Label,ESTIMATES_TsC1{k},PosLabel,NegLabel,posclass,TH)
        
        ESTIMATES_TsC2{k} = deepnet2(StC2');
        Stat_C2(k,:)= fun_Stats_Prediction2(C2Label,ESTIMATES_TsC2{k},PosLabel,NegLabel,posclass,TH)
        
        ESTIMATES_TsC3{k} = deepnet2(StC3');
        Stat_C3(k,:)= fun_Stats_Prediction2(C3Label,ESTIMATES_TsC3{k},PosLabel,NegLabel,posclass,TH)
        
        
        %% Save results
        toc(MajorT)
        TIMEs(k,1) = toc(MajorT);
        
        save(OutputFile,'crntHiddenSize','crntRegulariz','-regexp','^ESTIMATES_','^Stat_',...
            'TIMEs','-v7.3')
        
    end
end

%% Summary stats
[Summary , SummaryAUC] = fun_SummaryStatFiles( Paramters, [], [], ...
    OutputFileHeader, SumFile, []);
