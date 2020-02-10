%pfam_HMM
% Process: Parse pfam HMMs to extract their names and models
%01.23.2018


clear
tic

%% Data
% Donwload Pfam-A.hmm from pfam (a large file, remove it after parsing)
fileID=fopen('Pfam-A.hmm')
C = textscan(fileID,'%s %s');
fclose(fileID)

%% Parse for HMM names
FirstCol=C{1};
SecondCol=C{2};
clear C
inx=find(strcmp(FirstCol,'NAME'));
clear FirstCol
HMM_names=SecondCol(inx);
clear SecondCol

%% save HMM names
toc
save pfam_HMMs.mat HMM_names

%% HMM models
tic
HMM_models=cell(length(HMM_names),1);
for N=1:length(HMM_names)
    N
    HMM_models{N}= gethmmprof(HMM_names{N});
end
toc

%% save HMM models
save pfam_HMMs.mat HMM_models -append

