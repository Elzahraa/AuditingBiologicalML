%Node Degree Auditor Result
%08.22.2019

clear

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))

%% Paramters
PosLabel = 1;
NegLabel = -1;
posclass = PosLabel;
Paramters = [15, 10, 15, 15, 144, 15, 35];
ParamtersM7 = [1:5, 16:20];
ParamtersM5 = [3,9,15,21,27,33,39,45,51,57,63,69,75,81,87,93,99,105,111,117];
Ks = 10*ones(7,1);
Symmetric = [1, 1, 1, 0, 0, 1, 0];
Datasets = {'Marcotte','Vidal','Pan'};

%% Idenitfy best model for each dataset and retrive its performance
BestInD_m_p = zeros(3,2);
for D = 1:3
    M_AucCV = [] ;
    for M = 1:7
        Flag =  1;
        p = 0;
        while Flag
            p = p+1;
            if p> Paramters(M)
                Flag = 0;
            end
            try
                % Account for the reduction in paratmers for M5 and M7
                if (M~=5 & M~=7) | ...
                        M==5 & ~isempty(find(ParamtersM5==p)) | ...
                        (M==7 & ~isempty(find(ParamtersM7==p)))
                    
                    Regular_File = ['TK01_ParamterOpt_M',num2str(M) ,'_',Datasets{D},'HH_',num2str(p),'.mat'];
                    load(Regular_File,'Stat_CV')
                    crnt_AUC_CV = Stat_CV(:,6);
                    M_AucCV(p,M) = mean(crnt_AUC_CV);
                end
                
            catch
                Flag = 0;
            end
        end
        
    end
    
    [best_auc, inx ] = max(M_AucCV(:));
    m_tmp = floor(inx/size(M_AucCV,1))+1;
    p_tmp = mod(inx, size(M_AucCV,1));
    if p_tmp==0
        m_tmp=m_tmp-1;
        p_tmp = size(M_AucCV,1);
    end
    
    BestInD_m_p(D,1) = m_tmp;
    BestAUC(D,1) = best_auc;
    
    BestInD_m_p(D,2) = p_tmp;
end

%% Node degree auditing
load NodeDegreeLearning.mat AUCcv
NodeDegreeLearningAUC = mean(AUCcv, 2);
% Difference in AUC between best model for a dataset and the model that
% learned from the node degree features for that dataset
DiffAUC = BestAUC - NodeDegreeLearningAUC

%% save results
save NodeDegreeAuditorResults.mat NodeDegreeLearningAUC BestAUC DiffAUC
