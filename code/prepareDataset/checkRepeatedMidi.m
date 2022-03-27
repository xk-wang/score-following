function isRepeated = checkRepeatedMidi(folder)
% checkRepeatedMidi ���folder�ļ����ڵ�MIDI�ļ��Ƿ����ͬһ����ͬһʱ�������¼
% isRepeated = checkRepeatedMidi(folder)
% �����⣺midi_lib

if exist(folder,'dir')==0
    error('������ļ���·��������');
end

midis = dir([folder,'/*.mid']);
nMidi = length(midis);
isRepeated = cell(nMidi,2);
for iMidi = 1:nMidi
    midiName = midis(iMidi).name;
    isRepeated{iMidi,1} = midiName;
    midi = readmidi_java([folder,'\',midiName]);
    onset = unique(midi(:,6));
    offset = midi(:,6)+midi(:,7);
    for iEvent = 1:length(onset)
        thisOnset = onset(iEvent);
        mAll = find(midi(:,6)<=thisOnset & offset>thisOnset);
        pitches = midi(mAll,4);
        
        uniquePitches = unique(pitches);
        if length(pitches)-length(uniquePitches)~=0
            isRepeated{iMidi,2} = 1;
            break
            % �ϲ�Ϊһ��
            % repeatPitches = uniquePitches(histc(pitches,uniquePitches)~=1);
            % for iPitch = 1:length(repeatPitches)
            %     index = mAll(pitches==repeatPitches(iPitch));
            %     thisOnset = min(midi(index,6));
            %     thisDuration = max(offset(index))-thisOnset;
            %     midi(index(1),[6,7]) = [thisOnset,thisDuration];
            %     midi(index(2:end),:) = [];
            % end
        end
    end
end
end