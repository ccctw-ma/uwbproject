package com.funtl.hello.uwb;

/**
 * 算定位结果
 * @author LingZhe
 */
public class XYTDOA {

    static final double[][] BS = new double[4][2];
    static {
        BS[0] = new double[]{AnchorConst.X1, AnchorConst.Y1};
        BS[1] = new double[]{AnchorConst.X2, AnchorConst.Y2};
        BS[2] = new double[]{AnchorConst.X3, AnchorConst.Y3};
        BS[3] = new double[]{AnchorConst.X4, AnchorConst.Y4};
    }

    static final double C = 3*Math.pow(10, 8);

    double[] data; //time差[]
    double[] h = new double[3];
    double[] Za0 = new double[3];
    double[] Za1 = new double[3];
    double[] sh = new double[3];

    double R21, R31, R41;
    double K1, K2, K3, K4;

    double x21, x31, x41;
    double y21, y31, y41;

    double[][] Ga = new double[3][3];
    double[][] Q = new double[3][3];
    double[][] B = new double[3][3];
    double[][] FI = new double[3][3];

    double[][] covZa = new double[3][3];
    double[][] Ba2 = new double[3][3];
    double[][] sFI = new double[3][3];
    double[][] sGa = new double[3][2];
    double[] Za2 = new double[2];

    double[][] POS = new double[4][2];

    double BS_X_MAX, BS_X_MIN, BS_Y_MAX, BS_Y_MIN;

    //20211210改成volatile
    public double POS_X, POS_Y;

    public XYTDOA(double[] data) {
        this.data = data;

        Q[0][0] = 1;
        Q[1][1] = 1;
        Q[2][2] = 1;

        sGa[0][0] = 1;
        sGa[0][1] = 0;

        sGa[1][0] = 0;
        sGa[1][1] = 1;

        sGa[2][0] = 1;
        sGa[2][1] = 1;

        BS_X_MIN = BS_X_MAX = AnchorConst.X1;
        BS_Y_MIN = BS_Y_MAX = AnchorConst.Y1;

        for (int i=0;i<3;++i) {
            if (BS_X_MAX < BS[i+1][0]) {
                BS_X_MAX = BS[i+1][0];
            }
            if (BS_Y_MAX < BS[i+1][1]) {
                BS_Y_MAX = BS[i+1][1];
            }
            if (BS_X_MIN>BS[i+1][0]) {
                BS_X_MIN = BS[i+1][0];
            }
            if (BS_Y_MIN>BS[i+1][1]) {
                BS_Y_MIN = BS[i+1][1];
            }
        }
    }

    public double Calculate() {
        // 计算R
        double R21 = Math.abs((data[1]-data[0])*C);
        double R31 = Math.abs((data[2]-data[0])*C);
        double R41 = Math.abs((data[3]-data[0])*C);
//        System.out.println("R2-R1=" + R21 + "m," + "R3-R1=" +  R31 + "m," + "R4-R1=" +  R41 + "m");
        // 计算K1到K4
        double K1 = AnchorConst.K1;
        double K2 = AnchorConst.K2;
        double K3 = AnchorConst.K3;
        double K4 = AnchorConst.K4;
        // 计算h
        h[0] = 0.5*(Math.pow(R21,2)-K2+K1);
        h[1] = 0.5*(Math.pow(R31,2)-K3+K1);
        h[2] = 0.5*(Math.pow(R41,2)-K4+K1);

        x21 = AnchorConst.X2-AnchorConst.X1;
        x31 = AnchorConst.X3-AnchorConst.X1;
        x41 = AnchorConst.X4-AnchorConst.X1;

        y21 = AnchorConst.Y2-AnchorConst.Y1;
        y31 = AnchorConst.Y3-AnchorConst.Y1;
        y41 = AnchorConst.Y4-AnchorConst.Y1;

        // 计算Ga矩阵
        Ga[0][0] = -x21;
        Ga[0][1] = -y21;
        Ga[0][2] = -R21;
        //
        Ga[1][0] = -x31;
        Ga[1][1] = -y31;
        Ga[1][2] = -R31;
        //
        Ga[2][0] = -x41;
        Ga[2][1] = -y41;
        Ga[2][2] = -R41;

        Za0Cal();

        B[0][0] = Math.sqrt(Math.pow(BS[1][0]-Za0[0], 2) + Math.pow(BS[1][1]-Za0[1], 2));
        B[1][1] = Math.sqrt(Math.pow(BS[2][0]-Za0[0], 2) + Math.pow(BS[2][1]-Za0[1], 2));
        B[2][2] = Math.sqrt(Math.pow(BS[3][0]-Za0[0], 2) + Math.pow(BS[3][1]-Za0[1], 2));

        FI_Cal();
        Za1_Cal();

        Ba2[0][0] = Za1[0] - BS[0][0];
        Ba2[1][1] = Za1[1] - BS[0][1];
        Ba2[2][2] = Za1[2];

        sFI_Cal();

        sh[0] = Math.pow(Za1[0] - BS[0][0], 2);
        sh[1] = Math.pow(Za1[1] - BS[0][1], 2);
        sh[2] = Math.pow(Za1[2], 2);

        Za2_Cal();

        // now we can calculate the position of the object
        POS_Cal();

        return 0;
    }

    public double Za0Cal() {
        double[][] temp0 = new double[3][3];    // get transfer of Ga
        double[][] temp1 = new double[3][3];
        double[][] temp2 = new double[3][3];
        double[] temp3 = new double[3*3];
        double[] temp4 = new double[3*3];
        double[][] temp5 = new double[3][3];
        double[][] temp6 = new double[3][3];
        double[][] temp7 = new double[3][3];
        for (int i=0;i<3;i++) {
            temp0[i] = new double[3];
            temp1[i] = new double[3];
            temp2[i] = new double[3];
            temp5[i] = new double[3];
            temp6[i] = new double[3];
            temp7[i] = new double[3];
        }
        tMatrix(Ga, temp0); // Ga' = temp0
        mulMatri(temp0, Q, temp1);  // Ga' * inv(Q) = temp1
        mulMatri(temp1, Ga, temp2); // Ga' * inv(Q) * Ga = temp2 = temp3

        Matrix2Vector(temp2, temp3);

        inv(temp3, temp4, 3);   // inv(Ga' * inv(Q) * Ga) = temp4 = temp5
        Vector2Matrix(temp4, temp5);

        mulMatri(temp5, temp0,temp6);   // inv() * Ga' = temp6
        mulMatri(temp6, Q, temp7);  // inv() * Ga' * inv(Q) = temp7

        MatrixPlusVextor(temp7, h, Za0); // inv() * Ga' * inv(Q) * h = temp8 = Za0

        return 0;
    }

    public void FI_Cal() { // 希腊字母 fai
        double[][] temp0 = new double[3][3];
        mulMatri(B, Q, temp0);  // B * Q = temp0
        mulMatri(temp0, B, FI); // B * Q * B = temp1
        for (int i=0;i<3;++i) {
            for (int j=0;j<3;++j) {
                FI[i][j] = Math.pow(C, 2)*FI[i][j];
            }
        }
    }

    public void Za1_Cal() {
        double[][] temp0 = new double[3][3];//get transfer of Ga
        double[] temp1 = new double[3*3];

        double[] temp2 = new double[3*3];
        double[][] temp3 = new double[3][3];

        double[][] temp4 = new double[3][3];
        double[][] temp5 = new double[3][3];
        double[] temp6 = new double[3*3];
        double[] temp7 = new double[3*3];
        double[][] temp8 = new double[3][3];
        double[][] temp9 = new double[3][3];
        double[][] temp10 = new double[3][3];

        tMatrix(Ga, temp0); // Ga' = temp0
        Matrix2Vector(FI, temp1); // inv(FI)=temp1=temp2=temp3
        inv(temp1, temp2, 3);
        Vector2Matrix(temp2, temp3);

        mulMatri(temp0, temp3, temp4); // Ga' * inv(FI) = temp4
        mulMatri(temp4, Ga, temp5); // Ga' * inv(FI) * Ga = temp5

        Matrix2Vector(temp5, temp6);    // inv(Ga' * inv(FI) * Ga) = temp6 = temp7 = temp8
        inv(temp6, temp7, 3);
        Vector2Matrix(temp7, temp8);

        mulMatri(temp8, temp0, temp9);  // inv(Ga' * inv(FI) * Ga) * Ga' = temp9
        mulMatri(temp9, temp3, temp10); // inv(Ga' * inv(FI) * Ga) * Ga' * inv(FI) = temp10

        MatrixPlusVextor(temp10, h, Za1);

        if (Za1[2] < 0) {
            Za1[2] = -Za1[2];
        }
        // calculate the covZa
        for (int i=0;i<3;++i) {
            for (int j=0;j<3;++j) {
                covZa[i][j] = temp8[i][j];
            }
        }

    }

    public void sFI_Cal() {
        double[][] temp0 = new double[3][3];
        double[][] temp1 = new double[3][3];

        mulMatri(Ba2, covZa, temp0);    // Ba2 * covZa = temp0
        mulMatri(temp0, Ba2, temp1);    // Ba2 * covZa * Ba2 = temp1

        for (int i=0;i<3;++i) {
            for (int j=0;j<3;++j) {
                sFI[i][j] = 4*temp1[i][j];
            }
        }
    }

    public void Za2_Cal() {
        double[] temp1 = new double[3*3];
        double[] temp2 = new double[3*3];
        double[][] temp3 = new double[3][3];

        double[][] temp4 = new double[2][3];
        double[][] temp5 = new double[2][2];

        double[] temp6 = new double[2*2];
        double[] temp7 = new double[2*2];
        double[][] temp8 = new double[2][2];

        double[][] temp9 = new double[2][3];
        // Za2 = inv(sGa' * inv(sFI) * sGa) * sGa' * inv(sFI) * sh

        double[][] temp0 = new double[2][3];
        temp0[0] = new double[]{1,0,1}; //sGa' = temp0
        temp0[1] = new double[]{0,1,1};

        Matrix2Vector(sFI, temp1);  // inv(sFI) = temp1 = temp2 = temp3
        inv(temp1, temp2, 3);
        Vector2Matrix(temp2, temp3);

        mulMatri_23X33(temp0, temp3, temp4);    // sGa' * inv(sFI) = temp4

        // sGa' * inv(sFI) * sGa=temp5
        temp5[0][0] = temp4[0][0] + temp4[0][2];
        temp5[0][1] = temp4[0][1] + temp4[0][2];
        temp5[1][0] = temp4[1][0] + temp4[1][2];
        temp5[1][1] = temp4[1][1] + temp4[1][2];

        Matrix2Vector_22(temp5, temp6); // inv(sGa' * inv(sFI) * sGa)
        inv(temp6, temp7, 2);
        Vector2Matrix_22(temp7, temp8);

        //inv(sGa' * inv(sFI) * sGa) * sGa' * inv(sFI)=temp8 * temp4 = temp9
        for (int i=0;i<2;i++) {
            for (int j=0;j<3;j++) {
                for (int k=0;k<2;k++) {
                    temp9[i][j] += temp8[i][k] * temp4[k][j];
                }
            }
        }

//        for(int i=0;i<3;i++){
//            for(int j=0;j<3;j++){
//                System.out.println(temp9[i][j]);
//            }
//        }

        Za2[0] = temp9[0][0] * sh[0] + temp9[0][1] * sh[1] + temp9[0][2] * sh[2];
        Za2[1] = temp9[1][0] * sh[0] + temp9[1][1] * sh[1] + temp9[1][2] * sh[2];

    }

    /**
     * Ga' = temp0
     * 输入参数是3*3的矩阵
     * @param x
     * @param c
     * @return
     */
    public int tMatrix(double[][] x, double[][] c) {
        for (int i=0;i<3;++i) {
            for (int j=0;j<3;++j) {
                c[i][j] = x[j][i];
            }
        }
        return 0;
    }

    /**
     * Ga' * inv(Q) = temp1
     * @param x
     * @param y
     * @param z
     * @return
     */
    public int mulMatri(double[][] x, double[][] y, double[][] z) {
        int i, j, k;
        int m = 3;
        int n = 3;

        for (i=0;i<m;i++) {
            for (j=0;j<m;j++) {
                z[i][j] = 0;
                for (k=0;k<n;k++) {
                    z[i][j] += x[i][k] * y[k][j];
                }
            }
        }
        return 0;
    }

    /**
     * 矩阵转向量
     * matrixA is double[3][3]
     * vectorB is double[3*3]
     * @param matrixA
     * @param vectorB
     * @return
     */
    public int Matrix2Vector(double[][] matrixA, double[] vectorB) {
        int k = 0;
        for (int i=0;i<3;++i) {
            for (int j=0;j<3;++j) {
                vectorB[k] = matrixA[i][j];
                k++;
            }
        }
        return 0;
    }

    /**
     * 向量转矩阵
     * @param vectorC
     * @param matrixD
     */
    public void Vector2Matrix(double[] vectorC, double[][] matrixD) {
        int k=0;
        for (int i=0;i<3;++i) {
            for (int j=0;j<3;++j) {
                matrixD[i][j] = vectorC[k];
                k++;
            }
        }
    }

    public void inv(double[] a, double[] b, int n) {
        double deta = det(a, n);
        for (int i=0;i<n;i++) {
            for (int j=0;j<n;j++) {
                b[i*n+j] = rem(a, j, i, n) / deta;
            }
        }
    }

    public double det(double[] a, int n) {
        if (n == 1) {
            return a[0];
        }
        double sum = 0;
        for (int j=0;j<n;j++) {
            sum += a[0 * n + j] * rem(a, 0, j, n);
        }
        return sum;
    }

    /**
     * to calculate the inv of matrix a, get b finally
     * @param a
     * @param i
     * @param j
     * @param n
     * @return
     */
    public double rem(double[] a, int i, int j, int n) {
        int k, m;
        double[] pTemp = new double[(n-1)*(n-1)];
        for (k=0;k<i;k++) {
            for (m=0;m<j;m++) {
                pTemp[k*(n-1)+m] = a[k*n+m];
            }
            for (m=j;m<n-1;m++) {
                pTemp[k*(n-1)+m] = a[k*n+m+1];
            }
        }
        for (k=i;k<n-1;k++) {
            for (m=0;m<j;m++) {
                pTemp[k*(n-1)+m] = a[(k+1)*n+m];
            }
            for (m=j;m<n-1;m++) {
                pTemp[k*(n-1)+m] = a[(k+1)*n+m+1];
            }
        }
        double dResult = (((i+j)%2)==1 ? -1 : 1)*det(pTemp, n-1);
        return dResult;
    }

    public void MatrixPlusVextor(double[][] matrixE, double[] matrixF, double[] vectorC) {
        vectorC[0] = matrixE[0][0] * matrixF[0] + matrixE[0][1]*matrixF[1] + matrixE[0][2]*matrixF[2];
        vectorC[1] = matrixE[1][0] * matrixF[0] + matrixE[1][1]*matrixF[1] + matrixE[1][2]*matrixF[2];
        vectorC[2] = matrixE[2][0] * matrixF[0] + matrixE[2][1]*matrixF[1] + matrixE[2][2]*matrixF[2];

    }

    /**
     * x is a 2*3 matrix
     * y is a 3*3 matrix
     * @param x
     * @param y
     * @param z
     * @return
     */
    public double mulMatri_23X33(double[][] x, double[][] y, double[][] z) {
        int i, j, k;
        int m=2;
        int n=3;
        for (i=0;i<m;i++) {
            for (j=0;j<n;j++) {
                z[i][j] = 0;
                for (k=0;k<n;k++) {
                    z[i][j] += x[i][k] * y[k][j];
                }
            }
        }
        return 0;
    }

    /**
     * a is matrix 2*2
     * b is vector
     * @param matrixA
     * @param vectorB
     */
    public void Matrix2Vector_22(double[][] matrixA, double[] vectorB) {
        int k = 0;
        for (int i=0;i<2;++i) {
            for (int j=0;j<2;++j) {
                vectorB[k] = matrixA[i][j];
                k++;
            }
        }
    }

    /**
     * c is a vector
     * d is a matrix 2*2
     * @param vectorC
     * @param matrixD
     */
    public void Vector2Matrix_22(double[] vectorC, double[][] matrixD) {
        int k=0;
        for (int i=0;i<2;++i) {
            for (int j=0;j<2;++j) {
                matrixD[i][j] = vectorC[k];
                k++;
            }
        }
    }

    public void POS_Cal() {
        POS[0][0] = Math.sqrt(Za2[0]) + AnchorConst.X1;
        POS[0][1] = Math.sqrt(Za2[1]) + AnchorConst.Y1;

        POS[1][0] = -Math.sqrt(Za2[0]) + AnchorConst.X1;
        POS[1][1] = -Math.sqrt(Za2[1]) + AnchorConst.Y1;

        POS[2][0] = Math.sqrt(Za2[0]) - AnchorConst.X1;
        POS[2][1] = Math.sqrt(Za2[1]) - AnchorConst.Y1;

        POS[3][0] = -Math.sqrt(Za2[0]) - AnchorConst.X1;
        POS[3][1] = -Math.sqrt(Za2[1]) - AnchorConst.Y1;

        for (int i=0;i<4;++i) {
            if ((POS[i][0] < BS_X_MAX) && (POS[i][0] > BS_X_MIN)) {
                POS_X = POS[i][0];
            }
        }

        for (int i=0;i<4;++i) {
            if ((POS[i][1] < BS_Y_MAX) && (POS[i][1]>BS_Y_MIN)) {
                POS_Y = POS[i][1];
            }
        }
        System.out.println(POS_X);
        System.out.println(POS_Y);
    }

    public static void main(String[] args) {
        double[] time = new double[]{
                865.213578347608,	865.21357834842,	865.2135783432601,	865.213578354222        };
//         double[] time = new double[]{5166.12154169013, 1352.88168774873,979.600833452915,1577.97546871693};
        XYTDOA tdoa = new XYTDOA(time);
        tdoa.Calculate();
    }
}
