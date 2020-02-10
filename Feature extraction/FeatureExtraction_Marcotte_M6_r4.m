%FeatureExtraction_Marcotte_M6_r4
% Process: Feature extraction with randomization scheme r4
% Data: Marcotte dataset
% Framework: M6 (F6)
%11.05.2018

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
load DomainProfiles_HH_Marcotte.mat Scores
Scores_Original = Scores;
clear Scores

%% Dot signatures
DistSign_Rand = cell(training_rounds,1);
Times = tic;
for R = 1:training_rounds
    R
    % Randomize Scores
    crnt = zeros(size(Scores_Original));
    for r=1:size(Scores_Original,1)
        crnt_row = Scores_Original(r,:);
        inx = randperm(length(crnt_row),length(crnt_row));
        crnt_row = crnt_row(inx);
        crnt(r,:) = crnt_row;
    end
    Scores =crnt;
    
    % Scaling
    ZscoreS = zscore(Scores);
    
    % Generate DotSign
    tic
    DistSign = pdist2(ZscoreS,ZscoreS);
    toc
    DistSign_Rand{R} = DistSign;
    
    % Periodic saving
    save  Features_M6_MarcotteHH_r4.mat DistSign_Rand -v7.3
end
Times = toc(Times)

save  Features_M6_MarcotteHH_r4.mat DistSign_Rand Times -v7.3
