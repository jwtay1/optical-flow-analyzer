clearvars
clc

file = 'D:\Projects\Research\2022-optical-flow-analyzer\data\const\const_12047_1_001.nd2';
outputDir = 'D:\Projects\Research\2022-optical-flow-analyzer\processed\test';

MFP = MotionFlowProcessor;
process(MFP, file, outputDir)