%FeatureExtraction_Vidal_M3M4M5M7
% Process: Feature extraction
% Data: Pan dataset
% Framework: M3 and M4 (F3 and F4)
% Note: Features designed for M3 and M4 are used for M7 and M5, respectively
% 10.02.2018


clear

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

%% Features M3 (and M7)
Features=zeros(length(Seq),343);
for s = 1:length(Seq)
    s
    Features(s,:) = fun_Shen1Seq_Org(Seq{s});
end
save Features_M3_VidalHH.mat Features HORFv51

%% Features M4 (and M5)
clear Features
LAGs = 30;
Features=fun_FeaturesM4(Seq,LAGs);
save Features_M4_VidalHH.mat Features HORFv51
