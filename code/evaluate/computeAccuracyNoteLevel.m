function result = computeAccuracyNoteLevel(midi,midiGt,onsetTolerance,ignoreOctaveErrorsFlag)
% computeAccuracyNoteLevel 计算note-level onset only evaluation metrics
% 检测值与参考值匹配时至多一对一
%
% result = computeAccuracyNoteLevel(midi,midiGt,onsetTolerance,ignoreOctaveErrorsFlag)
%
% Inputs:
%  midi                     转录结果（第1、2列分别表示：音符序号 - onset(s)）
%  midiGt                   ground truth（第1、2列分别表示：音符序号 - onset(s)）
%  onsetTolerance           转录得到的音符与参考音符匹配时，onset允许偏差（s）(<=)
%  ignoreOctaveErrorsFlag   是否忽略倍频错误。1：忽略、其它：不忽略
%
% Outputs:
%  result   table，各字段分别表示：
%       （1）nRef         参考音符总数
%       （2）nTot         转录得到的音符总数
%       （3）nCorr        转录正确的音符总数
%       （4）nFalsePos    false positives数目
%       （5）nFalseNeg    false negatives数目
%       （6-9）recall、precision、F-Measure、accuracy
%
% 参考https://gist.github.com/justinsalamon/a46923f9c6ab58237585
% 不忽略倍频错误时，与https://github.com/craffel/mir_eval/blob/master/mir_eval/transcription.py结果一致
%
% Nan Yang 2016-07-29 将返回值数据类型由向量改为table，便于调用

nRref = size(midiGt,1);
nTot = size(midi,1);
nCorr = 0;
isMatched = zeros(nRref,1);  %用于指示ground truth中音符是否已经被匹配
if ignoreOctaveErrorsFlag==1 %忽略倍频错误时
    for iNoteTot = 1:nTot
        for iNoteRef = 1:nRref
            if abs(midi(iNoteTot,2)-midiGt(iNoteRef,2))<=onsetTolerance && mod(midi(iNoteTot,1)-midiGt(iNoteRef,1),12)==0 && isMatched(iNoteRef)==0
                nCorr = nCorr+1;
                isMatched(iNoteRef)=1;
                break;
            end
        end
    end
else    %不忽略倍频错误时
    for iNoteTot = 1:nTot
        for iNoteRef = 1:nRref
            if abs(midi(iNoteTot,2)-midiGt(iNoteRef,2))<=onsetTolerance && midi(iNoteTot,1)==midiGt(iNoteRef,1) && isMatched(iNoteRef)==0
                nCorr = nCorr+1;
                isMatched(iNoteRef)=1;
                break;
            end
        end
    end
end

metrics = computeAccuracy(nRref,nTot,nCorr);
result = array2table([nRref,nTot,nCorr],'VariableNames',{'nRref' 'nTot' 'nCorr'});
result = [result,metrics];
end