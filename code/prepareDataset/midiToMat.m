function midiToMat(folder,destination,startSec,endSec)
% midiToMat ����folder�ļ����е�.mid�ļ�����ͬ��.mat�ļ�����destination�ļ���
% �������������>2�����ȡstartSec-endSec(s)���һ�Σ�����startSec��Ϊ0s
%
% midiToMat(folder,destination,startSec,endSec)
%
% ��destination�ļ��в������򴴽�
% mat�ļ��д洢midi������3�У�������ţ�MIDI pitch-20�� - onset(s) - offset(s)��MIDI pitch 60 --> C4 = middle C)����onset - �����������
% �����⣺midi_lib

if exist(folder,'dir')==0
    error('MIDI�ļ����ڵ��ļ��в�����');
end

% ��destination�ļ��в������򴴽�
if exist(destination,'dir')==0
    mkdir(destination);
end

midis = dir([folder,'/*.mid']);
for iMidi = 1:length(midis)
    % ��MIDI�ļ�������ʾΪ3�и�ʽ
    midiName = midis(iMidi).name;
    midi = readmidi_java([folder,'\',midiName]);
    midi = [midi(:,4)-20,midi(:,6),midi(:,6)+midi(:,7)];    %������� = MIDI pitch - 20
    
    % ��ֻ��ȡstartSec-endSec(s)���һ��
    if nargin > 2
        midi = cutMidi(midi,startSec,endSec);
    end
    
    % ����Ϊ.mat�ļ�
    midi = sortrows(midi,[2,1]);    %��onset - �����������
    save([destination,'\',midiName(1:end-4),'.mat'],'midi');
end
end