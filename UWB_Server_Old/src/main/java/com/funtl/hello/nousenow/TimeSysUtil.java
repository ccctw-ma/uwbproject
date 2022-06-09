package com.funtl.hello.nousenow;

import com.funtl.hello.uwb.AnchorNameConst;
import com.funtl.hello.uwb.UwbRxTimeUtil;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

/**
 * old
 * 利用四基站，预处理数据，
 * 取4549从开始序号到000
 * @author LingZhe
 */
public class TimeSysUtil {

//    static String timeDataCsv = "E:\\309\\TDOA定位系统\\TDOA定位系统\\2. 自产开放系统\\Posense V1.1\\Database\\cleanData+F5024549.csv";

    static String timeDataCsv = "D:\\aa研究生工作\\实验室\\孟令哲UWB\\TDOA定位系统\\TDOA定位系统\\2. 自产开放系统\\Posense V1.1\\Database\\Log_20210602_112856.csv";

    static String originDataCsv = "D:\\aa研究生工作\\实验室\\孟令哲UWB\\\\TDOA定位系统\\TDOA定位系统\\2. 自产开放系统\\Posense V1.1\\Database\\testdata.csv";

    static Double delta21 = 0.0;

    static Double delta31 = 0.0;

    public static void prepare() {
        double[][] rxTimes = new double[256][3];
        BufferedReader reader = null;
        String line = null;
        try {
            reader = new BufferedReader(new FileReader(timeDataCsv));
            while ((line = reader.readLine()) != null) {
                String[] parameters = line.split(",");
                if (parameters.length>3 && parameters[2].equals(AnchorNameConst.Anchor1)) {
                    Integer seqNum = Integer.parseInt(parameters[1]);
                    double rxTime = UwbRxTimeUtil.rxTimeTransform(parameters[4], parameters[5]);
//                    switch (parameters[3]) {
//                        case AnchorNameConst.Anchor2:
//                            rxTimes[seqNum][0] = rxTime;
//                            break;
//                        case AnchorNameConst.Anchor3:
//                            rxTimes[seqNum][1] = rxTime;
//                            break;
//                        case AnchorNameConst.Anchor4:
//                            rxTimes[seqNum][2] = rxTime;
//                            break;
//                        default:
//                            break;
//                    }
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

        for (int num=10;num<=100;num+=10) {
            int beginSeq = 174;
            double delta21 = 0.0;
            double delta31 = 0.0;
            for (int i=0;i<num;i++) {
                beginSeq = beginSeq%256;
                delta21 += (rxTimes[beginSeq][1] - rxTimes[beginSeq][0]);
                delta31 += (rxTimes[beginSeq][2] - rxTimes[beginSeq][0]);
                beginSeq++;
            }
            delta21 = delta21/num;
            delta31 = delta31/num;

            System.out.println("delta12: "+delta21+", delta13: "+delta31);
        }

    }

    /**
     * 时钟同步
     * 暂时以4549为参考节点
     * RBS:Reference-Broadcast Synchronization
     * m: packets
     * n: receivers
     */
    public static void rbsTimeSynchronized() {
        BufferedReader reader = null;
        String line = null;
        Double[] anchor1 = new Double[256];
        Double[] anchor2 = new Double[256];
        Double[] anchor3 = new Double[256];
        try {
            reader = new BufferedReader(new FileReader(timeDataCsv));
            while ((line = reader.readLine()) != null) {
                String[] anchorsTimes = line.split(",");
                Integer turn1 = Integer.parseInt(anchorsTimes[1]);
                anchor1[turn1] = (Double.parseDouble(anchorsTimes[6]));
                Integer turn2 = Integer.parseInt(anchorsTimes[13]);
                anchor2[turn2] = (Double.parseDouble(anchorsTimes[18]));
                Integer turn3 = Integer.parseInt(anchorsTimes[19]);
                anchor3[turn3] = (Double.parseDouble(anchorsTimes[24]));
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

        int count = 0;
        for (int i=33;i<170;i++) {
            delta21 += (anchor1[i] - anchor2[i]);
            delta31 += (anchor1[i] - anchor3[i]);
            count++;
        }
        delta21 = delta21 / count;
        delta31 = delta31 / count;
        System.out.println("delta21:"+delta21);
        System.out.println("delta31:"+delta31);
    }

    public static void calculateLocation() {
        BufferedReader reader = null;
        String line = null;
        Double[][] syncTimes = new Double[256][3];
        for (int i=0;i<256;i++) {
            syncTimes[i] = new Double[3];
            for (int j=0;j<3;j++) {
                syncTimes[i][j] = 0.0;
            }
        }
        try {
            reader = new BufferedReader(new FileReader(originDataCsv));
            while ((line = reader.readLine()) != null) {
                String[] params = line.split(",");
                if (params.length > 3 && params[2].equals(AnchorNameConst.Label)) {
                    Integer turn = Integer.parseInt(params[1]);
//                    switch (params[3]) {
//                        case AnchorNameConst.Anchor1:
//                            syncTimes[turn][0] = UwbRxTimeUtil.rxTimeTransform(params[4], params[5]);
//                            break;
//                        case AnchorNameConst.Anchor2:
//                            break;// Do Nothing
//                        case AnchorNameConst.Anchor3:
//                            syncTimes[turn][1] = UwbRxTimeUtil.rxTimeTransform(params[4], params[5]);
//                            break;
//                        case AnchorNameConst.Anchor4:
//                            syncTimes[turn][2] = UwbRxTimeUtil.rxTimeTransform(params[4], params[5]);
//                            break;
//                        default:
//                            break;
//                    }
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

        for (int i=0;i<256;i++) {
            syncTimes[i][1] += delta21;
            syncTimes[i][2] += delta31;

            if (syncTimes[i][0]!=0.0 && syncTimes[i][1]!=0.0 && syncTimes[i][2]!=0.0) {
                System.out.print("d31:"+(syncTimes[i][2]-syncTimes[i][0])+"\t");
                System.out.print("d21:"+(syncTimes[i][1]-syncTimes[i][0])+"\t");
//                double x = FangMethodUtil.calcX(syncTimes[i][2]-syncTimes[i][0], syncTimes[i][1]-syncTimes[i][0]);
//                double y = FangMethodUtil.calcY(syncTimes[i][2]-syncTimes[i][0], syncTimes[i][1]-syncTimes[i][0]);
//                System.out.print(x+"\t");
//                System.out.println(y);
            }
        }

    }

}
