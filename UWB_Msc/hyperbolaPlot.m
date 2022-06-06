function hyperbolaPlot(x1, y1, x2, y2, d) %(x1,y1),(x2,y2)为焦点，d为距离差
    function z = myfun(x, y, x1, y1, x2, y2, d)
        z = (sqrt((x - x2) ^ 2 + (y - y2) ^ 2) - sqrt((x - x1) ^ 2 + (y - y1)^2)) - d;
    end
    h = ezplot(@(x, y)myfun(x, y, x1, y1, x2, y2, d)); %myfun()中，x1,y1,x2,y2,d为参数
    set(h, 'Color', [rand(), rand(), rand()])
    hold on
end