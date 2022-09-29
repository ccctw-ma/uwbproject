package com.uwb.uwb_server.utils;

import com.jmatio.io.MatFileReader;
import com.jmatio.types.MLArray;
import us.hebi.matlab.mat.format.Mat5;
import us.hebi.matlab.mat.types.MatFile;
import us.hebi.matlab.mat.types.Source;
import us.hebi.matlab.mat.types.Sources;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

/**
 * @author msc
 * @version 1.0
 * @date 2022/6/8 16:38
 */
public class Utils {


    public Map<String, MLArray> readMatFile() {
        MatFileReader reader;
        try {
            reader = new MatFileReader("D:/研究生学习/UWB冰场/uwbproject/UWB_Server/src/main/java/com/uwb/uwb_server/utils/dataCell_0524_moving2.mat");
            //reader = new MatFileReader(new File("./dataCell_0524_moving2.mat"));
            return reader.getContent();
        } catch (Exception e) {
            System.out.println("文件读取失败");
            e.printStackTrace();
        }

        //        Mat5File file = Mat5.readFromFile("D:\\研究生学习\\UWB冰场\\uwbproject\\UWB_Estimate\\dataCell_0524_moving2.mat");
        //
        //        Struct struct = file.getStruct("dataCell");
        //        System.out.println(struct);

        // Iterate over all entries in the mat file
        try (Source source = Sources.openFile("D:\\研究生学习\\UWB冰场\\uwbproject\\UWB_Estimate\\dataCell_0524_moving2.mat")) {
            MatFile mat = Mat5.newReader(source).readMat();
            for (MatFile.Entry entry : mat.getEntries()) {
                System.out.println(entry);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }


    public static List<String> readTxtFile(String filename) throws IOException {
        return Files.readAllLines(Paths.get(filename));
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
