package com.uwb.uwb_server.utils;


import Jama.Matrix;
import com.uwb.uwb_server.domain.DataCell;

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
        Matrix.identity(4,4).print(4,2);

    }
}
