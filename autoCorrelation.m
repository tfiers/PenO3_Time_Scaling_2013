function pitch = autoCorrelation( frame, sampleRate )
%AutoCorrelation
%   Determins the average pitch of the provided frame based on the
%   correlation of the signal with its self, shifted to different
%   positions.
%   Input:-frame: A short frame of sound for pitch detection.
%         -sampleRate: The sample rate at which the sound was recorded.
%   Output:-pitch: The average pitch of the providid frame of sound.

MIN_THRESHOLD = 0.10;%How much smaller than the maximum correlation value a point has to be before we assume a peak has been passed.
MAX_THRESHOLD = 0.90;%How much larger that the previous maximum correlation value a point has to be before we assume that the correlation signas is rising again.
minReached = 0;%Boolean to determin whether this is the first minimum reached
minPassed = 0;%Boolean to determin whether the second peak has been passed

maxCorrelation = 0;
maxCorrelationIndex = 0;
prevMaxCorrelation = 0;

for i = 2:size(frame, 2)%Same position guarentees a match so we start at 2.
    lengthOverlap = size(frame, 2) - i + 1;
    correlation = sum(frame(1:lengthOverlap) .* frame(i:size(frame, 2)))./lengthOverlap;
    if correlation > maxCorrelation
        maxCorrelation = correlation;
        maxCorrelationIndex = i;
    elseif correlation < maxCorrelation.*MIN_THRESHOLD%A maximum has definately been passed.
        %The following if statement makes sure that the first following
        %maximum is selected.
        if minPassed == 1%This is the second time that a maximum has been passed.
            break
        else%This is the first time a maximum has been passed.
            minReached = 1;
            %Set maxCorrelation and its index to a lower value incase the
            %correlation at the next peak is less than a correlation value
            %for a point close to the first peak.
            prevMaxCorrelation = maxCorrelation;
            maxCorrelation = correlation;
            maxCorrelationIndex = i;
        end
    elseif prevMaxCorrelation ~=0%Sets the flag for passing the first minimum to true.
        if correlation > prevMaxCorrelation.*MAX_THRESHOLD
            minPassed = 1;
        
        end%if
    end%if
end%for

pitch = sampleRate./maxCorrelationIndex;%Freqency is the number of samples per second devided by the number of samples between peaks.

end

