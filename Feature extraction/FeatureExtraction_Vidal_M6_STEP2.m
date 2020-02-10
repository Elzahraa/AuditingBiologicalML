%FeatureExtraction_Vidal_M6_STEP2
% Process: Compute distance between dataset proteins and the domain profiles
% to accelerate kernel calculations
% Data: Vidal dataset
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
load Vidal_Featurespfam.mat Scores
load Vidal2014Data.mat HORFv51 

%% Calculate distance 
tic 
ZscoreS = zscore(Scores);
toc
DistSign = pdist2(ZscoreS,ZscoreS);
toc

%% save 
save Features_M6_VidalHH.mat DistSign HORFv51  -v7.3 