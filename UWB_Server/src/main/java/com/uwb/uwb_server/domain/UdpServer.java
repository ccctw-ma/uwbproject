package com.uwb.uwb_server.domain;

import com.uwb.uwb_server.utils.Utils;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class UdpServer {
    private static int port = 3456;
    private static DatagramSocket socket = null;
    private static ExecutorService poolExecutor = null;
    public static boolean hasInit = false;
    public static KalmanFilter KF = new KalmanFilter();

    static {
        // 先用单线程线程池
        poolExecutor = Executors.newSingleThreadExecutor();
        // 启动UDP Server
        try {
            socket = new DatagramSocket(port);
        } catch (SocketException e) {
            e.printStackTrace();
        }
        System.out.println("UDP 管道已启动");
    }

    public static void service(){
        while (true) {
            try {
                DatagramPacket packet = new DatagramPacket(new byte[512], 512);
                socket.receive(packet);
                String msg = new String(packet.getData(), 0, packet.getLength(), StandardCharsets.UTF_8);
                String dataInfo;
//                System.out.print(msg);
                if (msg.startsWith("nanoLES") && msg.contains("\r")) {
                    dataInfo = msg.substring(0, msg.lastIndexOf("\r\n"));
                    //原始报文
//                    System.out.println(dataInfo);

                    WorkerThread task = new WorkerThread(dataInfo);
                    poolExecutor.execute(task);
                }
                //
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    public static void main(String[] args) throws IOException{
//        service();

        //本地测试
//        String filename = "/Users/leah/Work/309/IDEA_Projects/UWB_Server/src/main/java/com/uwb/uwb_server/utils/dataCell_0524_random.txt";
        String filename = "/home/msc/uwbproject/UWB_Server/src/main/java/com/uwb/uwb_server/utils/dataCell_0524_random.txt";
        BufferedReader reader;
        String line;
        try {
            reader = new BufferedReader(new FileReader(filename));
            while ((line = reader.readLine()) != null) {
                if (line.equals("")){
                    continue;
                }
                WorkerThread thread = new WorkerThread(line);
                poolExecutor.execute(thread);
            }
            System.out.println("while结束");
            reader.close();
        }catch (IOException ioException) {
            System.err.println(ioException);
        }
    }
}
