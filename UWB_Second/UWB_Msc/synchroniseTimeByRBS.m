
function [t1, t2, t3, t4] = synchroniseTimeByRBS(time1, time2 ,time3, time4, tempK12, tempB12, tempK23, tempB23, tempB24, tempK24)

    anchorPosition;
    % fprintf("timeFitting %f %f %f %f\n",tempK23, tempB23, tempK24, tempB24);
    t1 = (time1 - tempB12)/tempK12 - distance23/C + distance31/C;
    t2 = time2;
    t3 = (time3 - tempB23)/tempK23 - distance21/C + distance31/C;
    t4 = (time4 - tempB24)/tempK24 - distance21/C + distance41/C;
    % fprintf("同步后的时间 %f %f %f %f\n",t1, t2, t3, t4);