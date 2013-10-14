function pitch = autoCorrelation( frame, sampleRate )
%AutoCorrelation
%   Determins the average pitch of the provided frame based on the
%   correlation of the signal with its self, shifted to different
%   positions.
%   Input:-frame: A short frame of sound for pitch detection.
%         -sampleRate: The sample rate at which the sound was recorded.
%   Output:-pitch: The average pitch of the providid frame of sound.

THRESHOLD = 0.5;%How much smaller than the maximum correlation value a point has to be before we assume a peak has been passed.
minReached = 0;%Boolean to determin whether this is the first minimum reached

maxCorrelation = 0;
maxCorrelationIndex = 0;

for i = 2:size(frame, 2)%Same position guarentees a match
    
    lengthOverlap = size(frame, 2) - i+1;
    correlation = sum(frame(1:lengthOverlap) .* frame(i:size(frame, 2)))./lengthOverlap;
    if correlation > maxCorrelation
        maxCorrelation = correlation;
        maxCorrelationIndex = i;
    elseif correlation < maxCorrelation.*THRESHOLD%A maximum has definately been passed.
        %The following if statement makes sure that the first following
        %maximum is selected.
        if minReached == 1%This is the second time that a maximum has been passed.
            break
        else%This is the first time a maximum has been passed.
            minReached = 1;
            %Set maxCorrelation and its index to a lower value incase the
            %correlation at the next peak is less than a correlation value
            %for a point close to the first peak.
            maxCorrelation = correlation;
            maxCorrelationIndex = i;
        end
    end
end%for

pitch = sampleRate./maxCorrelationIndex;%Freqency is the number of samples per second devided by the number of samples between peaks.

end

