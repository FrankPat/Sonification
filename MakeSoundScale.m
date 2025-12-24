function MakeSoundScale(NewFreq,ScaleIndices)

% Function that translates the sequence in a sound signal that can be
% played with the 'sound' function in MatLab.
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

    fs = 44100;
    duration=1/4; % 1/4 notes @ 90 bpm = 1/6
    
    % Define sampling rate and tone duration
    t = 0:1/fs:duration - 1/fs; % Time vector for one tone
    
    % Define fade duration (e.g., 10 ms)
    fadeDuration = 0.01; % 10 milliseconds
    fadeSamples = round(fadeDuration * fs);
    fadeIn = linspace(0, 1, fadeSamples); % Linear fade-in
    fadeOut = linspace(1, 0, fadeSamples); % Linear fade-out

    signal = [];
    for i = 1:length(ScaleIndices)
        freq = NewFreq(ScaleIndices(i)); % Map to frequency
        tone = sin(2 * pi * freq * t); % Generate sine wave
        % Apply fade-in and fade-out
        tone(1:fadeSamples) = tone(1:fadeSamples) .* fadeIn;
        tone(end-fadeSamples+1:end) = tone(end-fadeSamples+1:end) .* fadeOut;
        signal = [signal, tone]; % Concatenate tones
    end

    % Ensure both signals are the same length by padding with zeros
    signal = padSignal(signal, length(signal));
    signal=signal/max(abs(signal));
    sound(signal,fs);
end


function paddedSignal = padSignal(signal, maxLength)
    % Pad the signal with zeros to match maxLength
    paddedSignal = [signal, zeros(1, maxLength - length(signal))];
end
