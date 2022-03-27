function [midi,pianoRoll] = pianoRollToMidi(pianoRoll,timeResolution,minDur)
% pianoRollToMidi 将piano roll转换为3列MIDI（，并加音符的最短时长约束）
%
% [midi,pianoRoll] = pianoRollToMidi(pianoRoll,timeResolution,minDur)
%
% Inputs:
%  pianoRoll        各行对应的音符的序号为行号，第i列对应的时间为(i-1)*timeResolution
%  timeResolution   pianoRoll中连续两列的时间差（s）
%  minDur           可选参数，音符的最短时长约束（s）（>=）
%
% Outputs:
%  midi             3列，音符序号 - onset(s) - offset(s)
%  pianoRoll        加最短时长约束时，会修改输入pianoRoll

nPitch = size(pianoRoll,1);
eventFlag = diff([zeros(nPitch,1) pianoRoll zeros(nPitch,1)],1,2);
nNote = 0;   %演奏的音符总数

% 对各音符分别寻找onset、offset time
if nargin == 2
    for iPitch = 1:nPitch
        onset = find(eventFlag(iPitch,:)==1);      %onset对应的帧
        offset = find(eventFlag(iPitch,:)==-1)-1;  %offset对应的帧
        iNote = nNote+1:nNote+length(onset);
        nNote = nNote+length(onset);
        midi(iNote,1) = iPitch;
        midi(iNote,2) = (onset-1)*timeResolution;  %onset(s)
        midi(iNote,3) = (offset-1)*timeResolution; %offset(s)
    end
else
    minNFrame = ceil(minDur/timeResolution);   %最短时长对应的帧序号差
    for iPitch = 1:nPitch
        onset = find(eventFlag(iPitch,:)==1);
        offset = find(eventFlag(iPitch,:)==-1)-1;
        for iNote = 1:length(onset)
            if(offset(iNote)-onset(iNote)>=minNFrame) %最短时长约束
                nNote = nNote+1;
                midi(nNote,1) = iPitch;
                midi(nNote,2) = (onset(iNote)-1)*timeResolution;
                midi(nNote,3) = (offset(iNote)-1)*timeResolution;
            else
                pianoRoll(iPitch,onset(iNote):offset(iNote))=0;    %修改pianoRoll
            end
        end
    end
end

if nNote==0
    midi = [];
end
end