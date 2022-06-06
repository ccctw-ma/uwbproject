package com.funtl.hello.uwb;

import java.util.ResourceBundle;

/**
 * 基站坐标常量，Ki值常量
 *
 * @author LingZhe
 */
public class AnchorConst {
    public static double X1;

    public static double Y1;

    public static double X2;

    public static double Y2;

    public static double X3;

    public static double Y3;

    public static double X4;

    public static double Y4;

    public static double K1; //Ki是chan方法里的 常量 xi^2 + yi^2 （xi,yi）是基站位置

    public static double K2;

    public static double K3;

    public static double K4;

    public static double distance21; //10   ↙左下52-51右下↘         //  *左上54 ----------------------右上49*
    public static double distance31; //20   ↗右上49-52左下↙         //  |                                   |
    public static double distance41; //30   ↖左上54-52左下↙         //  |                                   |
    public static double distance23; //12   ↘右下51-49右上↗         //  |                                   |
    public static double distance24; //     ↘右下51-54左上↖         //  |                                   |
    public static double distance34; //     ↗右上49-54左上↖         //  *左下51 ----------------------右下51*

    public static double getX1() {
        return X1;
    }

    public static void setX1(double x1) {
        X1 = x1;
    }

    public static double getY1() {
        return Y1;
    }

    public static void setY1(double y1) {
        Y1 = y1;
    }

    public static double getX2() {
        return X2;
    }

    public static void setX2(double x2) {
        X2 = x2;
    }

    public static double getY2() {
        return Y2;
    }

    public static void setY2(double y2) {
        Y2 = y2;
    }

    public static double getX3() {
        return X3;
    }

    public static void setX3(double x3) {
        X3 = x3;
    }

    public static double getY3() {
        return Y3;
    }

    public static void setY3(double y3) {
        Y3 = y3;
    }

    public static double getX4() {
        return X4;
    }

    public static void setX4(double x4) {
        X4 = x4;
    }

    public static double getY4() {
        return Y4;
    }

    public static void setY4(double y4) {
        Y4 = y4;
    }

    public static double getK1() {
        return K1;
    }

    public static void setK1(double k1) {
        K1 = k1;
    }

    public static double getK2() {
        return K2;
    }

    public static void setK2(double k2) {
        K2 = k2;
    }

    public static double getK3() {
        return K3;
    }

    public static void setK3(double k3) {
        K3 = k3;
    }

    public static double getK4() {
        return K4;
    }

    public static void setK4(double k4) {
        K4 = k4;
    }

    public static double getDistance21() {
        return distance21;
    }

    public static void setDistance21(double distance21) {
        AnchorConst.distance21 = distance21;
    }

    public static double getDistance31() {
        return distance31;
    }

    public static void setDistance31(double distance31) {
        AnchorConst.distance31 = distance31;
    }

    public static double getDistance41() {
        return distance41;
    }

    public static void setDistance41(double distance41) {
        AnchorConst.distance41 = distance41;
    }

    public static double getDistance23() {
        return distance23;
    }

    public static void setDistance23(double distance23) {
        AnchorConst.distance23 = distance23;
    }


    static {
        ResourceBundle resourceBundle = ResourceBundle.getBundle("anchorPosition");
        X1 = Double.parseDouble(resourceBundle.getString("Anchor1PosX"));
        Y1 = Double.parseDouble(resourceBundle.getString("Anchor1PosY"));
        X2 = Double.parseDouble(resourceBundle.getString("Anchor2PosX"));
        Y2 = Double.parseDouble(resourceBundle.getString("Anchor2PosY"));
        X3 = Double.parseDouble(resourceBundle.getString("Anchor3PosX"));
        Y3 = Double.parseDouble(resourceBundle.getString("Anchor3PosY"));
        X4 = Double.parseDouble(resourceBundle.getString("Anchor4PosX"));
        Y4 = Double.parseDouble(resourceBundle.getString("Anchor4PosY"));

        K1 = X1 * X1 + Y1 * Y1;
        K2 = X2 * X2 + Y2 * Y2;
        K3 = X3 * X3 + Y3 * Y3;
        K4 = X4 * X4 + Y4 * Y4;

        distance21 = Math.sqrt(Math.pow(X2 - X1, 2) + Math.pow(Y2 - Y1, 2)); //基站间的距离
        distance31 = Math.sqrt(Math.pow(X3 - X1, 2) + Math.pow(Y3 - Y1, 2));
        distance41 = Math.sqrt(Math.pow(X4 - X1, 2) + Math.pow(Y4 - Y1, 2));
        distance23 = Math.sqrt(Math.pow(X3 - X2, 2) + Math.pow(Y3 - Y2, 2));
        distance24 = Math.sqrt(Math.pow(X4 - X2, 2) + Math.pow(Y4 - Y2, 2));
        distance34 = Math.sqrt(Math.pow(X4 - X3, 2) + Math.pow(Y4 - Y3, 2));
//        System.out.println(distance21 + "," + distance31 + "," + distance41 + "," + distance23 + "," + distance13);
    }

    public static double[] getI(int i) {
        switch (i) {
            case 0:
                return new double[]{getX1(), getY1()};
            case 1:
                return new double[]{getX2(), getY2()};
            case 2:
                return new double[]{getX3(), getY3()};
            case 3:
                return new double[]{getX4(), getY4()};
            default:
                break;
        }
        return null;
    }


}
