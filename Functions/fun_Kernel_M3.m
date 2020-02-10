function K=fun_Kernel_M3(u,v,Gamma,Features)
%fun_Kernel_M3 calculates signature kernel matrix for M3

% Convert from indecies to features (sigantures)
u=[Features(u(:,1),:), Features(u(:,2),:)];
v=[Features(v(:,1),:), Features(v(:,2),:)];

% Kernel
Da=u(:,1:size(u,2)/2);
De=v(:,1:size(v,2)/2);
Db=u(:,1+size(u,2)/2:end);
Df=v(:,1+size(v,2)/2:end);

s1=(pdist2(Da,De)).^2 + (pdist2(Db,Df)).^2;
m=size(s1,1);
n=size(s1,2);
s2=(pdist2(Da,Df)).^2 + (pdist2(Db,De)).^2;
s=min([s1(:),s2(:)],[],2);
S=reshape(s,m,n);
K=exp(-Gamma*(S.^2));

%% Add example index (required for precomputed kernels in LibSVM)
K=[[1:size(K,1)]',K];

end



