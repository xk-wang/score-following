function hFormatted = formatHRow(h,noteInTemplate)
% formatHRow 将pitch activition格式化为NPITCH行。有多套模板时，将对应于同一音符的pitch activation相加
% 要求：一套模板各列对应的音符序号为noteInTemplate；多套模板拼接，各套对应的音符相同；若有静音模板，置于末尾，静音模板数<一套模板数
%
% hFormatted = formatHRow(h,noteInTemplate)
%
% Inputs:
%  h                pitch activition
%  noteInTemplate   一套模板各列对应的音符序号，为空时默认为1:1:NPITCH

global NPITCH   %多音调检测音符个数
hFormatted = zeros(NPITCH,size(h,2));

if isempty(noteInTemplate)  %隔NPITCH行相加，最后不满NPITCH行的舍弃
    for k = 1:size(h,1)/NPITCH
        hFormatted = hFormatted+h((k-1)*NPITCH+1:k*NPITCH,:);
    end
else
    nNote = length(noteInTemplate);    %隔nNote行相加，最后不满nNote行的舍弃
    newH = zeros(nNote,size(h,2));
    for k = 1:size(h,1)/nNote
        newH = newH+h((k-1)*nNote+1:k*nNote,:);
    end
    
    hFormatted(noteInTemplate,:) = newH;
end
end