%FeatureExtraction_Vidal_M1M2_STEP2
% Process: Prepare dot products of protein signatures to accelerate kernel
% calculations
% Data: Vidal dataset
% Framework: M1 (F1)
% Note: Features designed for M1 are used for M2
% 10.02.2018

clear

%% Data
load VidalHH_Signature.mat Signature

%% Dot signatures
DotSign=single(zeros(size(Signature,1)));
tic
parfor s1=1:size(Signature,1)
    s1
    DotSign(:,s1)=dot(repmat(Signature(s1,:),size(Signature,1),1),Signature,2);
end
toc
DotSign=single(DotSign);
save Vidal_Signature_Dot.mat DotSign  -v7.3
save Features_M1_VidalHH DotSign  -v7.3