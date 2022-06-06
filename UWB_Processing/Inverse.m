
function Matrix = Inverse(matrix)
    n = size(matrix,1);
    Expd = eye(n);
    
    for i = 1:n
        max = matrix(i,i);
        k=i;
        for j = i+1:n
            if abs(matrix(j,i)) > abs(max)
                max = matrix(j,i);
                k = j;
            end
        end
        if k~=i
            for j = 1:n
                tem = matrix(i,j);
				matrix(i,j) = matrix(k,j);
				matrix(k,j) = tem;
				tem = Expd(i,j);
				Expd(i,j) = Expd(k,j);
				Expd(k,j) = tem;
            end
        end
%         if matrix(i,i) == 0
%             return;
%         end
        tem = matrix(i,i);
        for j = 1:n
            matrix(i,j) = matrix(i,j) / tem;
			Expd(i,j) = Expd(i,j) / tem; 
        end
        for j =1:n
            if j~=i
                tem = matrix(j,i);
                for k = 1:n
                    matrix(j,k) = matrix(j,k) - matrix(i,k) * tem;
					Expd(j,k) = Expd(j,k) - Expd(i,k) * tem;
                end
            end
        end
    end
    Matrix = Expd;

end

