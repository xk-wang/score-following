function result = computeAccuracyNoteLevel(midi,midiGt,onsetTolerance,ignoreOctaveErrorsFlag)
% computeAccuracyNoteLevel ����note-level onset only evaluation metrics
% ���ֵ��ο�ֵƥ��ʱ����һ��һ
%
% result = computeAccuracyNoteLevel(midi,midiGt,onsetTolerance,ignoreOctaveErrorsFlag)
%
% Inputs:
%  midi                     ת¼�������1��2�зֱ��ʾ��������� - onset(s)��
%  midiGt                   ground truth����1��2�зֱ��ʾ��������� - onset(s)��
%  onsetTolerance           ת¼�õ���������ο�����ƥ��ʱ��onset����ƫ�s��(<=)
%  ignoreOctaveErrorsFlag   �Ƿ���Ա�Ƶ����1�����ԡ�������������
%
% Outputs:
%  result   table�����ֶηֱ��ʾ��
%       ��1��nRef         �ο���������
%       ��2��nTot         ת¼�õ�����������
%       ��3��nCorr        ת¼��ȷ����������
%       ��4��nFalsePos    false positives��Ŀ
%       ��5��nFalseNeg    false negatives��Ŀ
%       ��6-9��recall��precision��F-Measure��accuracy
%
% �ο�https://gist.github.com/justinsalamon/a46923f9c6ab58237585
% �����Ա�Ƶ����ʱ����https://github.com/craffel/mir_eval/blob/master/mir_eval/transcription.py���һ��
%
% Nan Yang 2016-07-29 ������ֵ����������������Ϊtable�����ڵ���

nRref = size(midiGt,1);
nTot = size(midi,1);
nCorr = 0;
isMatched = zeros(nRref,1);  %����ָʾground truth�������Ƿ��Ѿ���ƥ��
if ignoreOctaveErrorsFlag==1 %���Ա�Ƶ����ʱ
    for iNoteTot = 1:nTot
        for iNoteRef = 1:nRref
            if abs(midi(iNoteTot,2)-midiGt(iNoteRef,2))<=onsetTolerance && mod(midi(iNoteTot,1)-midiGt(iNoteRef,1),12)==0 && isMatched(iNoteRef)==0
                nCorr = nCorr+1;
                isMatched(iNoteRef)=1;
                break;
            end
        end
    end
else    %�����Ա�Ƶ����ʱ
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