fid = fopen('2022-10-08-15-12-00.txt');
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
