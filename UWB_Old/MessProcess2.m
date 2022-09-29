function MessProcess2(dataCell)
    global_Name1;
    global anchorRxTime;
    global tempK23;
    global tempB23;
    global tempK24;
    global tempB24;
    global haveNullOrDataCount;
    global anchorInteractionTimeMatrix;
    global anchorInteractionSeqMatrix;
    
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

            global timeBefore;
            timeBefore = [timeBefore;time1,time2,time3,time4];

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
                [t1, t2, t3, t4] = synchroniseTimeByRBS(time1, time2 ,time3, time4, tempB23, tempB24, tempK23, tempK24);
                time = [t1; t2; t3; t4];
            end  

            global timeAfter;
            timeAfter = [timeAfter;time'];

             %cleanThisSeqData
            anchorRxTime(seqNum+1,1) = 0;
            anchorRxTime(seqNum+1,2) = 0;
            anchorRxTime(seqNum+1,3) = 0;
            anchorRxTime(seqNum+1,4) = 0;
    
            %解算定位结果
            [POS_X,POS_Y] = XYTDOA(time,seqNum);
            global posiRes;
            posiRes = [posiRes;POS_X,POS_Y];
            fprintf("chan定位结果，X: %.2f, Y: %.2f\n",POS_X,POS_Y);

        end
    elseif isKey(AnchorMap, sendAnchorOrLabel)  && isKey(AnchorMap ,receiveAnchor)
        anchorInteractionTimeMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor), seqNum + 1) = rxTime;
        anchorInteractionSeqMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)) = seqNum + 1;
        [tempK23, tempB23, tempK24, tempB24] = timeFitting(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, window, tempK23, tempK24, tempB23, tempB24);
    else
        fprintf("未知基站名%s, %s\n",sendAnchorOrLabel, receiveAnchor);  
    end

end
