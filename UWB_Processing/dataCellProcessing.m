function dataCellProcessing(dataCell)

    systemConstant;  %基站位置 以及一些常量信息

    global anchorRxTime;
    global anchorInteractionTimeMatrix;
    global anchorInteractionSeqMatrix;

    global posiRes;
    global kalmanPosiRes;
    global timeBefore;
    global timeAfter;
    global dR;
    global abnormalRes;
    global timeBefore1;
    global timeBefore2;
    global timeBefore3;
    global timeBefore4;
    global InfoNumComesFromAnchor;
    global InfoNumComesFromLabel;
    
    seqNum = str2double(dataCell{1,2});        %序列号
    sendAnchorOrLabel = dataCell{1,3};         %发送的基站或标签
    receiveAnchor = dataCell{1,4};             %接收者的标签
    rxTime = rxTimeTransform(dataCell{1,5},dataCell{1,6});        %接收时间
    %fprintf("该组数据为 %d %s %s %d\n", seqNum, sendAnchorOrLabel, receiveAnchor, rxTime);
    % 如果发送方是标签
    if strcmp(sendAnchorOrLabel,Label)
        %基站接收到定位数据的本地时间

        InfoNumComesFromLabel = InfoNumComesFromLabel + 1;
        anchor = AnchorMap(receiveAnchor);
        anchorRxTime(seqNum + 1, anchor) = rxTime;
        if strcmp(receiveAnchor,Anchor1)
            timeBefore1 = [timeBefore1;seqNum + 1, rxTime];
        elseif strcmp(receiveAnchor,Anchor2)
            timeBefore2 = [timeBefore2;seqNum + 1, rxTime];
        elseif strcmp(receiveAnchor,Anchor3)
            timeBefore3 = [timeBefore3;seqNum + 1, rxTime];
        elseif strcmp(receiveAnchor,Anchor4)
            timeBefore4 = [timeBefore4;seqNum + 1, rxTime];
        end


        if length(find(anchorRxTime(seqNum + 1, : ) ~= 0 )) == 4
            time1 = anchorRxTime(seqNum+1,1);
            time2 = anchorRxTime(seqNum+1,2);
            time3 = anchorRxTime(seqNum+1,3);
            time4 = anchorRxTime(seqNum+1,4);
            time = [seqNum + 1; time1; time2; time3; time4];
            % 记录同步前且未进行拟合的时间数据
            toc;
            % fprintf("该组数据为 %d %s %s %d\n", seqNum, sendAnchorOrLabel, receiveAnchor, rxTime);
            timeBefore = [timeBefore;time'];
            % time
            % 对时间进行同步
            [t1, t2, t3, t4] = synchroniseTimeByRBS(time1, time2 ,time3, time4);
            time = [t1; t2; t3; t4];
            if range(time) > 1
                fprintf("时钟尚未全部同步\n");
            else
                
                % 记录同步后的时间
                timeAfter = [timeAfter;time'];
                %cleanThisSeqData
                for index = 0 : labelReceiveWindow
                    cleanIndex = seqNum - index;
                    if cleanIndex <= 0
                        cleanIndex = cleanIndex + dataPollingTimes;
                    end
                    anchorRxTime(cleanIndex, : ) = 0;
                end      
                R = [(t2 - t1) * C, (t3 - t1) * C, (t4 - t1) * C];
                dR  = [dR; R];
                kR = arrivalTimeKalmanFilter(R);
                [POS_X,POS_Y] = chan_base_3(R);
                [POS_X_K, POS_Y_K] = chan_base_3(kR);
                % resPlot(R, POS_X, POS_Y);
                if POS_X > -1 && POS_X < 10 && POS_Y > -1 && POS_Y < 10 
                    posiRes = [posiRes;POS_X, POS_Y];
                    scatter(POS_X, POS_Y, 'b');
                    pause(0.05);
                    fprintf("chan定位结果, X: %.2f, Y: %.2f\n",POS_X,POS_Y);
                else
                    abnormalRes = [abnormalRes;R];
                end
                if POS_X_K > -1 && POS_X_K < 10 && POS_Y_K > -1 && POS_Y_K < 10 
                    kalmanPosiRes = [kalmanPosiRes;POS_X_K, POS_Y_K];
                    scatter(POS_X_K, POS_Y_K, 'r');
                    pause(0.05);
                    fprintf("过滤后的定位结果, X: %.2f, Y: %.2f\n", POS_X_K, POS_Y_K);
                else
                    abnormalRes = [abnormalRes;R];
                end
            end
            

        end
    % 不是标签发出的消息就把基站之间的消息存起来，待数量达到窗口值时进行时钟的线性拟合 
    elseif isKey(AnchorMap, sendAnchorOrLabel)  && isKey(AnchorMap ,receiveAnchor)
        InfoNumComesFromAnchor = InfoNumComesFromAnchor + 1;
        anchorInteractionTimeMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor), seqNum + 1) = rxTime;
        anchorInteractionSeqMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)) = seqNum + 1;
        anchorTimeFitting();
    else
        fprintf("未知基站名%s, %s\n",sendAnchorOrLabel, receiveAnchor);  
    end  
    
end

