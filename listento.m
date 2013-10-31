% Creates a global audioplayer variable 'p' at 44100 samples/second 
% for the given 'signal', or the current answer 'ans' if no argument is
% given, and plays it.

function listento(signal)
    global p;
    p = audioplayer(signal, 44100);
    play(p);
end

% To stop playback, type
% stop(p);
% or
% stop