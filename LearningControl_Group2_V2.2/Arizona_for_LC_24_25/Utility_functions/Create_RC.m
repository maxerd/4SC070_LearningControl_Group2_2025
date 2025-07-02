% This script generates a time domain repetitive controller
save_switch = 1;

Ts = 1e-3;

cd ..\Models
load('Py_fit_new')
cd ..\Controllers
Cy = tf(load('yController.mat').Cy_DT);
cd ..

z = tf('z',Ts);

T = feedback(Py_DT*Cy,1);
Tfrd = feedback(Py_frd*Cy,1);

%Required outputs:
% - L_c: causal part of L. That is, L = z^{p_L}*L_c
% - p_L: number of preview samples of L
% - Q_c: causal part of Q. That is, Q = z^{p_Q}*Q_c
% - p_Q: number of preview samples of Q
% 3.2
[ai,bi,ci,di,phd] = zpetc(T.a,T.b,T.c,T.d,1);
Lc = minreal((ss(ai,bi,ci,di,Ts)));
L = (series(z^phd,(Lc)));


% figure(1);clf
% subplot(121)
% bode(inv(T),L); legend('inv(T)','L')
% subplot(122)
% bodemag(1-T*L);grid; hold on
% bodemag(1-Tfrd*L)
% ylim([-100 50]); title('Bode diagram 1-TL')


% Q-filter design

%c
fC = 100;       % desired cut-off frequency
fn = 1/(2*Ts);  % Nyquist frequency
M = 12;         % desired order of low-pass FIR filter

num = fir1(M,fC/fn);        % create low-pass FIR filter coefficients
Q = tf(num,1,Ts);           % create filter
Q = Q*Q';                   % use Q'*Q for zero phase shift
Q = Q/freqresp(Q,0)^2;      % scale DC gain (gain at omega=0) to 1

Qc = Q*tf(1,[1,zeros(1,M)],Ts); % Extract causal part
p_Q=M;                      % number of preview samples


% bodemag(Q*(1-Tfrd*L))

if save_switch == 1
    cd Controllers\
    save('RCcontroller','phd','Lc','p_Q','Qc');
    cd ..\Runfiles
end