function hFormatted = formatHRow(h,noteInTemplate)
% formatHRow ��pitch activition��ʽ��ΪNPITCH�С��ж���ģ��ʱ������Ӧ��ͬһ������pitch activation���
% Ҫ��һ��ģ����ж�Ӧ���������ΪnoteInTemplate������ģ��ƴ�ӣ����׶�Ӧ��������ͬ�����о���ģ�壬����ĩβ������ģ����<һ��ģ����
%
% hFormatted = formatHRow(h,noteInTemplate)
%
% Inputs:
%  h                pitch activition
%  noteInTemplate   һ��ģ����ж�Ӧ��������ţ�Ϊ��ʱĬ��Ϊ1:1:NPITCH

global NPITCH   %�����������������
hFormatted = zeros(NPITCH,size(h,2));

if isempty(noteInTemplate)  %��NPITCH����ӣ������NPITCH�е�����
    for k = 1:size(h,1)/NPITCH
        hFormatted = hFormatted+h((k-1)*NPITCH+1:k*NPITCH,:);
    end
else
    nNote = length(noteInTemplate);    %��nNote����ӣ������nNote�е�����
    newH = zeros(nNote,size(h,2));
    for k = 1:size(h,1)/nNote
        newH = newH+h((k-1)*nNote+1:k*nNote,:);
    end
    
    hFormatted(noteInTemplate,:) = newH;
end
end