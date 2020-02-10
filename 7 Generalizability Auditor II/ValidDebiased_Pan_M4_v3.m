%ValidDebiased_Pan_M4_v3
% Process: Generalizability Auditor II
% Data: Pan dataset
% Framework: M4 (F4)
% Manipulation: (1) Training data is debiased; (2) Testing on independent
% examples from Vidal dataset, yet the test examples follow the in-network
% criteria (C1) w.r.t. the training examples
%05.11.2019


clear
training_rounds = 10;

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))

%% Training balanced data
load PanHH_Balancedreduced.mat POStr POSCV POSts NEGtr NEGCV NEGts %sequence redundancy reduced

%% Testing data
load Valid_Panv3_balanced.mat TestPos TestNeg

%% Output
TKs='18';
TaskTitle='Validation3Debiased';
Model='M4';
Dataset='PanHH';
OutputFileHeader=['TK',TKs,'_',TaskTitle,'_', Model,'_', Dataset]

%% Parameter search space
Cs=[100,10, 1]';
Gammas=[0.1,0.01,0.001,0.0001,0.00001]';
Paramters=[];
for c=1:length(Cs)
    Paramters=[Paramters;repmat(Cs(c),size(Gammas)),Gammas];
end

%% Features
load Features_M4_PanHH.mat Features

%% Load the optimized model parameters
SumFileIn=['TK', num2str('01'),'Summary','_','ParamterOpt','_', Model,'_', Dataset]
load(SumFileIn)
[~,BestPar] = max(SummaryAUC.CVAUC);

%% Validation rounds
for paramterSet=BestPar
    paramterSet
    crntC = Paramters(paramterSet,1);
    crntGamma = Paramters(paramterSet,2);
    ParVector=['-c ',num2str(crntC),'  -t 2 -s 0 -h  0  -m 10000 -g ', num2str(crntGamma) ]; %-t 2: Gaussian kernel
    
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
        [StTrain,StCV,~,~] = fun_Standarize_TrTs_MSD(...
            [CrntPosMatTr;CrntNegMatTr],[CrntPosMatCV;CrntNegMatCV]);
        
        % Non-standardized
        % StTrain=[CrntPosMatTr;CrntNegMatTr];
        % StCV=[CrntPosMatCV;CrntNegMatCV];
        
        % C1
        CrntPosMatC1=[Features(posc1(:,1),:),...
            Features(posc1(:,2),:)];
        CrntNegMatC1=[Features(negc1(:,1),:),...
            Features(negc1(:,2),:)];
        [~,StC1,~,~] = fun_Standarize_TrTs_MSD(...
            [CrntPosMatTr;CrntNegMatTr],[CrntPosMatC1;CrntNegMatC1]);
        %
        %              %C2
        %         CrntPosMatC2=[Features(posc2(:,1),:),...
        %             Features(posc2(:,2),:)];
        %         CrntNegMatC2=[Features(negc2(:,1),:),...
        %             Features(negc2(:,2),:)];
        %             [~,StC2,~,~] = fun_Standarize_TrTs_MSD(...
        %                  [CrntPosMatTr;CrntNegMatTr],[CrntPosMatC2;CrntNegMatC2]);
        %
        %             %C4
        %         CrntPosMatC3=[Features(posc3(:,1),:),...
        %             Features(posc3(:,2),:)];
        %         CrntNegMatC3=[Features(negc3(:,1),:),...
        %             Features(negc3(:,2),:)];
        %             [~,StC3,~,~] = fun_Standarize_TrTs_MSD(...
        %                  [CrntPosMatTr;CrntNegMatTr],[CrntPosMatC3;CrntNegMatC3]);
        
        
        % independent test
        if ~isempty(posts)
            CrntPosMatTs=[Features(posts(:,1),:),...
                Features(posts(:,2),:)];
            CrntNegMatTs=[Features(negts(:,1),:),...
                Features(negts(:,2),:)];
            
            % Standardized
            [~,StTs,~,~] = fun_Standarize_TrTs_MSD(...
                [CrntPosMatTr;CrntNegMatTr],[CrntPosMatTs;CrntNegMatTs]);
        end
        
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
        [ESTIMATES_TsC1{k},Stat_C1(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,posc1,negc1,StC1,PosLabel,NegLabel,posclass);
        %         [ESTIMATES_TsC2{k},Stat_C2(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,posc2,negc2,StC2,PosLabel,NegLabel,posclass);
        %         [ESTIMATES_TsC3{k},Stat_C3(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,posc3,negc3,StC3,PosLabel,NegLabel,posclass);
        %
        
        %% Independent test performance
        if ~isempty(posts)
            [ESTIMATES_Ts{k},Stat_Ts(k,:),~,~,~,~ ] = fun_STDsvmTest1(MODEL,posts,negts,StTs,PosLabel,NegLabel,posclass);
        end
        
        %% Save results
        TIMEs(k,1)=toc;
        toc
        
        save(OutputFile,'crntC','crntGamma','-regexp','^ESTIMATES_','^Stat_',...
            'TIMEs','SVr','ParVector','-v7.3')
        
    end
end

