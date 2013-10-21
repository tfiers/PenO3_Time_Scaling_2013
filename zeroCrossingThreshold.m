function pitch = zeroCrossing( frame, sampleRate )
%zeroCrossing pitch detection
%   Determines the main pitch of the provided frame using a zero crossing algorithm expanded with a threshold band around zero.
%Input:-frame: A small fragment of mono audiosignal
%      -sampleRate: The sample rate of the audio signal
%Output:-pitch: The main pitch of the provided frame

signalLength = size(frame, 2)./sampleRate;%Length of frame in seconds

sign = zeros(1,size(frame, 2));%1 for a positive value, -1 for a negative value and 0 for a value close to 0.

BANDWIDTH = 0.9;%Portion of the largest amplitude below which a value is assumed to be zero

frameMax = max(frame(1,:));%The largest amplitude in the frame

average = mean(frame(1,:),2);%The average value of the frame

for i = 1:size(frame, 2)%Find peaks and dips
    if frame(1,i) >= (frameMax-average).*BANDWIDTH + average
        sign(1,i) = 1;
    elseif frame(1,i) <= -(frameMax-average).*BANDWIDTH + average
        sign(1,i) = -1;
    end
end

i = 1;%Loop counter
periods = 0;%Number of positive-negative-positive sign changes.

while i < size(frame, 2)%Look for sign changes
    
    while(sign(1,i) == 1)
        if i < size(frame, 2)
            i = i + 1;
        else
            break
        end
    end
    while(sign(1,i) == 0)
        if i < size(frame, 2)
            i = i + 1;
        else
            break
        end
    end
    while(sign(1,i) == -1)
        if i < size(frame, 2)
            i = i + 1;
        else
            break
        end
    end
    while(sign(1,i) == 0)
        if i < size(frame, 2)
            i = i + 1;
        else
            break
        end
    end
    periods = periods + 1;
end

if sign(1,size(sign, 2)) ~= 1%Subtract half a period if the end of the signal starts half way through a cycle
    periods = periods - 0.5;
end

if sign(1,size(sign, 2)) ~= 1%Subtract half a period if the end of the signal ends half way through a cycle
    periods = periods - 0.5;
end

pitch = periods/signalLength;%Average pitch of the provided frame

end

