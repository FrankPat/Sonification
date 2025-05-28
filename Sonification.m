function [ScaleIndices,NewScale] = Sonification(yData,StartingSeq,Key,SeqLength,FileName,flag)

% Function that transforms any dataseries (preferably a multiple of 8 or 16
% data points) into a musical sequence.
%
% INPUT
% yData       =  one-dimensional vector containing numeric (eral) data
% StartingSeq =  note in the chosen scale on which to start the sequence (1-7)
% Key         =  major key of the sequence (C, Db, D, Eb, ...)
% SeqLength   =  tonal span of the sequence (14 = 2 octaves)
% FileName    =  name of outputfile (without extension)
% flag        =  0: only abc output file is created
%                1: abc software and ps2pdf is executed to produce a pdf
%                file with sheet music
%
% OUTPUT
% Text file written with musical written in abc notation
% (https://abcnotation.com/). The file has the extension '.abc'
% If 'flag=1', the abc2ps programme will be executed and a pdf file created
% with the sheet music. This requires installation of the abc notation
% software as well as ghostscript and ps2pdf.
% Alternatively the .abc file can be transformed into sheet music using
% online abc tools (see https://abcnotation.com/ for more info).
%
%
%
% MIT License
%
% Copyright (c) 2025 Frank Pattyn
% 
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to
% the following conditions:
% 
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    Sequence=length(yData);
    Lines=Sequence/16;
    Scales={'C','Db','D','Eb','E','F','Gb','G','Ab','A','Bb','B'};
    ScaleStart=[1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7];
    for i=1:length(Scales)
        if cellfun(@strcmp,Key,Scales(i))
            ScaleChoice=i;
        end
    end

    ScaleFreq = [
        65.41, 73.42, 82.41, 87.31, 98.00, 110.00, 123.47, ...  % C2 to B2
        130.81, 146.83, 164.81, 174.61, 196.00, 220.00, 246.94, ...  % C3 to B3
        261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, ...  % C4 to B4
        523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77   % C5 to B5
        69.30, 77.78, 87.31, 92.50, 103.83, 116.54, 130.81, ...  % D?2 to C3
        138.59, 155.56, 174.61, 185.00, 207.65, 233.08, 261.63, ...  % D?3 to C4
        277.18, 311.13, 349.23, 369.99, 415.30, 466.16, 523.25, ...  % D?4 to C5
        554.37, 622.25, 698.46, 739.99, 830.61, 932.33, 1046.50   % D?5 to C6
        73.42, 82.41, 92.50, 98.00, 110.00, 123.47, 138.59, ...  % D2 to C#3
        146.83, 164.81, 185.00, 196.00, 220.00, 246.94, 277.18, ...  % D3 to C#4
        293.66, 329.63, 369.99, 392.00, 440.00, 493.88, 554.37, ...  % D4 to C#5
        587.33, 659.25, 739.99, 783.99, 880.00, 987.77, 1108.73   % D5 to C#6
        77.78, 87.31, 98.00, 103.83, 116.54, 130.81, 146.83, ...  % E?2 to D3
        155.56, 174.61, 196.00, 207.65, 233.08, 261.63, 293.66, ...  % E?3 to D4
        311.13, 349.23, 392.00, 415.30, 466.16, 523.25, 587.33, ...  % E?4 to D5
        622.25, 698.46, 783.99, 830.61, 932.33, 1046.50, 1174.66   % E?5 to D6
        82.41, 92.50, 103.83, 110.00, 123.47, 138.59, 155.56, ...  % E2 to D#3
        164.81, 185.00, 207.65, 220.00, 246.94, 277.18, 311.13, ...  % E3 to D#4
        329.63, 369.99, 415.30, 440.00, 493.88, 554.37, 622.25, ...  % E4 to D#5
        659.25, 739.99, 830.61, 880.00, 987.77, 1108.73, 1244.51   % E5 to D#6
        87.31, 98.00, 110.00, 116.54, 130.81, 146.83, 164.81, ...  % F2 to E3
        174.61, 196.00, 220.00, 233.08, 261.63, 293.66, 329.63, ...  % F3 to E4
        349.23, 392.00, 440.00, 466.16, 523.25, 587.33, 659.25, ...  % F4 to E5
        698.46, 783.99, 880.00, 932.33, 1046.50, 1174.66, 1318.51   % F5 to E6
        92.50, 103.83, 116.54, 130.81, 138.59, 155.56, 174.61, ...  % G?2 to F3
        185.00, 207.65, 233.08, 261.63, 277.18, 311.13, 349.23, ...  % G?3 to F4
        369.99, 415.30, 466.16, 554.37, 622.25, 698.46, 783.99, ...  % G?4 to F5
        830.61, 932.33, 1046.50, 1108.73, 1244.51, 1396.91, 1567.98   % G?5 to F6
        98.00, 110.00, 123.47, 130.81, 146.83, 164.81, 185.00, ...  % G2 to F#3
        196.00, 220.00, 246.94, 261.63, 293.66, 329.63, 369.99, ...  % G3 to F#4
        392.00, 440.00, 493.88, 523.25, 587.33, 659.25, 739.99, ...  % G4 to F#5
        783.99, 880.00, 987.77, 1046.50, 1174.66, 1318.51, 1479.98   % G5 to F#6
        103.83, 116.54, 130.81, 138.59, 155.56, 174.61, 196.00, ...  % A?2 to G3
        207.65, 233.08, 261.63, 277.18, 311.13, 349.23, 392.00, ...  % A?3 to G4
        415.30, 466.16, 523.25, 554.37, 622.25, 698.46, 783.99, ...  % A?4 to G5
        830.61, 932.33, 1046.50, 1108.73, 1244.51, 1396.91, 1567.98   % A?5 to G6
        110.00, 123.47, 138.59, 146.83, 164.81, 185.00, 207.65, ...  % A2 to G#3
        220.00, 246.94, 277.18, 293.66, 329.63, 369.99, 415.30, ...  % A3 to G#4
        440.00, 493.88, 554.37, 587.33, 659.25, 739.99, 830.61, ...  % A4 to G#5
        880.00, 987.77, 1108.73, 1174.66, 1318.51, 1479.98, 1661.22   % A5 to G#6
        116.54, 130.81, 146.83, 155.56, 174.61, 196.00, 220.00, ...  % B?2 to A3
        233.08, 261.63, 293.66, 311.13, 349.23, 392.00, 440.00, ...  % B?3 to A4
        466.16, 523.25, 587.33, 622.25, 698.46, 783.99, 880.00, ...  % B?4 to A5
        932.33, 1046.50, 1174.66, 1244.51, 1396.91, 1567.98, 1760.00   % B?5 to A6
        123.47, 138.59, 155.56, 164.81, 185.00, 207.65, 233.08, ...  % B2 to A#3
        246.94, 277.18, 311.13, 329.63, 369.99, 415.30, 466.16, ...  % B3 to A#4
        493.88, 554.37, 622.25, 659.25, 739.99, 830.61, 932.33, ...  % B4 to A#5
        987.77, 1108.73, 1244.51, 1318.51, 1479.98, 1661.22, 1864.66   % B5 to A#6
    ];

    strCell = {'C,', 'D,', 'E,', 'F,', 'G,', 'A,', 'B,', ...
        'C', 'D', 'E', 'F', 'G', 'A', 'B', ...
        'c', 'd', 'e', 'f', 'g', 'a', 'b', ...
        'c''', 'd''', 'e''', 'f''', 'g''', 'a''', 'b'''};
    strArray = string(strCell);

    if ScaleFreq(ScaleChoice,StartingSeq)<98
        StartingSeq=StartingSeq+7;
    end
    if ScaleFreq(ScaleChoice,StartingSeq)>98*2
        StartingSeq=StartingSeq-7;
    end
    x0=ScaleStart(ScaleChoice)+StartingSeq-1;
    x1=x0+SeqLength;
    NewScale=ScaleFreq(ScaleChoice,x0:x1);
    NewArray=strArray(x0:x1);

    yMin = min(yData);
    yMax = max(yData);
    ScaleIndices = round(1 + (yData - yMin) / (yMax - yMin) * ...
        (length(NewScale) - 1));

    command=[FileName, '.abc'];
    outfile=fopen(command,'w');
    fprintf(outfile,'X: 1\nT: Sonification\nM: 4/4\nL: 1/4\nK: %s\n', string(Key));
    cnt=0;
    for i=1:Lines
        for j=1:4
            for k=1:4
                cnt=cnt+1;
                fprintf(outfile,'%s',NewArray(ScaleIndices(cnt)));
            end
            fprintf(outfile,'|');
        end
        fprintf(outfile,'\n');
    end
    fclose(outfile);

    if flag==1
        command=['abcm2ps ', FileName];
        system(command);
        command=['ps2pdf Out.ps ', FileName, '.pdf'];
        system(command);
    end

end


