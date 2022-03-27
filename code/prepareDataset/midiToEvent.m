function midiToEvent(folder,destination,minDur)
% midiToEvent ��folder�ļ����е�MIDI����ת��Ϊevent��Ϣ����ͬ���ļ�����destination�ļ���
% �������������>2����ϲ����С��minDur��s����onset
%
% midiToEvent(folder,destination,minDur)
%
% ��folder��destination��ͬ����ԭMIDI���ݽ���event��Ϣ���ǡ�
% ��destination�ļ��в������򴴽�
% mat�ļ��д洢midi��������1-3�зֱ��ʾ��������� - onset(s) - offset(s)
% ���ɵ�.mat�ļ��д洢eventԪ�����飬5�У�
%  (1)onset(s)�����ڼ���������ࣩ
%  (2)�˿������������MIDI�����е��кţ����������������ж��Ƿ����ࣩ
%  (3)�˿��������������MIDI�����е��кţ��������׸����б����һ��λ��Ӧ�������Ƿ����ࣩ
%  (4)�˿���������������������
%  (5)���Ա�Ƶʱ���˿��������������������ţ�[0,11]��
% �������������>2��Ҫ��MIDI���ݰ�onset�������ɵ�event��2��5��Ϊ[],��3��4�в�һһ��Ӧ

if exist(folder,'dir')==0
    error('MIDI�������ڵ��ļ��в�����');
end

% ��destination�ļ��в������򴴽�
if exist(destination,'dir')==0
    mkdir(destination);
end

midis = dir([folder,'/*.mat']);
for iMidi = 1:length(midis)
    midiName = midis(iMidi).name;
    load([folder,'\',midiName]);
    if nargin>2
        event = [];
        onsetDiff = [diff(midi(:,2));minDur+eps];
        iNote = 1;
        while(iNote<=size(midi,1))
            jNote = iNote+find(onsetDiff(iNote:end)>=minDur,1)-1;
            event{end+1,1} = unique(midi(iNote:jNote,2));
            event{end,3} = iNote:jNote;
            event{end,4} = sort(midi(iNote:jNote,1));
            iNote = jNote+1;
        end
        event{1,5} = [];
    else
        onset = unique(midi(:,2));  %unique����������
        nOnset = length(onset);
        event = cell(nOnset,5);
        event(:,1) = num2cell(onset);
        for iOnset = 1:nOnset
            thisOnset = onset(iOnset);
            mAll = find(midi(:,2)<=thisOnset & midi(:,3)>thisOnset);
            mNew = mAll(midi(mAll,2)==thisOnset);
            %pitchesAll = midi(mAll,1);
            pitchesNew = midi(mNew,1);
            %pitchesAllOctave = mod(pitchesAll,12);
            pitchesNewOctave = mod(pitchesNew,12);
            %event(iOnset,2:7) = {mAll,mNew,pitchesAll,pitchesNew,pitchesAllOctave,pitchesNewOctave};
            event(iOnset,2:5) = {mAll,mNew,pitchesNew,pitchesNewOctave};
        end
    end
    
    %event = cell2struct(event,{'onset','mAll','mNew','pitchesAll','pitchesNew','pitchesAllOctave','pitchesNewOctave'},2);
    %struct ����ͬʱ�Ӷ���ṹ�������ȡ��ĳ����Ա����������ʹ��ѭ�����
    %event = cell2table(event,'VariableNames',{'onset' 'mAll' 'mNew' 'pitchesAll' 'pitchesNew' 'pitchesAllOctave' 'pitchesNewOctave'});
    %table ȡ����һ��Ϊtable��cell�ͣ�������������
    save([destination,'\',midiName],'event');
end
end