% Creates a global audioplayer variable 'p' at 44100 samples/second 
% for the current answer 'ans' and plays it.

p = audioplayer(ans, 44100);
play(p);

% To stop playback, type
% stop(p);
% or
% stop