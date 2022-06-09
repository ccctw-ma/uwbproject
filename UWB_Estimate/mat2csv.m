

tarFileName = "test.txt";
fop = fopen(tarFileName,'wt');

for i = 1 : length(dataCell)
    data_row = dataCell(i, :);
    s = join(data_row, ',');
    fprintf(fop,'%s', s);
    fprintf(fop, '\n');
end
back = fclose(fop);