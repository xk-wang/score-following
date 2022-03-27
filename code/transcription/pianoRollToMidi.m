function [midi,pianoRoll] = pianoRollToMidi(pianoRoll,timeResolution,minDur)
% pianoRollToMidi ��piano rollת��Ϊ3��MIDI�����������������ʱ��Լ����
%
% [midi,pianoRoll] = pianoRollToMidi(pianoRoll,timeResolution,minDur)
%
% Inputs:
%  pianoRoll        ���ж�Ӧ�����������Ϊ�кţ���i�ж�Ӧ��ʱ��Ϊ(i-1)*timeResolution
%  timeResolution   pianoRoll���������е�ʱ��s��
%  minDur           ��ѡ���������������ʱ��Լ����s����>=��
%
% Outputs:
%  midi             3�У�������� - onset(s) - offset(s)
%  pianoRoll        �����ʱ��Լ��ʱ�����޸�����pianoRoll

nPitch = size(pianoRoll,1);
eventFlag = diff([zeros(nPitch,1) pianoRoll zeros(nPitch,1)],1,2);
nNote = 0;   %�������������

% �Ը������ֱ�Ѱ��onset��offset time
if nargin == 2
    for iPitch = 1:nPitch
        onset = find(eventFlag(iPitch,:)==1);      %onset��Ӧ��֡
        offset = find(eventFlag(iPitch,:)==-1)-1;  %offset��Ӧ��֡
        iNote = nNote+1:nNote+length(onset);
        nNote = nNote+length(onset);
        midi(iNote,1) = iPitch;
        midi(iNote,2) = (onset-1)*timeResolution;  %onset(s)
        midi(iNote,3) = (offset-1)*timeResolution; %offset(s)
    end
else
    minNFrame = ceil(minDur/timeResolution);   %���ʱ����Ӧ��֡��Ų�
    for iPitch = 1:nPitch
        onset = find(eventFlag(iPitch,:)==1);
        offset = find(eventFlag(iPitch,:)==-1)-1;
        for iNote = 1:length(onset)
            if(offset(iNote)-onset(iNote)>=minNFrame) %���ʱ��Լ��
                nNote = nNote+1;
                midi(nNote,1) = iPitch;
                midi(nNote,2) = (onset(iNote)-1)*timeResolution;
                midi(nNote,3) = (offset(iNote)-1)*timeResolution;
            else
                pianoRoll(iPitch,onset(iNote):offset(iNote))=0;    %�޸�pianoRoll
            end
        end
    end
end

if nNote==0
    midi = [];
end
end