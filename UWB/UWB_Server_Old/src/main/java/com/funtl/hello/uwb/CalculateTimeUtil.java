package com.funtl.hello.uwb;

/**
 * 计算时间工具
 * 需要知道 时钟偏斜和时钟偏差
 * @author LingZhe
 */
public class CalculateTimeUtil {

    private static final double C = 3*Math.pow(10, 8);

    public static double calculateAnchor1RelativeTime(double T1) {
        double K1 = AdjustTimeUtil.getClockSkewK1();
        double B1 = AdjustTimeUtil.getClockOffsetB1();
//        System.out.println(B1);
//        System.out.println(AnchorConst.distance12);
//        System.out.println(AnchorConst.distance12 / C);
        // 把时钟偏斜K当做1处理

        return (T1 - B1) / K1  - AnchorConst.distance23 / C + AnchorConst.distance31 / C;
    }

    public static double calculateAnchor3RelativeTime(double T2) {

        double K2 = AdjustTimeUtil.getClockSkewK2();
        double B2 = AdjustTimeUtil.getClockOffsetB2();
        // 把时钟偏斜K当做1处理

        return (T2 - B2) / K2  - AnchorConst.distance21 / C + AnchorConst.distance31 / C;
    }

    public static double calculateAnchor4RelativeTime(double T3) {
        double K3 = AdjustTimeUtil.getClockSkewK3();
        double B3 = AdjustTimeUtil.getClockOffsetB3();
        // 把时钟偏斜K当做1处理

        return (T3 - B3) / K3  - AnchorConst.distance21 / C + AnchorConst.distance41 / C;
    }
}
