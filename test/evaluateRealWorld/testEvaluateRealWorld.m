[timeResolutionMfe,minDur,minDurFalsePos] = deal(0.01,0.06,0.1);

%% ���Ը���������evaluateRealWorld��ȷ�ԣ�����˵��.xlsx��
load('testRealWorld.mat');
pianoRoll = convertMidiToPianoRoll(performanceMidi,timeResolutionMfe);
tScore = (0:size(pianoRoll,2)-1)*timeResolutionMfe;
[isPlayed,falsePos] = evaluateRealWorld(pianoRoll,timeResolutionMfe,tScore,scoreMidi,minDur,minDurFalsePos);

%% ����MIDI����Ӧ��piano roll������evaluateRealWorld��ȷ��
isCorr = zeros(size(midiGt,1),1);
for iWav = 1:size(midiGt,1)
    scoreMidi = midiGt{iWav};
    scoreMidi(floor(scoreMidi(:,3)/timeResolutionMfe)-ceil(scoreMidi(:,2)/timeResolutionMfe)<ceil(minDur/timeResolutionMfe)+1,:) = [];
    pianoRoll = convertMidiToPianoRoll(scoreMidi,timeResolutionMfe);
    tScore = (0:size(pianoRoll,2)-1)*timeResolutionMfe;
    [isPlayed,falsePos] = evaluateRealWorld(pianoRoll,timeResolutionMfe,tScore,scoreMidi,minDur,minDurFalsePos);
    isCorr(iWav) = ~any(isPlayed-1) && isempty(falsePos);
end