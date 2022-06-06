close all;
clc;

delete(timerfind);
realTimeViewer = timer;
o.index = 1;
tic();
% h = animatedline('Color','r','LineWidth',2);
realTimeViewer.StartFcn = @timerStart;
realTimeViewer.TimerFcn = @(~,~) timerFuction(o);
realTimeViewer.Period = 0.1;
realTimeViewer.TasksToExecute = 10;
realTimeViewer.ExecutionMode = 'fixedRate';
realTimeViewer.StopFcn = @timerEnd;
start(realTimeViewer);


function timerStart(~, e)
    disp(['开始操作']);  
    toc(); 
end

function timerFuction(o)
    o.index = o.index + 1;
    o.index
    disp([ '正在操作 ']);  
    toc(); 
end

function timerEnd(t, e)
    disp(['结束操作']);
    toc();
    delete(t);
end