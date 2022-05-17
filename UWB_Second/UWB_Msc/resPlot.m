function resPlot(R, POS_X, POS_Y)
    hyperbolaPlot(0, 0, 6.3, 0, R(1))
    hyperbolaPlot(0, 0, 6.3, 4.7, R(2))
    hyperbolaPlot(0, 0, 0, 4.7, R(3))
    scatter(POS_X, POS_Y, 'g', '*')
    scatter(4.3, 1.85, 'b', '+')
    scatter(0, 0, 'r','p')
    scatter(6.3, 0, 'r','p')
    scatter(6.3, 4.7, 'r','p')
    scatter(0, 4.7, 'r','p')
    hold off
end