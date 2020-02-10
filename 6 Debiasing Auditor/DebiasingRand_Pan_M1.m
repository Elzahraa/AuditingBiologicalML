%DebiasingRand_Pan_M1
% Process: Debiasing Auditor
% Data: Pan dataset
% Framework: M1 (F1)
% Manipulation: Balancing node degree bias in training and masking features
% with random numbers (method: r2)
%02.15.2019


clear
training_rounds = 10;

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))

%% Training and testing data with balanced negative training data
load PanHH_Balancedreduced

%% Output
TKs='05';
TaskTitle='DebiasRand';
Model='M1';
Dataset='PanHH';
OutputFileHeader=['TK',TKs,'_',TaskTitle,'_', Model,'_', Dataset]
SumFile=['TK', num2str(TKs),'Summary','_',TaskTitle,'_', Model,'_', Dataset]

%% Parameter search space
Cs=[100,10, 1]';
Gammas=[0.1,0.01,0.001,0.0001,0.00001]';
Paramters=[];
for c=1:length(Cs)
    Paramters=[Paramters;repmat(Cs(c),size(Gammas)),Gammas];
end

%% Features
load Features_M1_PanHH_r2

%% Parameter optimization rounds
for paramterSet=1:length(Paramters)
    paramterSet
    
    crntC = Paramters(paramterSet,1);
    crntGamma = Paramters(paramterSet,2);
    ParVector=[' -c ',num2str(crntC),'  -t 4 -h 0 -m 10000' ];
    
    OutputFile=[OutputFileHeader,'_', num2str(paramterSet)  , '.mat'];
    
    %% Training rounds
    ESTIMATES_Tr = cell(training_rounds,1);
    Stat_Tr = zeros(training_rounds,7);
    ESTIMATES_TsCV = cell(training_rounds,1);
    Stat_CV = zeros(training_rounds,7);
    SVr = zeros(training_rounds,1);
    TIMEs = zeros(training_rounds,1);
    
    %     ESTIMATES_TsC1 = cell(training_rounds,1);
    %     Stat_C1 = zeros(training_rounds,7);
    %     ESTIMATES_TsC2 = cell(training_rounds,1);
    %     Stat_C2 = zeros(training_rounds,7);
    %     ESTIMATES_TsC3 = cell(training_rounds,1);
    %     Stat_C3 = zeros(training_rounds,7);
    
    for k=1:training_rounds
        k
        tic
        
        %% Randomized features
        DotSign = DotSign_Rand{k};
        
        %% Training and validation sets
        postr=POStr{k};
        negtr=NEGtr{k};
        poscv=POSCV{k};
        negcv=NEGCV{k};
        
        Tr=[postr;negtr];
        CV=[poscv;negcv];
        
        %% Test sets
        %         posc1 = POStsC1{k};
        %         posc2 = POStsC2{k};
        %         posc3 = POStsC4{k};
        %         negc1 = NEGtsC1{k};
        %         negc2 = NEGtsC2{k};
        %         negc3 = NEGtsC4{k};
        %
        %         C1 = [posc1;negc1];
        %         C2 = [posc2;negc2];
        %         C3 = [posc3;negc3];
        
        %% Precomputed Kernel
        %M1 Kernel: Symmteric+ normalize for length+ basic singature+ Gaussianized
        StTrain  = fun_Kernel_M1(Tr,Tr,DotSign,crntGamma);
        StCV     = fun_Kernel_M1(CV,Tr,DotSign,crntGamma);
        
        %         StC1    = fun_Kernel_M1(C1,Tr,DotSign,crntGamma);
        %         StC2    = fun_Kernel_M1(C2,Tr,DotSign,crntGamma);
        %         StC3    = fun_Kernel_M1(C3,Tr,DotSign,crntGamma);
        
        %% Train
        PosLabel = 1;
        NegLabel = -1;
        posclass = PosLabel;
        
        TrLabel = [PosLabel*ones(length(postr),1); NegLabel*ones(length(negtr),1)];
        if isequal(computer,'MACI64')
            MODEL=svmtrainXX(TrLabel,double(StTrain), ParVector); %mexa file for mac 64bit
        else
            MODEL=svmtrainX(TrLabel,double(StTrain), ParVector);  %assumed linux
            % If running on other operating system, mexa files from LibSVM
            % should be generated. Download LibSVM for Matlab from LibSVM
            % website.
        end
        SVr(k) = MODEL.totalSV/length(TrLabel);
        
        %% Train performance
        [ESTIMATES_Tr{k},Stat_Tr(k,:),~,~,~,~] = fun_STDsvmTest1(MODEL,postr,negtr,StTrain,PosLabel,NegLabel,posclass);
        
        %% CV performance
        [ESTIMATES_TsCV{k},Stat_CV(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,poscv,negcv,StCV,PosLabel,NegLabel,posclass);
        
        %% Test performance
        %         [ESTIMATES_TsC1{k},Stat_C1(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,posc1,negc1,StC1,PosLabel,NegLabel,posclass);
        %         [ESTIMATES_TsC2{k},Stat_C2(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,posc2,negc2,StC2,PosLabel,NegLabel,posclass);
        %         [ESTIMATES_TsC3{k},Stat_C3(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,posc3,negc3,StC3,PosLabel,NegLabel,posclass);
        
        %% Save results
        TIMEs(k,1)=toc;
        toc
        
        save(OutputFile,'crntC','crntGamma','-regexp','^ESTIMATES_','^Stat_',...
            'TIMEs','SVr','ParVector','-v7.3')
        
    end
end

%% Summary stats
[Summary , SummaryAUC] = fun_SummaryStatFilesNoC123( Paramters, [], [], ...
    OutputFileHeader, SumFile, []);