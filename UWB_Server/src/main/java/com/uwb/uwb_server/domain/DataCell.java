package com.uwb.uwb_server.domain;


/**
 * @author msc
 * @version 1.0
 * @date 2022/5/31 15:47
 */

public class DataCell {

    // 协议头
    public String protocolHeader;

    //数据类型
    public String dataType;

    //ID
    public String ID;

    //坐标 x, y, z
    public double x;
    public double y;
    public double z;

    //时间
    public double t;

    //序号
    public long sequenceNumber;

    //是否有效
    public boolean isValid;

    //信号均值
    public double meanSignal;


    public DataCell(double x, double y, double timeStamp) {
        this.x = x;
        this.y = y;
        this.t = timeStamp;
    }

    public DataCell(double[] data) {
        this.x = data[0];
        this.y = data[1];
        this.t = data[2];
    }

    public DataCell(String id, double x, double y, double z, double timeStamp, long sequenceNumber, boolean isValid, double meanSignal) {
        this.ID = id;
        this.x = x;
        this.y = y;
        this.z = z;
        this.t = timeStamp;
        this.sequenceNumber = sequenceNumber;
        this.isValid = isValid;
        this.meanSignal = meanSignal;
    }

}
