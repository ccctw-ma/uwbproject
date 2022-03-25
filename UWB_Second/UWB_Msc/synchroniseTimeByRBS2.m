function [t1, t2, t3, t4] = synchroniseTimeByRBS2(anchorFittingParamsMatrix, time1, time2 ,time3, time4)
    systemConstant;
    % fprintf("同步前的时间 %f %f %f %f\n",time1, time2, time3, time4);
    % t1 = time1;
    % t2 = (time2 - anchorFittingParamsMatrix(1, 2, 2)) / anchorFittingParamsMatrix(1, 2, 1) - distance41 / C + distance24 / C; 
    % t3 = (time3 - anchorFittingParamsMatrix(1, 3, 2)) / anchorFittingParamsMatrix(1, 3, 1) - distance41 / C + distance34 / C;
    % t4 = (time4 - anchorFittingParamsMatrix(1, 4, 2)) / anchorFittingParamsMatrix(1, 4, 1) - distance31 / C + distance34 / C;

    t1 = (time1 - anchorFittingParamsMatrix(2, 1, 2)) / anchorFittingParamsMatrix(2, 1, 1) - distance23 / C + distance31 / C;
    t2 = time2; 
    t3 = (time3 - anchorFittingParamsMatrix(2, 3, 2)) / anchorFittingParamsMatrix(2, 3, 1) - distance21 / C + distance31 / C;
    t4 = (time4 - anchorFittingParamsMatrix(2, 4, 2)) / anchorFittingParamsMatrix(2, 4, 1) - distance21 / C + distance41 / C;
    % fprintf("同步后的时间 %f %f %f %f\n",t1, t2, t3, t4);