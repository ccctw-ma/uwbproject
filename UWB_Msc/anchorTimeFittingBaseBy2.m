
% 基于RBS(参考广播同步算法)对基站的时间进行线性拟合，在窗口值为window的条件下进行数据进行处理得到时钟的线性关系
function [tempK23, tempB23, tempK24, tempB24] = anchorTimeFittingBaseBy2(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, windowSize, tempK23, tempK24, tempB23, tempB24)
 
    global tempY23Matrix;
    global tempY24Matrix;
    global tempX2Matrix; 
    global seqCount2;
    global lastIndex2;
    seq12 = anchorInteractionSeqMatrix(1,2);
    seq13 = anchorInteractionSeqMatrix(1,3);
    seq14 = anchorInteractionSeqMatrix(1,4);

    if seq12 == seq13 && seq13 == seq14 && seq12 ~= lastIndex2
        % 基站2，3，4均收到来自基站1的信号
        if length(find(anchorInteractionTimeMatrix(1, 2:4, seq12) ~= 0)) == 3
            % fprintf("满足设定要求基站1发射的序号:  %d %d %d \n",seq12,seq13,seq14);
            % fprintf("各自接受到的时间:  %d %d %d \n",anchorInteractionTimeMatrix(1,2,seq12),anchorInteractionTimeMatrix(1,3,seq12),anchorInteractionTimeMatrix(1,3,seq12));
            
            % 构建用于线性拟合的矩阵
            tempY23Matrix(seqCount2) = anchorInteractionTimeMatrix(1,3,seq12);
            tempY24Matrix(seqCount2) = anchorInteractionTimeMatrix(1,4,seq12);
            tempX2Matrix(seqCount2) = anchorInteractionTimeMatrix(1,2,seq12);
            seqCount2 = seqCount2 + 1;
            % 收集够满足窗口大小的数据 开始使用最小二乘法的线性拟合
            if seqCount2 == windowSize + 1
                % plot(tempX2Matrix(:,1), tempY23Matrix(:))
                % plot(tempX2Matrix(:,1), tempY24Matrix(:))               
                % res23 = inv(tempX2Matrix.' * tempX2Matrix) * tempX2Matrix.' * tempY23Matrix;
                % res24 = inv(tempX2Matrix.' * tempX2Matrix) * tempX2Matrix.' * tempY24Matrix;
                % 时钟之间是 y = kx + b 的线性关系
                res23 = polyfit(tempX2Matrix, tempY23Matrix, 1);
                res24 = polyfit(tempX2Matrix, tempY24Matrix, 1);
                tempK23 = res23(1);
                tempB23 = res23(2);
                tempK24 = res24(1);
                tempB24 = res24(2);
                % fprintf("timeFitting %d %d %d %d\n",tempK23, tempB23, tempK24, tempB24);
                seqCount2 = 1;
            end
            lastIndex2 = seq12;
        end
    end   
end