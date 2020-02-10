%FeatureExtraction_Pan_M1M2_STEP2
% Process: Prepare dot products of protein signatures to accelerate kernel
% calculations 
% Data: Pan dataset
% Framework: M1 (F1)
% Note: Features designed for M1 are used for M2
% 10.04.2018

clear

%% Data 
load PanHH_Signature.mat Signature

%% Dot signatures
DotSign=single(zeros(size(Signature,1)));
tic
parfor s1=1:size(Signature,1)
    s1
    DotSign(:,s1)=dot(repmat(Signature(s1,:),size(Signature,1),1),Signature,2);
end
toc
DotSign=single(DotSign);
save Pan_Signature_Dot.mat DotSign  -v7.3 
save Features_M1_PanHH DotSign  -v7.3 