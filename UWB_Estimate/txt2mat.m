fid = fopen('../UWB_Data/2022-09-17-11-50-21[标签先举过头顶跑一个来回，后放胸口跑一个来回].txt');
ff = fread(fid);
ends = find(ff == 10);
index = 1;
dataCell = [];
for i = 1 : length(ends)
    e = ends(i);
    ss = ff(index: e - 1);
    ss = char(ss);
    data_row = strsplit(ss', ',');
    dataCell = [dataCell; data_row];
    index = e + 1;
    index
end
