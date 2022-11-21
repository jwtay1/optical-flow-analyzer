clearvars
clc

dataFN = 'D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp\heartbeat.xlsx';

C = readcell(dataFN);

motion = [C{:, 2}];
group = {C{:, 3}};

[p, tbl, stats] = anova1(motion, group);

c = multcompare(stats);