function ACserial=fun_FeaturesM4(Seq,LAGs)
%fun_FeaturesM4 extracts oritein features as implemented in Guo2008
%Autocovariates of the AA 7 physicochemical properties

load AAproperties AAordered AApropNormOrdered Properties
Js=7;

ACserial=zeros(length(Seq),Js*LAGs);
for s=1:length(Seq)
    s
    crntSeq=Seq{s};
    n=length(crntSeq);
    crntSeqNum=aa2int(crntSeq);
    
    try
        X=(AApropNormOrdered(crntSeqNum,:))';        
    catch
        % Action: remove the undfied AA
        inx=find(crntSeqNum<1 | crntSeqNum>20);
        crntSeqNum(inx)=[];
        X=(AApropNormOrdered(crntSeqNum,:))';
        n=length(crntSeqNum);
    end
    
    XijMeanJ=mean(X,2);
    AC=zeros(Js,LAGs);
    
    for lag=1:LAGs
        XijSumlag=sum(X(:,1:n-lag),2);
        XiSumpluslag=sum(X(:,lag+1:end),2);
        
        Sum1=XijSumlag- ((n-lag)*XijMeanJ);
        Sum2=XiSumpluslag - ((n-lag)*XijMeanJ);
        AC(:,lag)=(1/(n-lag)).*Sum1.*Sum2; 
    end
    
    ACserial(s,:)=reshape(AC',1,Js*LAGs);
    
end

end