package com.funtl.hello.nousenow;

/**
 * 基于测距值
 * @author LingZhe
 */
public class WLAAlgorithmUtil {

    public double[][] getAMatrix(double x1, double x2, double x3, double x4,
                                 double y1, double y2, double y3, double y4) {
        double[][] aMatrix = new double[3][2];

        aMatrix[0][0] = x1 - x4;
        aMatrix[1][0] = x2 - x4;
        aMatrix[2][0] = x3 - x4;

        aMatrix[0][1] = y1 - y4;
        aMatrix[1][1] = y2 - y4;
        aMatrix[2][1] = y3 - y4;

        return aMatrix;
    }


}
