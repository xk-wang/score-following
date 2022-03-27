function [results wAcc wF] = batchProcessing()

addpath(genpath('../Libraries'));   %Ìí¼ÓÒÀÀµ¿âÂ·¾¶

fileList{1} = 'Disklavier_01_G1_A2.wav';
fileList{2} = 'Disklavier_02_G1_A3.wav';
fileList{3} = 'Disklavier_03_G1_B1.wav';
fileList{4} = 'Disklavier_04_G1_B3.wav';
fileList{5} = 'Disklavier_05_G2_A3.wav';
fileList{6} = 'Disklavier_06_G2_B2.wav';
fileList{7} = 'Disklavier_07_G2_C3.wav';


for i=2:7

    %[results{i} wAcc{i} wF{i}] = ScoreInformedTranscription_noMIDIsynth(fileList{i}, 15, 2.0, 1.3, 1.0, 2.1, 5);
    %È±comparePianoRolls_Rob_noMIDIsynthº¯Êý
    [results{i} wAcc{i} wF{i}] = ScoreInformedTranscription(fileList{i}, 15, 2.0, 1.3, 1.0, 2.1, 5);
    
end;

(wAcc{2} + wAcc{3} + wAcc{4} + wAcc{5} + wAcc{6} + wAcc{7})/6
(results{2}(3).Acc + results{3}(3).Acc + results{4}(3).Acc + results{5}(3).Acc + results{6}(3).Acc + results{7}(3).Acc)/6
(results{2}(4).Acc + results{3}(4).Acc + results{4}(4).Acc + results{5}(4).Acc + results{6}(4).Acc + results{7}(4).Acc)/6
(results{2}(5).Acc + results{3}(5).Acc + results{4}(5).Acc + results{5}(5).Acc + results{6}(5).Acc + results{7}(5).Acc)/6

rmpath(genpath('../Libraries'));    %É¾³ýÒÀÀµ¿âÂ·¾¶
