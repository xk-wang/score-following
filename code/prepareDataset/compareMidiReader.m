function diff = compareMidiReader(folder,thDiffBeat,thDiffSec)
% compareMidiReader ����folder�ļ����ڵ�MIDI�ļ����Աȿ�midi_lib��midi toolbox�Ľ������
%
% diff = compareMidiReader(folder,thDiffBeat,thDiffSec)
%
% Inputs:
%  folder       MIDI�ļ���·��
%  thDiffBeat   onset/duration (beat)�Ĳ������ֵ
%  thDiffSec    onset/offset (s)�Ĳ������ֵ
%  ��������ֵ�����ڷ���ֵdiff.diff����ʾ
%
% Outputs:
%  diff         �ṹ�壬��midi_lib��midi toolbox��������Ĳ���
%   ���ֶηֱ��ʾ��
%   fileName    MIDI�ļ����ļ���
%   diff        ��midi_lib��midi toolbox��������Ĳ���
%   diffTempos  tempo��time in beats at which the command was sent�Ĳ�������ֵ
%   diffBeat    onset/duration (beat)�Ĳ�������ֵ
%   diffSec     onset/offset (s)�Ĳ�������ֵ
%   missNoteToolbox ��midi toolbox warning: found multiple note-on matches for note-off, taking first,
%                   �ɴ�midi_lib��midi toolbox�������������
%
% �޸���midi toolbox�еĺ���readmidi��mdlMStrToNMat���������������tempos��tempos_time
% ƥ������������onset - duration - pitch��������������������ͬ������Ϊһһ��Ӧ��
%   ����ͬ������Ϊֻ����midi_lib��midi toolbox�������������
% ��diff.diff��ʾ��midi pitch��velocity��һ�¡���midi toolbox��midi_lib���������������������ƥ�䷽�����걸

rmpath(genpath('..\Libraries\maml_v0.1.3'));    %��maml_v0.1.3��midi toolbox��ͬ������readmidi

if exist(folder,'dir')==0
    error('������ļ���·��������');
end

midis = dir([folder,'/*.mid']);
nMidi = length(midis);
diff = struct('fileName',{[]},'diff',{[]},'diffTempos',{NaN(1,2)},'diffBeat',{NaN},'diffSec',{NaN},'missNoteToolbox',{[]});
for iMidi = 1:nMidi
    diff(iMidi).fileName = midis(iMidi).name;
    midiPath = [folder,'\',midis(iMidi).name];
    midiJava = readmidi_java(midiPath);
    midiJava = sortrows(midiJava,[1,2,4]);      %��onset - duration - pitch����
    midiJava(:,7) = midiJava(:,6)+midiJava(:,7);%offset
    temposJava = get_tempos(midiPath);
    
    [midiToolbox,~,temposToolbox,tempos_time] = readmidi(midiPath);
    midiToolbox = sortrows(midiToolbox,[1,2,4]);
    midiToolbox(:,7) = midiToolbox(:,6)+midiToolbox(:,7);
    
    if size(temposJava,1) ~= length(temposToolbox)
        diff(iMidi).diff = 'tempo������һ�£�';
    else
        diff(iMidi).diffTempos(1,[1,2]) = max(abs(temposJava(:,[1,2])-[temposToolbox',tempos_time']));
    end
    
    if size(midiJava,1)==size(midiToolbox,1)
        thisDiff = abs(midiJava-midiToolbox);
        if any(thisDiff(:,[4,5]))
            diff(iMidi).diff = [diff(iMidi).diff,'midi pitch��velocity��һ�£�'];
        else
            diff(iMidi).diffBeat = max(max(thisDiff(:,[1,2])));
            diff(iMidi).diffSec = max(max(thisDiff(:,[6,7])));
        end
    else
        diff(iMidi).diff = [diff(iMidi).diff,'����������һ�£�'];
        [iNoteJava,iNoteToolbox,diffBeat,diffSec] = deal(1,1,NaN,NaN);
        nNoteJava  = length(midiJava);
        while(iNoteJava<=nNoteJava && iNoteToolbox<=length(midiToolbox))
            if midiJava(iNoteJava,4)==midiToolbox(iNoteToolbox,4) && midiJava(iNoteJava,5)==midiToolbox(iNoteToolbox,5)
                diffBeat = max([diffBeat,abs(midiJava(iNoteJava,[1,2])-midiToolbox(iNoteToolbox,[1,2]))]);
                diffSec = max([diffSec,abs(midiJava(iNoteJava,[6,7])-midiToolbox(iNoteToolbox,[6,7]))]);
                iNoteJava = iNoteJava+1;
                iNoteToolbox = iNoteToolbox+1;
            else
                diff(iMidi).missNoteToolbox(end+1,:) = midiJava(iNoteJava,:);
                iNoteJava = iNoteJava+1;
            end
        end
        if iNoteJava<=nNoteJava
            diff(iMidi).missNoteToolbox(end+1:end+1+nNoteJava-iNoteJava,:) = midiJava(iNoteJava:nNoteJava,:);
        end
        if iNoteToolbox~=length(midiToolbox)+1
            diff(iMidi).missNoteToolbox = NaN;
            diff(iMidi).diff = [diff(iMidi).diff,'midi toolbox��midi_lib�������������'];
        end
        diff(iMidi).diffBeat = diffBeat;
        diff(iMidi).diffSec = diffSec;
    end
    if diff(iMidi).diffBeat>thDiffBeat
        diff(iMidi).diff = [diff(iMidi).diff,'onset��duration�Ĳ��쳬��',num2str(thDiffBeat),'beat��'];
    end
    if diff(iMidi).diffSec>thDiffSec
        diff(iMidi).diff = [diff(iMidi).diff,'onset��offset�Ĳ��쳬��',num2str(thDiffSec),'s��'];
    end
end

addpath(genpath('..\Libraries\maml_v0.1.3'));
end