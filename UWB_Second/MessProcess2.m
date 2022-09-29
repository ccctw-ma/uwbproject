function MessProcess2(dataCell)
    global_Name;

    global anchor12RxTime;
    global anchor13RxTime;
    global anchor14RxTime;
    global anchor12SeqNum;
    global anchor13SeqNum;
    global anchor14SeqNum;
    global anchor31RxTime;
    global anchor32RxTime;
    global anchor34RxTime;
    global anchor31SeqNum;
    global anchor32SeqNum;
    global anchor34SeqNum;
    global haveNullOrDataCount;
    global anchorRxTime;
    
    seqNum = str2double(dataCell{1,2});        %序列号
    sendAnchorOrLabel = dataCell{1,3};         %发送的基站或标签
    receiveAnchor = dataCell{1,4};             %接收
    rxTime = rxTimeTransform(dataCell{1,5},dataCell{1,6});        %接收时间
    
    if strcmp(sendAnchorOrLabel,Label)
        %基站接收到定位数据的本地时间
        if strcmp(receiveAnchor,Anchor1)
            anchorRxTime(seqNum+1,1) = rxTime;
        elseif strcmp(receiveAnchor,Anchor2)
            anchorRxTime(seqNum+1,2) = rxTime;
        elseif strcmp(receiveAnchor,Anchor3)
            anchorRxTime(seqNum+1,3) = rxTime;
        elseif strcmp(receiveAnchor,Anchor4)
            anchorRxTime(seqNum+1,4) = rxTime;
        end

        validDataCount = length(find(anchorRxTime(seqNum+1,:)~=0));
        if validDataCount == 4
            time1 = anchorRxTime(seqNum+1,1);
            time2 = anchorRxTime(seqNum+1,2);
            time3 = anchorRxTime(seqNum+1,3);
            time4 = anchorRxTime(seqNum+1,4);

            bool = 1;
            if anchor12RxTime(anchor12SeqNum+1) == 0
                fprintf("anchor12SeqNum:%d,本轮次anchor12RxTime为0.0\n",anchor12SeqNum);
                bool = 0;
            elseif anchor13RxTime(anchor13SeqNum+1)==0
                fprintf("anchor13SeqNum:%d,本轮次anchor13RxTime为0.0\n",anchor13SeqNum);
                bool = 0;
            elseif anchor14RxTime(anchor14SeqNum+1)==0
                fprintf("anchor14SeqNum:%d,本轮次anchor14RxTime为0.0\n",anchor14SeqNum);
                bool = 0;
            elseif anchor31RxTime(anchor31SeqNum+1)==0
                fprintf("anchor31SeqNum:%d,本轮次anchor31RxTime为0.0\n",anchor31SeqNum);
                bool = 0;
            elseif anchor32RxTime(anchor32SeqNum+1)==0
                fprintf("anchor32SeqNum:%d,本轮次anchor32RxTime为0.0\n",anchor32SeqNum);
                bool = 0;
            end

            if ~bool
                haveNullOrDataCount = haveNullOrDataCount+1;
                if((mod(haveNullOrDataCount,5) == 0 )|| (haveNullOrDataCount == 1) )
                    fprintf("第%d次，TimeUtil.haveNullOrData returned\n",haveNullOrDataCount);
                end
                return;
            end

            time = [time1;time2;time3;time4];
            if bool == 1
                [T1,T3,T4] = calculateSkewAndOffset(anchor12SeqNum,anchor13SeqNum,anchor14SeqNum,anchor31SeqNum,anchor32SeqNum,anchor12RxTime,anchor13RxTime,anchor14RxTime,anchor31RxTime,anchor32RxTime,dataPollingTimes,time1,time3,time4);
                time = [T1;time2;T3;T4];
            end  

             %cleanThisSeqData
            anchorRxTime(seqNum+1,1) = 0;
            anchorRxTime(seqNum+1,2) = 0;
            anchorRxTime(seqNum+1,3) = 0;
            anchorRxTime(seqNum+1,4) = 0;
    
            %解算定位结果
            [POS_X,POS_Y] = XYTDOA(time);
            fprintf("chan定位结果，X: %.2f, Y: %.2f\n",POS_X,POS_Y);

        end
    elseif strcmp(sendAnchorOrLabel,Anchor1)
        if strcmp(receiveAnchor,Anchor2)
            anchor12SeqNum = seqNum;
            anchor12RxTime(anchor12SeqNum+1) = rxTime;
        elseif strcmp(receiveAnchor,Anchor3)
            anchor13SeqNum = seqNum;
            anchor13RxTime(anchor13SeqNum+1) = rxTime;
        elseif strcmp(receiveAnchor,Anchor4)
            anchor14SeqNum = seqNum;
            anchor14RxTime(anchor14SeqNum+1) = rxTime;
        end

    elseif strcmp(sendAnchorOrLabel,Anchor3)
        if strcmp(receiveAnchor,Anchor1)
            anchor31SeqNum = seqNum;
            anchor31RxTime(anchor31SeqNum+1) = rxTime;
        elseif strcmp(receiveAnchor,Anchor2)
            anchor32SeqNum = seqNum;
            anchor32RxTime(anchor32SeqNum+1) = rxTime;
        elseif strcmp(receiveAnchor,Anchor4)
            anchor34SeqNum = seqNum;
            anchor34RxTime(anchor34SeqNum+1) = rxTime;
        end
        
    end

end

