% fclose(instrfindall);%先关闭之前可能存在的UDP

% %127.0.0.1即为本地
% u1=udp('127.0.0.1','RemotePort',8847,'LocalPort',8848);
% %u1的本机端口为8848，即监听所有发到8848端口的消息；
% %u1的远程端口为8847，即若u1发送消息，则发送到8847端口，本机端口为8847的UDP便会受到u1的消息
% u2=udp('127.0.0.1','RemotePort',8848,'LocalPort',8849);%同上
% u3=udp('127.0.0.1','RemotePort',8848,'LocalPort',8850);%同上

% u1.DatagramReceivedFcn = @instrcallback;%设置u1接收到数据包时，调用回调函数显示
% u2.DatagramReceivedFcn = @instrcallback;%设置u2接收到数据包时，调用回调函数显示
% u3.DatagramReceivedFcn = @instrcallback;%设置u3接收到数据包时，调用回调函数显示

% fopen(u1);%打开udp连接
% fopen(u2);%同上
% fopen(u3);%同上

% %-------------------------尝试让u2、u3发送消息，u1接收消息--------------------
% fprintf(u2,'u1 receive data from u2');
% %u2发送消息，因为u2的远程端口为8848，故此时u1监听到了这个消息
% fscanf(u1)%u1接收到u2发来的消息
% fprintf(u3,'u1 receive data from u3');%同上
% fscanf(u1)%同上

% %--------------------尝试让u1发送消息，u2、u3接收消息-------------------------
% u1.Remoteport=8849;%更改u1的远程端口为u2的本地端口，这样u2可以收到u1的消息
% fprintf(u1,'u2 reveive data from u1');%u1向8849端口发送消息，即u2的本机端口
% fscanf(u2)%u2接收到u1发来的消息


% u1.Remoteport=8850;%更改u1的远程端口为u3的本地端口，这样u3可以收到u1的消息
% fprintf(u1,'u3 reveive data from u1');%u1向8850端口发送消息，即u3的本机端口
% fscanf(u3)%u3接收到u1发来的消息

% %综上，可以理解为UDP的远程端口为发送消息的端口，本机端口为接收消息的端口
% %当u1的远程端口对应u2的本地端口时，u2接收到u1的消息

% fclose(u1);%关闭udp1连接
% fclose(u2);%同上
% fclose(u3);
% delete(u1);%删除udp1连接，释放内存
% delete(u2);%同上
% delete(u3);
% clear u1;%清除工作区中的udp1数据
% clear u2;%同上
% clear u3;.



udpReceiver = dsp.UDPReceiver('LocalIPPort',20000, 'MaximumMessageLength', 1024);
while true   
    dataReceived = udpReceiver();  %dataReceived就是原始报文
    if ~isempty(dataReceived) %数据不空 开始处理
        fprintf("%s\n",dataReceived); 
        str = char(dataReceived)';
    end
end
release(udpReceiver);
