package com.funtl.hello.nousenow;

import com.csvreader.CsvWriter;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;

/**
 * @author LingZhe
 */
public class FileThread implements Runnable {

    private List<List<String>> data;

    public FileThread (List<List<String>> data) {
        this.data = data;
    }

    @Override
    public void run() {
        writeDb(data);
    }

    public void writeDb(List<List<String>> lists) {
        DBCPUtil.writeDbByOneConn(lists);
    }

    public static void writeCsv(List<List<String>> lists) {
        File outFile = new File("D:\\aa研究生工作\\实验室\\孟令哲UWB\\TDOA定位系统\\TDOA定位系统\\2. 自产开放系统\\Posense V1.1\\Database\\" +"20210608.csv");
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(outFile));
            CsvWriter csvWriter = new CsvWriter(writer, ',');
            for (int i=0;i<lists.size();i++) {
                List<String> row = lists.get(i);
                StringBuilder inString = new StringBuilder();

                for (int j=0;j<row.size();j++) {
                    inString.append(row.get(j));
                    inString.append(',');
                }
                // 第一个参数表示要写入的字符串数组，每一个元素占一个单元格，第二个参数为true时表示自动换行
                csvWriter.writeRecord(inString.toString().split(","), true);
//                csvWriter.endRecord();// 换行
                csvWriter.flush();
            }

            csvWriter.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void writeDataByDBCP(List<String> data) {

    }
}
