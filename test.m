% csv_test
x0 = [ 0 1 2 3 4 5 6 7 8 9 0]

row = [0 x0];
fid = fopen('result.csv', 'a');
fprintf(fid, '%g,', row(1:end-1));
fprintf(fid, '%g\n', row(end));
fclose(fid);