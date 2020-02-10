%FeatureExtraction_Pan_M6_STEP2
% Process: Compute distance between dataset proteins and the domain profiles
% to accelerate kernel calculations
% Data: Pan dataset
% Framework: M6
%10.31.2018

% Kernel designed for M6: 
% K(x,y)=exp(gamma||x - y||2)
% K'(AB,CD) = min(K(A,C)+K(B,D), K(A,D)+K(B,C))

clear 

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))
addpath(genpath(cd))

%% Data
load Pan_Featurespfam.mat Scores
load PanUni.mat PanUni Hs

%% Calculate distance 
tic 
ZscoreS = zscore(Scores);
toc
DistSign = pdist2(ZscoreS,ZscoreS);
toc

%% save 
save Features_M6_PanHH.mat DistSign PanUni Hs  -v7.3 
