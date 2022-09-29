package com.funtl.hello.uwb;

import Jama.Matrix;

import static java.lang.Math.*;

public class TaylorAlgorithm {
    Position position;

    double[][] BS;

    double[] inputData;

    boolean calcFlag;

    Matrix tdoaDataNodelay;

    public TaylorAlgorithm() {

    }

    public Position getPosition() {
        return position;
    }

    public TaylorAlgorithm(double[] inputData) {
        position = new Position();
        BS = new double[4][3];
        for (int i = 0; i < BS.length; i++) {
            double[] bs = AnchorConst.getI(i);
            BS[i][0] = bs[0];
            BS[i][1] = bs[1];
            BS[i][2] = 0;
        }

        this.inputData = inputData;
        tdoaDataNodelay = new Matrix(new double[1][4]);
        int rowSize = 1;
        int colSize = 4;
        for (int row = 0; row < rowSize; row++) {
            for (int col = 0; col < colSize; col++) {
                tdoaDataNodelay.set(row, col, inputData[col]);
            }
        }
    }

    public Matrix operateSub(Matrix matrix, double value) {
        Matrix copyM = matrix.copy();
        for (int row = 0; row < copyM.getRowDimension(); row++) {
            for (int col = 0; col < copyM.getColumnDimension(); col++) {
                copyM.set(row, col, matrix.get(row, col) - value);
            }
        }
        return copyM;
    }

    public Matrix operateDivide(Matrix matrix, double value) {
        Matrix copyM = matrix.copy();
        for (int row = 0; row < copyM.getRowDimension(); row++) {
            for (int col = 0; col < copyM.getColumnDimension(); col++) {
                copyM.set(row, col, matrix.get(row, col) / value);
            }
        }
        return copyM;
    }

    public Matrix operateGetRow(Matrix matrix, int rowNum) {
        Matrix copyM = new Matrix(1, matrix.getColumnDimension());
        for (int col = 0; col < matrix.getColumnDimension(); col++) {
            copyM.set(0, col, matrix.get(rowNum, col));
        }
        return copyM;
    }

    public Matrix operateGetCol(Matrix matrix, int colNum) {
        Matrix copyM = new Matrix(matrix.getRowDimension(), 1);
        for (int row = 0; row < matrix.getRowDimension(); row++) {
            copyM.set(row, 0, matrix.get(row, colNum));
        }
        return copyM;
    }

    public double operateGetColMean(Matrix matrix, int index) {
        double meanValue = 0;
        for (int row = 0; row < matrix.getRowDimension(); row++) {
            meanValue += matrix.get(row, index);
        }
        meanValue /= matrix.getRowDimension();
        return meanValue;
    }

    public Matrix operateArrayToMatrix(double[] inArray, int rowSize, int colSize) {
        Matrix copyM = new Matrix(new double[rowSize][colSize]);
        for (int row = 0; row < rowSize; row++) {
            for (int col = 0; col < colSize; col++) {
                copyM.set(row, col, inArray[row * colSize + col]);
            }
        }
        return copyM;
    }


    /**
     * taylor迭代
     *
     * @param x
     * @param y
     */
    public void taylorCalculateXY(double x, double y) {
        double[] meanTdoaData = new double[3];
        for (int col = 0; col < 3; col++) {
            for (int row = 0; row < tdoaDataNodelay.getRowDimension(); row++) {
                meanTdoaData[col] += (tdoaDataNodelay.get(row, col + 1) - tdoaDataNodelay.get(row, 0));
            }
            meanTdoaData[col] /= tdoaDataNodelay.getRowDimension();
        }
        Matrix[] XQ = new Matrix[3];
        for (int row = 0; row < 3; row++) {
            XQ[row] = new Matrix(new double[1][tdoaDataNodelay.getRowDimension()]);
            for (int col = 0; col < tdoaDataNodelay.getRowDimension(); col++) {
                XQ[row].set(0, col, tdoaDataNodelay.get(col, row + 1) - tdoaDataNodelay.get(col, 0));
            }
        }
        Matrix Q = new Matrix(new double[3][3]);
        for (int row = 0; row < 3; row++) {
            for (int col = 0; col < 3; col++) {
                Matrix rowSub = operateSub(XQ[row], meanTdoaData[row]);
                Matrix colSub = operateSub(XQ[col], meanTdoaData[col]);
                Q.set(row, col, rowSub.times(colSub).transpose().get(0, 0));
            }
        }
        Matrix QReal = operateDivide(Q, XQ[0].getColumnDimension());

        double[] delta = new double[]{10, 10};
        double xTaylor = x;
        double yTaylor = y;
        while ((abs(delta[0]) + abs(delta[1])) > 1e-6) {
            double RTaylor21 = operateGetColMean(
                    operateGetCol(tdoaDataNodelay, 1)
                            .minus(operateGetCol(tdoaDataNodelay, 0))
                            .times(0.3), 0);
            double RTaylor31 = operateGetColMean(
                    operateGetCol(tdoaDataNodelay, 2)
                            .minus(operateGetCol(tdoaDataNodelay, 0))
                            .times(0.3), 0);
            double RTaylor41 = operateGetColMean(
                    operateGetCol(tdoaDataNodelay, 3)
                            .minus(operateGetCol(tdoaDataNodelay, 0))
                            .times(0.3), 0);

            double X1Taylor = BS[0][0];
            double Y1Taylor = BS[0][1];
            double X2Taylor = BS[1][0];
            double Y2Taylor = BS[1][1];
            double X3Taylor = BS[2][0];
            double Y3Taylor = BS[2][1];
            double X4Taylor = BS[3][0];
            double Y4Taylor = BS[3][1];

            double R1Taylor = sqrt(pow(X1Taylor - xTaylor, 2.0) + pow(Y1Taylor - yTaylor, 2.0));
            double R2Taylor = sqrt(pow(X2Taylor - xTaylor, 2.0) + pow(Y2Taylor - yTaylor, 2.0));
            double R3Taylor = sqrt(pow(X3Taylor - xTaylor, 2.0) + pow(Y3Taylor - yTaylor, 2.0));
            double R4Taylor = sqrt(pow(X4Taylor - xTaylor, 2.0) + pow(Y4Taylor - yTaylor, 2.0));

            double[] hTaylorArr = new double[]{
                    RTaylor21 - (R2Taylor - R1Taylor),
                    RTaylor31 - (R3Taylor - R1Taylor),
                    RTaylor41 - (R4Taylor - R1Taylor)
            };
            Matrix hTaylor;
            hTaylor = operateArrayToMatrix(hTaylorArr, 3, 1);
            double[] GTaylorArr = new double[]{
                    (X1Taylor - xTaylor) / R1Taylor - (X2Taylor - xTaylor) / R2Taylor, (Y1Taylor - yTaylor) / R1Taylor - (Y2Taylor - yTaylor) / R2Taylor,
                    (X1Taylor - xTaylor) / R1Taylor - (X3Taylor - xTaylor) / R3Taylor, (Y1Taylor - yTaylor) / R1Taylor - (Y3Taylor - yTaylor) / R3Taylor,
                    (X1Taylor - xTaylor) / R1Taylor - (X4Taylor - xTaylor) / R4Taylor, (Y1Taylor - yTaylor) / R1Taylor - (Y4Taylor - yTaylor) / R4Taylor
            };

            Matrix GTaylor;
            GTaylor = operateArrayToMatrix(GTaylorArr, 3, 2);
            Matrix QTaylor = QReal;
            double[] QStub = new double[]{
                    1, 0, 0,
                    0, 1, 0,
                    0, 0, 1};
            Matrix QStubMat;
            QStubMat = operateArrayToMatrix(QStub, 3, 3);
            QTaylor = QStubMat;

            Matrix GTranspose = GTaylor.transpose();
            Matrix QInverse = QTaylor.inverse();
            Matrix res = GTranspose.times(QInverse).times(GTaylor);

            if (res.rank() < res.getRowDimension()) {
                return;
            }
            Matrix debugMatrix1 = null;//(GTaylor.transpose().times(QTaylor.inverse()).times(GTaylor)).inverse();
            Matrix debugMatrix2;
            Matrix debugMatrix3;
            Matrix deltaMatrix;
            debugMatrix1 = res.inverse();
            debugMatrix2 = debugMatrix1.times(GTaylor.transpose());
            debugMatrix3 = debugMatrix2.times(QTaylor.inverse());
            deltaMatrix = debugMatrix3.times(hTaylor);
            delta[0] = deltaMatrix.get(0, 0);
            delta[1] = deltaMatrix.get(1, 0);
            if ((abs(delta[0]) + abs(delta[1])) > 1e-6) {
                xTaylor = xTaylor + delta[0];
                yTaylor = yTaylor + delta[1];
            }
        }
        position.setX(xTaylor);
        position.setY(yTaylor);

        calcFlag = true;
    }

    public void readTxt(double[] tdoa) {

    }

    public boolean getCalcResult(double[] xAndY) {
        if (calcFlag == false) {
            return false;
        }
        xAndY[0] = position.getX();
        xAndY[1] = position.getY();
        return true;
    }


    /**
     * old version
     *
     * @param x0
     * @param y0
     * @return
     */

    public static double[] calculateR(double x0, double y0) {
        double[] r1AndR2AndR3 = new double[3];
        double r1 = sqrt(
                pow(AnchorConst.getX1() - x0, 2)
                        + pow(AnchorConst.getY1() - y0, 2)
        );
        double r2 = sqrt(
                pow(AnchorConst.getX2() - x0, 2)
                        + pow(AnchorConst.getY2() - y0, 2)
        );
        double r3 = sqrt(
                pow(AnchorConst.getX3() - x0, 2)
                        + pow(AnchorConst.getY3() - y0, 2)
        );
        return new double[]{r1, r2, r3};
    }

    public static Matrix calculateMatrixG(double x0, double y0) {
        Matrix matrixG = new Matrix(new double[2][4]);
        double[] r1AndR2AndR3 = calculateR(x0, y0);
        double r1 = r1AndR2AndR3[0], r2 = r1AndR2AndR3[1], r3 = r1AndR2AndR3[2];
        matrixG.set(0, 0, (AnchorConst.getX1() - x0) / r1);
        matrixG.set(0, 1, (AnchorConst.getX2() - x0) / r2);
        matrixG.set(0, 2, (AnchorConst.getY1() - y0) / r1);
        matrixG.set(0, 3, (AnchorConst.getY2() - y0) / r2);
        //
        matrixG.set(1, 0, (AnchorConst.getX1() - x0) / r1);
        matrixG.set(1, 1, (AnchorConst.getX3() - x0) / r3);
        matrixG.set(1, 2, (AnchorConst.getY1() - y0) / r1);
        matrixG.set(1, 3, (AnchorConst.getY3() - y0) / r3);
        return matrixG;
    }

    public static Matrix calculateMatrixH(double[] r1AndR2AndR3) {
        double r1 = r1AndR2AndR3[0];
        double r2 = r1AndR2AndR3[1];
        double r3 = r1AndR2AndR3[2];

        double r21 = r2 - r1;

        return null;
    }

    public static Matrix calculateMatrixTranspose(Matrix matrixG) {
        Matrix matrixGT = matrixG.copy().transpose();
        return matrixGT;
    }
}
