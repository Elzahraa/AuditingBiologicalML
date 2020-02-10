function Paramters = fun_multiplex(varargin)
%fun_multiplex creates all combinations out of all members in the lists
%passed

N = nargin;

Par1 = varargin{1};
Par2 = varargin{2};

if N ==2
    Paramters= zeros(length(Par1)*length(Par2),2);
    pointer = 0;
    for p1=1:length(Par1)
        for p2 = 1: length(Par2)
            pointer = pointer +1;
            Paramters(pointer,:)= [Par1(p1), Par2(p2)];
            
        end
    end
    
    
elseif N == 3
    Par3 = varargin{3};
    Paramters= zeros(length(Par1)*length(Par2)*length(Par3),3);
    pointer = 0;
    for p1=1:length(Par1)
        for p2 = 1: length(Par2)
            for p3 = 1: length(Par3)
                pointer = pointer +1;
                Paramters(pointer,:)= [Par1(p1), Par2(p2), Par3(p3)];
            end
        end
    end
end

end