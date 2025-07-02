function [PSD,CAS,freqVec] = fftCas_V2(err,tvec,Nwindow,Fs,SPs)


fftVal = fft(err(end-Nwindow+1:end));
fftVal = fftVal(1:Nwindow/2+1);
PSD = 2*abs(fftVal).^2/(Nwindow*Fs);
PSD = abs(PSD);

freqVec = 0:Fs/Nwindow:Fs/2;

CAS = sqrt(abs(cumsum(PSD)*(Fs/Nwindow)));

end
