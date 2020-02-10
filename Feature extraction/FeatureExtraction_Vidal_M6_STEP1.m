%FeatureExtraction_Vidal_M6_STEP1
% Process: Prepare protein domain features
% Data: Vidal dataset
% Framework: M6
%10.03.2018


clear
%WorkerCount = 15;

%% Data
load Vidal2014Data HORFv51_Seq
NTSeq = HORFv51_Seq;
clear HORFv51_Seq

%% Convert Vidal NT into AA
Seq = cell(length(NTSeq),1);
for s = 1: length(NTSeq)
    %s
    Seq{s} = nt2aa(NTSeq{s});
end

%% Protein domain HMMs
fprintf('\n Get list of HMMs from pfam website. \n')
fprintf('\n Download pfam-A.hmm from Pfam/current_release. \n')
fprintf('\n Extract the HMM names, then delete the big file. \n')
fprintf('\n HMM preparation: Run pfam_HMM.m \n')
load pfam_HMMs.mat HMM_names
load pfam_HMMs.mat HMM_models

%% Domain features
Scores=zeros(length(Seq) ,length(HMM_names)) ;
%parpool(WorkerCount)
for N=1:length(HMM_names)
    N
    tic
    % Read into Matlab structure
    model = HMM_models{N};
    
    % Compare
    crntScores = zeros(length(Seq) ,1);
    for s=1:length(Seq)
        %s
        % Account for abnormal AAs
        SS=Seq{s};
        SSint = aa2int(SS);
        inx = find(SSint<1 | SSint>20);
        SS(inx)=[];
        crntScores(s,1)=hmmprofalign(model,SS);
    end
    Scores(:,N) = crntScores;
    toc
    
    % periodic saving
    if mod(N,100)==0
        % save every 100 protein
        save Vidal_Featurespfam.mat Scores
    end
end


