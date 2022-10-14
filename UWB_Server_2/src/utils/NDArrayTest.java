package utils;


import Jama.Matrix;
import domain.DataCell;

import java.util.ArrayDeque;
import java.util.HashMap;
import java.util.Map;

/**
 * @author msc
 * @version 1.0
 * @date 2022/5/31 16:11
 */
public class NDArrayTest {

    public static void main(String[] args) {
        DataCell cell = new DataCell(1.0, 2.0, 371298371);
        System.out.println(cell.x);
        System.out.println(cell.y);
        System.out.println(cell.t);
        Matrix H = new Matrix(new double[][]{{1}, {2}, {3}});
        Matrix s = H.transpose().times(H);
        s = s.plus(new Matrix(new double[][]{{1}}));
        s = s.inverse();
//        s.print(10, 5);
        Matrix.identity(4, 4).print(4, 2);

        Matrix t = new Matrix(new double[][]{{1, 2, 3, 4}, {1, 1, 4, 5}, {3, 5, 6, 7}, {1, 3, 1, 44}});
        t.inverse().print(4, 10);


        Map<String, Integer> map = new HashMap<>();
        System.out.println(map.getOrDefault("Hello world", 1));
        System.out.println(map.containsKey("Hello world"));
    }
}
