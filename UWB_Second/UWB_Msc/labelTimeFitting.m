
% 对基站接受到标签信号时间进行拟合 降低钟跳以及多径带来的误差
function fittedTime = labelTimeFitting(window, anchor, rxTime, seqNumber)
    persistent anchorIndexs;
    if isempty(anchorIndexs)
        anchorIndexs = [1, 1, 1, 1];
    end
    persistent preAnchorSeqs;
    if isempty(preAnchorSeqs)
        preAnchorSeqs = [0, 0, 0, 0];
    end
    persistent preAnchor;
    if isempty(preAnchor)
        preAnchor = zeros(4, 2);
    end
    global labelToAnchorTimeFittingMatrix;
    global fittingParamsMatrix;
    global hasFitted;
    % 还没有进行拟合就直接使用原始值
    if hasFitted == 0 
        fittedTime = rxTime;
    % 已有拟合参数就用模型去判断该数据是否为异常数据
    else
        a = fittingParamsMatrix(anchor, 1);
        % b = fittingParamsMatrix(anchor, 2);
        preSeq = preAnchor(anchor, 1);
        preTime = preAnchor(anchor, 2);
        currentSeq = seqNumber;
        if currentSeq < preSeq
            currentSeq = currentSeq +  256;
        end
        val = a * (currentSeq - preSeq) + preTime;
        threshold = 3 * a * (currentSeq - preSeq);
        % 接受的时间很可能是异常数据
        if abs(val - rxTime) > threshold
            fprintf("超过阈值 %d %f %f \n", anchor, val, rxTime);
            fittedTime = val;
        else
            fittedTime = rxTime;
        end
    end    

    %上一个信号的数据 
    preAnchor(anchor, 1) = seqNumber;
    preAnchor(anchor, 2) = fittedTime;


    % 基站接受到标签发送的信息序号
    % seqNumber = labelToAnchorSeqMatrix(anchor);
    % 基站接受到的标签发送的信息时间
    % rxTime = labelToAnchorTimeMatrix(anchor, seqNumber);

    
    if seqNumber < preAnchorSeqs(anchor) 
        seqNumber = seqNumber + 256;
        preAnchorSeqs(anchor) = seqNumber;
    end
    labelToAnchorTimeFittingMatrix(anchor, anchorIndexs(anchor), 1) = seqNumber;
    labelToAnchorTimeFittingMatrix(anchor, anchorIndexs(anchor), 2) = fittedTime;
    anchorIndexs(anchor) = anchorIndexs(anchor) + 1;
    if anchorIndexs(anchor) == window + 1
        % 进行一元一次线性拟合 假设接收时间和序号满足 y = ax + b 的线性关系
        res = polyfit(labelToAnchorTimeFittingMatrix(anchor, : , 1), labelToAnchorTimeFittingMatrix(anchor, : , 2) , 1);
        fittingParamsMatrix(anchor, 1) = res(1);
        fittingParamsMatrix(anchor, 2) = res(2);
        anchorIndexs(anchor) = 1;
        preAnchorSeqs(anchor) = 0;
        % 已完成至少一次数据拟合 之后可以使用模型去评判数据
        hasFitted = 1;
    end

end