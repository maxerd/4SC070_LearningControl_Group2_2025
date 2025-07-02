%% Simulation
% clear variables;
clc
set(0,'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
rng(1);                     % To generate same randomness
addpath(genpath("ProjectFiles\"))
refOn = 1;
initQ = false;
%% Settings for simulations
Ts = 0.001;                                                                 % Sampling time
Fs = 1/Ts;
load("ProjectFiles\Arizona_for_LC_24_25\Runfiles\Disturbance_LC24_25.mat")
load("ProjectFiles\Arizona_for_LC_24_25\References\Reference_LC24_25.mat")
Ndist = length(dist);
Repeats = 5;
Tend = Repeats*Ndist/Fs;                                                         % Simulation time (multiple of LCM of disturbances d1 and d2)
t = 0:Ts:Tend-Ts;
N = length(t);                                                              % Length of experiment
z = tf('z',Ts);

d = repmat(dist,Repeats,1);                                                                 % Disturbance applied to the system
yr = repmat(yref,Repeats,1);                                                                 % Disturbance applied to the system
noiseSTD = 0*1e-6;                                                          % STD of measurement noise


ref  = timetable(seconds(t)',yr);
dis  = timetable(seconds(t)',d);

%% Disturbance freq check
idx_window = 1:30000;
Nwindow = length(idx_window);
freq = Fs/Nwindow*(0:Nwindow-1);
D = fft(dist(idx_window'))/Nwindow;
peaks = 0;
freqs = [];
for i = 2:4800
    if abs(D(i)) > 1e-7
        peaks = peaks+1;
        freqs(peaks) = freq(i);
    end
end

Td1 = 1/freqs(1);
Td2 = 1/freqs(2);

Ne1 = Td1/Ts;
Ne2 = Td2/Ts;
%% Load the Arizona models

Cy = ss(load("ProjectFiles\Arizona_models_new\yController_new.mat").Cy_DT);                                     % Load the controller for the carriage

Py = load('ProjectFiles\Arizona_models_new\Py_fit_new.mat').Py_DT;                                              % Load the plant model of the carriage


% Load the plant and controller to the right variables
Pz = Py;
Cz = Cy;


%% Closed loops
loop = loopsens(Pz,Cz);
PS  = (loop.PSi);                % Process sensitivity
S   = (loop.So);                 % sensitivity
T   = (loop.To);                  % Complementary sensitivity




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Learning filter L and design robustness filter Q, such that Q(1-TL) < 1 forall w
% - Lc: causal part of L. That is, L = z^{p_L}*L_c
% - phd: number of preview samples of L
% - Qc: causal part of Q. That is, Q = z^{p_Q}*Q_c
% - pQ: number of preview samples of Q
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ai,bi,ci,di,phd] = zpetc(T.a,T.b,T.c,T.d,1);                                     % rho = 1 (Typically)
Lc = ss(ai,bi,ci,di,Ts);                                                          % Causal part   
L = z^phd*Lc;                                                               % non-causal L-filter used for stability checks

fC = 0.1;                                                                    % desired cut-off frequency
nQ = 12;                                                                    % desired order of low-pass FIR filter

fn = 1/2*Fs;                                                                % Nyquist frequency
num = fir1(nQ,fC);                                                       % create low-pass FIR filter coefficients
Q = tf(num,1,Ts);                                                         % create filter
Q = Q*Q';                                                                   % use Q'*Q for zero phase shift
Q = Q/freqresp(Q,0)^2;                                                      % scale DC gain (gain at omega=0) to 1

Qc = Q*tf(1,[1,zeros(1,nQ)],Ts);                                            % Extract causal part
pQ=nQ;                                                                      % number of preview samples
% figure(1314);bode(Q*(1-feedback(series(Py_frd,Cy_DT),1)*L))
%% Simulate the mbfrc system using simulink
clear out
warning('off')
f1 = [1/6 1/2 5/6];
f2 = [6.5 6.8 5.8];
f3 = [157.2 153.6667 153.16667];
% f3 = [44.5 45.833333 49];
phis = 0.002*ones(1,3);
err_RC1 = zeros(100,150000);
err_RC2 = zeros(100,150000);
err_RC3 = zeros(100,150000);
f = f1;
a = 0.0001;
for j = 1:100
    start = tic;
    a = 0.0001+(j-1)*0.0001;
    phi_mat = zeros(2*length(f));
    for i=1:length(f)
        if f(i) ~= 0
            [r_scale(i),tau(i)] = bode(T,f(i)*2*pi);
            phi_mat(2*(i-1)+1,2*(i-1)+1) = phis(i);
            phi_mat(2*(i-1)+2,2*(i-1)+2) = phis(i);
        else
            [r_scale(i),tau(i)] = bode(T,0.000001);
            phi_mat(2*(i-1)+1,2*(i-1)+1) = phis(i);
            phi_mat(2*(i-1)+2,2*(i-1)+2) = phis(i);
        end
    end
    out = sim('tes1.slx');
    endtime = toc(start);
    disp(['Frequency below bandwidth sample: ' num2str(j)])
    
    err_RC1(j,:) = squeeze(out.errorSig.Data)';
    disp(['time it took:' num2str(endtime)])
    if max(abs(err_RC1(j,:)) > 10000)
        disp('big value detected')
        break
    end
end
f = f2;
for j = 1:100
    start = tic;
    a = 0.0001+(j-1)*0.0001;
    phi_mat = zeros(2*length(f));
    for i=1:length(f)
        if f(i) ~= 0
            [r_scale(i),tau(i)] = bode(T,f(i)*2*pi);
            phi_mat(2*(i-1)+1,2*(i-1)+1) = phis(i);
            phi_mat(2*(i-1)+2,2*(i-1)+2) = phis(i);
        else
            [r_scale(i),tau(i)] = bode(T,0.000001);
            phi_mat(2*(i-1)+1,2*(i-1)+1) = phis(i);
            phi_mat(2*(i-1)+2,2*(i-1)+2) = phis(i);
        end
    end
    out = sim('tes1.slx');
    endtime = toc(start);
    disp(['Frequency at bandwidth sample: ' num2str(j)])
    err_RC2(j,:) = squeeze(out.errorSig.Data)';
    disp(['time it took:' num2str(endtime)])
    if max(abs(err_RC2(j,:)) > 10000)
        disp('big value detected')
        break
    end
end
f = f3;
for j = 1:100
    start = tic;
    a = 0.02+(j-1)*0.02;
    phi_mat = zeros(2*length(f));
    for i=1:length(f)
        if f(i) ~= 0
            [r_scale(i),tau(i)] = bode(T,f(i)*2*pi);
            phi_mat(2*(i-1)+1,2*(i-1)+1) = phis(i);
            phi_mat(2*(i-1)+2,2*(i-1)+2) = phis(i);
        else
            [r_scale(i),tau(i)] = bode(T,0.000001);
            phi_mat(2*(i-1)+1,2*(i-1)+1) = phis(i);
            phi_mat(2*(i-1)+2,2*(i-1)+2) = phis(i);
        end
    end
    out = sim('tes1.slx');
    endtime = toc(start);
    disp(['Frequency above bandwidth sample: ' num2str(j)])
    err_RC3(j,:) = squeeze(out.errorSig.Data)';
    disp(['time it took:' num2str(endtime)])
    if max(abs(err_RC3(j,:)) > 10000)
        disp('big value detected')
        break
    end
end

function cumsum = cas(fftDat)
cumsum(1:2) = fftDat(1:2);
    for i = 3:length(fftDat)
        cumsum(i) = cumsum(i-1)+fftDat(i);
    end
end



