%FeatureExtraction_Pan_M1M2_STEP1
% Process: Prepare protein sequence signatures
% Data: Pan dataset
% Framework: M1 (F1)
% Note: Features designed for M1 are used for M2
% 10.04.2018

clear 

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))

%% Data
load PanHH.mat Seq

%% Combinations
COMB=[];
cmb=nchoosek([1:20],2);
Doubles=[1:20;1:20]';
cmb=[Doubles;cmb];
for A=1:20
    COMB=[COMB;repmat(A,size(cmb,1),1),cmb];
end

%% Signatures 
Signature=single(zeros(length(Seq),length(COMB)));
for s=1:length(Seq)
    s
    Signature(s,:)=fun_ProteinSignature(Seq{s},COMB);
end
save PanHH_Signature.mat Signature



