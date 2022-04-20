clc; 
close all; % clean window
clear all;


%--------------------建立udp连接-------------------------
% udpServer = udp('192.168.1.50','RemotePort',10000,'LocalPort',20000);
% fopen(udpServer);

udpReceiver = dsp.UDPReceiver('LocalIPPort',20000, 'MaximumMessageLength', 1024);

globalConstant;
globalVariable;

posiRes = [];
mean_posiRes = [];
kal_posiRes = [];
kalmanDataArr = [];
invalidDataNum = 0;

% figure();
% hold on;
% axis([-1, 7, -1 , 5]);

config = initSystemConfig();
KF = Kfclass(config);

count = 1;
tmep_mean_size = 2;
tmep_mean = zeros(2, tmep_mean_size);


dataCell = [];
tic;

while true
    dataReceived = udpReceiver();  %dataReceived就是原始报文
    if ~isempty(dataReceived) %数据不空 开始处理
        str = char(dataReceived);
        data_row = strsplit(str', ',');
        if length(data_row) ~= 15
            continue;
        end
        [protocol_header, data_type, id, electricity...
         ,pos_x, pos_y, pos_z, time_stamp...
         ,sequence_number, isValid, mean_signal] = parseData(data_row);   

        
        if ~isValid || isnan(pos_x) || isnan(pos_y) 
            invalidDataNum = invalidDataNum + 1;
            continue;
        end
    
        % 收集数据
        dataCell = [dataCell; data_row];

        if ~config.hasInit
            KF.initKf(pos_x, pos_y, time_stamp);
            config.hasInit = true;
            continue;
        end
    
        [pos_x_est, pos_y_est, pos_x_cor, pos_y_cor, k_x, k_y] = KF.Run(time_stamp, [pos_x; pos_y]);
        mean_posi = KF.mean_Kf();
    
        posiRes = [posiRes; pos_x, pos_y];
        kal_posiRes = [kal_posiRes; pos_x_cor, pos_y_cor];
        mean_posiRes = [mean_posiRes; mean_posi(1), mean_posi(2)];
    
        kalmanDataArr = [kalmanDataArr;pos_x, pos_x_est, pos_x_cor, mean_posi(1), k_x, pos_y, pos_y_est, pos_y_cor,  mean_posi(2), k_y];

        % if count ~= tmep_mean_size +1
        %     tmep_mean(1, count) = mean_posi(1);
        %     tmep_mean(2, count) = mean_posi(2);
        %     count = count + 1;
        % else
            
        %     temp_mean_posi = mean(tmep_mean,2)
        %     scatter(temp_mean_posi(1), temp_mean_posi(2), 'r');
        %     scatter(pos_x, pos_y, 'b');
        %     count = 1;
        %     toc
        %     pause(0.000000000001);
        % end
        

        mean_posi
        toc;
        length(posiRes)
        % scatter(pos_x, pos_y, 'blue');
        % scatter(mean_posi(1), mean_posi(2), 'r');
        % pause(0.0000000001)


    end
end



%%
% fclose(udpServer);
% delete(udpServer);
% clear udpServer;
release(udpReceiver);