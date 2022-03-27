function pianoRoll = midiToPianoRoll(midi,timeResolution)
% midiToPianoRoll 将MIDI信息转换为piano roll
%
% pianoRoll = midiToPianoRoll(midi,timeResolution)
%
% Inputs:
%  midi             第1-3列分别表示：音符序号 - onset(s) - offset(s)
%  timeResolution   pianoRoll中连续两列的时间差（s）
%
% Outputs:
%  pianoRoll        行号为音符序号，第i列对应的时间为(i-1)*timeResolution
%
% 参考: https://code.soundsoftware.ac.uk/projects/score-informed-piano-transcription/repository/entry/convertMIDIToPianoRoll.m (by E. Benetos)

global NPITCH   %音调个数
pianoRoll = zeros(NPITCH,floor(max(midi(:,3))/timeResolution)+1);
for iNote = 1:size(midi,1)
    onsetFrame = ceil(midi(iNote,2)/timeResolution)+1;      %onset对应的帧
    offsetFrame = floor(midi(iNote,3)/timeResolution)+1;    %offset对应的帧
    pianoRoll(midi(iNote,1),onsetFrame:offsetFrame) = 1;
end
end