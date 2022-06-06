tcpPort = 3456;
t = tcpclient("192.168.1.50",3456);
dataCell = [];

globalConstant;
globalVariable;


posiRes = [];
kal_posiRes = [];
config = initSystemConfig();
KF = Kfclass4(config);
figure();
tic
a1 = animatedline('Color','b', 'LineWidth', 2);
a2 = animatedline('Color','r', 'LineWidth', 2);

axis([-1, 20, -1 , 18]);
axis equal;

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
                      % 拿到实时的观测数据
                    [protocol_header, data_type, id, electricity...
                     ,pos_x, pos_y, pos_z, time_stamp...
                     ,sequence_number, isValid, mean_signal] = parseData(sensorDataCells');

                    if ~isnan(pos_x) && ~isnan(pos_y) 
                        posiRes = [posiRes; pos_x, pos_y];
                    end
                
                    % 对滤波器进行初始化
                    if config.initIndex == 1
                        if isnan(pos_x) || isnan(pos_y)
                            continue;
                        end
                        KF.initKf(pos_x, pos_y, time_stamp);
                        config.initIndex = config.initIndex + 1;
                        continue;
                    end
                    Z = [pos_x, pos_y]
                   
                    kal_res = KF.Run(time_stamp, [pos_x; pos_y]);
               
                    Kal = [kal_res.pos_x_cor, kal_res.pos_y_cor]     
                    kal_posiRes = [kal_posiRes; kal_res.pos_x_cor, kal_res.pos_y_cor];
                    
                    addpoints(a1, pos_x, pos_y);
                    addpoints(a2, kal_res.pos_x_cor, kal_res.pos_y_cor);
                     % update screen 
                    drawnow limitrate
               end
           end   
        end
    end
end



function [protocol_header, data_type, id, electricity, pos_x, pos_y, pos_z, time_stamp, sequence_number, isValid, mean_signal] = parseData(data)

    protocol_header = data(1);              %协议头 
    data_type = data(2);                    %数据类型
    id = data(3);                           %ID
    electricity = data(4);                  %电量

    pos_x = str2double(data(5));
    pos_y = str2double(data(6));
    pos_z = str2double(data(7));            %坐标X，坐标Y，坐标Z 
    time_stamp = formatTime(data(9));       %时间

    sequence_number = str2double(data(10)); %序号
    isValid = str2double(data(13));         %是否有效
    mean_signal = str2double(data(15));     %信号均值

end

function time = formatTime(time_stamp)
    time_stamp = char(time_stamp);
    hour =  str2double(time_stamp(12:13));
    minute = str2double(time_stamp(15:16));
    second = str2double(time_stamp(18:19));
    millisecond = str2double(time_stamp(21:end));
    time =  hour * 3600 + minute * 60 + second + millisecond / 1000;
    
end