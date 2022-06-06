filename = 'data.txt';
fid = fopen(filename,'w');
for count = 1:size(dataCell,1)
    fprintf(fid,['%s',',','%s',',','%s',',','%s',',','%s',',','%s',',','%s',',','%s',',','%s',',','%s','\n'],dataCell{count,1}{1,:});
end
fclose(fid);
