%Input data
file = 'D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp\Myocardiocyte motion measurements.xlsx';
C = readcell(file);

%Category = col 3, beat rate = col 4, max motion = col 5
%%

%Prepare data
data = [C{2:end, 4}; C{2:end, 5}];
g = C(2:end, 3);

%%
[p, tbl, stats] = anova1(data, g);

c = multcompare(stats);