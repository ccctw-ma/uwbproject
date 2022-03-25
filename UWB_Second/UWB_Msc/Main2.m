% version 2

clc;
close all;


systemConstant;

% 基站之间交互的时间矩阵
anchorInteractionTimeMatrix = zeros(anchorNum, anchorNum, dataPollingTimes);

% 基站之间交互的序号矩阵
anchorInteractionSeqMatrix = zeros(anchorNum, anchorNum, 1) + 1;

% 基站之间进行拟合的参数矩阵 y = ax + b, 这里保存 a 和 b;
anchorFittingParamsMatrix = zeros(anchorNum, anchorNum, 2) + 1;

% 各个基站接受到标签发送信号的时间
anchorRxTime = zeros(dataPollingTimes, anchorNum);

% 时间拟合中上一次存储的序号
lastIndexs = zeros(1, anchorNum);

% 时间拟合用到的矩阵 用来存储需要拟合的数据  
tempFittingMatrix = zeros(anchorNum, anchorNum, windowSize);

% 时间拟合矩阵当前的的大小
tempFittingMatrixSize = zeros(1, anchorNum) + 1;

rMinus = [];
posiRes = [];
timeAfter = [];
timeBefore = [];
distance_label_anchor1 = [];

% 记录异常的定位结果
abnormalRes = [];
timeBefore1 = [];
timeBefore2 = [];
timeBefore3 = [];
timeBefore4 = [];

dR = [];

for count = 1:size(dataCell,1)
    seqNum = str2double(dataCell{count,1}{1,2});        %序列号
    sendAnchorOrLabel = dataCell{count,1}{1,3};         %发送的基站或标签
    receiveAnchor = dataCell{count,1}{1,4};             %接收者的标签
    rxTime = rxTimeTransform(dataCell{count,1}{1,5},dataCell{count,1}{1,6});        %接收时间
    % fprintf("该组数据为 %d %s %s %d\n", seqNum, sendAnchorOrLabel, receiveAnchor, rxTime);

    % 如果发送方是标签
    if strcmp(sendAnchorOrLabel,Label)
        %基站接收到定位数据的本地时间
        seqNumber = seqNum + 1;
        % 对基站接受到的来自标签的时间进行拟合
        fittedTime = rxTime;
        if strcmp(receiveAnchor,Anchor1)
            anchorRxtime(seqNum+1, 1) = fittedTime;
            timeBefore1 = [timeBefore1;seqNum + 1, fittedTime];
        elseif strcmp(receiveAnchor,Anchor2)
            anchorRxtime(seqNum+1, 2) = fittedTime;
            timeBefore2 = [timeBefore2;seqNum + 1, fittedTime];
        elseif strcmp(receiveAnchor,Anchor3)
            anchorRxtime(seqNum+1, 3) = fittedTime;
            timeBefore3 = [timeBefore3;seqNum + 1, fittedTime];
        elseif strcmp(receiveAnchor,Anchor4)
            anchorRxtime(seqNum+1, 4) = fittedTime;
            timeBefore4 = [timeBefore4;seqNum + 1, fittedTime];
        end


        if length(find(anchorRxtime(seqNum + 1, : ) ~= 0 )) == 4
            time1 = anchorRxtime(seqNum+1,1);
            time2 = anchorRxtime(seqNum+1,2);
            time3 = anchorRxtime(seqNum+1,3);
            time4 = anchorRxtime(seqNum+1,4);
            time = [time1; time2; time3; time4];
            % 记录同步前且未进行拟合的时间数据
            timeBefore = [timeBefore;time'];
            % 对时间进行同步
            [t1, t2, t3, t4] = synchroniseTimeByRBS2(anchorFittingParamsMatrix, time1, time2 ,time3, time4);
            time = [t1; t2; t3; t4];
            
            % 记录同步后的时间
            timeAfter = [timeAfter;time'];
            %cleanThisSeqData
            for index = 0:labelReceiveWindow
                cleanIndex = seqNumber - index;
                if cleanIndex <= 0
                    cleanIndex = cleanIndex + dataPollingTimes;
                end
                anchorRxtime(cleanIndex, : ) = 0;
            end
            R = [(t2 - t1) * C, (t3 - t1) * C, (t4 - t1) * C];
            dR = [dR; R];

            % [xTaylor,yTaylor] = taylorCalculateXY(POS_X,POS_Y);
            %解算定位结果
            % [POS_X,POS_Y] = XYTDOA(time,seqNum);
            [POS_X,POS_Y] = chanNumOfAnchor3([t1, t2, t3]);
            
            % X = myChan2(BSN, BS, R, dR)
            % X = myChan2_test(BSN, BS, R, dR)
            % X = myChan3(BSN, BS, R, dR)
            % X = myChan3_test(BSN, BS, R, dR)
            % POS_X = X(1);
            % POS_Y = X(2);
            % POS_Z = X(3);
            if POS_X > 0 && POS_X < 10 && POS_Y > 0 && POS_Y < 10 
                posiRes = [posiRes;POS_X, POS_Y];
                fprintf("chan定位结果, X: %.2f, Y: %.2f\n",POS_X,POS_Y);
            else
                abnormalRes = [abnormalRes;time1, time2, time3, time4];
            end

        end


    % 不是标签发出的消息就把基站之间的消息存起来，待数量达到窗口值时进行时钟的线性拟合 
    elseif isKey(AnchorMap, sendAnchorOrLabel)  && isKey(AnchorMap ,receiveAnchor)
        anchorInteractionTimeMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor), seqNum + 1) = rxTime;
        anchorInteractionSeqMatrix(AnchorMap(sendAnchorOrLabel), AnchorMap(receiveAnchor)) = seqNum + 1;
        % 不使用四号基站
        for anchor = 1 : anchorNum - 1
            anchorArr = [1 : anchorNum];
            anchorArr(anchor) = [];
            % 此时anchor向其它anchorNum - 1个基站发送的序号相同就可以存起来进行拟合
            if range(anchorInteractionSeqMatrix(anchor, anchorArr)) == 0 && anchorInteractionSeqMatrix(anchor, anchorArr(1)) ~= lastIndexs(anchor)
                seqNum = anchorInteractionSeqMatrix(anchor, anchorArr(1));
                % 其它anchorNum - 1个基站接受的信息不为空
                if length(find(anchorInteractionTimeMatrix(anchor, anchorArr, seqNum) ~= 0)) == anchorNum - 1
                    tempFittingMatrix(anchor, anchorArr, tempFittingMatrixSize(anchor)) = anchorInteractionTimeMatrix(anchor, anchorArr, seqNum);
                    tempFittingMatrixSize(anchor) = tempFittingMatrixSize(anchor) + 1;
                    % 数据量达到窗口值就开始拟合
                    if tempFittingMatrixSize(anchor) == windowSize + 1
                        % 例如 基站1发送信号，就把基站3，4同步到2上 尽量同步到1 2 这两个基站上
                        % 1 : 2 (3 4)
                        % 2 : 1 (3 4)
                        % 3 : 2 (1 4)
                        base = 2;
                        if anchor == 2
                            base = 1;
                        end
                        anchorArr(find(anchorArr == base)) = [];
                        for i = 1 : length(anchorArr)
                            otherAnchor = anchorArr(i);
                            tempFittingRes = polyfit(tempFittingMatrix(anchor, base, :), tempFittingMatrix(anchor, otherAnchor, :), 1);
                            anchorFittingParamsMatrix(base, otherAnchor, 1) = tempFittingRes(1);
                            anchorFittingParamsMatrix(base, otherAnchor, 2) = tempFittingRes(2);
                           
                        end
                        tempFittingMatrixSize(anchor) = 1;
                    end
                    lastIndexs(anchor) = seqNum;
                end
            end
        end
    else
        fprintf("未知基站名%s, %s\n",sendAnchorOrLabel, receiveAnchor);  
    end
end    

% 删除定位结果里的全0行
posiRes(all(posiRes == 0, 2), : ) = [];
% 列的均值
% res_mean = mean(posiRes, 1);
% fprintf("定位结果均值 X: %f, Y: %f\n", res_mean(1), res_mean(2));

% res_distance12 = sqrt(power(res_mean(1) - Anchor2PosX, 2) + power(res_mean(2) - Anchor2PosY, 2)) - sqrt(power(res_mean(1) - Anchor1PosX, 2) + power(res_mean(2) - Anchor1PosY, 2));
% 列元素的标准差
% res_std = std(posiRes, 0 , 1);
% fprintf("定位结果标准差 X: %f, Y: %f\n", res_std(1), res_std(2));
% fprintf("可用的数据：%d 异常数据：%d 比例为：%f \n", length(posiRes), length(abnormalRes), length(abnormalRes)/ (length(abnormalRes) + length(posiRes)));