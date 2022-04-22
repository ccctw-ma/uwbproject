clc; 
close all; % clean window

globalConstant;
globalVariable;

tic
% posiRes = [];
% mean_posiRes = [];
% kal_posiRes = [];
ftm_posiRes = [];
ftm_mean_posiRes = [];
kalmanDataArr = [];
invalidDataNum = 0;

% figure();
% hold on;
% axis([-1, 7, -1 , 5]);

cfg = testFtmPeConfig();
KF = KfFtmclass(cfg); % Kalman Filter Constructor
mean_set = zeros(2, 5);
tic()

Anchors = [
    0.25, 3.75;
    0.25, 0.5;
    6.75, 0.5;
    6.75, 4.75;
    4,    5;
];

for index = 1 : length(dataCell)
% for index = 1 : 1000
    data_row = dataCell(index, :);
    [protocol_header, data_type, id, electricity...
     ,pos_x, pos_y, pos_z, time_stamp...
     ,sequence_number, isValid, mean_signal] = parseData(data_row);
    
    if ~isValid || isnan(pos_x) || isnan(pos_y) 
        invalidDataNum = invalidDataNum + 1;
        continue;
    end

    if index == 1
        KF.initKF(time_stamp, [pos_x, pos_y, pos_z]');
        continue;
    end

    for i = 1: 5
        x = Anchors(i, 1);
        y = Anchors(i, 2);
        measRange = sqrt((pos_x - x) ^ 2 + (pos_y - y) ^ 2);
        Rsp.pos = [x, y, 0]';
        [posEst,updateDone,bias,latErrPredict,latErrUpdate,KFtime] = KF.Run(measRange, time_stamp, Rsp);
        mean_set(1, i) = posEst(1);
        mean_set(2, i) = posEst(2);
         
    end

    ftm_posi = mean(mean_set, 2);
    mean_ftm_posi = KF.mean_Kf(ftm_posi);
    ftm_posiRes = [ftm_posiRes; ftm_posi'];
    ftm_mean_posiRes = [ ftm_mean_posiRes; mean_ftm_posi'];


    % scatter(pos_x, pos_y, 'blue');
    % scatter(mean_posi(1), mean_posi(2), 'r');
    % pause(0.00001);

end
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
    mean_signal = data(15);                 %信号均值

end


function time = formatTime(time_stamp)
    % time = datetime(strrep(time_stamp, "T", " "), 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
    % dur = time - datetime('1970-01-01', 'InputFormat', 'yyyy-MM-dd');
    % time = milliseconds(dur) / 1000;
    % days = datenum(time_stamp(1:10));

    time_stamp = char(time_stamp);
    hour =  str2double(time_stamp(12:13));
    minute = str2double(time_stamp(15:16));
    second = str2double(time_stamp(18:19));
    millisecond = str2double(time_stamp(21:end));
    time =  hour * 60 + minute * 60 + second + millisecond / 1000;
    
end


