figure();

axis([-1, 20, -1 , 18]);
axis equal;
hold on;
x = linspace(0, 10, 2000);
 
for k = 1:length(posiRes)
    scatter(posiRes(k, 1), posiRes(k, 2),'green');
    drawnow limitrate
end
drawnow

%%
h = animatedline('Color','r');
axis([-1, 20, -1 , 18]);
axis equal;
x = linspace(0,4*pi,10000);
y = sin(x);

for k = 1:length(posiRes)
    addpoints(h,posiRes(k, 1), posiRes(k, 2));
    drawnow 
end
%%
t = timer();
t.StartDelay = 3;
t.TimerFcn = @(~, ~) disp('3 seconds have elapsed');
start(t);
%%
t = timer;
t.StartFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
    datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t.StopFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
    datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
t.TimerFcn = @(~,thisEvent)disp([thisEvent.Type ' executed '...
     datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
% t.TasksToExecute = 3;
t.ExecutionMode = 'fixedRate';
t.Period = 2;

start(t)

%%
close all;
delete(timerfind());
realTimeViewer = timer;
index = 1;
tic();
% h = animatedline('Color','r','LineWidth',2);
realTimeViewer.StartFcn = @(~, thisEvent)disp(['1']);  toc(); 
realTimeViewer.TimerFcn = @(~, thisEvent) [disp(index); toc();];
realTimeViewer.Period = 0.01;
realTimeViewer.TasksToExecute = 100;
realTimeViewer.ExecutionMode = 'fixedRate';
realTimeViewer.StopFcn = @(~, thisEvent) toc(); disp(['3']);
start(realTimeViewer);

%%
c = timerfind();


%%
axis([-1, 20, -1 , 18]);
x = posiRes(:, 1);
y = posiRes(:, 2);
% plot(x,y)
hold on
p = plot(x(1),y(1),'o','MarkerFaceColor','red');
hold off
% axis manual
for k = 2:length(x)
    p.XData = x(k);
    p.YData = y(k);
    drawnow limitrate
end

%%
figure
u = uicontrol('Style','slider','Position',[10 50 20 340],...
    'Min',1,'Max',16,'Value',1);
for k = 1:16
    plot(fft(eye(k+16)))
    axis([-1 1 -1 1])
    u.Value = k;
    M(k) = getframe(gcf);
end

axes('Position',[0 0 1 1])
movie(M, 1)

%%
close all;
figure();
tic
a1 = animatedline('Color','b', 'LineWidth', 2);
a2 = animatedline('Color','r', 'LineWidth', 2);

axis([-1, 20, -1 , 18]);
axis equal;
x = linspace(0,20,10000);
for k = 1:length(kal_posiRes)
    % first line
    xk = posiRes(k, 1);
    yk = posiRes(k, 2);
    addpoints(a1, xk, yk);

    % second line
    xk = kal_posiRes(k, 1);
    yk = kal_posiRes(k, 2);
    addpoints(a2, xk, yk);

    % update screen 
    drawnow limitrate
    pause(0.005);
end
toc

%%
x = linspace(-6,6,1000);
y = sin(x);
plot(x,y)
axis manual
ax = gca;
h = hgtransform('Parent',ax);
hold on
plot(x(1),y(1),'o','Parent',h);
hold off
t = text(x(1),y(1),num2str(y(1)),'Parent',h,...
    'VerticalAlignment','top','FontSize',14);

for k = 2:length(x)
    m = makehgtform('translate',x(k)-x(1),y(k)-y(1),0);
    h.Matrix = m;
    t.String = num2str(y(k));
    drawnow
end

