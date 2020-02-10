%FeatureExtraction_Vidal_M1M2_r4
% Process: Feature extraction with randomization scheme r4
% Data: Vidal dataset
% Framework: M1 (F1)
% Note: Features designed for M1 are used for M2
%11.04.2018

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

%% Convert NT 2 AA
Seq = cell(length(NTSeq),1);
for s = 1: length(NTSeq)
    
    Seq{s} = nt2aa(NTSeq{s});
end

%% Dot signatures
load VidalHH_Signature Signature
Signature_Original = Signature;
clear Signature

DotSign_Rand = cell(training_rounds,1);
for R = 1:training_rounds
    R
    %Randomize signature
    crnt = zeros(size(Signature_Original));
    for r=1:size(Signature_Original,1)
        crnt_row = Signature_Original(r,:);
        inx = randperm(length(crnt_row),length(crnt_row));
        crnt_row = crnt_row(inx);
        crnt(r,:) = crnt_row;
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
    
    % Periodic saving
    save  Features_M1_VidalHH_r4.mat DotSign_Rand -v7.3
    
end


