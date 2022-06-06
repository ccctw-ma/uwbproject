package com.funtl.hello.nousenow;

import com.funtl.hello.uwb.*;

import java.util.List;

public class WorkerThreadBackup20210928  implements Runnable {

    private String str;

    public WorkerThreadBackup20210928(String str) {
        this.str = str;
    }

    //调试debug用参数
    static private int haveNullOrDataCount = 0;
    //调试用到的参数结束

    @Override
    public void run() {
//        prepareData();
    }

    /**
     *
     */
//    public void prepareData() {
//        String[] parameters = str.split(",");
//        if (parameters.length<=6) {
//            System.out.println("parameters.length<=6");
//            return;
//        }
////        System.out.println("解析后的报文数组：" + Arrays.toString(parameters));
//        // 序列号
//        int seqNum = Integer.parseInt(parameters[1]);
//        // 发送
//        String sendAnchorOrLabel = parameters[2];
//        // 接收
//        String receiveAnchor = parameters[3];
//        // 接收时间
//        double rxTime = UwbRxTimeUtil.rxTimeTransform(parameters[4], parameters[5]);
//        // 定位数据包
//        if (sendAnchorOrLabel.equals(AnchorNameConst.Label)) {
//            // 基站接收到定位数据的本地时间
//            if (receiveAnchor.equals(AnchorNameConst.Anchor1)) {
//                UdpServer.anchorRxTime[seqNum][0] = rxTime;
////               System.out.println("准备数据中的A1的rxTime:" + UdpServer.anchorRxTime[seqNum][0]);                //这里输出一个浮点数
//            } else if (receiveAnchor.equals(AnchorNameConst.Anchor2)) {
//                UdpServer.anchorRxTime[seqNum][1] = rxTime;
////               System.out.println("准备数据中的A2的rxTime:" + UdpServer.anchorRxTime[seqNum][1]);
//            } else if (receiveAnchor.equals(AnchorNameConst.Anchor3)) {
//                UdpServer.anchorRxTime[seqNum][2] = rxTime;
////               System.out.println("准备数据中的A3的rxTime:" + UdpServer.anchorRxTime[seqNum][2]);
//            } else if (receiveAnchor.equals(AnchorNameConst.Anchor4)) {
//                UdpServer.anchorRxTime[seqNum][3] = rxTime;
////               System.out.println("准备数据中的A4的rxTime:" + rxTime);
//            }
//            if (canLocateLabelPosition(seqNum)) {
//                double time1 = UdpServer.anchorRxTime[seqNum][0];
//                double time2 = UdpServer.anchorRxTime[seqNum][1];
//                double time3 = UdpServer.anchorRxTime[seqNum][2];
//                double time4 = UdpServer.anchorRxTime[seqNum][3];
////               System.out.println("seq:"+seqNum+",\ttime: "+time1+",\t"+time2+",\t"+time3+",\t"+time4); //20210826注掉
////               TimeUtil.calculateOffset();
//                if (!TimeUtil.haveNullOrData()) {
////                   System.out.println("TimeUtil return了");
//                    if (haveNullOrDataCount % 10 == 0) {
//                        System.out.println("第" + ++haveNullOrDataCount + "次，TimeUtil.haveNullOrData returned");
//                    }
//                    return;
//                }
//                TimeUtil.calculateSkewAndOffset();
//                time1 = CalculateTimeUtil.calculateAnchor1RelativeTime(time1);
//                time3 = CalculateTimeUtil.calculateAnchor3RelativeTime(time3);
//                time4 = CalculateTimeUtil.calculateAnchor4RelativeTime(time4);
////               System.out.println("time: "+time1+",\t"+time2+",\t"+time3+",\t"+time4); //20210826注掉
//                double[] time = new double[]{time1, time2, time3, time4};
////               calculateLocation(time);
//                cleanThisSeqData(seqNum);
//                XYTDOA chanTDOA = new XYTDOA(time); //XYTDOA 用来解定位结果
//                chanTDOA.Calculate();
////               System.out.println("pos_x and pos_y is: " + chanTDOA.POS_X+","+chanTDOA.POS_Y);//改为下边的format输出
//                System.out.format("X: %.2f, Y: %.2f\n",chanTDOA.POS_X,chanTDOA.POS_Y);
//                List<String> data = SignalDataUtil.splitSignalData(parameters[6], parameters[7], parameters[8], parameters[9],
//                        chanTDOA.POS_X, chanTDOA.POS_Y);
////               DBCPUtil.writeDbByOneConnc(data); //这里的某一句会输出false  会卡住 直接注掉了20210826
////               if (d2 > 0.0) {
////                   deltaTime21 = Math.abs(UdpServer.anchorRxTime[seqNum][1] - d2 - UdpServer.anchorRxTime[seqNum][0]);
////                   if (d3 > 0.0) {
////                       deltaTime31 = Math.abs(UdpServer.anchorRxTime[seqNum][2] - d3 - UdpServer.anchorRxTime[seqNum][0]);
////                   } else {
////                       deltaTime31 = Math.abs(UdpServer.anchorRxTime[seqNum][2] + d3 - UdpServer.anchorRxTime[seqNum][0]);
////                   }
////               } else if (d2 < 0.0) {
////                   deltaTime21 = Math.abs(UdpServer.anchorRxTime[seqNum][1] + d2 - UdpServer.anchorRxTime[seqNum][0]);
////                   if (d3 > 0.0) {
////                       deltaTime31 = Math.abs(UdpServer.anchorRxTime[seqNum][2] - d3 - UdpServer.anchorRxTime[seqNum][0]);
////                   } else {
////                       deltaTime31 = Math.abs(UdpServer.anchorRxTime[seqNum][2] + d3 - UdpServer.anchorRxTime[seqNum][0]);
////                   }
////               }
//                // 输出定位坐标
////               SignalDataUtil.splitSignalData(parameters[6], chanS[2], chanS[3]);
//            }
//        } else if (sendAnchorOrLabel.equals(AnchorNameConst.Anchor1)){ // 基站同步数据包
//            TimeUtil.storeAnchorTime(str);
////           AdjustTimeUtil.setBeginSeq(seqNum);
////           if (receiveAnchor.equals(AnchorNameConst.Anchor2)) {
////               AdjustTimeUtil.referenceTime[seqNum][0] = rxTime;
////           } else if (receiveAnchor.equals(AnchorNameConst.Anchor3)) {
////               AdjustTimeUtil.referenceTime[seqNum][1] = rxTime;
////           } else if (receiveAnchor.equals(AnchorNameConst.Anchor4)) {
////               AdjustTimeUtil.referenceTime[seqNum][2] = rxTime;
////           }
////
////           AdjustTimeUtil.addDataCount();
////           if (AdjustTimeUtil.haveEnoughDataCount()) {
////               AdjustTimeUtil.calculateSkewAndOffset(seqNum);
////           }
//        } else if (sendAnchorOrLabel.equals(AnchorNameConst.Anchor3)) {
//            TimeUtil.storeAnchorTime(str);
//        }
//    }

    public boolean canLocateLabelPosition(int turn) {
        int validDataCount = 0;
        for (int i=0;i<4;i++) {
            if (UdpServer.anchorRxTime[turn][i] != 0.0) {
                validDataCount++;
            }else {
                System.out.println("数组第" + i +"个为空，检查第" + i + "个基站");
            }
        }
        return validDataCount == 4;
//                AdjustTimeUtil.isIsAdjustDelta() &&
//                UdpServer.anchorRxTime[turn][0] != 0.0 &&
//                UdpServer.anchorRxTime[turn][1] != 0.0 &&
//                UdpServer.anchorRxTime[turn][2] != 0.0;
    }

    public void cleanThisSeqData(int seqNum) {
        UdpServer.anchorRxTime[seqNum][0] = 0.0;
        UdpServer.anchorRxTime[seqNum][1] = 0.0;
        UdpServer.anchorRxTime[seqNum][2] = 0.0;
        UdpServer.anchorRxTime[seqNum][3] = 0.0;
    }

    public double[][] calculateLocation(double[] times) {
        double t1 = times[0];
        double t2 = times[1];
        double t3 = times[2];
        double t4 = times[3];
        double[][] result = new double[4][4];
        // 1,2,3
//        result[0] = ChanMethodUtil.calculateLocation(Math.abs(t2-t1), Math.abs(t3-t1));
        result[0] = FangMethodUtil.calcXAndY(Math.abs(t2-t1), Math.abs(t3-t1));
        // 1,2,4
//        result[1] = ChanMethodUtil.calculateLocation(Math.abs(t2-t1), Math.abs(t4-t1));
        result[1] = FangMethodUtil.calcXAndY(Math.abs(t2-t1), Math.abs(t4-t1));
        // 1,3,4
//        result[2] = ChanMethodUtil.calculateLocation(Math.abs(t3-t1), Math.abs(t4-t1));
        result[2] = FangMethodUtil.calcXAndY(Math.abs(t3-t1), Math.abs(t4-t1));
        // 2,3,4
//        result[3] = ChanMethodUtil.calculateLocation(Math.abs(t3-t2), Math.abs(t4-t2));
        result[3] = FangMethodUtil.calcXAndY(Math.abs(t3-t2), Math.abs(t4-t2));

        for (int i=0;i<4;i++) {
            for (int j=0;j<4;j++) {
                System.out.print(result[i][j]+"\t");
            }
            System.out.println();
        }
        return result;
    }
}