package domain;

import Jama.Matrix;

import java.util.*;

/**
 * @author msc
 * @version 1.0
 * @date 2022/5/31 17:00
 */
public class KalmanFilter {

    public boolean hasInit;
    private double time;
    private Matrix X_n1;
    private Matrix X_n;
    private Matrix P;
    private Matrix K;
    private Matrix Q;
    private final Matrix H;
    private Matrix Z;
    private final Matrix R_base;
    private final double varQ; // 过程噪声方差基数
    private final double measNoiseVar; // 量测数据方差
    private final double b; // 速度方差遗忘因子
    private final double R_upper_bound;
    private double var_vx_pre;
    private double var_vy_pre;
    private final double expansionRatio; // 额外扩张比例
    private long step;

    private final double static_vel_threshold; // 静止状态的速度阈值

    private long static_step;

    private final Deque<DataCell> realTimeDataSet;
    private final int realTimeDataSetSize;

    private final Deque<Double> xVelocityVarSet;
    private final Deque<Double> yVelocityVarSet;
    private final int velocityVarSetSize;


    public KalmanFilter() {
        this.hasInit = false;
        this.H = new Matrix(new double[][]{
                {1, 0, 0, 0},
                {0, 0, 1, 0}
        });
        this.P = Matrix.identity(4, 4).times(0.01);
        this.measNoiseVar = 0.1;
        this.R_base = new Matrix(new double[][]{
                {this.measNoiseVar, 0},
                {0, this.measNoiseVar}
        });
        this.b = 0.8;
        this.varQ = 0.02;
        this.R_upper_bound = 2;
        this.var_vx_pre = 0.0;
        this.var_vy_pre = 0.0;
        this.static_vel_threshold = 0.5;
        this.realTimeDataSet = new ArrayDeque<>();
        this.realTimeDataSetSize = 40;
        this.xVelocityVarSet = new ArrayDeque<>();
        this.yVelocityVarSet = new ArrayDeque<>();
        this.velocityVarSetSize = 10;
        this.step = 1;
        this.static_step = 0;
        this.expansionRatio = 100;
    }

    /**
     *
     *
     */
    public void initKf(DataCell cell) {
        this.X_n1 = new Matrix(new double[][]{{cell.x}, {0}, {cell.y}, {0}});
        for (int i = 0; i < this.realTimeDataSetSize; i++) {
            realTimeDataSet.add(cell);
        }
        for (int i = 0; i < this.velocityVarSetSize; i++) {
            xVelocityVarSet.add(0.0);
            yVelocityVarSet.add(0.0);
        }
        this.time = cell.t;
    }

    /**
     * 对实时数据进行处理分析数据的特性
     */
    public List<Double> realTimeDataAnalysis(DataCell cell) {
        this.realTimeDataSet.pollFirst();
        if (Double.isNaN(cell.x)) {
            cell.x = this.realTimeDataSet.getLast().x;
        }
        if (Double.isNaN(cell.y)) {
            cell.y = this.realTimeDataSet.getLast().y;
        }
        this.realTimeDataSet.add(cell);
        // 计算定位结果的方差
        double sumX = 0.0, sumY = 0.0, meanX, meanY, varX = 0.0, varY = 0.0;
        for (DataCell dataCell : this.realTimeDataSet) {
            sumX += dataCell.x;
            sumY += dataCell.y;
        }
        meanX = sumX / this.realTimeDataSetSize;
        meanY = sumY / this.realTimeDataSetSize;
        for (DataCell dataCell : this.realTimeDataSet) {
            varX += (dataCell.x - meanX) * (dataCell.x - meanX);
            varY += (dataCell.y - meanY) * (dataCell.y - meanY);
        }
        varX = varX / (this.realTimeDataSetSize - 1);
        varY = varY / (this.realTimeDataSetSize - 1);

        // 计算该窗口内的速度以及速度的方差
        double vxs = 0.0;
        double vys = 0.0;
        DataCell base = this.realTimeDataSet.getLast();
        int count = 0;
        for (DataCell dataCell : this.realTimeDataSet) {
            if (++count == this.realTimeDataSetSize) continue;
            double dx = base.x - dataCell.x;
            double dy = base.y - dataCell.y;
            double dt = base.t - dataCell.t;
            if (dt == 0.0) {
                vxs += 0;
                vys += 0;
            } else {
                double vx = dx / dt;
                double vy = dy / dt;
                vxs += vx;
                vys += vy;
            }
        }
        vxs /= (count - 1);
        vys /= (count - 1);

        this.xVelocityVarSet.pollFirst();
        this.yVelocityVarSet.pollFirst();
        this.xVelocityVarSet.add(vxs);
        this.yVelocityVarSet.add(vys);
        double sumVX = 0.0, sumVY = 0.0, meanVX, meanVY, varVX = 0.0, varVY = 0.0;
        for (Double vx : xVelocityVarSet) sumVX += vx;
        for (Double vy : yVelocityVarSet) sumVY += vy;
        meanVX = sumVX / this.velocityVarSetSize;
        meanVY = sumVY / this.velocityVarSetSize;
        for (Double vx : xVelocityVarSet) varVX += (vx - meanVX) * (vx - meanVX);
        for (Double vy : yVelocityVarSet) varVY += (vy - meanVY) * (vy - meanVY);
        varVX = varVX / (this.velocityVarSetSize - 1);
        varVY = varVY / (this.velocityVarSetSize - 1);

        // 计算当前点与前一个点的欧式距离
        double cx = cell.x, cy = cell.y;
        double px = this.X_n1.get(0, 0), py = this.X_n1.get(2, 0);
        double v = Math.sqrt(Math.pow(vxs, 2) + Math.pow(vys, 2));
        double distance = Math.sqrt(Math.pow(cx - px, 2) + Math.pow(cy - py, 2));

        return new ArrayList<>(Arrays.asList(varX, vxs, varVX, varY, vys, varVY, v, distance));
    }

    public void XYPositionKalmanFilter(double dt, DataCell cell) {
        Matrix curZ = new Matrix(new double[][]{{cell.x}, {cell.y}});
        // F 运动状态状态转移方程
        Matrix F = new Matrix(new double[][]{
                {1, dt, 0, 0},
                {0, 1, 0, 0},
                {0, 0, 1, dt},
                {0, 0, 0, 1}
        });
        Matrix Q = new Matrix(new double[][]{
                {dt * this.varQ, 0, 0, 0},
                {0, 2 * dt * this.varQ, 0, 0},
                {0, 0, dt * this.varQ, 0},
                {0, 0, 0, 2 * dt * this.varQ}
        });

        // 静止状态转移方程
        Matrix static_F = new Matrix(new double[][]{
                {1, 0, 0, 0},
                {0, 1, 0, 0},
                {0, 0, 1, 0},
                {0, 0, 0, 1}
        });
        Matrix static_Q = new Matrix(4, 4);

        Matrix X_n_n = this.X_n1;
        Matrix P_n_n = this.P;
        Matrix X_n1_n = null;
        Matrix P_n1_n = null;
        Matrix X_n1_n1 = null, P_n1_n1 = null;

        boolean isValidMeasurementData = true;
        List<Double> realTimeDataAnalysisRes = realTimeDataAnalysis(cell);
        double varX = realTimeDataAnalysisRes.get(0);
        double vx = realTimeDataAnalysisRes.get(1);
        double varVX = realTimeDataAnalysisRes.get(2);
        double varY = realTimeDataAnalysisRes.get(3);
        double vy = realTimeDataAnalysisRes.get(4);
        double varVY = realTimeDataAnalysisRes.get(5);
        double v = realTimeDataAnalysisRes.get(6);
        double distance = realTimeDataAnalysisRes.get(7);

        // 观测结果为NaN或者超过设定的界限那么观测结果为无效数据
        if (Double.isNaN(curZ.get(0, 0)) || Double.isNaN(curZ.get(1, 0)) || curZ.get(0, 0) < 0 || curZ.get(1, 0) < 0) {
            X_n1_n = static_F.times(X_n_n);
            P_n1_n = static_F.times(P_n_n).times(static_F.transpose()).plus(static_Q);

            X_n1_n1 = X_n1_n;
            P_n1_n1 = P_n1_n;
        } else {
            // 有效数据可以通过对过往数据集进行分析分为静止和运动两种状态

            // 静止状态
            if (v <= this.static_vel_threshold || (v < this.static_vel_threshold * 2 && this.static_step >= 20 && distance <= 0.5)) {
                this.static_step += v <= this.static_vel_threshold ? 1 : -1;
                X_n1_n = static_F.times(X_n_n);
                P_n1_n = static_F.times(P_n_n).times(static_F.transpose()).plus(static_Q);
                // 新息向量
                Matrix innovation = curZ.minus(this.H.times(X_n1_n));
                Matrix baseDiff = this.H.times(P_n1_n).times(this.H.transpose()).plus(this.R_base);
                double R_diff = Math.abs(innovation.transpose().times(baseDiff.inverse()).times(innovation).get(0, 0));
                Matrix R_n = null;
                if (R_diff <= this.R_upper_bound) {
                    R_n = new Matrix(new double[][]{
                            {(this.measNoiseVar + varX) * Math.max(R_diff, 0.5), 0},
                            {0, (this.measNoiseVar + varY) * Math.max(R_diff, 0.5)}
                    });
                } else {
                    // 基础扩大比例
                    double baseRate = R_diff / this.R_upper_bound;
                    R_n = this.R_base.times(baseRate + this.expansionRatio);
                }
                Matrix K_n = P_n1_n.times(this.H.transpose()).times(this.H.times(P_n1_n).times(this.H.transpose()).plus(R_n).inverse());
                P_n1_n1 = Matrix.identity(4, 4).minus(K_n.times(this.H)).times(P_n1_n);
                X_n1_n1 = X_n1_n.plus(K_n.times(curZ.minus(this.H.times(X_n1_n))));
            }
            // 运动状态
            else {
                this.static_step = Math.max(0, this.static_step - 10);
                X_n1_n = F.times(X_n_n);
                P_n1_n = F.times(P_n_n).times(F.transpose()).plus(Q);
                // 新息向量
                Matrix innovation = curZ.minus(this.H.times(X_n1_n));
                Matrix baseDiff = this.H.times(P_n1_n).times(this.H.transpose()).plus(this.R_base);
                double R_diff = Math.abs(innovation.transpose().times(baseDiff.inverse()).times(innovation).get(0, 0));

//                varVX = this.b * this.var_vx_pre + (1 - this.b) * varVX;
//                varVY = this.b * this.var_vy_pre + (1 - this.b) * varVY;
                Matrix R_n;
                if (R_diff <= this.R_upper_bound) {
                    R_n = new Matrix(new double[][]{
                            {(this.measNoiseVar + varX) * Math.max(R_diff, 0.5), 0},
                            {0, (this.measNoiseVar + varY) * Math.max(R_diff, 0.5)}
                    });
                } else {
                    // 基础扩大比例
                    double baseRate = R_diff / this.R_upper_bound;
                    double R_x = varX, R_y = varY;
                    if (varVX > this.measNoiseVar) R_x = this.measNoiseVar * this.expansionRatio;
                    if (varVY > this.measNoiseVar) R_y = this.measNoiseVar * this.expansionRatio;
                    Matrix additional = new Matrix(new double[][]{
                            {R_x, 0},
                            {0, R_y}
                    });
                    R_n = this.R_base.times(baseRate).plus(additional);
                }
//                this.var_vx_pre = varVX;
//                this.var_vy_pre = varVY;
                Matrix K_n = P_n1_n.times(this.H.transpose()).times(this.H.times(P_n1_n).times(this.H.transpose()).plus(R_n).inverse());
                P_n1_n1 = Matrix.identity(4, 4).minus(K_n.times(this.H)).times(P_n1_n);
                X_n1_n1 = X_n1_n.plus(K_n.times(curZ.minus(this.H.times(X_n1_n))));
            }

        }

        this.X_n = X_n1_n;
        this.X_n1 = X_n1_n1;
        this.P = P_n1_n1;
        this.Z = curZ;
    }

    public double[] run(DataCell cell) {
        double dt = (Math.max(cell.t - this.time, 0) + 86400) % 86400;
        if (dt == 0.0) dt = 0.005;
        this.time = this.time + dt;
        XYPositionKalmanFilter(dt, cell);
        this.step += 1;
        return new double[]{this.X_n1.get(0, 0), this.X_n1.get(2, 0)};
    }
}
