function signal=Data2Music(data,startx,endx,sequence,lowest, ...
    key,span,fs,duration,outfile,IPmethod,abc)

% Function that reads a two column data vector with x and y values, where x
% is commonly taken as time in a time series, and interpolates a sequence
% of 'sequence' number of notes between 'startx' and 'endx'. The
% function calls first the Sonification function that outputs
% 'ScaleIndices', i.e., the number of the notes within the chosen scale, as
% well as 'NewScale', which are the frequencies that correspond to each of
% the chosen major scale. In a next step a sound signal is produced, using
% the function MakeSoundScale. Finally the original data and the
% interpolated scale based on the data are plotted in one figure.
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
%

    % Interpolate the time sequence to the sepcified number of steps definied
    % by sequence
    time=linspace(startx,endx,sequence)';
    var=interp1(data(:,1),data(:,2),time);
    [ScaleIndices,NewFreq] = Sonification(var,lowest,key,span, ...
        outfile,IPmethod,abc);

    signal=MakeSoundScale(NewFreq,ScaleIndices,fs,duration);
    signal=signal/max(abs(signal));
    
    figure;
    subplot(2,1,1)
    plot(data(:,1),data(:,2),'-');
    hold on;
    plot(time,var,'or');
    grid on;
    subplot(2,1,2);
    plot(ScaleIndices,'o-');
    grid on;

end
