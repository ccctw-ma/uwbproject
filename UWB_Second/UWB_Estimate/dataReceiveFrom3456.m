
tcpPort = 3456;
t = tcpclient("192.168.1.50",3456);
dataCell = [];

while true
    while (t.NumBytesAvailable > 0)
        dataReceived = readline(t);
         if ~isempty(dataReceived) %数据不空 开始处理
           fprintf("%s",dataReceived); 
           str = string(dataReceived)';
           str = strtrim(str);      %删除前导和尾随空白
%            str = split(str, ',');
    %         adjoinIndex = startsWith(str,'nanoLES')     %用正则表达式计算#RT出现位置
            if  startsWith(str,'nanoLES')
                sensorDataCells = split(str, ',');
                if size(sensorDataCells,1) == 15
                     dataCell = [dataCell;sensorDataCells'];   %以元胞形式存储报文
                end
            end
         end

    end
end
%%
% disconnect(t);