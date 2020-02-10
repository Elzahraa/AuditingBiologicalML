%FeatureExtraction_Vidal_M1M2_r2
% Process: Feature extraction with randomization scheme r2
% Data: Vidal dataset
% Framework: M1 (F1)
% Note: Features designed for M1 are used for M2
%11.21.2018

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
Org_Seq = Seq;

%% Convert NT 2AA
Seq = cell(length(NTSeq),1);
for s = 1: length(NTSeq)
    
    Seq{s} = nt2aa(NTSeq{s});
end

%% Combinations
COMB=[];
cmb=nchoosek([1:20],2);
Doubles=[1:20;1:20]';
cmb=[Doubles;cmb];
for A=1:20
    COMB=[COMB;repmat(A,size(cmb,1),1),cmb];
end

%% Signatures and dot signatures
MajorTime1 = tic;
DotSign_Rand = cell(training_rounds,1);
AvgLength = round(mean(cellfun(@length,Seq)))

for R = 1:training_rounds
    R
    % Random sequence
    Seq=cell(length(Org_Seq),1);
    for s = 1:length(Seq)
        Seq{s} = int2aa(randi(20,1,AvgLength));
    end
    
    % Signatures
    Signature=single(zeros(length(Seq),length(COMB)));
    for s=1:length(Seq)
        
        Signature(s,:)=fun_ProteinSignature(Seq{s},COMB);
    end
    
    % Dot signature
    DotSign=zeros(size(Signature,1));
    tic
    parfor s1=1:size(Signature,1)
        
        DotSign(:,s1)=dot(repmat(Signature(s1,:),size(Signature,1),1),Signature,2);
    end
    toc
    DotSign_Rand{R} = DotSign;
    MajorTime = toc(MajorTime1)
    
    % Periodic saving
    save  Features_M1_VidalHH_r2.mat DotSign_Rand -v7.3 AvgLength MajorTime
    
end