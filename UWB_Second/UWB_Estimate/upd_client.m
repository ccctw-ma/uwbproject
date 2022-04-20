%fclose(instrfindall);%先关闭之前可能存在的UDP

%127.0.0.1即为本地
udpClient =udp('127.0.0.1','RemotePort',20000,'LocalPort',10000);
%u1的本机端口为8848，即监听所有发到8848端口的消息；
%u1的远程端口为8847，即若u1发送消息，则发送到8847端口，本机端口为8847的UDP便会受到u1的消息
% u2=udp('127.0.0.1','RemotePort',8848,'LocalPort',8849);%同上
% u3=udp('127.0.0.1','RemotePort',8848,'LocalPort',8850);%同上

% u1.DatagramReceivedFcn = @instrcallback;%设置u1接收到数据包时，调用回调函数显示
fopen(udpClient);%打开udp连接


%--------------------u1发送消息-------------------------
% u1.Remoteport=8849;
% set(udpClient, 'OutputBufferSize', 8192);

while true
    fprintf(udpClient,'hi 8850 this is the message come form 127.0.0. 1:8848');%u1发送消息给u2
end

% u1.Remoteport=8850;
% fprintf(u1,'u3 reveive data from u1');%u1发送消息给u3

%--------------------u1接收消息-------------------------
% fscanf(u1)
% fscanf(u1)

%%
fclose(udpClient);%关闭udp1连接
delete(udpClient);%删除udp1连接，释放内存
clear udpClient;%清除工作区中的udp1数据

