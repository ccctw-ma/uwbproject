package com.funtl.hello.uwb;

import com.funtl.hello.nousenow.FangMethodUtil;

import java.util.Arrays;
import java.util.List;

/**
 * 工作线程
 * @author LingZhe
 */
public class WorkerThread implements Runnable {

    private String[] uwbMessage;

    private static int firstRoundCount = -1;
    private boolean isFirstRound = true;



    public WorkerThread(String dataInfo) {
        this.uwbMessage = dataInfo.split("\n");
//        for (int i = 0; i < uwbMessage.length; i++) {
//            System.out.println(i + "," + uwbMessage[i]);
//        }
    }

    //调试debug用参数
    static private int haveNullOrDataCount = 0;
    //调试用到的参数结束


    @Override
    public void run() {
        processData();
    }

    public boolean canLocateLabelPosition(int turn) {
        int validDataCount = 0;
        for (int i=0;i<4;i++) {
            if (UdpServer.anchorRxTime[turn][i] != 0.0) {
                validDataCount++;
            }
        }
//        System.out.println(validDataCount);
        return validDataCount == 4;
    }

    public void cleanThisSeqData(int seqNum) {
        UdpServer.anchorRxTime[seqNum][0] = 0.0;
        UdpServer.anchorRxTime[seqNum][1] = 0.0;
        UdpServer.anchorRxTime[seqNum][2] = 0.0;
        UdpServer.anchorRxTime[seqNum][3] = 0.0;
    }

    public void processData() {
        //先区分Uwb报文是否粘连如果粘连，如果粘连，用\r区分进入length=1的逻辑
//        String[] uwbMessage = str.split("\r");
//        System.out.println(Arrays.toString(uwbMessage));
        if (uwbMessage.length == 1) {
            //没有粘连，字符串数组内部只有一个较长的字符串[#RT……]
            String[] parameters = uwbMessage[0].split(",");
            if (!isLegalMessage(parameters)) {
                System.out.println("数据不合法，目前只能返回");
                return;
            }
            processParameters(parameters);

        } else if (uwbMessage.length == 2){
            //有粘连，字符串数组内部有两个#RT开头的报文[#RT……，#RT……]
            for (int i = 0; i < 2; i++) {
                String[] parameters = uwbMessage[i].split(",");
                if (!isLegalMessage(parameters)) {
                    System.out.println("数据不合法，目前只能返回");
                    return;
                }
                processParameters(parameters);
            }
        } else {
            System.out.println("传入的UwbMessage粘连出现其他问题");
        }
    }

    private void processParameters(String[] parameters) {
//        if(isFirstRound) {
//            if (firstRoundCount > 512){
//                isFirstRound = false;
//            }else {
//                firstRoundCount++;
//            }
//        }
        // 序列号
        int seqNum = Integer.parseInt(parameters[1]);
        // 发送的基站或标签
        String sendAnchorOrLabel = parameters[2];
        // 接收
        String receiveAnchor = parameters[3];
        // 接收时间
        double rxTime = UwbRxTimeUtil.rxTimeTransform(parameters[4], parameters[5]);
//        System.out.println(rxTime);
        // 定位数据包
        if (sendAnchorOrLabel.equals(AnchorNameConst.Label)) {
            // 基站接收到定位数据的本地时间
            if (receiveAnchor.equals(AnchorNameConst.Anchor1)) {
                UdpServer.anchorRxTime[seqNum][0] = rxTime;
            } else if (receiveAnchor.equals(AnchorNameConst.Anchor2)) {
                UdpServer.anchorRxTime[seqNum][1] = rxTime;
            } else if (receiveAnchor.equals(AnchorNameConst.Anchor3)) {
                UdpServer.anchorRxTime[seqNum][2] = rxTime;
            } else if (receiveAnchor.equals(AnchorNameConst.Anchor4)) {
                UdpServer.anchorRxTime[seqNum][3] = rxTime;
            }
            if (canLocateLabelPosition(seqNum)) {
                double time1 = UdpServer.anchorRxTime[seqNum][0];
                double time2 = UdpServer.anchorRxTime[seqNum][1];
                double time3 = UdpServer.anchorRxTime[seqNum][2];
                double time4 = UdpServer.anchorRxTime[seqNum][3];
//                System.out.println(time1 + "," + time2 + "," + time3 + "," + time4);
                if (!TimeUtil.haveNullOrDataThisTurn()) {
                    ++haveNullOrDataCount;
                    if (haveNullOrDataCount % 5 == 0 || haveNullOrDataCount == 1 ) {
                        System.out.println("第" + haveNullOrDataCount + "次，TimeUtil.haveNullOrData returned");
                    }
                    return;
                }
                TimeUtil.calculateSkewAndOffset(); //计算时钟偏斜并补偿
                time1 = CalculateTimeUtil.calculateAnchor1RelativeTime(time1);
                time3 = CalculateTimeUtil.calculateAnchor3RelativeTime(time3);
                time4 = CalculateTimeUtil.calculateAnchor4RelativeTime(time4);
                double[] time = new double[]{time1, time2, time3, time4};
                cleanThisSeqData(seqNum);
                XYTDOA chanTDOA = new XYTDOA(time); //XYTDOA 用来解定位结果
                chanTDOA.Calculate();
                new Thread(() -> System.out.format("chan定位结果，X: %.2f, Y: %.2f\n",chanTDOA.POS_X,chanTDOA.POS_Y)).start();
                TaylorAlgorithm taylorAlgorithm = new TaylorAlgorithm(time);
                taylorAlgorithm.taylorCalculateXY(chanTDOA.POS_X,chanTDOA.POS_Y);
//                new Thread(() -> System.out.format("taylor定位结果，X: %.2f, Y: %.2f\n",taylorAlgorithm.position.getX(),taylorAlgorithm.position.getY())).start();
//                if (chanTDOA.POS_X == 0d && chanTDOA.POS_Y == 0d) {
//                    System.out.println("=======================");
//                    System.out.println(Arrays.toString(time));
//                    System.out.format("定位结果，X: %.2f, Y: %.2f\n",chanTDOA.POS_X,chanTDOA.POS_Y);
//                    System.out.println("=======================");
//                }else {
//                    System.out.format("taylor定位结果，X: %.2f, Y: %.2f\n",taylorAlgorithm.position.getX(),taylorAlgorithm.position.getY());
//                }
            }
        } else if (sendAnchorOrLabel.equals(AnchorNameConst.Anchor1)){ // 基站同步数据包
            TimeUtil.putAnchorTime(sendAnchorOrLabel,receiveAnchor,seqNum,rxTime);
        } else if (sendAnchorOrLabel.equals(AnchorNameConst.Anchor3)) {
            TimeUtil.putAnchorTime(sendAnchorOrLabel,receiveAnchor,seqNum,rxTime);
        }
    }

    private boolean isLegalMessage(String[] parameters) {
        //检查parameters每一项是否合规
        if (!parameters[0].equals("#RT")) {
            System.out.println("报头不是#RT");
            return false;
        }
        if (parameters[1].length() != 3 || (Integer.parseInt(parameters[1]) > 255 && Integer.parseInt(parameters[1]) < 0)) {
            System.out.println("序列有错，大了或小了或粘连了");
            return false;
        }
        if (parameters[2].length() != 8) {
            System.out.println("报文中发出基站ID有问题");
            return false;
        }
        if (parameters[3].length() != 8) {
            System.out.println("报文中接受基站ID有问题");
            return false;
        }
        return true;
    }
}
