package com.funtl.hello.uwb;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

/**
 *
 * 对齐时钟
 * @author LingZhe
 */
public class AdjustTimeUtil {

    static boolean isAdjustDelta = false;

    static double delta12 = 0.0;

    static double delta13 = 0.0;

    static double delta12Rate = 0.0;

    static double delta13Rate = 0.0;

    static boolean isSetBeginSeq = false;

    static int beginSeq = 0;

    static int dataCount = 0;

    // 2021-06-05
    static double clockSkewK2 = 0.0;

    static double clockSkewK3 = 0.0;

    static double clockOffsetB2 = 0.0;

    static double clockOffsetB3 = 0.0;

    // 2021-06-09
    static double clockSkewK1 = 0.0;
    static double clockOffsetB1 = 0.0;

    static int pollingTimes = 256;

    // 同步基站收到参考基站的同步包的时间
    static double[][] referenceTime = new double[256][3];

    static LinkedList<Double> deltas2 = new LinkedList<>();

    static LinkedList<Double> deltas3 = new LinkedList<>();

//    public static void calculateSkewAndOffset(int seq) {
//        if (!haveEnoughDataCount()) return;
//
//        if (havePartSeqData(seq)) return;
//
//        int seqNum = seq;
//        double tempK2 = 0.0;
//        double tempK3 = 0.0;
//
//        double tempB2 = 0.0;
//        double tempB3 = 0.0;
//
//        tempK2 = (referenceTime[seqNum%pollingTimes][1] - referenceTime[(seqNum+1)/pollingTimes][1]) /
//                (referenceTime[seqNum%pollingTimes][0] - referenceTime[(seqNum+1)%pollingTimes][0]);
//
//        tempK3 = (referenceTime[seqNum%pollingTimes][2] - referenceTime[(seqNum+1)%pollingTimes][2]) /
//                (referenceTime[seqNum%pollingTimes][0] - referenceTime[(seqNum+1)%pollingTimes][0]);
//
//
//
//        if (Double.isNaN(tempK2) || tempK2==0.0 || Double.isNaN(tempK3) || tempK3==0.0) return;
//
//        tempB2 = (referenceTime[seqNum%pollingTimes][1] - referenceTime[seqNum%pollingTimes][0]) / tempK2;
//        tempB3 = (referenceTime[seqNum%pollingTimes][2] - referenceTime[seqNum%pollingTimes][0]) / tempK3;
//
//        clockSkewK2 = tempK2;
//        clockSkewK3 = tempK3;
//
//        clockOffsetB2 = tempB2;
//        clockOffsetB3 = tempB3;
//
//        System.out.println("K2:"+clockSkewK2+",B2:"+clockOffsetB2);
//        System.out.println(referenceTime[seq][0]+","+referenceTime[seq][1]);
//
//        isAdjustDelta = true;
//        clearDataCount(seq);
//        clearBeginSeq();
//    }

    public static void calculateRateOfChange(double delta2, double delta3) {
        if (deltas2.size() > 2) {
            deltas2.removeFirst();
        }
        if (deltas3.size() > 2) {
            deltas3.removeFirst();
        }

        deltas2.addLast(delta2);
        deltas3.addLast(delta3);
        Double[] trans2 = deltas2.toArray(new Double[2]);
        Double[] trans3 = deltas3.toArray(new Double[2]);
//        System.out.println("trans2 = " + trans2);
//        System.out.println("trans3 = " + trans3);
        double rate2 = 0.0;
        double rate3 = 0.0;
        for (int i=0;i<1;i++) {
            rate2 += (trans2[i+1] - trans2[i]);
            rate3 += (trans3[i+1] - trans3[i]);
        }
//        rate2 /= 4.0;
//        rate3 /= 4.0;
        delta12Rate = rate2;
        delta13Rate = rate3;
        System.out.println("delta12Rate:"+delta12Rate+",delta13Rate:"+delta13Rate+"\n");
    }

    /**
     *
     */
    public static void rbsTimeSync() {
        if (!haveEnoughDataCount()) return;

        double tmpDelta12 = 0.0;
        double tmpDelta13 = 0.0;

        int validCount1 = 0;
        int validCount2 = 0;

        int seqNum = beginSeq;


        for (int i=0;i<1;i++) {
            seqNum = seqNum % 256;
            if (referenceTime[seqNum][0]!=0.0 && referenceTime[seqNum][1]!=0.0) {
                tmpDelta12 += referenceTime[seqNum][0] - referenceTime[seqNum][1];
                ++validCount1;
            }
            if (referenceTime[seqNum][0]!=0.0 && referenceTime[seqNum][2]!=0.0) {
                tmpDelta13 += referenceTime[seqNum][0] - referenceTime[seqNum][2];
                ++validCount2;
            }
            seqNum++;
        }

        seqNum = seqNum%256;
        tmpDelta12 = (referenceTime[seqNum][1] - referenceTime[seqNum][1]) / (referenceTime[seqNum][0] - referenceTime[seqNum][0]);
        tmpDelta12 = (referenceTime[seqNum][1] - referenceTime[seqNum][1]) / (referenceTime[seqNum][0] - referenceTime[seqNum][0]);

        delta12 = tmpDelta12;
        delta13 = tmpDelta13;
        delta12 = (delta12 / validCount1);
        delta13 = (delta13 / validCount2);
        System.out.println("delta12: "+delta12+"\t delta13: "+delta13);
        if (Double.isNaN(delta12) || Double.isNaN(delta13)) return;
        isAdjustDelta = true;
        clearDataCount(beginSeq);
        clearBeginSeq();
        calculateRateOfChange(delta12, delta13);
    }

    public static double getDelta12() {
        return delta12;
    }

    public static double getDelta13() {
        return delta13;
    }

    public static boolean haveEnoughDataCount() {
        return dataCount >= 6;
    }

    public static void clearDataCount(int seq) {
        referenceTime[seq][0] = referenceTime[seq][1] = referenceTime[seq][2] = 0;
        referenceTime[(seq+1)%pollingTimes][0] = referenceTime[(seq+1)%pollingTimes][1] = referenceTime[(seq+1)%pollingTimes][2] = 0;
        dataCount = 0;
    }

    public static void addDataCount() {
        dataCount++;
    }

    public static void setBeginSeq(int beginSeq) {
        if (isSetBeginSeq) return;
        AdjustTimeUtil.beginSeq = beginSeq;
        isSetBeginSeq = true;
    }

    public static void clearBeginSeq() {
        isSetBeginSeq = false;
        beginSeq = -1;
    }

    public static boolean isIsAdjustDelta() {
        return isAdjustDelta;
    }

    public static boolean havePartSeqData(int seq) {
        return referenceTime[seq][0] == 0.0 && referenceTime[seq][1] == 0.0 || referenceTime[seq][2] == 0.0;
    }

    public static double getClockSkewK2() {
        return clockSkewK2;
    }

    public static double getClockSkewK3() {
        return clockSkewK3;
    }

    public static double getClockOffsetB2() {
        return clockOffsetB2;
    }

    public static double getClockOffsetB3() {
        return clockOffsetB3;
    }

    public static void setClockSkewK2(double clockSkewK2) {
        AdjustTimeUtil.clockSkewK2 = clockSkewK2;
    }

    public static void setClockSkewK3(double clockSkewK3) {
        AdjustTimeUtil.clockSkewK3 = clockSkewK3;
    }

    public static void setClockOffsetB2(double clockOffsetB2) {
        AdjustTimeUtil.clockOffsetB2 = clockOffsetB2;
    }

    public static void setClockOffsetB3(double clockOffsetB3) {
        AdjustTimeUtil.clockOffsetB3 = clockOffsetB3;
    }

    public static double getClockSkewK1() {
        return clockSkewK1;
    }

    public static double getClockOffsetB1() {
        return clockOffsetB1;
    }

    public static void setClockSkewK1(double clockSkewK1) {
        AdjustTimeUtil.clockSkewK1 = clockSkewK1;
    }

    public static void setClockOffsetB1(double clockOffsetB1) {
        AdjustTimeUtil.clockOffsetB1 = clockOffsetB1;
    }
}
