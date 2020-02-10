function FeatureVect= fun_ProteinSignature(Seq,COMB)
%fun_ProteinSignature extracts protien signature feature vectors as described in:
%"Martin, S., Roe, D., & Faulon, J. L. (2005). Predicting protein?protein
%interactions using signature products. Bioinformatics, 21(2), 218-226."

%% Prepare sequences
k=size(COMB,2);
SeqN=aa2int(Seq);
List=zeros(length(SeqN)-k+1,k);
for L=1:size(List,1)
    List(L,:)=SeqN(L:L+k-1);
end
ListSorted=[List(:,1),sort(List(:,2:end),2)];

%% Counting
FeatureVect=zeros(1,size(COMB,1));
for v=1:size(COMB,1)
    FeatureVect(v)= fun_FreqMer(ListSorted,COMB(v,:));
end

end

function Freq=fun_FreqMer(List,mer)
% designed for 3-mer
Freq=length(find(List(:,1)==mer(1)&List(:,2)==mer(2)&List(:,3)==mer(3)));
end


