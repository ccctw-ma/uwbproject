package com.funtl.hello.nousenow;

import com.funtl.hello.uwb.SignalDataUtil;
import org.apache.commons.dbcp2.BasicDataSourceFactory;

import javax.sql.DataSource;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.Properties;

/**
 * @author LingZhe
 */
public class DBCPUtil {
    private static final String filePath = "D:\\IntelliJIdeaProjects\\hello_array_problem\\src\\main\\resources\\dbcp.properties";
    private static Properties properties = new Properties();
    private static DataSource dataSource;

    static {
        try {
            FileInputStream inputStream = new FileInputStream(filePath);
            properties.load(inputStream);
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {
            dataSource = BasicDataSourceFactory.createDataSource(properties);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() {
        Connection connection = null;
        try {
            connection = dataSource.getConnection();
            System.out.println(connection.isClosed());
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
            connection.setAutoCommit(false);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return connection;
    }

    public static void writeDbByOneConn(List<List<String>> data) {
        Connection connection = getConnection();
        try {
            for (int i=0;i<data.size();i++) {
                writeDbByOneConnc(data.get(i));
            }
            connection.close();
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }

    }

    public static void writeJieLiDataByOneConn(String x, String y) {
        Connection connection = getConnection();
        try {
            connection.setAutoCommit(true);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        String sql = "insert into jieliUwb(pos_x, pos_y) " +
                " values(?, ?)";
        PreparedStatement statement = null;
        try {
            statement = connection.prepareStatement(sql);
            statement.setFloat(1, Float.parseFloat(x));
            statement.setFloat(2, Float.parseFloat(y));
            statement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
            connection.close();
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
    }

    public static void writeDbByOneConnc(List<String> data) {
        Connection connection = getConnection();
        try {
            connection.setAutoCommit(true);
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }

        String sql = "insert into uwbPos" +
                "(stdNoise, pathAmp1, pathAmp2, pathAmp3, growthCIR, preamCount, pw1, pw2, nlos, pos_x, pos_y) " +
                " values(?,?,?,?,?,?,?,?,?,?,?)";
        try {
            PreparedStatement ptmt = connection.prepareStatement(sql);
            ptmt.setInt(1, Integer.parseInt(data.get(0)));
            ptmt.setInt(2, Integer.parseInt(data.get(1)));
            ptmt.setInt(3, Integer.parseInt(data.get(2)));
            ptmt.setInt(4, Integer.parseInt(data.get(3)));
            ptmt.setInt(5, Integer.parseInt(data.get(4)));
            ptmt.setInt(6, Integer.parseInt(data.get(5)));
            ptmt.setFloat(7, Float.parseFloat(data.get(6)));
            ptmt.setFloat(8, Float.parseFloat(data.get(7)));
            ptmt.setInt(9, Integer.parseInt(data.get(8)));
            ptmt.setFloat(10, Float.parseFloat(data.get(9)));
            ptmt.setFloat(11, Float.parseFloat(data.get(10)));
            //
            int result = ptmt.executeUpdate();
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }

        
        try {
            connection.close();
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }

//        StringBuilder builder = new StringBuilder();
//        for (int i=0;i<data.size();i++) {
//            builder.append(data.get(i));
//            if (i != data.size()-1) {
//                builder.append(",");
//            }
//        }
//        String sql = "insert into uwbPos values (" + builder.toString() +")";
//        try {
//            statement.execute(sql);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
    }

    public static void main(String[] args) {
        List<String> data = SignalDataUtil.splitSignalData("0024-0824-0752-0572-0076-0752","2","3","4",1.1,1.1);
        writeDbByOneConnc(data);
    }
}
