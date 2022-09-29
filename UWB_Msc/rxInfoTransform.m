
function [stdNoise, firstPathAmp1, firstPathAmp2, firstPathAmp3, maxGrowthCIR, rxPreamCount] = rxInfoTransform(ori, data)
    infos = strsplit(data, '-');
    stdNoise = hex2dec(char(infos(1)));
    firstPathAmp1 = hex2dec(char(infos(2)));
    firstPathAmp2 = hex2dec(char(infos(3)));
    firstPathAmp3 = hex2dec(char(infos(4)));
    maxGrowthCIR = hex2dec(char(infos(5)));
    rxPreamCount = hex2dec(char(infos(6)));
end