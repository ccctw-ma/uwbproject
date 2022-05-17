clc;
clear;
close all;

anchors = [
    0, 12.9;
    0, 0;
    15.4, 0;
    15.4, 14.3;
    8.7, 14.3;
];

% 路线参考路径
point_hat_set = [];


gcf  = figure();
SIZE = get(0, 'ScreenSize');
set(gcf, 'outerposition', SIZE);


dataFile1 = ["dataCell_moving1.mat","dataCell_moving2.mat"];
dataFile2 = ["dataCell_moving_round.mat", "dataCell_moving_round2.mat"]; 
dataFile3 = ["dataCell_moving_S.mat","dataCell_random_moving.mat"];
dataFile4 = ["dataCell_moving_X1.mat", "dataCell_moving_X2.mat"];
dataFile5 = ["dataCell_static_8_8-8.mat", "dataCell_static_12_7-2.mat"];
dataFileAll = [dataFile1, dataFile2, dataFile3, dataFile4, dataFile5];
tic();
dataFile = dataFile4;
for i = 1 : size(dataFile, 2)
    subplot(1, 2, i);
    axis([-1, 20, -1 , 18]);
    axis equal;
    hold on;
    data = load(dataFile(i));
    [posiRes, kal_posiRes, KF] = Main(data.dataCell);
    for j = 1 : size(anchors, 1)
        x = anchors(j, 1);
        y = anchors(j, 2);
        scatter(x, y, 100, 'k','s', 'filled');
    end
    scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
    scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
    scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
    scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(: ,2), 'yellow');
    hold off;
    toc();
end

function [posiRes, kal_posiRes, KF]  = Main(dataCell)
    clc; 
    globalConstant;
    globalVariable;

    invalidDataNum = 0;
    posiRes = [];
    mean_posiRes = [];
    kal_posiRes = [];
    kal_mean_posiRes = [];
    kalmanDataArr = [];
    signals = [];

    config = initSystemConfig();
    KF = Kfclass4(config);
    
    for index = 1 : length(dataCell)
    
        data_row = dataCell(index, :);
    
        % 拿到实时的观测数据
        [protocol_header, data_type, id, electricity...
         ,pos_x, pos_y, pos_z, time_stamp...
         ,sequence_number, isValid, mean_signal] = parseData(data_row);
    
        signals = [signals; mean_signal];
        
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
        % mean_posi = KF.mean_Kf();
        Kal = [kal_res.pos_x_cor, kal_res.pos_y_cor]
        
        kal_posiRes = [kal_posiRes; kal_res.pos_x_cor, kal_res.pos_y_cor];
    
    %     kal_mean_posiRes = [kal_mean_posiRes; kal_res.mean_x, kal_res.mean_y];
    
        % kalmanDataArr = [kalmanDataArr;pos_x, kal_res.pos_x_est, kal_res.pos_x_cor, mean_posi(1), kal_res.k_x...
        %                 , pos_y, kal_res.pos_y_est, kal_res.pos_y_cor,  mean_posi(2), kal_res.k_y];
        kalmanDataArr = [kalmanDataArr;pos_x, kal_res.pos_x_est, kal_res.pos_x_cor, kal_res.k_x...
                            ,pos_y, kal_res.pos_y_est, kal_res.pos_y_cor, kal_res.k_y];
    
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







