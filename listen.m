% Creates a global audioplayer variable 'p' for the current ans
% at 44100 samples/second and plays it.

p = audioplayer(ans, 44100);
play(p);

% To stop playback, type
% stop(p);