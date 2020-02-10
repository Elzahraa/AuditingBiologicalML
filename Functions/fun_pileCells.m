function Pile = fun_pileCells( Cells )
%fun_pileCells piles the content of all the cells below each other.

Pile=[];
for k = 1:length(Cells)
    try
        Pile = [Pile; Cells{k}];
    catch
        pause
    end
end

end

