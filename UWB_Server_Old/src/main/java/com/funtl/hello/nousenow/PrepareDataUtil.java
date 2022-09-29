package com.funtl.hello.nousenow;

import com.csvreader.CsvWriter;
import com.funtl.hello.uwb.AnchorNameConst;
import com.funtl.hello.uwb.UwbRxTimeUtil;

import java.io.*;
import java.util.LinkedList;
import java.util.List;

/**
 * old
 * 以定位标签到基站的时间数据建立时间序列
 * 四个基站
 * 2021-05-21
 * @author LingZhe
 */
public class PrepareDataUtil {

    static final String[][] base = new String[256][8];

    static final double[][] baseTime = new double[256][4];

    static final String csvSplitBy = ",";

    /**
     * 根据文件建立基础时间体系
     *
     * @param fileName
     */
    public static void buildBaseMatrix(String fileName) {
        BufferedReader reader = null;
        String line = "";
        int count = 0;
        try {
            reader = new BufferedReader(new FileReader(fileName));
            while ((line = reader.readLine()) != null ) {
                String[] params = line.split(csvSplitBy);
                if (params.length>=3 && params[2].equals(AnchorNameConst.Label)) {
                    Integer turn = Integer.parseInt(params[1]);
//                    switch (params[3]) {
//                        case AnchorNameConst.Anchor2:
//                            base[turn][0] = params[3];
//                            base[turn][1] = params[4];
//                            break;
//                        case AnchorNameConst.Anchor3:
//                            base[turn][2] = params[3];
//                            base[turn][3] = params[4];
//                            break;
//                        case AnchorNameConst.Anchor4:
//                            base[turn][4] = params[3];
//                            base[turn][5] = params[4];
//                            break;
//                        default:
//                            break;
//                    }
                    count++;
                }
            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (reader!=null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }


    public static void buildBaseMatrixFromCleanData(String fileName) {
        BufferedReader reader = null;
        String line = null;
        try {
            reader = new BufferedReader(new FileReader(fileName));
            while ((line = reader.readLine()) != null) {
                String[] params = line.split(",");
                Integer turn = Integer.parseInt(params[1]);
                base[turn][0] = params[4];
                base[turn][1] = params[5];

                base[turn][2] = params[9];
                base[turn][3] = params[10];
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (reader!=null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

    }



    public static void prepareOriginData(String fileName) {
        String baseAnchor = null;
        for (int i=0;i<4;i++) {
            baseAnchor = AnchorNameConst.getAnchorStr(i+1);
            cleanOriginCsvData(fileName, baseAnchor);
        }
    }


    /**
     * 处理原有数据
     * @param fileName
     */
    public static void cleanOriginCsvData(String fileName, String baseAnchor) {
        List<List<String>> cleanedData = new LinkedList<>();
        BufferedReader reader = null;
        String line = null;
        try {
            reader = new BufferedReader(new FileReader(fileName));
            while ((line = reader.readLine()) != null) {
                String[] params = line.split(",");
                // 定位标签发出，基站接收的数据
                if (params.length>=3 && params[2].equals(baseAnchor)) {
//                if (params.length>=3 && params[2].equals(AnchorNameConst.Label)) {
                    Integer turn = Integer.parseInt(params[1]);
                    double rxTime = UwbRxTimeUtil.rxTimeTransform(params[4], params[5]);
//                    switch (params[3]) {
//                        case AnchorNameConst.Anchor1:
//                            base[turn][0] = params[4];
//                            base[turn][1] = params[5];
//                            break;
//                        case AnchorNameConst.Anchor2:
//                            base[turn][2] = params[4];
//                            base[turn][3] = params[5];
//                            break;
//                        case AnchorNameConst.Anchor3:
//                            base[turn][4] = params[4];
//                            base[turn][5] = params[5];
//                            break;
//                        case AnchorNameConst.Anchor4:
//                            base[turn][6] = params[4];
//                            base[turn][7] = params[5];
//                            break;
//                        default:
//                            break;
//                    }
                }
            }
        }  catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (reader!=null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        for (int i=0;i<256;i++) {
            if (!hasEnoughTimeData(base[i])) {
                continue;
            }
            cleanedData.add(rowData(i, base[i], baseAnchor));
        }

        writeCsv(cleanedData, baseAnchor);

        //  这里是顺序打印，不是按插入顺序打印
//        for (int i=0;i<cleanedData.size();i++) {
//            for (int j=0;j<cleanedData.get(i).size();j++) {
//                System.out.print(cleanedData.get(i).get(j)+"\t");
//            }
//            System.out.println();
//            if (i<255) {
//                Double anc1Time = Double.parseDouble(cleanedData.get(i).get(6));
//                Double anc1Next = Double.parseDouble(cleanedData.get(i+1).get(6));
//                System.out.print(anc1Next - anc1Time);
//                System.out.print("\t");
//                Double anc2Time = Double.parseDouble(cleanedData.get(i).get(12));
//                Double anc2Next = Double.parseDouble(cleanedData.get(i+1).get(12));
//                System.out.println(anc2Next - anc2Time);
//            }
//
//        }
    }

    /**
     * 判断base[i]是否有足够数据，防止null
     * @param data
     * @return
     */
    public static boolean hasEnoughTimeData(String[] data) {
        int validTime = 0;
        for (String time : data) {
            if (time!=null) {
                validTime++;
            }
        }
        return validTime>=6;
    }

    /**
     * @构造预处理数据的一行
     * @param turn
     * @param baseTime
     * @return
     */
    public static List<String> rowData(int turn, String[] baseTime, String baseAnchor) {
        List<String> row = new LinkedList<>();
        row.add("#RT");

        for (int i=0;i<4;i++) {
            row.add(""+turn);
            row.add(baseAnchor);
//            row.add(AnchorNameConst.Label);
            row.add(AnchorNameConst.getAnchorStr(i+1));
            String anc1TimeHigh = ""+0;
            String anc1TimeLow = ""+0;
            if (baseTime[i*2] != null) {
                anc1TimeHigh = baseTime[i*2];
                anc1TimeLow = baseTime[i*2+1];
            }
            row.add(anc1TimeHigh);
            row.add(anc1TimeLow);
            if (baseTime[i*2] != null) {
                row.add(""+UwbRxTimeUtil.rxTimeTransform(anc1TimeHigh, anc1TimeLow));
            } else {
                row.add(""+0);
            }
        }


        return row;
    }

    /**
     * javacsv写入
     * @param lists
     */
    public static void writeCsv(List<List<String>> lists, String baseAnchor) {
        File outFile = new File("E:\\309\\TDOA定位系统\\TDOA定位系统\\2. 自产开放系统\\Posense V1.1\\Database\\cleanData+"+baseAnchor+".csv");
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

    /**
     * base矩阵，调用时间转换工具，生成同一数据包到不同基站的计算时间
     */
    public static List<List<String>> timeTransfer() {
        List<List<String>> data = new LinkedList<>();
        for (int i=0; i<256; i++){
            List<String> row = new LinkedList<>();
            if (base[i]==null || base[i][0]==null || base[i][2]==null) {
                System.out.println(0+"\t"+0);
                continue;
            }
            if (base[i][0].indexOf('.')>=0 || base[i][1].indexOf('.')>=0) continue;
            baseTime[i][0] = UwbRxTimeUtil.rxTimeTransform(base[i][0], base[i][1]);
            if (base[i][2].indexOf('.')>=0 || base[i][3].indexOf('.')>=0) continue;
            baseTime[i][1] = UwbRxTimeUtil.rxTimeTransform(base[i][2], base[i][3]);

            System.out.println(i+":\t"+baseTime[i][0]+"\t"+baseTime[i][1]);
            row.add(""+i);
            row.add(""+baseTime[i][0]);
            row.add(""+baseTime[i][1]);
            data.add(row);
        }
        return data;
//        writeCSVFile(data, "E:/tdoa");
     }

    /**
     * 构建时间序列
     * @param timeData
     */
     public static void createDeltaTimeSeq(List<List<String>> timeData) {

     }

    public static void writeCSVFile(List<List<String>> data, String outputPath) {
        File csvFile = null;
        BufferedWriter csvFileOutputStream = null;
        try {
            File file = new File(outputPath);
            if (!file.exists()) {
                if (file.mkdirs()) {
                    System.out.println("创建成功");
                }
            }

            csvFile = new File("E:/TDOA/tdoaTimeSys.csv");
            csvFileOutputStream = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(csvFile, true)));

            for (List<String> row : data) {
                writeRow(row, csvFileOutputStream);
                csvFileOutputStream.newLine();
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (csvFileOutputStream != null) {
                    csvFileOutputStream.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private static void writeRow(List<String> row, BufferedWriter csvWriter) throws IOException {
        int i=0;
        for (String data : row) {
            csvWriter.write(DelQuota(data));
            if (i!=row.size()-1) {
                csvWriter.write(",");
            }
            i++;
        }
    }

    public static String DelQuota(String str) {
        String result = str;
        //String[] strQuota = {"\t", "\r", "\n", "~", "!", "@", "#", "$", "%", "^", "&", "*", "`", ";", "'", ",", "/", ":", "/,", "<", ">", "?"};
        String[] strQuota = {"\t", "\r", "\n", "\"",  ",", ";"};

        for (int i = 0; i < strQuota.length; i++) {
            if (result.indexOf(strQuota[i]) > -1) {
                result = result.replace(strQuota[i], " ");
            }
        }
        return result;
    }




}