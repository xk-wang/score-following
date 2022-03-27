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
% generateMultipitchFile ���ɷ���mir_eval������������۵��ļ�
% 
% Inputs:
%  pianoRoll        �����������
%  timeResolution   pianoRoll���������е�ʱ��s��
%  filePath         ���ɵ��ļ���·��
%  Ҫ��pianoRoll��i�ж�Ӧ��������MIDI pitchΪ(i+20)��MIDI pitch 60 --> C4 = middle C��,��Ӧ��Ƶ��Ϊ440*2.^((i+20-69)/12);
%       ��j�ж�Ӧ���м�ʱ��Ϊ(j-1)*timeResolution

for iFrame = 1:size(pianoRoll,2);
    time = (iFrame-1)*timeResolution;       %��֡�м�ʱ��
    note = find(pianoRoll(:,iFrame)==1);    %��֡�����������
    frequency = 440*2.^((note+20-69)/12);   %��֡�������������Ƶ�ʣ�Hz��
    dlmwrite(filePath,[time frequency'],'-append','delimiter','\t');
end
end

function generateTranscriptionFile(midi,filePath)
% generateTranscriptionFile ���ɷ���mir_eval�Զ�����ת¼���۵��ļ�
% 
% Inputs:
%  midi         ת¼�����3�У�MIDI pitch - onset(s) - offset(s)��
%  filePath     ���ɵ��ļ���·��
%  Ҫ��midi��MIDI pitch i��Ӧ��Ƶ��Ϊ440*2.^((i+20-69)/12)

midi = midi(:,[2,3,1]);
midi(:,3) = 440*2.^((midi(:,3)-69)/12); %��MIDI pitchת��ΪƵ�ʣ�Hz��
save(filePath,'midi','-ascii');
end