clc;
close all;


global_Name;     %定位数据包
anchorPosition;  %基站位置 以及一些常量信息

for count = 1:size(dataCell,1)
    seqNum = str2double(dataCell{count,1}{1,2});        %序列号
    sendAnchorOrLabel = dataCell{count,1}{1,3};         %发送的基站或标签
    receiveAnchor = dataCell{count,1}{1,4};             %接收者的标签
    rxTime = rxTimeTransform(dataCell{count,1}{1,5},dataCell{count,1}{1,6});        %接收时间
    % fprintf("该组数据为 %d %s %s %d\n", seqNum, sendAnchorOrLabel, receiveAnchor, rxTime);

    % 如果发送方是标签
    if strcmp(sendAnchorOrLabel,Label)
        %基站接收到定位数据的本地时间
        if strcmp(receiveAnchor,Anchor1)
            anchorRxtime(seqNum+1, 1) = rxTime;
        elseif strcmp(receiveAnchor,Anchor2)
            anchorRxtime(seqNum+1, 2) = rxTime;
        elseif strcmp(receiveAnchor,Anchor3)
            anchorRxtime(seqNum+1, 3) = rxTime;
        elseif strcmp(receiveAnchor,Anchor4)
            anchorRxtime(seqNum+1, 4) = rxTime;
        end
        
        if length(find(anchorRxtime(seqNum + 1, : ) ~= 0 )) == 4
            time1 = anchorRxtime(seqNum+1,1);
            time2 = anchorRxtime(seqNum+1,2);
            time3 = anchorRxtime(seqNum+1,3);
            time4 = anchorRxtime(seqNum+1,4);
            time = [time1; time2; time3; time4];

            % 对时间进行同步
            [t1, t2, t3, t4] = synchroniseTimeByRBS(time1, time2 ,time3, time4, tempB23, tempB24, tempK23, tempK24);
            time = [t1; t2; t3; t4];
              
            timeAfter = [timeAfter;time'];
            
            
            %cleanThisSeqData
            anchorRxtime(seqNum+1,1) = 0;
            anchorRxtime(seqNum+1,2) = 0;
            anchorRxtime(seqNum+1,3) = 0;
            anchorRxtime(seqNum+1,4) = 0;
    
            %解算定位结果
            [POS_X,POS_Y] = XYTDOA(time,seqNum);
            posiRes = [posiRes;POS_X,POS_Y];
            fprintf("chan定位结果, X: %.2f, Y: %.2f\n",POS_X,POS_Y);
            % [xTaylor,yTaylor] = taylorCalculateXY(POS_X,POS_Y);

        end


    % 不是标签发出的消息就把基站之间的消息存起来，待数量达到窗口值时进行始终的线性拟合 
    elseif isKey(AnchorMap, sendAnchorOrLabel)  && isKey(AnchorMap ,receiveAnchor)
        anchorInteractionTimeMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor), seqNum + 1) = rxTime;
        anchorInteractionSeqMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)) = seqNum + 1;
        [tempK23, tempB23, tempK24, tempB24] = timeFitting(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, window, tempK23, tempK24, tempB23, tempB24);
    else
        fprintf("未知基站名%s, %s\n",sendAnchorOrLabel, receiveAnchor);  
    end
end    











