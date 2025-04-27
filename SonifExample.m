function SonifExample

% Example that transforms the ENSO dataseries into a musical sequence,
% using the Sonification function
% F. Pattyn - ULB
% 2025

% Output written with abc notation: https://abc.rectanglered.com/

clear;
close all;

sequence=64; % Length of the sequence (16,32,64, ...)
startseq=2; % Note in scale on which to start the sequence (1-7)
key={'Bb'}; % 12 keys to chose from (no sharps, only flats)
span =14; % Tonal span of the sequence (14 = 2 octaves)

% In this example, the Key is B flat major (BbM7), resulting in B flat and
% E flat as key signatures. The key is similar to C minor 7 (Cm7), so if
% you want a minor key, you need to provide the key of the associated major
% scale with the same key signatures. The starting note is C, which is the
% second note in the sequence of Bb. The sequence spans 14 notes, whic is
% equivalent to two octaves, in this case from C3 to C5. The output is a
% file named ENSO.abc, which contains abc notation. Its content is the
% following:
%
% X: 1
% T: Sonification
% M: 4/4
% L: 1/4
% K: Bb
% bAdB|fbaB|eddf|fgBa|
% Gcdd|ABc'a|Faaa|eBDc|
% AccE|Bcee|Fcac|eFdA|
% BBac'|Cagg|cBBe|cfAc'|
%
% Using online tools it is possible to write this out as sheet music (pdf
% file), as well as audition. Many different free tools are available on 
% https://abc.rectanglered.com/


% Read data set where x and y values are in the first two columns
data=load('ENSOdata.txt');
% Interpolate the time sequence to the sepcified number of steps definied
% by sequence
time=linspace(data(1,1),data(end,1),sequence)';


var=interp1(data(:,1),data(:,2),time);
ScaleIndices = Sonification(var,startseq,key,span,'ENSO',0);

figure;
subplot(2,1,1)
plot(data(:,1),data(:,2),'-');
grid on;
subplot(2,1,2);
plot(ScaleIndices,'o-');
grid on;
    
end


