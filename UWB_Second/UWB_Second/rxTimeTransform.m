% rxTimeHigh    时间高位，四个字节
% rxTimeLow     时间低位，五个字节,最高字节组成tmpTimeLow_H，最低4字节组成tmpTimeLow_L
function rxTimes = rxTimeTransform(rxTimeHigh,rxTimeLow)
    con1 = power(2,40);
    con2 = power(2,32);
    con3 = 63897600000.0;

    rxTimeLen = length(rxTimeHigh); %高4位例：00000047
    for begin = 1:rxTimeLen
        if rxTimeHigh(begin) ~= '0'
            break;
        end
    end
    rxTimeHigh = extractBetween(rxTimeHigh,begin, rxTimeLen);
    %   处理低位 前两个字符是 时间低位中的 5字节中的 最高字节，剩下8个字符是 后四个字节
    rxTimeLowH = rxTimeLow(1:2);
    rxTimeLowL = rxTimeLow(3:end);
    %   hex2dec 作用是把字符串表示的16进制数转换成一个十进制数
    rxHigh = hex2dec(rxTimeHigh);
    rxLowH = hex2dec(rxTimeLowH);
    rxLowL = hex2dec(rxTimeLowL);
    
    v = rxHigh * con1;
    v = v + rxLowH * con2;
    v = v + rxLowL;
    rxTimes = double(v) / con3;

end




