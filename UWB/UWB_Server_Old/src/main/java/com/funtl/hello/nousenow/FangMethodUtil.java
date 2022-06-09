package com.funtl.hello.nousenow;

import com.funtl.hello.uwb.AnchorConst;

/**
 * Fang算法位置计算公式 //白给
 * @author LingZhe
 * Na
 */
public class FangMethodUtil {

    private static final double C = 3*Math.pow(10, 8);

    public static double calcA(double delta31, double delta21) {
        double R31 = C*delta31;
        double R21 = C*delta21;

        double a = 0.0;
//        a = AnchorConst.X2*R31/R21 - AnchorConst.X3;
//        a = a/AnchorConst.Y3;

        a = R31*(AnchorConst.X3/R21) - AnchorConst.X4;
        a = a/AnchorConst.Y4;

        return a;
    }

    public static double calcB(double delta31, double delta21) {
        double K3 = AnchorConst.K4;
        double R31 = C*delta31;
        double R21 = C*delta21;

        double b = 0.0;

//        b = K3 - R31*R31 + R31*R21*(1-Math.pow((AnchorConst.X2/R21),2.0));
//        b = b/(2.0*AnchorConst.Y3);

        b = K3 - R31*R31 + R31*R21*(1-Math.pow((AnchorConst.X3/R21),2.0));
        b = b/(2.0*AnchorConst.Y4);

        return b;
    }

    public static double calcD(double a, double delta21) {
        double R21 = C*delta21;

        double d = 0.0;

//        d = 1.0 - Math.pow(AnchorConst.X2/R21, 2.0) + Math.pow(a, 2.0);

        d = 1.0 - Math.pow(AnchorConst.X3/R21, 2) + Math.pow(a, 2);

        return  -1*d;
    }

    public static double calcE(double a, double b, double delta21) {

        double R21 = C*delta21;

        double e = 0.0;
//        e = AnchorConst.X2 * (1.0 - Math.pow((AnchorConst.X2 / R21), 2.0) )- e;

        e = AnchorConst.X3 * (1-Math.pow((AnchorConst.X3 / R21), 2.0)) - 2*a*b;

        return e;
    }

    public static double calcF(double b, double delta21) {
        double R21 = C*delta21;

        double f = Math.pow(R21/2, 2)*Math.pow(1-Math.pow(AnchorConst.X3/R21, 2), 2);
        f = f - Math.pow(b, 2);
//        f = f * Math.pow((1.0 - Math.pow((AnchorConst.X2/R21), 2.0)), 2.0);
        return f;
    }

    public static double[] calcXAndY(double delta31, double delta21) {
        double a = calcA(delta31, delta21);
        double b = calcB(delta31, delta21);

        double d = calcD(a, delta21);
        double e = calcE(a, b, delta21);
        double f = calcF(b, delta21);

        double x1 = -1*e - Math.sqrt(e*e - 4*d*f);
        x1 = x1 / (2.0*d);
        double y1 = a*x1+b;

        double x2 = -1*e + Math.sqrt(e*e - 4*d*f);
        x2 = x2 / (2.0*d);
        double y2 = a*x2+b;
        return new double[]{x1, y1, x2, y2};
    }

//    public static double calcY(double delta31, double delta21) {
//        double a = calcA(delta31, delta21);
//        double b = calcB(delta31, delta21);
//        double x = calcX(delta31, delta21);
//
//        double y = a*x+b;
//
//        return y;
//    }

}
