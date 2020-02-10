%Recurrence Scoring Function
%02.07.2019

clear
training_rounds = 10;

%% Add data and function paths
crnt_dir = pwd;
parent_dir = crnt_dir(1:(find(crnt_dir==crnt_dir(1),1,'last'))-1);
addpath(genpath(parent_dir))

%% Run experiment 
AUC_cv = zeros(10,5);
pointer = 0;

for d=[1,2,4]
    pointer = pointer + 1;
    figure;
    clear POStr NEGtr POSCV NEGCV
    
    %% Load dataset d
    if d==1
        % Dataset 1: Marcotte
        load MarcotteHH.mat
        
    elseif d==2
        % Dataset 2: Vidal with redundancy reduction
        load VidalHH_RedRed.mat
        NEGtr = NEGtrR;
        
    elseif d ==5
        % Dataset 5: Vidal without redundancy reduction (Ignore)
        load VidalHH.mat
        NEGtr = NEGtrR;
        
        
    elseif d==3
        % Dataset 3: Pan without redundancy reduction (Ignore)
        load PanHH.mat
        
        
    elseif d==4
        % Dataset 4: Pan with redundancy reduction
        load PanHH_reduced.mat
        POSCV = POScv;
        NEGCV = NEGcv;
    end
    
    %% Scoring function
    
    for k=1:10
        postr=[POStr{k}];
        negtr=[NEGtr{k}];
        
        poscv=POSCV{k};
        negcv=NEGCV{k};
        CV= [poscv;negcv];
        
        CVCounts = zeros(length(CV),4);
        
        for p=1:length(CV)
            
            CVCounts(p,1) = length(find(postr==CV(p,1)));
            CVCounts(p,2) = length(find(postr==CV(p,2)));
            CVCounts(p,3) = length(find(negtr==CV(p,1)));
            CVCounts(p,4) = length(find(negtr==CV(p,2)));
            
        end
        
        %% Scoring function (PosCount / PosCount+NegCount)
        ScoreCV{pointer,k} = (CVCounts(:,1) + CVCounts(:,2))./sum(CVCounts,2);
        
        %%  Assess performance of the scoring function
        
        Labels{pointer,k} = [ones(length(poscv),1);zeros(length(negcv),1)];
        [X,Y,T,AUC_cv(k,pointer) ,OP]=perfcurve(Labels{pointer,k}, ScoreCV{pointer,k}, 1);
        
        plot(X,Y)
        hold on
        
    end
    
    %% Figure labels 
    title(['Scoring function | Recurrence Auditor | Dataset ',num2str(pointer)])
    xlabel('False positive rate')
    ylabel('True positive rate')
end

%% Results
RecurrenceAUC = mean(AUC_cv);
RecurrenceAUC = RecurrenceAUC(1:3); 

RecurrenceAUC_Data1 = RecurrenceAUC(1)
RecurrenceAUC_Data2 = RecurrenceAUC(2)
RecurrenceAUC_Data3 = RecurrenceAUC(3)



save SoringFunctionResult.mat RecurrenceAUC ScoreCV Labels
