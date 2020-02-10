function K = fun_Kernel_M6(Ts_Row,Tr_Col,DistSign,Gamma)
%fun_Kernel_M6 calculates signature kernel matrix for M6

K=zeros(size(Ts_Row,1),size(Tr_Col,1));
for r=1:size(Ts_Row,1)
    A=Ts_Row(r,1);
    B=Ts_Row(r,2);
    
    for c=1:size(Tr_Col,1)
        C=Tr_Col(c,1);
        D=Tr_Col(c,2);
        K(r,c)= exp( - Gamma*(min(  DistSign(A,C)* DistSign(B,D) , ...
            DistSign(A,D)* DistSign(B,C))));
    end
end

%% Add example index (required for precomputed kernels in LibSVM)
K=[[1:size(Ts_Row,1)]',K];

end