function pitch = zeroCrossing( frame, sampleRate )
%zeroCrossing pitch detection
%   Determines the main pitch of the provided frame.
%Input:-frame: A small fragment of mono audiosignal
%      -sampleRate: The sample rate of the audio signal
%Output:-pitch: The main pitch of the provided frame

signalLength = size(frame, 2)./sampleRate;%Length of frame in seconds

sign = zeros(1,size(frame, 2));%1 for a positive value, 0 for a negative value

for i = 1:size(frame, 2)%Find positive and negative values
    if frame(1,i)>=0
        sign(1,i) = 1;
    end
end
   
signShift = [0, sign];%sign shifted 1 place to the right
sign = [sign, 0];%sign extended

isDiff = abs(signShift - sign);%Looks for sign changes
riseVSfall = signShift - sign;%Checks if there are more positive to negative changes than vice versa or the opposite.    

%Number of sign changes with correction for discrepencies between the number of positive to negative and negative to positive changes.
zeroCross = sum(isDiff)-abs(sum(riseVSfall))./2;

pitch = zeroCross./2./signalLength;%Average pitch of the provided frame

end

