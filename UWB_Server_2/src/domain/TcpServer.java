package domain;

import java.io.*;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class TcpServer {
    private static int port = 3456;
    private static String address = "127.0.0.1";
    private static Socket socket = null;
    private static ExecutorService poolExecutor = null;
    public static KalmanFilter KF = new KalmanFilter();
    public static boolean hasInit = false;
    public static String infoSavaPath = "C:\\Program Files\\UWB\\infoSaving\\" + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

    static {
        // 先用单线程线程池
        poolExecutor = Executors.newSingleThreadExecutor();
        // 启动UDP Server
        try {
            socket = new Socket("192.168.8.30", port);
            System.out.println("socket has been initialed...");
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println("TCP tube is already");
    }

    public static void service() {
        while (true) {
            try {
                InputStream in = socket.getInputStream();
                byte[] b = new byte[1024];
                int len = in.read(b);
                String msg = new String(b, 0, len);

                String dataInfo;
                if (msg.startsWith("nanoLES") && msg.contains("\r")) {
                    dataInfo = msg.substring(0, msg.lastIndexOf("\r\n"));
                    //将报文写入txt文件: WriteMsgToTxt(infoSavaPath, dataInfo);
                    new Thread(() -> WriteMsgToTxt(infoSavaPath, dataInfo)).start();
                    //开始进入计算流程
                    WorkerThread task = new WorkerThread(dataInfo);
                    poolExecutor.execute(task);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static void WriteMsgToTxt(String filePath, String msg) {
        try {
            FileWriter fw = new FileWriter(filePath, true);
            BufferedWriter bw = new BufferedWriter(fw);
            bw.write(msg + "\r\n");// 往已有的文件上添加字符串
            bw.close();
            fw.close();
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public static void main(String[] args) throws IOException {
        service();

//        本地测试
//        String filename = "/Users/leah/Work/309/IDEA_Projects/UWB_Server/src/main/java/com/uwb/uwb_server/utils/dataCell_0524_random.txt";
//        BufferedReader reader;
//        String line;
//        try {
//            reader = new BufferedReader(new FileReader(filename));
//            while ((line = reader.readLine()) != null) {
//                if (line.equals("")){
//                    continue;
//                }
//                WriteMsgToTxt(infoSavaPath, line);
//                WorkerThread thread = new WorkerThread(line);
//                poolExecutor.execute(thread);
//            }
//            System.out.println("while结束");
//            reader.close();
//        }catch (IOException ioException) {
//            System.err.println(ioException);
//        }
    }
}



