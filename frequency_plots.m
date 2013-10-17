function [ output_args ] = frequency_plots( filename1,filename2, name1_legend, name2_legend)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Fs = 44100;                   % Sampling frequency
T = 1/Fs;                     % Sample time
L = 1000;                     % Length of signal
t = (0:L-1)*T;                % Time vector
x = audioread(filename1);
y = audioread(filename2);


NFFT = 2^nextpow2(L); % Next power of 2 from length of y
X = fft(x,NFFT)/L;
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.

figure
plot(f,2*abs(X(1:NFFT/2+1)),'c','LineWidth',3)
title('Frequency spectrum')
xlabel('Frequency (Hz)')
ylabel('Power')
hold on
plot(f,2*abs(Y(1:NFFT/2+1)),'b')
legend(name1_legend,name2_legend)
hold off


figure
plot(x,'c','LineWidth',2)
title('Frequency spectrum')
xlabel('Frequency (Hz)')
ylabel('Power')
hold on
plot(y,'b')
legend(name1_legend,name2_legend)
hold off


end