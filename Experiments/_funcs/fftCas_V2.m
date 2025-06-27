function [PSD,CAS,freqVec] = fftCas_V2(sig,N,Fs,SPs)

sig.tVec = sig.tVec(1:30000*SPs);
sig.e    = sig.e(1:30000*SPs);

idx_window = find(sig.tVec==sig.tVec(end),1)-N+1:find(sig.tVec==sig.tVec(end),1);
Nwindow = length(idx_window);

fftVal = fft(sig.e(idx_window));
fftVal = fftVal(1:Nwindow/2+1);
PSD = 2*abs(fftVal).^2/(Nwindow*Fs);
PSD = abs(PSD);

freqVec = 0:Fs/Nwindow:Fs/2;

CAS = sqrt(abs(cumsum(PSD)*(Fs/N)));

end
