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
                    % 例如 基站1发送信号，就把基站3，4同步到2上
                    base = 2;
                    if anchor == 2
                        base = 1;
                    end
                    anchorArr(find(anchorArr == base)) = [];
                    if anchor == 3 && base == 2
                        anchorArr(find(anchorArr == 4)) = [];
                    end
                    for i = 1 : length(anchorArr)
                        otherAnchor = anchorArr(i);
                        % 找寻 base 与 otherAnchor 之间的一阶线性关系
                        tempFittingRes = polyfit(tempFittingMatrix(anchor, base, :), tempFittingMatrix(anchor, otherAnchor, :), 1);
                        anchorFittingParamsMatrix(base, otherAnchor, 1) = tempFittingRes(1);
                        anchorFittingParamsMatrix(base, otherAnchor, 2) = tempFittingRes(2);
                        fprintf("基站%d 与 基站%d 已经时钟同步\n", base, otherAnchor);
                       
                    end
                    tempFittingMatrixSize(anchor) = 1;
                end
                lastIndexs(anchor) = seqNum;
            end
        end
    end  
end