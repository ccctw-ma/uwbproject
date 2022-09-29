

function [t1,t3,t4] = calculateSkewAndOffset(anchor12SeqNum,anchor13SeqNum,anchor14SeqNum,anchor31SeqNum,anchor32SeqNum,anchor12RxTime,anchor13RxTime,anchor14RxTime,anchor31RxTime,anchor32RxTime,dataPollingTimes,time1,time3,time4)

    seq = min(anchor31SeqNum,anchor32SeqNum);
    tempK21 = (anchor31RxTime(seq+1) - anchor31RxTime(mod(seq-1+dataPollingTimes,dataPollingTimes)+1)) / (anchor32RxTime(seq+1) - anchor32RxTime(mod(seq-1+dataPollingTimes,dataPollingTimes)+1));
    tempB21 = anchor31RxTime(seq+1) - tempK21 * anchor32RxTime(seq+1);

    seq = min(anchor12SeqNum,anchor13SeqNum);
    tempK23 = (anchor13RxTime(seq+1) - anchor13RxTime(mod(seq-1+dataPollingTimes,dataPollingTimes)+1)) / (anchor12RxTime(seq+1) - anchor12RxTime(mod(seq-1+dataPollingTimes,dataPollingTimes)+1));
    tempB23 = anchor13RxTime(seq+1) - tempK23 * anchor12RxTime(seq+1);

    seq = min(anchor12SeqNum,anchor14SeqNum);
    tempK24 = (anchor14RxTime(seq+1) - anchor14RxTime(mod(seq-1+dataPollingTimes,dataPollingTimes)+1)) / (anchor12RxTime(seq+1) - anchor12RxTime(mod(seq-1+dataPollingTimes,dataPollingTimes)+1));
    tempB24 = anchor14RxTime(seq+1) - tempK24 * anchor12RxTime(seq+1);

    anchorPosition;

    t1 = (time1 - tempB21)/tempK21 - distance23 / C + distance31 / C;
    t3 = (time3 - tempB23)/tempK23 - distance21 / C + distance31 / C;
    t4 = (time4 - tempB24)/tempK24 - distance21 / C + distance41 / C;

end