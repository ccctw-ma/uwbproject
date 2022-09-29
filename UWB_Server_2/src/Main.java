import domain.DataCell;
import domain.KalmanFilter;
import utils.Utils;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Main {
    public static void main(String[] args) throws IOException {

//        String filePath = "C:\\Users\\Lenovo\\IdeaProjects\\uwb_Java\\src\\data\\8.3.txt";
//        String filePath = "C:\\Users\\Lenovo\\IdeaProjects\\uwb_Java\\src\\data\\2022-09-17-11-50-21[标签先举过头顶跑一个来回，后放胸口跑一个来回].txt";
//        String filePath = "C:\\Users\\Lenovo\\IdeaProjects\\uwb_Java\\src\\data\\test01.txt";
//        String filePath = "C:\\Users\\Lenovo\\IdeaProjects\\uwb_Java\\src\\data\\dataCell_0524_random.txt";
        String filePath = "C:\\Users\\Lenovo\\IdeaProjects\\uwb_Java\\src\\data\\dataCell_0524_moving1.txt";
        String outPutPath = "C:\\Users\\Lenovo\\IdeaProjects\\uwb_Java\\src\\data\\output.txt";
        List<String> lines = Utils.readTxtFile(filePath);
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

        try {
            FileWriter fw = new FileWriter(outPutPath);
            BufferedWriter bw = new BufferedWriter(fw);
            for (double[] doubles : kalRes) {
                System.out.println(Arrays.toString(doubles));
                bw.write(doubles[0] + "," + doubles[1] + "\r\n");// 往已有的文件上添加字符串
            }
            bw.close();
            fw.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}