clc;
close all;


global_Name;     %定位数据包
anchorPosition;  %基站位置 以及一些常量信息

% 记录异常的定位结果
abnormalRes = [];
% 记录正常的定位结果所使用的时钟
normalRes = [];
timeBefore1 = [];
timeBefore2 = [];
timeBefore3 = [];
timeBefore4 = [];
fittedTimeCollections = [];
seqNumbers = [];
% labelToAnchorTimeMatrix = zeros(4, 256);
% labelToAnchorSeqMatrix = zeros(4, 1) + 1;

labelReceiveWindow = 16;
diffR = [];
diffKalmanR = [];
kalmanPosiRes = [];
abnormalKalmanRes = [];



for count = 1 : size(dataCell, 1)
    seqNum = str2double(dataCell{count,1}{1,2});        %序列号
    sendAnchorOrLabel = dataCell{count,1}{1,3};         %发送的基站或标签
    receiveAnchor = dataCell{count,1}{1,4};             %接收者的标签
    rxTime = rxTimeTransform(dataCell{count,1}{1,5},dataCell{count,1}{1,6});        %接收时间
    % fprintf("该组数据为 %d %s %s %d\n", seqNum, sendAnchorOrLabel, receiveAnchor, rxTime);

    % 如果发送方是标签
    if strcmp(sendAnchorOrLabel,Label)
        %基站接收到定位数据的本地时间

        anchor = AnchorMap(receiveAnchor);
        seqNumber = seqNum + 1;
        seqNumbers = [seqNumbers; seqNumber];
        % 对基站接受到的来自标签的时间进行拟合
        % fittedTime = labelTimeFitting(window, anchor, rxTime, seqNumber);
        fittedTime = rxTime;
        % fittedTimeCollections = [fittedTimeCollections;rxTime, fittedTime];
        if strcmp(receiveAnchor,Anchor1)
            anchorRxtime(seqNumber, 1) = fittedTime;
            timeBefore1 = [timeBefore1;seqNumber, fittedTime];
        elseif strcmp(receiveAnchor,Anchor2)
            anchorRxtime(seqNumber, 2) = fittedTime;
            timeBefore2 = [timeBefore2;seqNumber, fittedTime];
        elseif strcmp(receiveAnchor,Anchor3)
            anchorRxtime(seqNumber, 3) = fittedTime;
            timeBefore3 = [timeBefore3;seqNumber, fittedTime];
        elseif strcmp(receiveAnchor,Anchor4)
            anchorRxtime(seqNumber, 4) = fittedTime;
            timeBefore4 = [timeBefore4;seqNumber, fittedTime];
        end


        if length(find(anchorRxtime(seqNum + 1, : ) ~= 0 )) == 4
            if sum(clockSynchronized) ~= 3
                fprintf("基站时钟尚未同步\n");
                continue;
            end
            time1 = anchorRxtime(seqNumber, 1);
            time2 = anchorRxtime(seqNumber, 2);
            time3 = anchorRxtime(seqNumber, 3);
            time4 = anchorRxtime(seqNumber, 4);
            time = [seqNumber, time1, time2, time3, time4];
            % 记录同步前且未进行拟合的时间数据
            timeBefore = [timeBefore;time];
            % 对时间进行同步
            [t1, t2, t3, t4] = synchroniseTimeByRBS(time1, time2 ,time3, time4, tempK21, tempB21, tempK23, tempB23, tempK24, tempB24);
            % [t1, t2, t3, t4] = synchroniseTimeByRBS(time1, time2 ,time3, time4);
            time = [t1, t2, t3, t4];
            % 记录同步后的时间
            timeAfter = [timeAfter;time];
            %cleanThisSeqData
            for index = 0:labelReceiveWindow
                cleanIndex = seqNumber - index;
                if cleanIndex <= 0
                    cleanIndex = cleanIndex + dataPollingTimes;
                end
                anchorRxtime(cleanIndex, : ) = 0;
            end
              
            R = [(t2 - t1) * C, (t3 - t1) * C, (t4 - t1) * C];
            % R = [R21, R31, R41];
            diffR = [diffR; R];

            kalmanR = arrivalTimeKalmanFilter(R);
            % kalmanR = arrivalTimeKalmanFilter(R, time);
            diffKalmanR = [diffKalmanR; kalmanR];


            [POS_X,POS_Y] = chan_base_3(R);
            [POS_X_K, POS_Y_K] = chan_base_3(kalmanR);

            
            %resPlot(R, POS_X, POS_Y);
            if POS_X_K > -1 && POS_X_K < 10 && POS_Y_K > -1 && POS_Y_K < 10 
                kalmanPosiRes = [kalmanPosiRes;POS_X_K, POS_Y_K];
                
            else
                abnormalKalmanRes = [abnormalKalmanRes;POS_X_K, POS_Y_K, kalmanR];
            end
            if POS_X > -1 && POS_X < 10 && POS_Y > -1 && POS_Y < 10 
                posiRes = [posiRes;POS_X, POS_Y];
                normalRes = [normalRes;seqNumber, t1, t2, t3, t4];
                % if preTime == -1
                %     dt = 0.5;               
                % else
                %     dt = abs(t2 - preTime);
                % end
                % dts = [dts; dt];
                % preTime = t2;
                % [X, K, P] = XYPositionKalmanFilter(dt, X, [POS_X; POS_Y], P);    
                % Xs = [Xs;X'];
                % Ks = [Ks;K];
                % Ps = [Ps;P];
                fprintf("chan定位结果, X: %.2f, Y: %.2f\n",POS_X,POS_Y);
            else
                abnormalRes = [abnormalRes;seqNumber, t1, t2, t3, t4];
                % abnormalRes = [abnormalRes; seqNumber, time1, time2, time3, time4];
            end

        end


    % 不是标签发出的消息就把基站之间的消息存起来，待数量达到窗口值时进行时钟的线性拟合 
    elseif isKey(AnchorMap, sendAnchorOrLabel)  && isKey(AnchorMap ,receiveAnchor)
        anchorInteractionTimeMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor), seqNum + 1) = rxTime;
        anchorInteractionSeqMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)) = seqNum + 1;
        [tempK23, tempB23, tempK24, tempB24] = anchorTimeFittingBaseBy2(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, window, tempK23, tempK24, tempB23, tempB24);
        [tempK21, tempB21] = anchorTimeFittingBaseBy3(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, window, tempK21, tempB21);
        
    else
        fprintf("未知基站名%s, %s\n",sendAnchorOrLabel, receiveAnchor);  
    end
end    

% 删除定位结果里的全0行
posiRes(all(posiRes == 0, 2), : ) = [];
% 列的均值
res_mean = mean(posiRes, 1);
fprintf("定位结果均值 X: %f, Y: %f\n", res_mean(1), res_mean(2));

res_distance12 = sqrt(power(res_mean(1) - Anchor2PosX, 2) + power(res_mean(2) - Anchor2PosY, 2)) - sqrt(power(res_mean(1) - Anchor1PosX, 2) + power(res_mean(2) - Anchor1PosY, 2));
% 列元素的标准差
res_std = std(posiRes, 0 , 1);
fprintf("定位结果标准差 X: %f, Y: %f\n", res_std(1), res_std(2));
fprintf("可用的数据：%d 异常数据：%d 比例为：%f \n", length(posiRes), length(abnormalRes), length(abnormalRes)/ (length(abnormalRes) + length(posiRes)));