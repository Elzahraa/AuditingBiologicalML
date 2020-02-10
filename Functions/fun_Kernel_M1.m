function K=fun_Kernel_M1(Ts_Row,Tr_Col,DotSign,Gamma)
%fun_Kernel_M1 calculates signature kernel matrix for M1

K=zeros(size(Ts_Row,1),size(Tr_Col,1));
for r=1:size(Ts_Row,1)
    A=Ts_Row(r,1);
    B=Ts_Row(r,2);
    
    for c=1:size(Tr_Col,1)
        C=Tr_Col(c,1);
        D=Tr_Col(c,2);
        K(r,c)= exp(-Gamma*(kbar(A,B,A,B,DotSign) + kbar(C,D,C,D,DotSign) - 2*kbar(A,B,C,D,DotSign)  ));
    end
end

%% Add example index (required for precomputed kernels in LibSVM)
K=[[1:size(Ts_Row,1)]',K];

end

function Kb=kbar(A,B,C,D,DotSign)
Kb=2*((normK(A,C,DotSign)*normK(B,D,DotSign))+(normK(A,D,DotSign)*normK(B,C,DotSign)));
end

function KAC=normK(A,C,DotSign)
KAC=DotSign(A, C)/sqrt(DotSign(A, A)*DotSign(C, C));
end

