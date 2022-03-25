
% 基于RBS(参考广播同步算法)对基站的时间进行线性拟合，在窗口值为window的条件下进行数据进行处理得到时钟的线性关系
function anchorTimeFitting()
 
    systemConstant;
    global anchorInteractionSeqMatrix;
    global anchorInteractionTimeMatrix;
    global anchorFittingParamsMatrix;
    global tempFittingMatrix;
    global tempFittingMatrixSize;
    global lastIndexs;
    % 对所有基站进行线性拟合
    for anchor = 1 : anchorNum
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
                    
                    % 例如 基站1发送信号，就把基站3，4同步到2上
                    base = anchor + 1;
                    if base == 5
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



    % if seq12 == seq13 && seq13 == seq14 && seq12 ~= lastIndex2
    %     % 基站2，3，4均收到来自基站1的信号
    %     if length(find(anchorInteractionTimeMatrix(1, 2:4, seq12) ~= 0)) == 3
    %         % fprintf("满足设定要求基站1发射的序号:  %d %d %d \n",seq12,seq13,seq14);
    %         % fprintf("各自接受到的时间:  %d %d %d \n",anchorInteractionTimeMatrix(1,2,seq12),anchorInteractionTimeMatrix(1,3,seq12),anchorInteractionTimeMatrix(1,3,seq12));
            
    %         % 构建用于线性拟合的矩阵
    %         tempY23Matrix(seqCount2) = anchorInteractionTimeMatrix(1,3,seq12);
    %         tempY24Matrix(seqCount2) = anchorInteractionTimeMatrix(1,4,seq12);
    %         tempX2Matrix(seqCount2) = anchorInteractionTimeMatrix(1,2,seq12);
    %         seqCount2 = seqCount2 + 1;
    %         % 收集够满足窗口大小的数据 开始使用最小二乘法的线性拟合
    %         if seqCount2 == window + 1
    %             % plot(tempX2Matrix(:,1), tempY23Matrix(:))
    %             % plot(tempX2Matrix(:,1), tempY24Matrix(:))               
    %             % res23 = inv(tempX2Matrix.' * tempX2Matrix) * tempX2Matrix.' * tempY23Matrix;
    %             % res24 = inv(tempX2Matrix.' * tempX2Matrix) * tempX2Matrix.' * tempY24Matrix;
    %             % 时钟之间是 y = kx + b 的线性关系
    %             res23 = polyfit(tempX2Matrix, tempY23Matrix, 1);
    %             res24 = polyfit(tempX2Matrix, tempY24Matrix, 1);
    %             tempK23 = res23(1);
    %             tempB23 = res23(2);
    %             tempK24 = res24(1);
    %             tempB24 = res24(2);
    %             % fprintf("timeFitting %d %d %d %d\n",tempK23, tempB23, tempK24, tempB24);
    %             seqCount2 = 1;
    %         end
    %         lastIndex2 = seq12;
    %     end
    % end   
end