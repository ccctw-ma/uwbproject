
function [xTaylor,yTaylor] = taylorCalculateXY(Pos_X,Pos_Y,time)
    tdoaDataNodelay = time';
    meanTdoaData = [tdoaDataNodelay(1,2) - tdoaDataNodelay(1,1),tdoaDataNodelay(1,3) - tdoaDataNodelay(1,1),tdoaDataNodelay(1,4) - tdoaDataNodelay(1,1)];
    XQ = meanTdoaData';
    
    Q = zeros(3);
    for row = 1:3
        for col = 1:3
            rowSub = XQ(row) - meanTdoaData(row);
            colSub = XQ(col) - meanTdoaData(col);
            Q(row,col) = rowSub * colSub;
        end
    end

    Qeal = Q;
    delta = [10,10];
    xTaylor = Pos_X;
    yTaylor = Pos_Y;

    anchorPosition;

    while abs(delta(1))+abs(delta(2)) > 1e-6
        RTaylor21 = mean((tdoaDataNodelay(:,2) - tdoaDataNodelay(:,1)) * 0.3);
        RTaylor31 = mean((tdoaDataNodelay(:,3) - tdoaDataNodelay(:,1)) * 0.3);
        RTaylor41 = mean((tdoaDataNodelay(:,4) - tdoaDataNodelay(:,1)) * 0.3);

        BS = [Anchor1PosX,Anchor1PosY,0;Anchor2PosX,Anchor2PosY,0;Anchor3PosX,Anchor3PosY,0;Anchor4PosX,Anchor4PosY,0];
        X1Taylor = BS(1,1);
        Y1Taylor = BS(1,2);
        X2Taylor = BS(2,1);
        Y2Taylor = BS(2,2);
        X3Taylor = BS(3,1);
        Y3Taylor = BS(3,2);
        X4Taylor = BS(4,1);
        Y4Taylor = BS(5,2);

        R1Taylor = sqrt(power(X1Taylor-xTaylor,2) + power(Y1Taylor-yTaylor,2));
        R2Taylor = sqrt(power(X2Taylor-xTaylor,2) + power(Y2Taylor-yTaylor,2));
        R3Taylor = sqrt(power(X3Taylor-xTaylor,2) + power(Y3Taylor-yTaylor,2));
        R4Taylor = sqrt(power(X4Taylor-xTaylor,2) + power(Y4Taylor-yTaylor,2));
    
        hTaylor = [RTaylor21 - (R2Taylor - R1Taylor);RTaylor31 - (R3Taylor - R1Taylor);RTaylor41 - (R4Taylor - R1Taylor)];
        GTaylor = [(X1Taylor - xTaylor) / R1Taylor - (X2Taylor - xTaylor) / R2Taylor, (Y1Taylor - yTaylor) / R1Taylor - (Y2Taylor - yTaylor) / R2Taylor;(X1Taylor - xTaylor) / R1Taylor - (X3Taylor - xTaylor) / R3Taylor, (Y1Taylor - yTaylor) / R1Taylor - (Y3Taylor - yTaylor) / R3Taylor;(X1Taylor - xTaylor) / R1Taylor - (X4Taylor - xTaylor) / R4Taylor, (Y1Taylor - yTaylor) / R1Taylor - (Y4Taylor - yTaylor) / R4Taylor];
        QStubMat = eye(3);
        QTaylor = QStubMat;
        GTranspose = GTaylor';
        QInverse = inv(QTaylor);
        res = GTranspose * QInverse * GTaylor;
        
        if rank(res) < size(res,1)
            return;
        end

        debugMatrix1 = inv(res);
        debugMatrix2 = debugMatrix1 * GTaylor';
        debugMatrix3 = debugMatrix2 * inv(QTaylor);
        deltaMatrix = debugMatrix3 * hTaylor;
        delta = [deltaMatrix(1,1),deltaMatrix(2,1)];

        if abs(delta(1))+abs(delta(2)) > 1e-6
            xTaylor = xTaylor + delta(1);
            yTaylor = yTaylor + delta(2);
        end

    end
    
    calcFlag = 1;

end

