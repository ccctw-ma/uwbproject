package com.funtl.hello.uwb;

/**
 * @author LingZhe
 */
public class TimeUtil {

    private static double[] anchor12RxTime = new double[256];

    private static double[] anchor13RxTime = new double[256];

    private static double[] anchor14RxTime = new double[256];

    private static int anchor12SeqNum = 0;

    private static int anchor13SeqNum = 0;

    private static int anchor14SeqNum = 0;

    private static double[] anchor31RxTime = new double[256];

    private static double[] anchor32RxTime = new double[256];

    private static double[] anchor34RxTime = new double[256];

    private static int anchor31SeqNum = 0;

    private static int anchor32SeqNum = 0;

    private static int anchor34SeqNum = 0;

    private static int dataPollingTimes = 256;

    /**
     * 存储Anchor1发送的数据和Anchor3发送的数据
     * @param anchorOrLabelFrom 从哪个基站发来的
     * @param anchorTo 去往的那个基站
     * @param seqNum 轮次序号
     * @param rxTime 接收时间
     */
    public static void putAnchorTime(String anchorOrLabelFrom, String anchorTo, int seqNum, double rxTime) {
        if (anchorOrLabelFrom.equals(AnchorNameConst.Anchor1)) {
            if (anchorTo.equals(AnchorNameConst.Anchor2)) {
                anchor12SeqNum = seqNum;
                anchor12RxTime[anchor12SeqNum] = rxTime;
            } else if (anchorTo.equals(AnchorNameConst.Anchor3)) {
                anchor13SeqNum = seqNum;
                anchor13RxTime[anchor13SeqNum] = rxTime;
            } else if (anchorTo.equals(AnchorNameConst.Anchor4)) {
                anchor14SeqNum = seqNum;
                anchor14RxTime[anchor14SeqNum] = rxTime;
            }
        } else if (anchorOrLabelFrom.equals(AnchorNameConst.Anchor3)) {
            if (anchorTo.equals(AnchorNameConst.Anchor1)) {
                anchor31SeqNum = seqNum;
                anchor31RxTime[anchor31SeqNum] = rxTime;
            } else if (anchorTo.equals(AnchorNameConst.Anchor2)) {
                anchor32SeqNum = seqNum;
                anchor32RxTime[anchor32SeqNum] = rxTime;
            } else if (anchorTo.equals(AnchorNameConst.Anchor4)) {
                anchor34SeqNum = seqNum;
                anchor34RxTime[anchor34SeqNum] = rxTime;
            }
        }
    }

//    public static boolean haveNullOrData() {
//        if (anchor12RxTime[anchor12SeqNum] == 0.0 ||
//                anchor12RxTime[(anchor12SeqNum - 1 + dataPollingTimes) % dataPollingTimes] == 0.0) {
//            System.out.println("anchor12SeqNum:" + anchor12SeqNum + ",本轮次anchor12RxTime为0.0");
//            return false;
//        } else if (anchor13RxTime[anchor13SeqNum] == 0.0 ||
//                anchor13RxTime[(anchor13SeqNum - 1 + dataPollingTimes) % dataPollingTimes] == 0.0) {
//            System.out.println("anchor13SeqNum:" + anchor13SeqNum + ",本轮次anchor13RxTime为0.0");
//            return false;
//        } else if (anchor14RxTime[anchor14SeqNum] == 0.0 ||
//                anchor14RxTime[(anchor14SeqNum - 1 + dataPollingTimes) % dataPollingTimes] == 0.0) {
//            System.out.println("anchor14SeqNum:" + anchor14SeqNum + ",本轮次anchor14RxTime为0.0");
//            return false;
//        } else if (anchor31RxTime[anchor31SeqNum] == 0.0 ||
//                anchor31RxTime[(anchor31SeqNum - 1 + dataPollingTimes) % dataPollingTimes] == 0.0) {
//            System.out.println("anchor31SeqNum:" + anchor31SeqNum + ",本轮次anchor31RxTime为0.0");
//            return false;
//        } else if (anchor32RxTime[anchor32SeqNum] == 0.0 ||
//                anchor32RxTime[(anchor32SeqNum - 1 + dataPollingTimes) % dataPollingTimes] == 0.0) {
//            System.out.println("anchor32SeqNum:" + anchor32SeqNum + ",本轮次anchor32RxTime为0.0");
//            return false;
//        }
//        return true;
//    }

    public static boolean haveNullOrDataThisTurn() {
        if (anchor12RxTime[anchor12SeqNum] == 0.0) {
            System.out.println("anchor12SeqNum:" + anchor12SeqNum + ",本轮次anchor12RxTime为0.0");
            return false;
        } else if (anchor13RxTime[anchor13SeqNum] == 0.0) {
            System.out.println("anchor13SeqNum:" + anchor13SeqNum + ",本轮次anchor13RxTime为0.0");
            return false;
        } else if (anchor14RxTime[anchor14SeqNum] == 0.0) {
            System.out.println("anchor14SeqNum:" + anchor14SeqNum + ",本轮次anchor14RxTime为0.0");
            return false;
        } else if (anchor31RxTime[anchor31SeqNum] == 0.0) {
            System.out.println("anchor31SeqNum:" + anchor31SeqNum + ",本轮次anchor31RxTime为0.0");
            return false;
        } else if (anchor32RxTime[anchor32SeqNum] == 0.0) {
            System.out.println("anchor32SeqNum:" + anchor32SeqNum + ",本轮次anchor32RxTime为0.0");
            return false;
        }
        return true;
    }


    public static void calculateOffset() {
        double tempB23 = 0;
        int seq = Math.min(anchor12SeqNum, anchor13SeqNum);
        tempB23 = anchor13RxTime[seq] - 1 * anchor12RxTime[seq];
        AdjustTimeUtil.setClockOffsetB2(tempB23);

        double tempB24 = 0;
        seq = Math.min(anchor12SeqNum, anchor14SeqNum);
        tempB24 = anchor14RxTime[seq] - 1 * anchor12RxTime[seq];
        AdjustTimeUtil.setClockOffsetB3(tempB24);

        double tempB21 = 0;
        seq = Math.min(anchor31SeqNum, anchor32SeqNum);
        tempB21 = anchor31RxTime[seq] - 1 * anchor32RxTime[seq];
        AdjustTimeUtil.setClockOffsetB1(tempB21);
    }

    public static void calculateSkewAndOffset() {
        if (!haveNullOrDataThisTurn()) {
            return;
        }
        double tempK23 = 0.0;
        double tempB23 = 0.0;

        double tempK24 = 0.0;
        double tempB24 = 0.0;
        // 基站1发送，做基站3和基站2之间的同步
        int seq = Math.min(anchor12SeqNum, anchor13SeqNum);
        tempK23 = (anchor13RxTime[seq] - anchor13RxTime[(seq - 1 + dataPollingTimes) % dataPollingTimes])
                / (anchor12RxTime[seq] - anchor12RxTime[(seq - 1 + dataPollingTimes) % dataPollingTimes]);

        tempB23 = anchor13RxTime[seq] - tempK23 * anchor12RxTime[seq];

        AdjustTimeUtil.setClockSkewK2(tempK23);
        AdjustTimeUtil.setClockOffsetB2(tempB23);
        // 基站1发送，做基站4和基站2之间的同步
        seq = Math.min(anchor12SeqNum, anchor14SeqNum);
        tempK24 = (anchor14RxTime[seq] - anchor14RxTime[(seq - 1 + dataPollingTimes) % dataPollingTimes]) /
                (anchor12RxTime[seq] - anchor12RxTime[((seq - 1 + dataPollingTimes)) % dataPollingTimes]);

        tempB24 = anchor14RxTime[seq] - tempK24 * anchor12RxTime[seq];

        AdjustTimeUtil.setClockSkewK3(tempK24);
        AdjustTimeUtil.setClockOffsetB3(tempB24);

        double tempK21 = 0.0;
        double tempB21 = 0.0;

        seq = Math.min(anchor31SeqNum, anchor32SeqNum);

        tempK21 = (anchor31RxTime[seq] - anchor31RxTime[(seq - 1 + dataPollingTimes) % dataPollingTimes]) /
                (anchor32RxTime[seq] - anchor32RxTime[(seq - 1 + dataPollingTimes) % dataPollingTimes]);

        tempB21 = anchor31RxTime[seq] - tempK21 * anchor32RxTime[seq];

        AdjustTimeUtil.setClockSkewK1(tempK21);
        AdjustTimeUtil.setClockOffsetB1(tempB21);

//        System.out.println("K2: "+tempK2+", B2: "+tempB2);
//        System.out.println("K3: "+tempK3+", B3: "+tempB3);
    }

    public static void cleanBeforeData(int seq) {
        anchor12RxTime[seq] = 0.0;
        anchor13RxTime[seq] = 0.0;
        anchor14RxTime[seq] = 0.0;
    }
}
