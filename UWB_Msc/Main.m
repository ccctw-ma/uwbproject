clc;
close all;


% global_Name;     %定位数据包
% anchorPosition;  %基站位置 以及一些常量信息

systemVariable;

% 记录异常的定位结果
abnormalRes = [];
% 记录正常的定位结果所使用的时钟
normalRes = [];
timeBefore1 = [];
timeBefore2 = [];
timeBefore3 = [];
timeBefore4 = [];
seqNumbers = [];
% labelToAnchorTimeMatrix = zeros(4, 256);
% labelToAnchorSeqMatrix = zeros(4, 1) + 1;

diffR = [];
diffKalmanR = [];
diffMeanR = [];
kalmanPosiRes = [];
abnormalKalmanRes = [];

preTime = -1;
dts = [];
P = eye(6) * 100;
X = zeros(6, 1);
Xs = [];
Ks = [];
Ps = [];

nloss = [];
stdNoises = [];

anchorInteractionInfos = cell(4, 4);
global anchorInteractionInfosAfterCorrect;
anchorInteractionInfosAfterCorrect = cell(4, 4);

fittingParams = [];

figure();
hold on;
axis([-1, 7, -1 , 5]);

for count = 1 : size(dataCell, 1)
    % 排除掉不正常的原始数据
    if length(dataCell{count, 1}) ~= 10
        continue;
    end

    seqNum = str2double(dataCell{count,1}{1,2});        %序列号
    sendAnchorOrLabel = dataCell{count,1}{1,3};         %发送的基站或标签
    receiveAnchor = dataCell{count,1}{1,4};             %接收者的标签
    rxTime = rxTimeTransform(dataCell{count,1}{1,5},dataCell{count,1}{1,6});        %接收时间
    % 噪音水平标准差stdNoise， 路径1强度firstPathAmp1， 路径2强度firstPathAmp2，路径3强度firstPathAmp3， 信道最大冲击相应maxGrowthCIR，接收前导包数 rxPreamCount
    [stdNoise, firstPathAmp1, firstPathAmp2, firstPathAmp3, maxGrowthCIR, rxPreamCount] = rxInfoTransform(dataCell{count, 1}, dataCell{count, 1}{1, 7});
    % 信道功率PW1
    PW1 = str2double(dataCell{count, 1}{1, 8});
    % 信道功率PW2
    PW2 = str2double(dataCell{count, 1}{1, 9});
    % NLOS概率值
    NLOS = str2double(dataCell{count, 1}{1, 10});
    % fprintf("该组数据为 %d %s %s %d\n", seqNum, sendAnchorOrLabel, receiveAnchor, rxTime);
    nloss = [nloss; NLOS];
    stdNoises = [stdNoises;stdNoise];

    % matlab 下标从1开始
    seqNumber = seqNum + 1;

    % 如果发送方是标签
    if strcmp(sendAnchorOrLabel,Label)
        %基站接收到定位数据的本地时间

        % continue;
        anchor = AnchorMap(receiveAnchor);
        seqNumbers = [seqNumbers; seqNumber];
       
        if strcmp(receiveAnchor,Anchor1)
            anchorRxTime(seqNumber, 1) = rxTime;
            timeBefore1 = [timeBefore1;seqNumber, rxTime, stdNoise, NLOS];
        elseif strcmp(receiveAnchor,Anchor2)
            anchorRxTime(seqNumber, 2) = rxTime;
            timeBefore2 = [timeBefore2;seqNumber, rxTime, stdNoise, NLOS];
        elseif strcmp(receiveAnchor,Anchor3)
            anchorRxTime(seqNumber, 3) = rxTime;
            timeBefore3 = [timeBefore3;seqNumber, rxTime, stdNoise, NLOS];
        elseif strcmp(receiveAnchor,Anchor4)
            anchorRxTime(seqNumber, 4) = rxTime;
            timeBefore4 = [timeBefore4;seqNumber, rxTime, stdNoise, NLOS];
        end


        if length(find(anchorRxTime(seqNumber, : ) ~= 0 )) == 4
          
            time1 = anchorRxTime(seqNumber, 1);
            time2 = anchorRxTime(seqNumber, 2);
            time3 = anchorRxTime(seqNumber, 3);
            time4 = anchorRxTime(seqNumber, 4);
            time = [seqNumber, time1, time2, time3, time4];
            %在拿完数据后清除数据，避免后续拿到重复的数据
            for index = 0:labelReceiveWindow
                cleanIndex = seqNumber - index;
                if cleanIndex <= 0
                    cleanIndex = cleanIndex + dataPollingTimes;
                end
                anchorRxTime(cleanIndex, : ) = 0;
            end

            % 记录同步前且未进行拟合的时间数据
            timeBefore = [timeBefore;time];
            % 对时间进行同步
            [t1, t2, t3, t4] = synchroniseTimeByRBS(time1, time2 ,time3, time4, tempK21, tempB21, tempK23, tempB23, tempK24, tempB24);
            % [t1, t2, t3, t4] = synchroniseTimeByRBS2(time1, time2 ,time3, time4);
            time = [t1, t2, t3, t4];
            % fittingParams = [fittingParams;tempK21, tempK23, tempK24, tempB21, tempB23, tempB24];
            fittingParams = [fittingParams;anchorFittingParamsMatrix(2, 1, 1), anchorFittingParamsMatrix(2, 3, 1), anchorFittingParamsMatrix(2, 4, 1),anchorFittingParamsMatrix(2, 1, 2), anchorFittingParamsMatrix(2, 3, 2), anchorFittingParamsMatrix(2, 4, 2)];
            % 记录同步后的时间
            timeAfter = [timeAfter;time];
            if range(time) > 0.000001
                fprintf("基站时钟尚未同步\n");
                continue;
            end
            % 过滤没能正确同步的数据
            timeAfterFilter = [timeAfterFilter; time];
  
              
            R = [(t2 - t1) * C, (t3 - t1) * C, (t4 - t1) * C];
            % R = [R21, R31, R41];
            if preTime == -1
                dt = 0.5;               
            else
                dt = abs(t2 - preTime);
            end 
            dts = [dts; dt];
            preTime = t2;

            % [z, e, pos, mean_res, k] = DvKalman(R(1), dt);
            % Xs = [Xs;z, e, pos, mean_res, k];

            [kalmanR, meanR] = arrivalTimeKalmanFilter(R, dt);
            
            diffR = [diffR; R];
            diffKalmanR = [diffKalmanR; kalmanR];
            diffMeanR = [diffMeanR; meanR];

            [POS_X,POS_Y] = chan_base_3(kalmanR);
            [POS_X_K, POS_Y_K] = chan_base_3(meanR);

            scatter(POS_X_K, POS_Y_K, 'blue');
            pause(0.01);
            %resPlot(R, POS_X, POS_Y);
            if POS_X_K > -1 && POS_X_K < 10 && POS_Y_K > -1 && POS_Y_K < 10 
                kalmanPosiRes = [kalmanPosiRes;POS_X_K, POS_Y_K];
                fprintf("chan定位结果, X: %.2f, Y: %.2f\n",POS_X_K,POS_Y_K);
                % if preTime == -1
                %     dt = 0.5;               
                % else
                %     dt = abs(t2 - preTime);
                % end
                % dts = [dts; dt];
                % preTime = t2;
                % [X, K, P] = XYPositionKalmanFilter(dt, X, [POS_X_K; POS_Y_K], P, kalmanPosiRes);    
                % Xs = [Xs; X'];
                % Ks = [Ks; K(1, 1), K(4, 2)];
                % Ps = [Ps; P];
            else
                abnormalKalmanRes = [abnormalKalmanRes; kalmanR];
            end
            if POS_X > -1 && POS_X < 10 && POS_Y > -1 && POS_Y < 10 
                posiRes = [posiRes;POS_X, POS_Y];
                normalRes = [normalRes;seqNumber, t1, t2, t3, t4];
                
            else
                abnormalRes = [abnormalRes;seqNumber, t1, t2, t3, t4];
            end

        end


    % 不是标签发出的消息就把基站之间的消息存起来，待数量达到窗口值时进行时钟的线性拟合 
    elseif isKey(AnchorMap, sendAnchorOrLabel)  && isKey(AnchorMap ,receiveAnchor)
        anchorInteractionInfos{AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)} = [anchorInteractionInfos{AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)};seqNumber, rxTime, stdNoise, NLOS];
        % anchorTimeFitting(sendAnchorOrLabel, receiveAnchor, seqNumber, rxTime);
        anchorInteractionTimeMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor), seqNum + 1) = rxTime;
        anchorInteractionSeqMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)) = seqNum + 1;
        [tempK23, tempB23, tempK24, tempB24] = anchorTimeFittingBaseBy2(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, windowSize, tempK23, tempK24, tempB23, tempB24);
        [tempK21, tempB21] = anchorTimeFittingBaseBy3(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, windowSize, tempK21, tempB21);
        
    else
        fprintf("未知基站名%s, %s\n",sendAnchorOrLabel, receiveAnchor);  
    end
end    

% 删除定位结果里的全0行
% posiRes(all(posiRes == 0, 2), : ) = [];
% 列的均值
% res_mean = mean(posiRes, 1);
% fprintf("定位结果均值 X: %f, Y: %f\n", res_mean(1), res_mean(2));

% res_distance12 = sqrt(power(res_mean(1) - Anchor2PosX, 2) + power(res_mean(2) - Anchor2PosY, 2)) - sqrt(power(res_mean(1) - Anchor1PosX, 2) + power(res_mean(2) - Anchor1PosY, 2));
% 列元素的标准差
% res_std = std(posiRes, 0 , 1);
% fprintf("定位结果标准差 X: %f, Y: %f\n", res_std(1), res_std(2));
% fprintf("可用的数据：%d 异常数据：%d 比例为：%f \n", length(posiRes), length(abnormalRes), length(abnormalRes)/ (length(abnormalRes) + length(posiRes)));


 