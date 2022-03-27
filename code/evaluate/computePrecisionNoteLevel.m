function [result,sfResult] = computePrecisionNoteLevel(sfResult,sfResultGt,varargin)
% computePrecisionNoteLevel �������׸���note level precision
%
% Inputs:
%  sfResult     ����3�У�onset - ���� - ��Ӧ�������е�λ��
%  sfResultGt   cell��2�У�onset - ��Ӧ�������е�λ�ã����ܶ������ȷ��ʱΪ[]��
%
% Outputs:
%  result   table�����ֶηֱ��ʾ��
%       ��1��nRef     MIDI�ļ����������ܸ���
%       ��2��nCorr    ��λ��ȷ����������
%       ��3��precision
%  sfResult �����˵�4�У���־��λ�Ƿ���ȷ��NaN��ʾ��ȷ����ȷ��λ

sfResult(:,4) = 0;
result = table;
result.nRef = size(sfResult,1);
result.nCorr = 0;
for iNote = 1:result.nRef
    iEvent = find(cell2mat(sfResultGt(:,1))<=sfResult(iNote,1)+1e-3,1,'last');  %�򸡵�������Ӱ��
    if isempty(sfResultGt{iEvent,2})
        result.nRef = result.nRef-1;
        sfResult(iNote,4) = NaN;
    elseif ismember(sfResult(iNote,3),sfResultGt{iEvent,2})
        result.nCorr = result.nCorr+1;
        sfResult(iNote,4) = 1;
    end
end
result.precision = result.nCorr/result.nRef;
end