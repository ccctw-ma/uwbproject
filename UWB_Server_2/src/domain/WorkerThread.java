package domain;

import java.io.IOException;
import java.net.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;

import static domain.TcpServer.*;

public class WorkerThread implements Runnable {
    private String uwbMessage;
    private List<String> ipList;

    private KalmanFilter kf;

    private String id;

    public WorkerThread(KalmanFilter kf, String dataInfo, String id) throws IOException {
        this.uwbMessage = dataInfo;
        this.ipList = Files.readAllLines(Paths.get("C:\\Program Files\\UWB\\ipConfig.txt"));
        this.kf = kf;
        this.id = id;
    }
    @Override
    public void run(){
        try {
            processData();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void processData() throws IOException {
        double[] data = parseData(this.uwbMessage);
        DataCell cell = new DataCell(data);

        if (!kf.hasInit) {
            if (Double.isNaN(cell.x) || Double.isNaN(cell.y)) {
                return;
            }
            kf.initKf(cell);
            kf.hasInit = true;
            double[] res = new double[]{cell.x, cell.y};
            sendLocInfo(res);
        } else {
            double[] res = kf.run(cell);
            sendLocInfo(res);
        }
    }

    public void sendLocInfo(double[] res) throws IOException {
        DatagramSocket ds = new DatagramSocket();
        byte[] bys = (this.id + "," + res[0] + "," + res[1]).getBytes();
        for(String ip : ipList){
            ip = ip.trim();
            String[] hostAddress = ip.split(":");
            DatagramPacket dp = new DatagramPacket(bys, bys.length, new InetSocketAddress(hostAddress[0],Integer.parseInt(hostAddress[1])));
            ds.send(dp);
        }
//        DatagramPacket dp = new DatagramPacket(bys, bys.length, new InetSocketAddress("localhost", 3460));
//        ds.send(dp);
        ds.close();
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
