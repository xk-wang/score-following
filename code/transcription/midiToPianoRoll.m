function pianoRoll = midiToPianoRoll(midi,timeResolution)
% midiToPianoRoll ��MIDI��Ϣת��Ϊpiano roll
%
% pianoRoll = midiToPianoRoll(midi,timeResolution)
%
% Inputs:
%  midi             ��1-3�зֱ��ʾ��������� - onset(s) - offset(s)
%  timeResolution   pianoRoll���������е�ʱ��s��
%
% Outputs:
%  pianoRoll        �к�Ϊ������ţ���i�ж�Ӧ��ʱ��Ϊ(i-1)*timeResolution
%
% �ο�: https://code.soundsoftware.ac.uk/projects/score-informed-piano-transcription/repository/entry/convertMIDIToPianoRoll.m (by E. Benetos)

global NPITCH   %��������
pianoRoll = zeros(NPITCH,floor(max(midi(:,3))/timeResolution)+1);
for iNote = 1:size(midi,1)
    onsetFrame = ceil(midi(iNote,2)/timeResolution)+1;      %onset��Ӧ��֡
    offsetFrame = floor(midi(iNote,3)/timeResolution)+1;    %offset��Ӧ��֡
    pianoRoll(midi(iNote,1),onsetFrame:offsetFrame) = 1;
end
end