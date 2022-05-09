clc; 
close all; % clean window

globalConstant;
globalVariable;

tic();
invalidDataNum = 0;


posiRes = [];
mean_posiRes = [];
kal_posiRes = [];
kal_mean_posiRes = [];
kalmanDataArr = [];

config = initSystemConfig();
KF = Kfclass3(config);

for index = 1 : length(dataCell)
% for index = 1 : 500
    data_row = dataCell(index, :);

    % 拿到实时的观测数据
    [protocol_header, data_type, id, electricity...
     ,pos_x, pos_y, pos_z, time_stamp...
     ,sequence_number, isValid, mean_signal] = parseData(data_row);
    
    if ~isValid || isnan(pos_x) || isnan(pos_y) 
        invalidDataNum = invalidDataNum + 1;
        continue;
    end

    % 对滤波器进行初始化
    if config.initIndex == 1
        KF.initKf(pos_x, pos_y, time_stamp, config.initIndex);
        config.initIndex = config.initIndex + 1;
        continue;
    end
    Z = [pos_x, pos_y]
    
    kal_res = KF.Run(time_stamp, [pos_x; pos_y]);
    % mean_posi = KF.mean_Kf();
    Kal = [kal_res.pos_x_cor, kal_res.pos_y_cor]
    posiRes = [posiRes; pos_x, pos_y];
    kal_posiRes = [kal_posiRes; kal_res.pos_x_cor, kal_res.pos_y_cor];

    kal_mean_posiRes = [kal_mean_posiRes; kal_res.mean_x, kal_res.mean_y];

    % kalmanDataArr = [kalmanDataArr;pos_x, kal_res.pos_x_est, kal_res.pos_x_cor, mean_posi(1), kal_res.k_x...
    %                 , pos_y, kal_res.pos_y_est, kal_res.pos_y_cor,  mean_posi(2), kal_res.k_y];
    kalmanDataArr = [kalmanDataArr;pos_x, kal_res.pos_x_est, kal_res.pos_x_cor, kal_res.k_x...
                        ,pos_y, kal_res.pos_y_est, kal_res.pos_y_cor, kal_res.k_y];
    toc();

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
    mean_signal = data(15);                 %信号均值

end


function time = formatTime(time_stamp)
    time_stamp = char(time_stamp);
    hour =  str2double(time_stamp(12:13));
    minute = str2double(time_stamp(15:16));
    second = str2double(time_stamp(18:19));
    millisecond = str2double(time_stamp(21:end));
    time =  hour * 3600 + minute * 60 + second + millisecond / 1000;
    
end


