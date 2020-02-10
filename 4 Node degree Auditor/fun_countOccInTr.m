function inPOStr12NEGtr12=fun_countOccInTr(POStr,NEGtr,List)
%fun_countOccInTr counts frequency of each protein in a list of PPI pairs
% 02.17.2018

inPOStr12NEGtr12=zeros(size(List,1),4);

for t=1:size(List,1)
   
    inPOStr12NEGtr12(t,1)=length(find(POStr(:)==List(t,1)));
    inPOStr12NEGtr12(t,2)=length(find(POStr(:)==List(t,2)));
    inPOStr12NEGtr12(t,3)=length(find(NEGtr(:)==List(t,1)));
    inPOStr12NEGtr12(t,4)=length(find(NEGtr(:)==List(t,2)));
end

end
