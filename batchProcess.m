clearvars
clc

baseDir = 'D:\Projects\Research\2022-optical-flow-analyzer\processed';

wntFiles = dir(fullfile(baseDir, 'wnt*.mat'));

MFA = MotionFlowAnalyzer;

analyze(MFA, wntFiles(1:5), 'D:\Projects\Research\2022-optical-flow-analyzer\processed\analyzed\wnt.mat')
