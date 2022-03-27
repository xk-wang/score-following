function diff = compareMidiReader(folder,thDiffBeat,thDiffSec)
% compareMidiReader 对于folder文件夹内的MIDI文件，对比库midi_lib、midi toolbox的解析结果
%
% diff = compareMidiReader(folder,thDiffBeat,thDiffSec)
%
% Inputs:
%  folder       MIDI文件夹路径
%  thDiffBeat   onset/duration (beat)的差异的阈值
%  thDiffSec    onset/offset (s)的差异的阈值
%  若超过阈值，则在返回值diff.diff中提示
%
% Outputs:
%  diff         结构体，库midi_lib、midi toolbox解析结果的差异
%   各字段分别表示：
%   fileName    MIDI文件的文件名
%   diff        库midi_lib、midi toolbox解析结果的差异
%   diffTempos  tempo、time in beats at which the command was sent的差异的最大值
%   diffBeat    onset/duration (beat)的差异的最大值
%   diffSec     onset/offset (s)的差异的最大值
%   missNoteToolbox 库midi toolbox warning: found multiple note-on matches for note-off, taking first,
%                   由此midi_lib比midi toolbox多解析出的音符
%
% 修改了midi toolbox中的函数readmidi、mdlMStrToNMat，增加了输出参数tempos、tempos_time
% 匹配解析结果：按onset - duration - pitch多条件排序。若音符数相同，则认为一一对应；
%   若不同，则认为只存在midi_lib比midi toolbox多解析出音符。
% 若diff.diff提示“midi pitch、velocity不一致”或“midi toolbox比midi_lib多解析出音符”，则上述匹配方法不完备

rmpath(genpath('..\Libraries\maml_v0.1.3'));    %库maml_v0.1.3和midi toolbox有同名函数readmidi

if exist(folder,'dir')==0
    error('输入的文件夹路径不存在');
end

midis = dir([folder,'/*.mid']);
nMidi = length(midis);
diff = struct('fileName',{[]},'diff',{[]},'diffTempos',{NaN(1,2)},'diffBeat',{NaN},'diffSec',{NaN},'missNoteToolbox',{[]});
for iMidi = 1:nMidi
    diff(iMidi).fileName = midis(iMidi).name;
    midiPath = [folder,'\',midis(iMidi).name];
    midiJava = readmidi_java(midiPath);
    midiJava = sortrows(midiJava,[1,2,4]);      %按onset - duration - pitch排序
    midiJava(:,7) = midiJava(:,6)+midiJava(:,7);%offset
    temposJava = get_tempos(midiPath);
    
    [midiToolbox,~,temposToolbox,tempos_time] = readmidi(midiPath);
    midiToolbox = sortrows(midiToolbox,[1,2,4]);
    midiToolbox(:,7) = midiToolbox(:,6)+midiToolbox(:,7);
    
    if size(temposJava,1) ~= length(temposToolbox)
        diff(iMidi).diff = 'tempo个数不一致；';
    else
        diff(iMidi).diffTempos(1,[1,2]) = max(abs(temposJava(:,[1,2])-[temposToolbox',tempos_time']));
    end
    
    if size(midiJava,1)==size(midiToolbox,1)
        thisDiff = abs(midiJava-midiToolbox);
        if any(thisDiff(:,[4,5]))
            diff(iMidi).diff = [diff(iMidi).diff,'midi pitch、velocity不一致；'];
        else
            diff(iMidi).diffBeat = max(max(thisDiff(:,[1,2])));
            diff(iMidi).diffSec = max(max(thisDiff(:,[6,7])));
        end
    else
        diff(iMidi).diff = [diff(iMidi).diff,'音符个数不一致；'];
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
            diff(iMidi).diff = [diff(iMidi).diff,'midi toolbox比midi_lib多解析出音符；'];
        end
        diff(iMidi).diffBeat = diffBeat;
        diff(iMidi).diffSec = diffSec;
    end
    if diff(iMidi).diffBeat>thDiffBeat
        diff(iMidi).diff = [diff(iMidi).diff,'onset或duration的差异超过',num2str(thDiffBeat),'beat；'];
    end
    if diff(iMidi).diffSec>thDiffSec
        diff(iMidi).diff = [diff(iMidi).diff,'onset或offset的差异超过',num2str(thDiffSec),'s；'];
    end
end

addpath(genpath('..\Libraries\maml_v0.1.3'));
end