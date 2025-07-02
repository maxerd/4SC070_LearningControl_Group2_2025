%% Simulation
% clear variables;
clc
set(0,'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
rng(1);                     % To generate same randomness
addpath(genpath("../LearningControl_Group2_V2.2\")) % add base folder to path so everything gets loaded


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulation settings
refOn = 1;              % Set to 1 to turn on reference and to 0 to turn off reference
tradRC_on = 1;          % set to 1 to turn on traditional RC controller and 0 to turn it off
simpleMBFRC = true;     % set to true to use simplified MBFRC and false for non-simplified MBFRC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Settings for simulations
Ts = 0.001;                                                                 % Sampling time
Fs = 1/Ts;
load("Arizona_for_LC_24_25\Runfiles\Disturbance_LC24_25.mat")  % Load the disturbance and reference signals
load("Arizona_for_LC_24_25\References\Reference_LC24_25.mat")
Ndist = length(dist);                                                       % Define the number of samples in the disturbance signal
Repeats = 4;                                                                %Amount of times the disturbance and/or reference of 30 seconds is repeated
Tend = Repeats*Ndist/Fs;                                                         % Simulation time (multiple of LCM of disturbances d1 and d2)
t = 0:Ts:Tend-Ts;
N = length(t);                                                              % Length of experiment
z = tf('z',Ts);

d = repmat(dist,Repeats,1);                                                                 % Disturbance applied to the system
yr = repmat(yref,Repeats,1);                                                                 % Reference applied to the system
noiseSTD = 0*1e-6;                                                          % STD of measurement noise


ref  = timetable(seconds(t)',yr);	                                       %t Timetables for the reference and disturbance signals                                                              
dis  = timetable(seconds(t)',d);

ffy = 0*(vel*0.95+acc*0.81);                                               % Attempt at applying the feedforward signal in simulation (did not work so remove 0* to try to apply this)
ffy = repmat(ffy,Repeats,1);
ffy = timetable(seconds(t)',ffy);
%% Disturbance plot
% analsysis of the disturbance signal by plotting the disturbance signal
% itself and an fft of the signal. The reference is also plotted, this plot
% was used in the paper
D = fft(d)/N;

figure(1);clf                                                           
    subplot(211)
        plot(t,d);grid on;hold on
            xlabel('Time [s]'); ylabel('Disturbances')
            title('Disturbances applied to the Arizona Carriage')
    subplot(212)
        semilogx(Fs/N*(0:N-1),(abs(D)));grid;hold on
            xlim([1e-1 Fs/2])
            xlabel('Frequency [Hz]')
            ylabel('fft(d)')
            title('fft/N of disturbance signal')

figure(124);clf;grid on;hold on
    plot(t(1:30000),yr(1:30000))
        xlabel('Time [s]')
        ylabel('y reference [m]')
        title('Reference for the y axis of the Arizona printer')
%% Disturbance freq check
% Checks at which frequencies the peaks in the disturbance occurs and saves
% this so this can be used later on for MBFRC
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

disp(['Number of peaks found in disturbance signal PSD: ',num2str(peaks)])
Td1 = 1/freqs(1);
Td2 = 1/freqs(2);

Ne1 = Td1/Ts;
Ne2 = Td2/Ts;

%% Load the Arizona models

Cy = ss(load("Arizona_models_new\yController_new.mat").Cy_DT);                                     % Load the controller for the carriage

Py = load('Arizona_models_new\Py_fit_new.mat').Py_DT;                                              % Load the plant model of the carriage


% Load the plant and controller to the right variables
Pz = Py;
Cz = Cy;


%% Closed loops
loop = loopsens(Pz,Cz);
PS  = (loop.PSi);                % Process sensitivity
S   = (loop.So);                 % sensitivity
T   = (loop.To);                  % Complementary sensitivity
%% Define input basis functions


Nfreqs = 47;    % Take the first Nfreqs frequencies from the disturbance to attneuate

f = [0 freqs(1:Nfreqs)];        % Save the frequencies in a frequency vector 0 stands for DC
phis = 0.0001*ones(1,Nfreqs+1); % define a vector of phis where each phi corresponds to a single frequency
a = 0.001;                      % define an a where it is currently scalar but can be expanded to be frequency dependant same as with phi


% Make an identity matrix of the phis where each defined phi comes back
% twice as there are 2 basis functions per frequency
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

%% Simulate the mbfrc system using simulink
clear out
starttime = tic;
if simpleMBFRC
    out = sim('SimplifiedMBFRC.slx');
else
    out = sim('NonSimplifiedMBFRC.slx');    
end
endtime = toc(starttime) % Used to check how long the simulation took
% Rename the output signals and thake the fft and cas of the error signal
err_RC = out.errorSig.Data;
RC_out = squeeze(out.MBFRCout.Data);
[Err_RC,cas_RC,freq2] = fftCas_V2(err_RC,out.errorSig.Time,30000,1/1000,Repeats);

figure(201);clf
    subplot(211)
        semilogx(freq2,abs(Err_RC));hold on
            title('Fourier transform of error with RC')
            xlabel('Frequency [Hz]')
            ylabel('Power')
    subplot(212)
        semilogx(freq2,cas_RC);hold on
            title('Cumulative amplitude spectrum with RC')
            xlabel('Frequency [Hz]')
            ylabel('Power')

%% Make nice 3D plot
%this makes a nice 3D plot of the error signals
timeVec = linspace(0,30,30000);
figure(202);clf
colors = winter(Repeats);
for i = 1:Repeats
    L2Norm(i) = norm(err_RC((i-1)*30000+1:i*30000),2);
end
subplot(313)
semilogy(1:Repeats,L2Norm(1:Repeats));hold on
for i = 1:Repeats
    subplot(311);hold on
        plot3(timeVec,i*ones(30000,1),err_RC((i-1)*30000+1:i*30000),"Color",colors(i,:))
            xlabel('Time [s]')
            ylabel('Period \#')
            zlabel('Error [m]')
            title('Error plot divided in periods')
            view(15,35)
    subplot(312);hold on
        plot3(timeVec,i*ones(30000,1),RC_out((i-1)*30000+1:i*30000),"Color",colors(i,:))
            xlabel('Time [s]')
            ylabel('Period \#')
            zlabel('RC output [v]')
            title('RC output plot divided in periods')
            view(15,35)
    subplot(313);hold on
        semilogy(i,L2Norm(i),'x',"Color",colors(i,:),'LineWidth', 2)
            xlabel('Period \#')
            ylabel('L2 norm of error')
            title('L2 norm of the error per period')
end







