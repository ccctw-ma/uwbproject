clc; 
close all; % clean window

globalConstant;
globalVariable;

tic();
invalidDataNum = 0;

% load('../UWB_Data/dataCell_static_8_8-8.mat');
posiRes = [];
mean_posiRes = [];
kal_posiRes = [];
kal_mean_posiRes = [];
kalmanDataArr = [];
times = [];


config = initSystemConfig();
KF = Kfclass6(config);

for index = 1 : length(dataCell)

    data_row = dataCell(index, :);

    % 拿到实时的观测数据
    [protocol_header, data_type, id, electricity...
     ,pos_x, pos_y, pos_z, time_stamp...
     ,sequence_number, isValid, mean_signal] = parseData(data_row);

    posiRes = [posiRes; pos_x, pos_y];
    times = [times; time_stamp];
    node.pos_x = pos_x;
    node.pos_y = pos_y;
    node.time_stamp = time_stamp;
    node.mean_signal = mean_signal;
    % 对滤波器进行初始化
    if config.initIndex == 1
        if isnan(pos_x) || isnan(pos_y)
            continue;
        end
        KF.initKf(node);
        config.initIndex = config.initIndex + 1;
        kal_posiRes = [kal_posiRes; pos_x, pos_y];
        continue;
    end
   
    kal_res = KF.Run(node);
   
    kal_posiRes = [kal_posiRes; kal_res.pos_x_cor, kal_res.pos_y_cor];
    
    kalmanDataArr = [kalmanDataArr;pos_x, kal_res.pos_x_est, kal_res.pos_x_cor, kal_res.k_x, kal_res.v_x...
                        ,pos_y, kal_res.pos_y_est, kal_res.pos_y_cor, kal_res.k_y, kal_res.v_y];
    
% %     kal_mean_posiRes = [kal_mean_posiRes; kal_res.pos_x_smo, kal_res.pos_y_smo];
end
resTestSmooth2();
toc();

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


