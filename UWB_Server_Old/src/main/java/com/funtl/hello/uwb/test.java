package com.funtl.hello.uwb;

import Jama.Matrix;

public class test {
    Matrix tdoaDataNodelay;

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

    public test(double[] data){
        tdoaDataNodelay = new Matrix(new double[1][4]);
        int rowSize = 1;
        int colSize = 4;
        for (int row = 0; row < rowSize; row++) {
            for (int col = 0; col < colSize; col++) {
                tdoaDataNodelay.set(row, col, data[col]);
            }
        }
        //double RT = operateGetColMean(operateGetCol(tdoaDataNodelay,1).minus(operateGetCol(tdoaDataNodelay,0)).times(0.3),0);
        //System.out.println(RT);
    }

    public void taylorCalculateXY(){
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
        double RTaylor21 = operateGetColMean(
                operateGetCol(tdoaDataNodelay, 1)
                        .minus(operateGetCol(tdoaDataNodelay, 0))
                        .times(0.3), 0);
        System.out.println(operateGetColMean(
                operateGetCol(tdoaDataNodelay, 1)
                        .minus(operateGetCol(tdoaDataNodelay, 0))
                        .times(0.3), 0));


    }
}
