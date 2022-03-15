% 1.保存原始报文的csv  2.保存测距差R21 R31 R41
udpPort = 6666;
udpReceiver = dsp.UDPReceiver('LocalIPPort',udpPort, 'MaximumMessageLength', 1024);
global_Name1;
global_Name2;
dataCell = [];
while true   
    dataReceived = udpReceiver();  %dataReceived就是原始报文
    if ~isempty(dataReceived) %数据不空 开始处理
%        fprintf("%s",dataReceived); 
       str = char(dataReceived)';
       str = strtrim(str);      %删除前导和尾随空白
       adjoinIndex = regexp(str,'#[A-Z][A-Z]');     %用正则表达式计算#RT出现位置
       if ~isempty(adjoinIndex)
           dataCount = size(adjoinIndex,2);     %判断报文是否粘连
           if dataCount == 1    %无粘连
                sensorDataCells = split(str, ',');
                dataCell = [dataCell;{sensorDataCells'}];   %以元胞形式存储报文
                MessProcess2(sensorDataCells');
           elseif dataCount == 2    %粘连
               str1 = str(1:adjoinIndex(1,2)-1);    %用str1,str2将粘连报文分开
               str2 = str(adjoinIndex(1,2):end);
               sensorDataCells1 = split(str1, ',');     %分割报文
               sensorDataCells2 = split(str2, ',');
               dataCell = [dataCell;{sensorDataCells1'};{sensorDataCells2'}];   %以元胞形式存储报文
               MessProcess2(sensorDataCells1');
               MessProcess2(sensorDataCells2');
           end
       end

    end
%     pause(0.001)
end
release(udpReceiver);
%  报文保存   测距差保存   测距成功率（发送频率、粘连和不粘连的概率） 


%%
% 删除定位结果里的全0行
posiRes(all(posiRes == 0, 2), : ) = [];
% 列的均值
res_mean = mean(posiRes, 1);
fprintf("定位结果均值 X: %f, Y: %f\n", res_mean(1), res_mean(2));
% 列元素的标准差
res_std = std(posiRes, 0 , 1);
fprintf("定位结果标准差 X: %f, Y: %f\n", res_std(1), res_std(2));