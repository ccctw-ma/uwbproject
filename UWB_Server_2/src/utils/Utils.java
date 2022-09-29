package utils;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

/**
 * @author msc
 * @version 1.0
 * @date 2022/6/8 16:38
 */
public class Utils {

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
