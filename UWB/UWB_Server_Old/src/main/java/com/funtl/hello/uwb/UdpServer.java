package com.funtl.hello.uwb;


import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.*;

/**
 *
 * @author LingZhe
 */
public class UdpServer {

    private static int port = 6666;

    private static int seqNum = 256;

    private static DatagramSocket socket = null;

    private static ExecutorService poolExecutor = null;


    // 基站收到标签的定位数据包的时间
    public static double[][] anchorRxTime = new double[seqNum][4];

    static {
        // 先用单线程线程池
        poolExecutor = Executors.newSingleThreadExecutor();
//        poolExecutor = new ThreadPoolExecutor(5, 10, 200, TimeUnit.MILLISECONDS,
//                new ArrayBlockingQueue<Runnable>(100));
        // 启动UDP Server
        try {
            socket = new DatagramSocket(port);
        } catch (SocketException e) {
            e.printStackTrace();
        }
        System.out.println("UDP 管道已启动");
    }

    public static void service() {
        while (true) {
            try {
                DatagramPacket packet = new DatagramPacket(new byte[512], 512);
                socket.receive(packet);
                String msg = new String(packet.getData(), 0, packet.getLength(), StandardCharsets.UTF_8);
                String dataInfo;
//                System.out.print(msg);
                if (msg.startsWith("#RT") && msg.contains("\r")) {
                    dataInfo = msg.substring(0, msg.lastIndexOf("\r\n"));
                    //原始报文
                    System.out.println(dataInfo);

                    WorkerThread task = new WorkerThread(dataInfo);
                    poolExecutor.execute(task);
                }
                //
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private static final String filename = "F:\\aa研究生工作\\实验室\\孟令哲UWB\\TDOA定位系统\\TDOA定位系统\\2. 自产开放系统\\Posense V1.1\\Database\\Log_20210928_201601.csv";
    public static void simulateOperation(String filename) {
        BufferedReader reader;
        String line;
//        int count = 0;
        try {
            reader = new BufferedReader(new FileReader(filename));
            while ((line = reader.readLine()) != null) {
//                count++;
//                System.out.println(count);
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

    public static void main(String[] args) {
        service();
//        simulateOperation(filename);

    }

}
