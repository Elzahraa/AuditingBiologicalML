function F_Vseq_norm= fun_Shen1Seq_Org(Seq)
%fun_Shen1Seq_Org extracts features as explained in Shen2007 (M3)

%% Paramters 
ShenAA={'AVG', 'ILFP', 'YMTS', 'HNQW', 'RK','DE','C'};
Norm_Type='Shen Original';
AA_class=ShenAA;
AA_class_n=7;
kmer=3;

%% AA mapping into one of the 7 AA groups 
CrntVpSeq=Seq;
CrntVp_mapedSeq=zeros(length(CrntVpSeq),1);
for n=1:length(CrntVpSeq)
    for AAc=1:AA_class_n
        if ~isempty(strfind(AA_class{AAc},CrntVpSeq(n)))
            CrntVp_mapedSeq(n)=AAc;
        end
    end
end
Vp_mapedSeq=CrntVp_mapedSeq;

%% Generating all k-mer combinations
Kmers_comb=cell(AA_class_n^kmer,1);
kmer_Mat=unique(combnk(repmat([1:AA_class_n]',kmer,1),kmer),'rows'); %#ok<*NBRAK>
if kmer==1
    kmer_Mat=kmer_Mat';
end
for Trip=1:size(Kmers_comb,1)
    for k=1:kmer
        Kmers_comb{Trip,1}(k,1)=int2str(kmer_Mat(Trip,k));
    end
    Kmers_comb{Trip,1}=Kmers_comb{Trip,1}';
end

%% Counting
F_Vseq=zeros(1,AA_class_n^kmer);
CrntVp_mapedSeq=Vp_mapedSeq;
String_Vseq=(int2str(CrntVp_mapedSeq))';
for t=1:length(Kmers_comb)% =AA_class_n^kmer
    F_Vseq(1,t)=length(strfind(String_Vseq,Kmers_comb{t,1}));
end

%% Normalization
% Ciu2012: di={fi-min(f)/e^(max(f)-min(f))}  -1
% Shen2007: di=fi-min(f)/(max(f)-min(f))
F_Vseq_norm=NormalizeSVM(Norm_Type,F_Vseq);

end

function Fnorm=NormalizeSVM(Norm_Type,F)
if strcmp(Norm_Type,'Cui')
    Fnorm=((F-min(F))/exp(max(F)-min(F)))-1;
elseif strcmp(Norm_Type,'Shen')
    Fnorm=(F-min(F))/(max(F)-min(F));
elseif strcmp(Norm_Type,'None')
    Fnorm=F;
elseif strcmp(Norm_Type,'Shen Original')
    Fnorm=(F-min(F))/(max(F));
end
end