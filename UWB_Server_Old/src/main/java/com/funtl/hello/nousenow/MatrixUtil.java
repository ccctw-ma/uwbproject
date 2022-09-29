package com.funtl.hello.nousenow;

import com.funtl.hello.uwb.AnchorConst;
import org.ujmp.core.DenseMatrix;
import org.ujmp.core.Matrix;

/**
 * @author LingZhe
 */
public class MatrixUtil {

    static final double C = 3*Math.pow(10, 8);

    static Matrix matrixI = DenseMatrix.Factory.zeros(2,2);

    static Matrix matrixZ = DenseMatrix.Factory.zeros(2,2);

    static Matrix matrixS = DenseMatrix.Factory.zeros(2,2);

    static Matrix matrixSTran = null;
    static {
        matrixI.setAsDouble(1.0, 0, 0);
        matrixI.setAsDouble(1.0, 1, 1);
        matrixZ.setAsDouble(1.0, 0, 1);
        matrixZ.setAsDouble(1.0, 1, 0);
        matrixS.setAsDouble((AnchorConst.X3-AnchorConst.X2), 0,0);
        matrixS.setAsDouble((AnchorConst.Y3-AnchorConst.Y2), 0,1);
        matrixS.setAsDouble((AnchorConst.X4-AnchorConst.X2), 1,0);
        matrixS.setAsDouble((AnchorConst.Y4-AnchorConst.Y2), 1,1);
        matrixSTran = matrixS.transpose();
    }

    public static Matrix calculateMatrix(double timeDiff1, double timeDiff2) {
        Matrix matrixDTran = DenseMatrix.Factory.zeros(2,2);
        matrixDTran.setAsDouble(C*timeDiff1, 0,0);
        matrixDTran.setAsDouble(C*timeDiff2, 1,1);
        Matrix matrixD = matrixDTran.transpose();

        Matrix matrixN = (matrixI.minus(matrixZ)).mtimes(matrixD);

        Matrix matrixNTran = matrixN.transpose();

        Matrix matrixU = DenseMatrix.Factory.zeros(2, 1);
        matrixU.setAsDouble(AnchorConst.K3 - AnchorConst.K2 - C*timeDiff1, 0,0);
        matrixU.setAsDouble(AnchorConst.K4 - AnchorConst.K2 - C*timeDiff2, 1,0);

        Matrix matrixX = (matrixSTran.mtimes(matrixNTran).mtimes(matrixN).mtimes(matrixS))
                .transpose()
                .mtimes(matrixSTran)
                .mtimes(matrixNTran)
                .mtimes(matrixN)
                .mtimes(matrixU);
        return matrixX;
    }



    public static void main(String[] args) {
    }
}
