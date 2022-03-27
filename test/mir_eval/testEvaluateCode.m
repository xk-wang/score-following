function testEvaluateCode()
addpath(genpath('..\..\code\evaluate'));

timeResolution = 0.01;
load('Data\pianoRoll.mat');
load('Data\pianoRollGt.mat');
generateMultipitchFile(pianoRoll,timeResolution,'DataPy\multipitch.txt');
generateMultipitchFile(pianoRollGt,timeResolution,'DataPy\multipitchGt.txt');
resultFrameLevel = computeAccuracyFrameLevel(pianoRoll,pianoRollGt,0);
resultFrameLevelIgnoreOctaveErrors = computeAccuracyFrameLevel(pianoRoll,pianoRollGt,1);
clear('pianoRoll','pianoRollGt');

onsetTolerance = 0.05;
load('Data\midi.mat');
load('Data\midiGt.mat');
generateTranscriptionFile(midi,'DataPy\transcription.txt');
generateTranscriptionFile(midiGt,'DataPy\transcriptionGt.txt');
resultNoteLevel = computeAccuracyNoteLevel(midi,midiGt,onsetTolerance,0);
resultNoteLevelIgnoreOctaveErrors = computeAccuracyNoteLevel(midi,midiGt,onsetTolerance,1);
clear('midi','midiGt');

save result\result.mat resultFrameLevel resultFrameLevelIgnoreOctaveErrors resultNoteLevel resultNoteLevelIgnoreOctaveErrors
rmpath(genpath('..\..\code\evaluate'));
end

function generateMultipitchFile(pianoRoll,timeResolution,filePath)
% generateMultipitchFile 生成符合mir_eval多音调检测评价的文件
% 
% Inputs:
%  pianoRoll        多音调检测结果
%  timeResolution   pianoRoll中连续两列的时间差（s）
%  filePath         生成的文件的路径
%  要求：pianoRoll第i行对应的音符的MIDI pitch为(i+20)（MIDI pitch 60 --> C4 = middle C）,对应的频率为440*2.^((i+20-69)/12);
%       第j列对应的中间时刻为(j-1)*timeResolution

for iFrame = 1:size(pianoRoll,2);
    time = (iFrame-1)*timeResolution;       %该帧中间时刻
    note = find(pianoRoll(:,iFrame)==1);    %该帧被演奏的音符
    frequency = 440*2.^((note+20-69)/12);   %该帧被演奏的音符的频率（Hz）
    dlmwrite(filePath,[time frequency'],'-append','delimiter','\t');
end
end

function generateTranscriptionFile(midi,filePath)
% generateTranscriptionFile 生成符合mir_eval自动音乐转录评价的文件
% 
% Inputs:
%  midi         转录结果，3列（MIDI pitch - onset(s) - offset(s)）
%  filePath     生成的文件的路径
%  要求：midi中MIDI pitch i对应的频率为440*2.^((i+20-69)/12)

midi = midi(:,[2,3,1]);
midi(:,3) = 440*2.^((midi(:,3)-69)/12); %将MIDI pitch转换为频率（Hz）
save(filePath,'midi','-ascii');
end