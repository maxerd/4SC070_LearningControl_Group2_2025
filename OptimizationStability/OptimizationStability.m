clear all;close all;clc

%% Settings for simulations
Ts = 0.001;                                                                 % Sampling time
Fs = 1/Ts;

f    = [1/6 1/2]; % Define the to be attenuated frequencies

z = tf('z',Ts);

%% Load the Arizona models
Cy = ss(load('Arizona_models_new\yController_new.mat').Cy_DT);                                     % Load the controller for the carriage
Py = load('Arizona_models_new\Py_fit_new.mat').Py_DT;                                              % Load the plant model of the carriage

%% Loop calculations
loop = loopsens(Py,Cy);
PS  = (loop.PSi);                % Process sensitivity
S   = (loop.So);                 % sensitivity
T   = (loop.To);                  % Complementary sensitivity

%% Define the MBFRC 
syms phi z
clear strPhis

% Make the seperate M's for the frequencies
for i=1:length(f)
    eval(['syms phi' num2str(i)])
    strPhis{i} = ['phi',num2str(i)];
    [r,tau] = bode(T,f(i));
    [toSum.num(i),toSum.den(i)] = makeSimpleFunc(eval(['phi' num2str(i)]),f(i),r,tau*pi/180,Ts);
end

%% Make full (symbolic) equation of the simplified MBFRC
% Denominator
M_tot_den = toSum.den(1);
for i=2:length(toSum.den)
    M_tot_den = M_tot_den*toSum.den(i);
end

% Numerator
M_tot_num = 0;
for j = 1:length(toSum.num)
    temp = toSum.num(j);
    for i=(1:length(toSum.den))
        if i~=j
            temp = temp*toSum.den(i);
        end
    end
    M_tot_num = M_tot_num+temp;
end

%% Plant defined in symbolic 'z'
Py_tf = tf(Py);
for i=flip([1:length(Py_tf.den{1})])
    zs_num(length(Py_tf.num{1})-i+1,1) = z^(i-1);
    zs_den(length(Py_tf.den{1})-i+1,1) = z^(i-1);
end

Py_num = Py_tf.num{1}*zs_num;
Py_den = Py_tf.den{1}*zs_den;
Py_sym = Py_num/Py_den;

%% Controller defined in symbolic 'z'
Cy_tf = tf(Cy);
for i=flip([1:length(Cy_tf.den{1})])
    zs_num_C(length(Cy_tf.num{1})-i+1,1) = z^(i-1);
    zs_den_C(length(Cy_tf.den{1})-i+1,1) = z^(i-1);
end
Cy_num = Cy_tf.num{1}*zs_num_C;
Cy_den = Cy_tf.den{1}*zs_den_C;
Cy_sym = Cy_num/Cy_den;

%% Make the sensitivity defined in symbolic 'z'
clc
PC_num = Cy_num*Py_num;
PC_den = Cy_den*Py_den;

S_den = Py_den*Cy_den*M_tot_den+Py_num*Cy_num*(M_tot_den+M_tot_num);
S_num = Py_den*Cy_den*M_tot_den;


S_den_coeffs = fliplr(coeffs(S_den,z));
S_num_coeffs = fliplr(coeffs(S_num,z));

%% Very inefficient search for the optimal phi for a single frequency
% for i=fliplr(linspace(0.01,1,100))
%     max(abs(roots(subs(S_den_coeffs,'phi1',i))))
%     if max(abs(roots(subs(S_den_coeffs,'phi1',i))))<1
%         disp(['Best phi found at: ',num2str(i)])
%         bestPhi = i;
%         break
%     end
% end
% 
% for i=fliplr(linspace(bestPhi,bestPhi+0.01,101))
%     if max(abs(roots(subs(S_den_coeffs,'phi',i))))<1
%         disp(['Best phi found at: ',num2str(i)])
%         bestPhi = i;
%         break
%     end
% end

%% Non-linear optimization
fun = @(x) -sum(x);

A = [];
b = [];
Aeq = [];
beq = [];
lb = zeros(1,length(f));
ub = ones(1,length(f));
x0 = 0.00001.*ones(1,length(f));

nonlcon = @(x) maxAbsEig(x,strPhis,S_den_coeffs,S_num_coeffs,Ts);
phi_opt = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon);

%% Make a transfer function using of M and check nyquist and the stability margins
syms z
M_z_num = subs(M_tot_num,strPhis,1000000*phi_opt);
M_z_den = subs(M_tot_den,strPhis,phi_opt);

M_z_num_coeff = double(fliplr(coeffs(M_z_num,z)));
M_z_den_coeff = double(fliplr(coeffs(M_z_den,z)));

M = tf(M_z_num_coeff,M_z_den_coeff,Ts,'Variable','z');

figure(1);clf;nyquist(series(series(Py,Cy),M))
figure(2);clf;margin(series(series(Py,Cy),M))

%% Function definitions

% non-linear optimization constraint
function [c,ceq] = maxAbsEig(phis,strPhis,S_den_coeffs,S_num_coeffs,Ts)
    fullTF = tf(double(subs(S_num_coeffs,strPhis,phis)),double(subs(S_den_coeffs,strPhis,phis)),Ts);
    fullTF = minreal(fullTF);
    c = max(abs(pole(fullTF)))-0.9999;
    ceq = [];
end

% Make a single (approximate) simplified MBFRC transfer function
function [M_num,M_den] = makeSimpleFunc(phi,f,r,tau,Ts)
    syms z
    w = f*2*pi;
    M_num = ((phi)*(cos(w*Ts-tau)*z^2-cos(tau)*z));
    M_den = ((r)*(z^2-2*cos(w*Ts)*z+1));
end














