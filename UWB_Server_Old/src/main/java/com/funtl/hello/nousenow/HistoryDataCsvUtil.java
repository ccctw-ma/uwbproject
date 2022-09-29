package com.funtl.hello.nousenow;

import com.funtl.hello.uwb.AnchorNameConst;
import com.funtl.hello.uwb.UwbRxTimeUtil;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

/**
 * old 好像不用了
 * 获取端口数据之前，用历史数据尝试定位
 * @author LingZhe
 */
public class HistoryDataCsvUtil {

    public static Map<String, Deque<Double[]>> anchorTime = new HashMap<>();

    static double[] anchor1TurnTime = new double[256];

    static double[] anchor2TurnTime = new double[256];

    static double[] anchor3TurnTime = new double[256];

    public static final String csvSplitBy = ",";

    static {
        // 临时清理之前内容
        anchorTime.clear();

        for (int i=0;i<3;i++) {
            anchorTime.put(AnchorNameConst.Anchor1, new LinkedList<Double[]>());
            anchorTime.put(AnchorNameConst.Anchor2, new LinkedList<Double[]>());
            anchorTime.put(AnchorNameConst.Anchor3, new LinkedList<Double[]>());
        }
    }

    public static void transformCsvData(String fileName) {
        BufferedReader reader = null;
        String line = "";
        int count = 0;
        try {
            reader = new BufferedReader(new FileReader(fileName));
            while ((line= reader.readLine()) != null) {
                String[] params = line.split(csvSplitBy);
                if (params.length>=3 && params[2].equals(AnchorNameConst.Label)) {
                    count++;
                    double turn = Double.valueOf(params[1]);
                    Integer Turn = Integer.valueOf(params[1]);
                    double rxMeasureTime = UwbRxTimeUtil.rxTimeTransform(params[4], params[5]);
//                    switch (params[3]) {
//                        case AnchorNameConst.Anchor1:
//                            anchor1TurnTime[Turn] = rxMeasureTime;
//                            anchorTime.get(AnchorNameConst.Anchor1).addLast(new Double[]{turn, rxMeasureTime});
//                            break;
//                        case AnchorNameConst.Anchor2:
//                            anchor2TurnTime[Turn] = rxMeasureTime;
//                            anchorTime.get(AnchorNameConst.Anchor2).addLast(new Double[]{turn, rxMeasureTime});
//                            break;
//                        case AnchorNameConst.Anchor3:
//                            anchor3TurnTime[Turn] = rxMeasureTime;
//                            anchorTime.get(AnchorNameConst.Anchor3).addLast(new Double[]{turn, rxMeasureTime});
//                            break;
//                        default:
//                            break;
//                    }
                    if (count/3 == 100) {
                        calculatePosition();
                        count = 0;
                    }
                }
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void calculateDiffDeltaTime() {
        // 4549和6354
        Deque<Double[]> anchorTime1 = anchorTime.get(AnchorNameConst.Anchor2);
        Deque<Double[]> anchorTime2 = anchorTime.get(AnchorNameConst.Anchor1);
        double[] times1 = new double[256];
        double[] times2 = new double[256];

        Iterator<Double[]> iterator = anchorTime1.iterator();
        while (iterator.hasNext()) {
            Double[] turnAndTime = iterator.next();
            times1[(int) Math.round(turnAndTime[0])] = turnAndTime[1];
        }
        iterator = anchorTime2.iterator();
        while (iterator.hasNext()) {
            Double[] turnAndTime = iterator.next();
            times2[(int) Math.round(turnAndTime[0])] = turnAndTime[1];
        }

        for (int i=36;i<=189;i++) {
            double time1 = times1[i];
            double time2 = times2[i];

            if (time1>0 && time2>0) {
                System.out.print(i+""+":  ");
                System.out.println(Math.abs(time1-time2));
            }

        }

//        for (int i=36;i<=75;i++) {
//            double time1 = anchorTime1.removeFirst()[1];
//            double time2 = anchorTime2.removeFirst()[1];
//            System.out.println(Math.abs(time1-time2));
//        }
//        anchorTime1.removeFirst();
//        for (int i=77;i<=98;i++) {
//            if (i==77) {
//                Double[] tAndT = anchorTime1.getFirst();
//                System.out.println(tAndT[0]);
//            }
//            double time1 = anchorTime1.removeFirst()[1];
//            double time2 = anchorTime2.removeFirst()[1];
//            System.out.println(Math.abs(time1-time2));
//        }
//        anchorTime2.removeFirst();
//        for (int i=100;i<=110;i++) {
//            double time1 = anchorTime1.removeFirst()[1];
//            double time2 = anchorTime2.removeFirst()[1];
//            System.out.println(Math.abs(time1-time2));
//        }
//        anchorTime2.removeFirst();
//        anchorTime2.removeFirst();
//        for (int i=113;i<=138;i++) {
//            double time1 = anchorTime1.removeFirst()[1];
//            double time2 = anchorTime2.removeFirst()[1];
//            System.out.println(Math.abs(time1-time2));
//        }


//        Iterator<Double[]> iterator = anchorTime1.iterator();
//        while (iterator.hasNext()) {
//            Double[] turnAndTime = iterator.next();
//            System.out.print(turnAndTime[0]+"\t");
//        }
//        System.out.println();
//
//        iterator = anchorTime1.iterator();
//        while (iterator.hasNext()) {
//            Double[] turnAndTime = iterator.next();
//            System.out.print(turnAndTime[1]+"\t");
//        }
//        System.out.println();
//
//        iterator = anchorTime2.iterator();
//        while (iterator.hasNext()) {
//            Double[] turnAndTime = iterator.next();
//            System.out.print(turnAndTime[0]+"\t");
//        }
//        System.out.println();
//
//        iterator = anchorTime2.iterator();
//        while (iterator.hasNext()) {
//            Double[] turnAndTime = iterator.next();
//            System.out.print(turnAndTime[1]+"\t");
//        }
//        System.out.println();
//
//        iterator = anchorTime2.iterator();
    }

    public static void calculatePosition() {
//        Deque<Double[]> anchor1 = anchorTime.get(AnchorNameConst.Anchor1);
//        Deque<Double[]> anchor2 = anchorTime.get(AnchorNameConst.Anchor2);
//        Deque<Double[]> anchor3 = anchorTime.get(AnchorNameConst.Anchor3);
//
//        Map<Double, Double> anchorMap1 = new TreeMap<>();
//        Map<Double, Double> anchorMap2 = new TreeMap<>();
//        Map<Double, Double> anchorMap3 = new TreeMap<>();
//
//        Iterator<Double[]> iterator1 = anchor1.iterator();
//        while (iterator1.hasNext() && anchorMap1.size()<255) {
//            Double[] params = iterator1.next();
//            anchorMap1.put(params[0], params[1]);
//        }
//
//        iterator1 = anchor2.iterator();
//        while (iterator1.hasNext() && anchorMap2.size()<255) {
//            Double[] params = iterator1.next();
//            anchorMap2.put(params[0], params[1]);
//        }
//
//        iterator1 = anchor3.iterator();
//        while (iterator1.hasNext() && anchorMap3.size()<255) {
//            Double[] params = iterator1.next();
//            anchorMap3.put(params[0], params[1]);
//        }
//        for (int i=0;i<256;i++) {
//            System.out.println(anchor1TurnTime[i]);
//            System.out.println(anchor2TurnTime[i]);
//            System.out.println(anchor3TurnTime[i]);
//
//        }

        for (int i=0;i<256;i++) {
            double anchor1Time = anchor1TurnTime[i];
            double anchor2Time = anchor2TurnTime[i];
            double anchor3Time = anchor3TurnTime[i];

            if (anchor1Time==0||anchor2Time==0||anchor3Time==0) {
                continue;
            }

            double delta21 = anchor2Time-anchor1Time;
            double delta31 = anchor3Time-anchor1Time;

//            double x = FangMethodUtil.calcX(delta31, delta21);
//            double y = FangMethodUtil.calcY(delta31, delta21);

//            System.out.println("x location: "+x+", y location: "+y);
        }

//        Iterator<Double> iterator = anchorMap1.keySet().iterator();
//        while (iterator.hasNext()) {
//            double key = iterator.next();
//            double anchor1RxTime = anchorMap1.getOrDefault(key, 0.0);
//            double anchor2RxTime = anchorMap2.getOrDefault(key, 0.0);
//
//            if (anchor1RxTime==0.0 || anchor2RxTime==0.0) {
//                continue;
//            }
//            System.out.print("time1: "+anchor1RxTime+", time2: "+anchor2RxTime+", ");
//            System.out.println(Math.abs(anchor1RxTime - anchor2RxTime));
//
//        }



    }



}
