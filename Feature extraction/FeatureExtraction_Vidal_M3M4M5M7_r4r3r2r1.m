%FeatureExtraction_Vidal_M3M4M5M7_r4r3r2r1
% Process: Feature extraction with four randomizing feature schemes
% Data: Vidal dataset
% Framework: M3 and M4 (F3 and F4)
% Note: Features designed for M3 and M4 are used for M7 and M5, respectively
%10.10.2018

%Randomization schemes:
%r4: Shuffling each feature vector
%r3: Random numbers in the range of feature values
%r2: Features are extracted from a random sequence of a fixed length
%r1: Features are extracted from random sequences of lengths equal to the
%original proteins

clear
training_rounds = 10;

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))
addpath(genpath(cd))

%% Data
load Vidal2014Data.mat HORFv51_Seq HORFv51
NTSeq = HORFv51_Seq;
clear HORFv51_Seq

%% Convert NT to AA
Seq = cell(length(NTSeq),1);
for s = 1: length(NTSeq)
    s
    Seq{s} = nt2aa(NTSeq{s});
end

%% Features M3 - r4
load Features_M3_VidalHH.mat Features
Features_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    crnt = zeros(size(Features));
    for r=1:size(Features,1)
        crnt_row = Features(r,:);
        inx = randperm(length(crnt_row),length(crnt_row));
        crnt_row = crnt_row(inx);
        crnt(r,:) = crnt_row;
    end
    Features_Rand{R} = crnt;
    
end
clear Features
save  Features_M3_VidalHH_r4.mat Features_Rand
clear Features_Rand

%% Features M3 - r3
load Features_M3_VidalHH.mat Features
Features_Rand = cell(training_rounds,1);
cols = size(Features,2);
Range =[min(min(Features)), max(max(Features))];
for R = 1:training_rounds
    crnt = zeros(size(Features));
    for r=1:size(Features,1)
        crnt(r,:) =  Range(1) + (Range(2)-Range(1))*rand(1,cols); % spans all the feature space range
        % crnt(r,:) = rand(1,cols); Between 0 and 1
    end
    Features_Rand{R} = crnt;
end
clear Features
save  Features_M3_VidalHH_r3.mat Features_Rand
clear Features_Rand

%% Features M3 - r2
AvgLength = round(mean(cellfun(@length,Seq)))
Features_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    crnt=zeros(length(Seq),343);
    for s = 1:length(Seq)
        RandSeq = int2aa(randi(20,1,AvgLength));
        crnt(s,:) = fun_Shen1Seq_Org(RandSeq);
    end
    Features_Rand{R} = crnt;
end
save Features_M3_VidalHH_r2.mat Features_Rand AvgLength
clear Features_Rand Features_Rand

%% Features M3 - r1
Features_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    crnt=zeros(length(Seq),343);
    for s = 1:length(Seq)
        RandSeq = int2aa(randi(20,1,length(Seq{s})));
        crnt(s,:) = fun_Shen1Seq_Org(RandSeq);
    end
    Features_Rand{R} = crnt;
end
save Features_M3_VidalHH_r1.mat Features_Rand
clear Features_Rand Features_Rand



%%
%%
%% Features M4 - r4
load  Features_M4_VidalHH.mat Features
Features_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    crnt = zeros(size(Features));
    for r=1:size(Features,1)
        crnt_row = Features(r,:);
        inx = randperm(length(crnt_row),length(crnt_row));
        crnt_row = crnt_row(inx);
        crnt(r,:) = crnt_row;
    end
    Features_Rand{R} = crnt;
end
clear Features
save  Features_M4_VidalHH_r4.mat Features_Rand
clear Features_Rand

%% Features M4 - r3
load  Features_M4_VidalHH.mat Features
Features_Rand = cell(training_rounds,1);
cols = size(Features,2);
Range =[min(min(Features)), max(max(Features))];
for R = 1:training_rounds
    crnt = zeros(size(Features));
    for r=1:size(Features,1)
        crnt(r,:) =  Range(1) + (Range(2)-Range(1))*rand(1,cols); % spans all the feature space range
        % crnt(r,:) = rand(1,cols); Between 0 and 1
    end
    Features_Rand{R} = crnt;
    
end
clear Features
save  Features_M4_VidalHH_r3.mat Features_Rand
clear Features_Rand

%% Features M4 - r2
AvgLength = round(mean(cellfun(@length,Seq)))
LAGs = 30;
Features_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    RandSeq=cell(length(Seq),1);
    for s = 1:length(Seq)
        RandSeq{s} = int2aa(randi(20,1,AvgLength));
    end
    Features_Rand{R} = fun_FeaturesM4(RandSeq,LAGs);
end
clear Features
save  Features_M4_VidalHH_r2.mat Features_Rand AvgLength
clear Features_Rand

%% Features M4 - r1
LAGs = 30;
Features_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    RandSeq=cell(length(Seq),1);
    for s = 1:length(Seq)
        RandSeq{s} = int2aa(randi(20,1,length(Seq{s})));
    end
    Features_Rand{R} = fun_FeaturesM4(RandSeq,LAGs);
end
clear Features
save  Features_M4_VidalHH_r1.mat Features_Rand AvgLength
clear Features_Rand



