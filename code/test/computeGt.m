function [midiGt,pianoRollGt] = computeGt(midiMatPath)
% computeGt ����ground truth������Ϊmat�ļ�
% [midiGt,pianoRollGt] = computeGt(midiMatPath)
% pianoRollGt ʱ��ֱ��ʹ̶�Ϊ0.01s

gtTimeResolution = 0.01;
midis = dir([midiMatPath,'/*.mat']);
nMidi = length(midis);
midiGt = cell(nMidi,1);
pianoRollGt = cell(1,nMidi);
for iMidi = 1:nMidi
    load([midiMatPath,'\',midis(iMidi).name]);
    midiGt{iMidi} = midi;
    pianoRollGt{iMidi} = midiToPianoRoll(midi,gtTimeResolution);
end
save('gt.mat','midiGt','pianoRollGt');
end