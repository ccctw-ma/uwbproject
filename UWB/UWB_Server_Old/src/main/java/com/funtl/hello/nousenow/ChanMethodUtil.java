package com.funtl.hello.nousenow;

import com.funtl.hello.uwb.AnchorConst;

/**
 * 不用了
 * @author LingZhe
 */
public class ChanMethodUtil {

    static final double C = 3*Math.pow(10, 8);

    static double Y21 = AnchorConst.Y3 - AnchorConst.Y2;
    static double Y31 = AnchorConst.Y4 - AnchorConst.Y2;
    static double X21 = AnchorConst.X3 - AnchorConst.X2;
    static double X31 = AnchorConst.X4 - AnchorConst.X2;

    public static double[] calculatePAndQ(double timeDiff1, double timeDiff2) {
        double R21 = C*timeDiff1;
        double R31 = C*timeDiff2;

        double p1 = Y21*R31*R31 - Y31*R21*R21 + (Y31-Y21)*(AnchorConst.K3-AnchorConst.K2);
        p1 = p1 / (2*X21*Y31 - 2*X31*Y21);

        double q1 = Y21*R31 - Y31*R21;
        q1 = q1 / (X21*Y31 - X31*Y21);

        double p2 = X21*R31*R31 - X31*R21*R21 + (X31-X21)*(AnchorConst.K3-AnchorConst.K2);
        p2 = p2 / (2*X31*Y21 - 2*X21*Y31);

        double q2 = X21*R31 - X31*R21;
        q2 = q2 / (X31*Y21 - X21*Y31);

        return new double[]{p1, q1, p2, q2};
    }

    public static double[] calculateLocation(double timeDiff1, double timeDiff2) {
        double[] PAndQ = calculatePAndQ(timeDiff1, timeDiff2);

        double p1 = PAndQ[0];
        double q1 = PAndQ[1];
        double p2 = PAndQ[2];
        double q2 = PAndQ[3];

        double a = q1*q1 +q2*q2 - 1;
        double b = -2*(q1*(AnchorConst.X2-p1) + q2*(AnchorConst.Y2-p2));
        double c = Math.pow(AnchorConst.X2-p1, 2) - Math.pow(AnchorConst.Y2-p1, 2);

        double r11 = (-b + Math.sqrt(b*b-4*a*c)) / (2*a);
        double r12 = (-b - Math.sqrt(b*b-4*a*c)) / (2*a);

        double x1 = r11*q1+p1;
        double y1 = r11*q2+p2;

        double x2 = r12*q1+p1;
        double y2 = r12*q2+p2;

        return new double[]{x1, y1, x2, y2};
    }

}
