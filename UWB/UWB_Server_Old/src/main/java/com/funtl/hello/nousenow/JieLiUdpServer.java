package com.funtl.hello.nousenow;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.concurrent.ExecutorService;

/**
 * 捷力的计算结果
 * @author LingZhe
 */
public class JieLiUdpServer {

    private static int port = 6667;

    private static DatagramSocket socket = null;

    private static ExecutorService poolExecutor = null;

    static {
        // 启动UDP Server
        try {
            socket = new DatagramSocket(port);
        } catch (SocketException e) {
            e.printStackTrace();
        }
        System.out.println("UDP 服务器已启动,正在监听JieLi的结果");
    }

    public static void service() {
        while (true) {
            try {
                DatagramPacket packet = new DatagramPacket(new byte[512], 512);
                System.out.println("-----------");
                socket.setSoTimeout(1500);

                socket.receive(packet);

                String msg = new String(packet.getData(), 0, packet.getLength(), StandardCharsets.UTF_8);
                String[] dataInfo = msg.split(",");
                System.out.println("===========");
                System.out.println(Arrays.toString(dataInfo));
//                DBCPUtil.writeJieLiDataByOneConn(dataInfo[2], dataInfo[3]);
            } catch (Exception e) {
                System.out.println(e);
            }
        }
    }

    public static void main(String[] args) {
        service();
    }
}
