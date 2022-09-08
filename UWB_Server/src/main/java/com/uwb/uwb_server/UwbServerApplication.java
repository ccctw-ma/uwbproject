package com.uwb.uwb_server;

import com.uwb.uwb_server.domain.DataCell;
import com.uwb.uwb_server.domain.KalmanFilter;
import com.uwb.uwb_server.utils.Utils;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@SpringBootApplication
public class UwbServerApplication {

    public static void main(String[] args) throws IOException {
//        SpringApplication.run(UwbServerApplication.class, args);
//        System.out.println("Hello world");
//        String s = "nanoLES,TP,dadba4ef,00,nan,nan,nan,inf,2022-05-24T15:13:14.380,242,nan,0eb60101,1,new-section,-114.6";
//        System.out.println(Arrays.toString(Utils.parseData(s)));
//        List<String> lines = Utils.readTxtFile("/home/msc/uwbproject/UWB_Server/src/main/java/com/uwb/uwb_server/utils/dataCell_0524_random.txt");
//        List<String> lines = Utils.readTxtFile("/home/msc/uwbproject/UWB_Server/src/main/java/com/uwb/uwb_server/utils/dataCell_0524_moving1.txt");
        List<String> lines = Utils.readTxtFile("D:\\研究生学习\\UWB冰场\\uwbproject\\UWB_Server\\src\\main\\java\\com\\uwb\\uwb_server\\utils\\dataCell_0524_moving1.txt");
        boolean hasInit = false;
        KalmanFilter KF = new KalmanFilter();
        List<double[]> kalRes = new ArrayList<>();
        for (String line : lines) {
            double[] data = Utils.parseData(line);
            DataCell cell = new DataCell(data);
            if (!hasInit) {
                if (Double.isNaN(cell.x) || Double.isNaN(cell.y)) {
                    continue;
                }
                KF.initKf(cell);
                hasInit = true;
                kalRes.add(new double[]{cell.x, cell.y});
            } else {
                double[] res = KF.run(cell);
                kalRes.add(res);
            }
        }
        for (double[] doubles : kalRes) {
            System.out.println(Arrays.toString(doubles));
        }
    }

}
