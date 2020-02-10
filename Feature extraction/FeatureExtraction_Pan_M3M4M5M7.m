%FeatureExtraction_Pan_M3M4M5M7
% Process: Feature extraction
% Data: Pan dataset
% Framework: M3 and M4 (F3 and F4)
% Note: Features designed for M3 and M4 are used for M7 and M5, respectively
% 07/16/2018


clear

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))
addpath(genpath(cd))

%% Features M3 (and M7)
load PanData.mat Hs Seq
Features=zeros(length(Seq),343);
for s = 1:length(Seq)
    Features(s,:) = fun_Shen1Seq_Org(Seq{s});
end
save Features_M3_PanData.mat Features Hs
clear Features

%% Features M4 (and M5)
load PanData.mat Hs Seq
LAGs = 30;
Features=fun_FeaturesM4(Seq,LAGs);
save Features_M4_PanData.mat Features Hs
