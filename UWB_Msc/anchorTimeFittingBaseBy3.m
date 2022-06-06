
% 基于RBS(参考广播同步算法)对基站的时间进行线性拟合，在窗口值为window的条件下进行数据进行处理得到时钟的线性关系
function [tempK21, tempB21] = anchorTimeFittingBaseBy3(anchorInteractionSeqMatrix, anchorInteractionTimeMatrix, windowSize, tempK21, tempB21)
    global seqCount3;
    global lastIndex3;
    global tempY12Matrix;
    global tempX2MatrixBase3;
    seq31 = anchorInteractionSeqMatrix(3,1);
    seq32 = anchorInteractionSeqMatrix(3,2);
    

    if seq31 == seq32 && seq31 ~= lastIndex3
        % 基站2，3，4均收到来自基站1的信号
        if length(find(anchorInteractionTimeMatrix(3, 1:2, seq31) ~= 0)) == 2
            % fprintf("满足设定要求基站1发射的序号:  %d %d %d \n",seq12,seq13,seq14);
            % fprintf("各自接受到的时间:  %d %d %d \n",anchorInteractionTimeMatrix(1,2,seq12),anchorInteractionTimeMatrix(1,3,seq12),anchorInteractionTimeMatrix(1,3,seq12));
            
            % 构建用于线性拟合的矩阵
            tempY12Matrix(seqCount3) = anchorInteractionTimeMatrix(3,1,seq31);
            tempX2MatrixBase3(seqCount3) = anchorInteractionTimeMatrix(3,2,seq31);
            seqCount3 = seqCount3 + 1;
            % 收集够满足窗口大小的数据 开始使用最小二乘法的线性拟合
            if seqCount3 == windowSize + 1
                % 时钟之间是 y = kx + b 的线性关系
                res12 = polyfit(tempX2MatrixBase3, tempY12Matrix, 1);
                tempK21 = res12(1);
                tempB21 = res12(2);
                % fprintf("timeFitting %f %f \n",tempK21, tempB21);
                seqCount3 = 1;
            end
            lastIndex3 = seq31;
        end
    end   
end