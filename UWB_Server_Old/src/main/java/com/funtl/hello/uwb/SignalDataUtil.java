package com.funtl.hello.uwb;

import com.csvreader.CsvWriter;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 * 信号处理工具
 * @author LingZhe
 */
public class SignalDataUtil {

    private static ExecutorService fileWritePoolExecutor = Executors.newSingleThreadExecutor();


    static List<List<String>> prepareData = new LinkedList<>();

    public static List<String> splitSignalData(String signals, String pw1, String pw2, String nlos,
                                               double x, double y) {
        String[] channelData = signals.split("-");
        String[] data = new String[channelData.length];
        for (int i=0;i<channelData.length;i++) {
            long tmp = UwbRxTimeUtil.parseStr16ToLong(channelData[i]);
            data[i] = String.valueOf(tmp);
        }

        List<String> rowData = new LinkedList<>(Arrays.asList(data));
        rowData.add(pw1);
        rowData.add(pw2);
        rowData.add(nlos);
        rowData.add(String.valueOf(x));
        rowData.add(String.valueOf(y));

        return rowData;

//        prepareData.add(rowData);
//
//        if (prepareData.size() > 5) {
//            FileThread thread = new FileThread(prepareData);
//            Future future = fileWritePoolExecutor.submit(thread);
//            if (future.isDone()) {
//                prepareData.clear();
//            }
//        }

    }



}
