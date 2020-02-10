%FeatureExtraction_Pan_M1M2_r3
% Process: Feature extraction with randomization scheme r3
% Data: Pan dataset
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
load PanHH_Signature Signature
Signature_Original = Signature;
clear Signature

%% Dot signatures
cols = size(Signature_Original,2);
Range =[min(min(Signature_Original)), max(max(Signature_Original))];
MT= tic;

DotSign_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    R
    % Randomize signature
    crnt = zeros(size(Signature_Original));
    for r=1:size(Signature_Original,1)
        crnt(r,:) =  Range(1) + (Range(2)-Range(1))*rand(1,cols); % spans all the feature space range
        % crnt(r,:) = rand(1,cols); Between 0 and 1
    end
    Signature =crnt;
    
    % Generate DotSign
    DotSign=zeros(size(Signature,1));
    tic
    parfor s1=1:size(Signature,1)
        s1
        DotSign(:,s1)=dot(repmat(Signature(s1,:),size(Signature,1),1),Signature,2);
    end
    toc
    DotSign_Rand{R} = DotSign;
    MajorTime = toc(MT)
    
    % Periodic saving
    save  Features_M1_PanHH_r3.mat DotSign_Rand MajorTime -v7.3
    
end