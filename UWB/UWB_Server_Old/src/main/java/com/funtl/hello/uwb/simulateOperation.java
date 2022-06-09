package com.funtl.hello.uwb;

import java.io.BufferedReader;
import java.io.FileReader;



public class simulateOperation {
    private static final String FILENAME = "E:\\aa研究生工作\\aa毕业论文相关\\UWB数据集\\home\\dataCell2Csv.csv";
    public static void simulateOperation(String filename) {
        BufferedReader reader;
        String line;
        try {
            reader = new BufferedReader(new FileReader(filename));
            while ((line = reader.readLine()) != null) {
                if (!line.startsWith("#RT")){
                    continue;
                }
                WorkerThread thread = new WorkerThread(line);
//                poolExecutor.execute(thread);
//                System.out.println(line);
            }
            reader.close();

        }catch (Exception e) {
            System.err.println(e);
        }finally {
//            socket.close();
//            poolExecutor.shutdown();
        }
    }
}
