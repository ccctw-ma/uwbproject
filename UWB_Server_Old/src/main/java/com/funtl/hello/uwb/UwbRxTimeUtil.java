package com.funtl.hello.uwb;

/**
 * uwb定位基站时间转换工具
 *
 * @author LingZhe
 */
public class UwbRxTimeUtil {

    private static final long con1 = 0x10000000000L;

    private static final long con2 = 0x100000000L;

    private static final double con3 = 63897600000.0;

    //下边几个被con123替代操作了
    private static final double highConst = 17.207401025641025641025641025641;
    private static final double lowConst = 0.06721641025641025641025641025641;
    private static final double divisorConst = 63897600000.0;

    /**
     * 原数据16进制数据转换
     *
     * @param rxTimeHigh //时间高位，四个字节
     * @param rxTimeLow  //时间低位，五个字节,最高字节组成tmpTimeLow_H，最低4字节组成tmpTimeLow_L
     * @return
     */
    public static double rxTimeTransform(String rxTimeHigh, String rxTimeLow) {
        long[] rxTimes = stringTimeTransformRx(rxTimeHigh, rxTimeLow);

        //处理完字符串，得到时间高位 和 低位
        long rxHigh = rxTimes[0];
        long rxLowH = rxTimes[1];
        long rxLowL = rxTimes[2];

        //计算接收时间 RxMeasureTime
        return calculate(rxHigh, rxLowH, rxLowL);
    }

    private static double calculate(long rxTimeHigh, long rxTimeLowH, long rxTimeLowL) {
        long v = 0;
        v += rxTimeHigh * con1;
        v += rxTimeLowH * con2;
        v += rxTimeLowL;

        double res = v + 0.0;
        return res / con3;
    }

    /**
     * 时间格式分割提取
     *
     * @return
     */
    public static long[] stringTimeTransformRx(String rxTimeHigh, String rxTimeLow) {
        //处理高位
        int rxTimeLen = rxTimeHigh.length(); //高4位例：00000047
        int begin;
        for (begin = 0; begin < rxTimeLen; begin++) {//有0就跳过,找到第一个不为0的
            if (rxTimeHigh.charAt(begin) != '0') {
                break;
            }
        }
                                                            //01234567 len=8
        rxTimeHigh = rxTimeHigh.substring(begin, rxTimeLen);//00000047

        //处理低位 前两个字符是 时间低位中的 5字节中的 最高字节，剩下8个字符是 后四个字节
        String rxTimeLowH = rxTimeLow.substring(0, 2);
        String rxTimeLowL = rxTimeLow.substring(2);

        long rxHigh = parseStr16ToLong(rxTimeHigh);
        long rxLowH = parseStr16ToLong(rxTimeLowH);
        long rxLowL = parseStr16ToLong(rxTimeLowL);

        return new long[]{rxHigh, rxLowH, rxLowL};
    }

    /**
     * 字符串16进制转换
     *
     * @param str16
     * @return
     */
    public static long parseStr16ToLong(String str16) {
        str16 = str16.toLowerCase();
        byte[] bA = str16.getBytes();
        long result = 0L;
        for (int i = 0; i < bA.length; i++) {
            result <<= 4;
            byte b = (byte) (bA[i] - 48);
            if (b > 9) {
                b = (byte) (b - 39);
            }
            // 非16进制字符
            if (b > 15 || b < 0) {
                throw new NumberFormatException("For input String '" + str16);
            }
            result += b;
        }
        return result;
    }

    public static void main(String[] args) {
//        System.out.println();
    }

}
