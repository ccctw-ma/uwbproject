package com.uwb.uwb_server.domain;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.uwb.uwb_server.domain.UdpServer.KF;
import static com.uwb.uwb_server.domain.UdpServer.hasInit;

public class WorkerThread implements Runnable {
    private String uwbMessage;
    List<double[]> kalRes = new ArrayList<>();

    public WorkerThread(String dataInfo) {
        this.uwbMessage = dataInfo;
    }
    @Override
    public void run(){processData();}

    public void processData(){
        double[] data = parseData(uwbMessage);
        DataCell cell = new DataCell(data);

        if (!hasInit) {
            if (Double.isNaN(cell.x) || Double.isNaN(cell.y)) {
                return;
            }
            KF.initKf(cell);
            hasInit = true;
            kalRes.add(new double[]{cell.x, cell.y});
        } else {
            double[] res = KF.run(cell);
            kalRes.add(res);
        }
        new Thread(() -> System.out.println(Arrays.toString(kalRes.get(kalRes.size()-1)))).start();
//        System.out.println(Arrays.toString(kalRes.get(kalRes.size()-1)));
    }

    public static double[] parseData(String dataLine) {
        String[] strings = dataLine.split(",");
        double x = !strings[4].equals("nan") ? Double.parseDouble(strings[4]) : Double.NaN;
        double y = !strings[5].equals("nan") ? Double.parseDouble(strings[5]) : Double.NaN;
        String time = strings[8];

        int hour = Integer.parseInt(time.substring(11, 13));
        int minute = Integer.parseInt(time.substring(14, 16));
        int second = Integer.parseInt(time.substring(17, 19));
        int millisecond = Integer.parseInt(time.substring(20));
//        System.out.println(hour + " " + minute + " " + second + " " + millisecond);
        double timeStamp =  hour * 3600 + minute * 60 + second + millisecond * 1.0 / 1000;
        return new double[]{x, y, timeStamp};
    }
}
