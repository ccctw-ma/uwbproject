classdef resPlot < handle
    %RESPLOT 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        video
        mTimer
        period
        posiRes
        kal_posiRes
        times
        anchors
        firstFrame
        index
        remainTime
        pre_time
        
        dataDelay
        curDataDelay
        videoDelay
        curVideoDelay

        h
        p1 
        p2
        p3

        a1
        a2
    end
    
    methods
        function obj = resPlot(fileUrl, posiRes, kal_posiRes, times, dataDelay, videoDelay)
           delete(timerfindall());
           obj.video = VideoReader(fileUrl);
           obj.posiRes = posiRes;
           obj.kal_posiRes = kal_posiRes;
           obj.times = times;
           obj.anchors = [
                0, 7.2;
                0, 0;
                20.8, 0;
                20.8, 7.2;
                10.4, 7.2;
            ];
            obj.period = round(1 / obj.video.FrameRate, 3);
            obj.firstFrame = readFrame(obj.video);
            obj.index = 1;
            obj.remainTime = 0;
            obj.pre_time = 0;
            obj.dataDelay = dataDelay;
            obj.curDataDelay = 0;
            obj.videoDelay = videoDelay;
            obj.curVideoDelay = 0;

            obj.mTimer = timer();
            obj.mTimer.StartFcn = @obj.first;
            obj.mTimer.TimerFcn = @obj.step;
            obj.mTimer.ExecutionMode = "Fixedrate";
            obj.mTimer.Period = obj.period;
            
            clc;
            close all;
            obj.h = figure();				% 创建图形窗口
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	% 关闭相关的警告提示（因为调用了非公开接口）
            jFrame = get(obj.h,'JavaFrame');	% 获取底层 Java 结构相关句柄吧
            pause(0.1);					% 在 Win 10，Matlab 2017b 环境下不加停顿会报 Java 底层错误。各人根据需要可以进行实验验证
            set(jFrame,'Maximized',1);	%设置其最大化为真（0 为假）
            pause(0.1);					% 个人实践中发现如果不停顿，窗口可能来不及变化，所获取的窗口大小还是原来的尺寸。各人根据需要可以进行实验验证
            warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		% 打开相关警告设置
            obj.p1 = subplot(2, 2, 1);
            hold on;
            axis([-1, 20, -1 , 15]);
            axis image;
            title(obj.p1, '观测值', 'FontSize', 16);

            for i = 1 : size(obj.anchors, 1)
                x = obj.anchors(i, 1);
                y = obj.anchors(i, 2);
                scatter(x, y, 100, 'k','s', 'filled');
            end

            obj.p2 = subplot(2, 2, 3);
            hold on;
            axis([-1, 20, -1 , 15]);
            axis image;
            title(obj.p2, '算法修正值', 'FontSize', 16);
            for i = 1 : size(obj.anchors, 1)
                x = obj.anchors(i, 1);
                y = obj.anchors(i, 2);
                scatter(x, y, 100, 'k','s', 'filled');
            end

            obj.a1 = animatedline('Parent',obj.p1,'Color','b','LineWidth',2);
            obj.a2 = animatedline('Parent',obj.p2,'Color','r','LineWidth',2);

            obj.p3 = subplot(2,2,[2,4]);
            axis image;
            title(obj.p3, '视频录像', 'FontSize', 16);
        end
        
        function draw(obj)
            

            start(obj.mTimer);
            
        end
        
        function first(obj, ~, ~)
            set(image(obj.firstFrame), 'cdata', readFrame(obj.video))
            obj.pre_time = obj.times(obj.index);
            addpoints(obj.a1, obj.posiRes(obj.index, 1), obj.posiRes(obj.index, 2));
            addpoints(obj.a2, obj.kal_posiRes(obj.index, 1), obj.kal_posiRes(obj.index, 2));
            drawnow limitrate;
            obj.index = obj.index + 1;
        end

        function step(obj, t, ~)
            if obj.curVideoDelay < obj.videoDelay
                obj.curVideoDelay = obj.curVideoDelay + 1;
            else
                if hasFrame(obj.video)
                    set(image(obj.firstFrame), 'cdata', readFrame(obj.video))
                else
                    stop(t), delete(t);
                end
            end

            if obj.curDataDelay < obj.dataDelay
                obj.curDataDelay = obj.curDataDelay + 1;
            else
                while obj.index <= length(obj.times)
                    delta = obj.times(obj.index) - obj.pre_time;
                    obj.pre_time = obj.times(obj.index);
                    addpoints(obj.a1, obj.posiRes(obj.index, 1), obj.posiRes(obj.index, 2));
                    addpoints(obj.a2, obj.kal_posiRes(obj.index, 1), obj.kal_posiRes(obj.index, 2));
                    drawnow limitrate;
                    obj.index = obj.index + 1;
                    obj.remainTime = obj.remainTime + delta;
                    if obj.remainTime >= obj.period
                        obj.remainTime = mod(obj.remainTime, obj.period);
                        break;
                    end
                end
            end
        end
    end
end

