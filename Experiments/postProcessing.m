clear all;close all;clc

%% Some definitions
addpath('./_funcs')
addpath('reportFigures')

stndFig_1 = [100 100 750 175];
stndFig_2 = [100 300 750 350];

Fs = 1e3;
Ts = 1/Fs;

tVec_SP1 = (0:30000-1)*Ts;
tVec_SP2 = (0:60000-1)*Ts;
tVec_SP3 = (0:90000-1)*Ts;
tVec_SP4 = (0:120000-1)*Ts;
tVec_SP5 = (0:150000-1)*Ts;
tVec_SP6 = (0:180000-1)*Ts;

%% Disturbance only
realDist = load('./_rawData/Disturbance_LC24_25.mat');
realDist.e = realDist.dist;
realDist.tVec = realDist.t;

[realDist.psd,realDist.cas,realDist.freqVec] = fftCas_V2(realDist,30000,Fs,1);

figure(101);clf
    set(gcf,'Position',stndFig_1)
    semilogx(realDist.freqVec,realDist.psd);hold on;grid minor
        title('PSD of disturbance with FB and FF only')
        xlabel('Frequency [Hz]')
        ylabel('Power [V^2/Hz]')
print('./reportFigures/General/disturbancePower_real_2','-depsc')

%% With FB and FF compared to 1 frequency simplified MBFRC
FF_FB               = loadExperiment('./_rawData\FF_FB\data_LC_2025_6_17_meas0.mat');
MBFRC_1_6s          = loadExperiment('./_rawData\MBFRC_1_6s\data_LC_2025_6_17_meas0.mat');

[FF_FB.psd,FF_FB.cas,FF_FB.freqVec] = fftCas_V2(FF_FB,30000,Fs,1);
[MBFRC_1_6s.psd,MBFRC_1_6s.cas,MBFRC_1_6s.freqVec] = fftCas_V2(MBFRC_1_6s,30000,Fs,1);

figure(201);clf
    set(gcf,'Position',stndFig_2)
    subplot(211)
        semilogx(FF_FB.freqVec,FF_FB.psd);hold on;grid minor
        semilogx(MBFRC_1_6s.freqVec,MBFRC_1_6s.psd);
            title('PSD comparing error with FB and FF only to single frequency MBFRC')
            xlabel('Frequency [Hz]')
            ylabel('Power [m^2/Hz]')
            legend('FB and FF controller','simplified MBFRC, 1 freq','location','best')
    subplot(212)
        semilogx(FF_FB.freqVec,FF_FB.cas);hold on;grid minor
        semilogx(MBFRC_1_6s.freqVec,MBFRC_1_6s.cas);
            title('CAS comparing error with FB and FF only to single frequency MBFRC')
            xlabel('Frequency [Hz]')
            ylabel('RMSE [m]')
            legend('FB and FF controller','simplified MBFRC, 1 freq','location','best')
print('./reportFigures/simple_MBFRC/comp_MBFRC_FB_PSD_CAS_2','-depsc')

%% Increasing amount of frequencies with simplified MBFRC
FF_FB               = loadExperiment('./_rawData\FF_FB\data_LC_2025_6_17_meas0.mat');
RC_6s               = loadExperiment('./_rawData\RC_6s\data_LC_2025_6_17_meas0.mat');
MBFRC_3_6s_2s_DC    = loadExperiment('./_rawData\MBFRC_3_6s_2s_DC\data_LC_2025_6_17_meas0.mat');
MBFRC_7             = loadExperiment('./_rawData\MBFRC_7\data_LC_2025_6_17_meas1.mat');
MBFRC_20_SP3        = loadExperiment('./_rawData\MBFRC_20_SP3\data_LC_2025_6_18_meas1.mat');
MBFRC_47_SP10       = loadExperiment('./_rawData\MBFRC_47_SP10\data_LC_2025_6_18_meas1.mat');

[FF_FB.psd,FF_FB.cas,FF_FB.freqVec] = fftCas_V2(FF_FB,30000,Fs,1);
[RC_6s.psd,RC_6s.cas,RC_6s.freqVec] = fftCas_V2(RC_6s,30000,Fs,1);
[MBFRC_3_6s_2s_DC.psd,MBFRC_3_6s_2s_DC.cas,MBFRC_3_6s_2s_DC.freqVec] = fftCas_V2(MBFRC_3_6s_2s_DC,30000,Fs,1);
[MBFRC_7.psd,MBFRC_7.cas,MBFRC_7.freqVec] = fftCas_V2(MBFRC_7,30000,Fs,1);
[MBFRC_20_SP3.psd,MBFRC_20_SP3.cas,MBFRC_20_SP3.freqVec] = fftCas_V2(MBFRC_20_SP3,30000,Fs,2);
[MBFRC_47_SP10.psd,MBFRC_47_SP10.cas,MBFRC_47_SP10.freqVec] = fftCas_V2(MBFRC_47_SP10,30000,Fs,10);

figure(301);clf
    set(gcf,'Position',stndFig_2)
    subplot(211)
        semilogx(FF_FB.freqVec,abs(FF_FB.psd));hold on;grid minor
        semilogx(RC_6s.freqVec,abs(RC_6s.psd))
        semilogx(MBFRC_3_6s_2s_DC.freqVec,abs(MBFRC_3_6s_2s_DC.psd))
        semilogx(MBFRC_7.freqVec,abs(MBFRC_7.psd))
        semilogx(MBFRC_20_SP3.freqVec,abs(MBFRC_20_SP3.psd))
        semilogx(MBFRC_47_SP10.freqVec,abs(MBFRC_47_SP10.psd))
            title('PSD of error with increasing amount of attenuated frequencies')
            xlabel('Frequency [Hz]')
            ylabel('Power [m^2/Hz]')
            legend('FB only','RC, 6s/6000samples','MBFRC, 3freqs (1/6, 1/2, 0Hz)','MBFRC, 7freqs','MBFRC, 20freqs','MBFRC, 47freqs','location','best')
    subplot(212)
        semilogx(FF_FB.freqVec,FF_FB.cas);hold on;grid minor
        semilogx(RC_6s.freqVec,RC_6s.cas)
        semilogx(MBFRC_3_6s_2s_DC.freqVec,MBFRC_3_6s_2s_DC.cas)
        semilogx(MBFRC_7.freqVec,MBFRC_7.cas)
        semilogx(MBFRC_20_SP3.freqVec,MBFRC_20_SP3.cas)
        semilogx(MBFRC_47_SP10.freqVec,MBFRC_47_SP10.cas)
            title('CAS of error with increasing amount of attenuated frequencies')
            xlabel('Frequency [Hz]')
            ylabel('RMSE [m]')
            legend('FB only','RC, 6s/6000samples','MBFRC, 3freqs (1/6, 1/2, 0Hz)','MBFRC, 7freqs','MBFRC, 20freqs','MBFRC, 47freqs','location','best')
print('./reportFigures/simple_MBFRC/comp_moreFreqs_PSD_CAS_2','-depsc')

%% simplified VS non-simplified, 47 freqs
MBFRC_47_SP10       = loadExperiment('./_rawData\MBFRC_47_SP10\data_LC_2025_6_18_meas1.mat');
MBFRC_NS_48_SP4     = loadExperiment('./_rawData\MBFRC_NS_47_SP4\data_LC_2025_6_26_meas0.mat');

[MBFRC_47_SP10.psd,MBFRC_47_SP10.cas,MBFRC_47_SP10.freqVec] = fftCas_V2(MBFRC_47_SP10,30000,Fs,4);
[MBFRC_NS_48_SP4.psd,MBFRC_NS_48_SP4.cas,MBFRC_NS_48_SP4.freqVec] = fftCas_V2(MBFRC_NS_48_SP4,30000,Fs,4);
MBFRC_47_SP10.e = LCgetError(MBFRC_47_SP10,4);
MBFRC_NS_48_SP4.e = LCgetError(MBFRC_NS_48_SP4,4);

figure(401);clf
    set(gcf,'Position',stndFig_2)
    subplot(211)
        semilogx(MBFRC_47_SP10.freqVec,MBFRC_47_SP10.psd);hold on;grid minor
        semilogx(MBFRC_NS_48_SP4.freqVec,MBFRC_NS_48_SP4.psd)
            title('PSD of error comparing simplified and non-simplified MBFRC')
            xlabel('Frequency [Hz]')
            ylabel('Power [m^2/Hz]')
            legend('Simplified MBFRC','Non-simplified MBFRC','Location','best')
    subplot(212)
        semilogx(MBFRC_47_SP10.freqVec,MBFRC_47_SP10.cas);hold on;grid minor
        semilogx(MBFRC_NS_48_SP4.freqVec,MBFRC_NS_48_SP4.cas)
            title('CAS of error comparing simplified and non-simplified MBFRC')
            xlabel('Frequency [Hz]')
            ylabel('RMSE [m]')
            legend('Simplified MBFRC','Non-simplified MBFRC','Location','best')
print('./reportFigures/nonsimple_MBFRC/comp_48freq_PSD_CAS_2','-depsc')

figure(402);clf
    set(gcf,'Position',stndFig_1)
    plot(tVec_SP4,MBFRC_47_SP10.e);hold on;grid minor
    plot(tVec_SP4,MBFRC_NS_48_SP4.e)
        title('Error plot comparing simplified and non-simplified MBFRC')
        xlabel('Time [s]')
        ylabel('Error [m]')
        legend('Simplified MBFRC','Non-simplified MBFRC','Location','best')
print('./reportFigures/nonsimple_MBFRC/comp_48freq_Err_2','-depsc')

%% simplified with and without RC, 48 freqs
MBFRC_47_SP10       = loadExperiment('./_rawData\MBFRC_47_SP10\data_LC_2025_6_18_meas1.mat');
MBFRC_RC_48_SP6     = loadExperiment('./_rawData\MBFRC+RC_48_SP6\data_LC_2025_6_20_meas11.mat');

[MBFRC_47_SP6.psd,MBFRC_47_SP6.cas,MBFRC_47_SP6.freqVec] = fftCas_V2(MBFRC_47_SP10,60000,Fs,6);
[MBFRC_RC_48_SP6.psd,MBFRC_RC_48_SP6.cas,MBFRC_RC_48_SP6.freqVec] = fftCas_V2(MBFRC_RC_48_SP6,60000,Fs,6);

MBFRC_RC_48_SP6.e = LCgetError(MBFRC_RC_48_SP6,6);
MBFRC_47_SP6.e = LCgetError(MBFRC_47_SP10,6);

figure(501);clf
    set(gcf,'Position',stndFig_2)
    subplot(211)
        semilogx(MBFRC_47_SP6.freqVec,MBFRC_47_SP6.psd);hold on;grid minor
        semilogx(MBFRC_RC_48_SP6.freqVec,MBFRC_RC_48_SP6.psd)
            title('PSD of error comparing simplified MBFRC with and without added RC')
            xlabel('Frequency [Hz]')
            ylabel('Power [m^2/Hz]')
            legend('Simplified MBFRC','Simplified MBFRC with RC','Location','best')
    subplot(212)
        semilogx(MBFRC_47_SP6.freqVec,MBFRC_47_SP6.cas);hold on;grid minor
        semilogx(MBFRC_RC_48_SP6.freqVec,MBFRC_RC_48_SP6.cas)
            title('CAS of error comparing simplified MBFRC with and without added RC')
            xlabel('Frequency [Hz]')
            ylabel('RMSE [m]')
            legend('Simplified MBFRC','Simplified MBFRC with RC','Location','best')
print('./reportFigures/simple_MBFRC_RC/comp_48freq_PSD_CAS_2','-depsc')

figure(502);clf
    set(gcf,'Position',stndFig_1)
    sgtitle('Error plot of simplified MBFRC with and without added RC')
    subplot(6,3,[1 2 4 5 7 8 10 11 13 14])
        plot(tVec_SP6,MBFRC_47_SP6.e);hold on;grid minor
        plot(tVec_SP6,MBFRC_RC_48_SP6.e)
        xlim([0 180])
            xlabel('Time [s]')
            ylabel('Error [m]')
                legend('Simplified MBFRC','Simplified MBFRC with RC','Location','northeast')
    subplot(6,3,[3 6 9 12 15])
        plot(tVec_SP6,MBFRC_47_SP6.e);hold on;grid minor
        plot(tVec_SP6,MBFRC_RC_48_SP6.e)
        xlim([170 180])
        ylim([-10e-6 10e-6])
            xlabel('Time [s]')
            ylabel('Error [m]')
                % legend('Simplified MBFRC','Simplified MBFRC with RC','Location','best')
print('./reportFigures/simple_MBFRC_RC/comp_48freq_Err_2','-depsc')

%% simplified and non-simplified MBFRC with, 48 freqs
MBFRC_RC_48_SP6     = loadExperiment('./_rawData\MBFRC+RC_48_SP6\data_LC_2025_6_20_meas11.mat');
MBFRC_RC_NS_48_SP6  = loadExperiment('./_rawData\MBFRC+RC_NS_48_SP6\data_LC_2025_6_20_meas10.mat');

[MBFRC_RC_48_SP4.psd,MBFRC_RC_48_SP4.cas,MBFRC_RC_48_SP4.freqVec] = fftCas_V2(MBFRC_RC_48_SP6,60000,Fs,6);
[MBFRC_RC_NS_48_SP6.psd,MBFRC_RC_NS_48_SP6.cas,MBFRC_RC_NS_48_SP6.freqVec] = fftCas_V2(MBFRC_RC_NS_48_SP6,60000,Fs,6);
MBFRC_RC_48_SP4.e = LCgetError(MBFRC_RC_48_SP6,6);
MBFRC_RC_NS_48_SP6.e = LCgetError(MBFRC_RC_NS_48_SP6,6);

figure(601);clf
    set(gcf,'Position',stndFig_2)
    subplot(211)
        semilogx(MBFRC_RC_48_SP4.freqVec,MBFRC_RC_48_SP4.psd);hold on;grid minor
        semilogx(MBFRC_RC_NS_48_SP6.freqVec,MBFRC_RC_NS_48_SP6.psd)
            title('PSD of error comparing simplified and non-simplified MBFRC with RC')
            xlabel('Frequency [Hz]')
            ylabel('Power [m^2/Hz]')
            legend('Simplified MBFRC with RC','Non-simplified MBFRC with RC','Location','best')
    subplot(212)
        semilogx(MBFRC_RC_48_SP4.freqVec,MBFRC_RC_48_SP4.cas);hold on;grid minor
        semilogx(MBFRC_RC_NS_48_SP6.freqVec,MBFRC_RC_NS_48_SP6.cas)
            title('CAS of error comparing simplified and non-simplified MBFRC with RC')
            xlabel('Frequency [Hz]')
            ylabel('RMSE [m]')
            legend('Simplified MBFRC with RC','Non-simplified MBFRC with RC','Location','best')
print('./reportFigures/nonSimple_MBFRC_RC/compToSimple_48freq_PSD_CAS_2','-depsc')

figure(602);clf
    set(gcf,'Position',stndFig_1)
    sgtitle('Error plot comparing simplified and non-simplified MBFRC with RC')
    subplot(6,3,[1 2 4 5 7 8 10 11 13 14])
        plot(tVec_SP6,MBFRC_RC_48_SP4.e);hold on;grid minor
        plot(tVec_SP6,MBFRC_RC_NS_48_SP6.e)
        xlim([0 180])
            xlabel('Time [s]')
            ylabel('Error [m]')
                legend('Simplified MBFRC with RC','Non-simplified MBFRC with RC','Location','northeast')
    subplot(6,3,[3 6 9 12 15])
        plot(tVec_SP6,MBFRC_RC_48_SP4.e);hold on;grid minor
        plot(tVec_SP6,MBFRC_RC_NS_48_SP6.e)
        xlim([170 180])
        ylim([-10e-6 10e-6])
            xlabel('Time [s]')
            ylabel('Error [m]')
                % legend('Simplified MBFRC','Simplified MBFRC with RC','Location','best')
print('./reportFigures/nonSimple_MBFRC_RC/compToSimple_48freq_Err_2','-depsc')

%% Q-filter testing
MBFRC_RC_NS_48_SP6_Q01  = loadExperiment('./_rawData\MBFRC+RC_NS_48_SP6_24Jul\data_LC_2025_6_24_meas3_Q0.1.mat');
MBFRC_RC_NS_48_SP6_Q025 = loadExperiment('./_rawData\MBFRC+RC_NS_48_SP6_24Jul\data_LC_2025_6_24_meas3_Q0.25.mat');

[MBFRC_RC_NS_48_SP6_Q01.psd,MBFRC_RC_NS_48_SP6_Q01.cas,MBFRC_RC_NS_48_SP6_Q01.freqVec] = fftCas_V2(MBFRC_RC_NS_48_SP6_Q01,30000,Fs,6);
[MBFRC_RC_NS_48_SP6_Q025.psd,MBFRC_RC_NS_48_SP6_Q025.cas,MBFRC_RC_NS_48_SP6_Q025.freqVec] = fftCas_V2(MBFRC_RC_NS_48_SP6_Q025,30000,Fs,6);
MBFRC_RC_NS_48_SP6_Q01.e = LCgetError(MBFRC_RC_NS_48_SP6_Q01,6);
MBFRC_RC_NS_48_SP6_Q025.e = LCgetError(MBFRC_RC_NS_48_SP6_Q025,6);

figure(701);clf
    set(gcf,'Position',stndFig_2)
    subplot(211)
        semilogx(MBFRC_RC_NS_48_SP6_Q01.freqVec,MBFRC_RC_NS_48_SP6_Q01.psd);hold on;grid minor
        semilogx(MBFRC_RC_NS_48_SP6_Q025.freqVec,MBFRC_RC_NS_48_SP6_Q025.psd)
            title('PSD of error comparing Q-filter with different cut-off frequencies')
            xlabel('Frequency [Hz]')
            ylabel('Power [m^2/Hz]')
            legend('Cut-off at 0.1\cdot Fn','Cut-off at 0.25\cdot Fn','location','best')
    subplot(212)
        semilogx(MBFRC_RC_NS_48_SP6_Q01.freqVec,MBFRC_RC_NS_48_SP6_Q01.cas);hold on;grid minor
        semilogx(MBFRC_RC_NS_48_SP6_Q025.freqVec,MBFRC_RC_NS_48_SP6_Q025.cas)
            title('CAS of error comparing Q-filter with different cut-off frequencies')
            xlabel('Frequency [Hz]')
            ylabel('RMSE [m]')
            legend('Cut-off at 0.1\cdot Fn','Cut-off at 0.25\cdot Fn','location','best')
print('./reportFigures/Q-filter/comp_48freq_PSD_CAS_2','-depsc')

figure(702);clf
    set(gcf,'Position',stndFig_1)
    sgtitle('Error plot comparing Q-filter with different cut-off frequencies')
    subplot(6,3,[1 2 4 5 7 8 10 11 13 14])
        plot(tVec_SP6,MBFRC_RC_NS_48_SP6_Q01.e);hold on;grid minor
        plot(tVec_SP6,MBFRC_RC_NS_48_SP6_Q025.e)
        xlim([0 180])
            xlabel('Time [s]')
            ylabel('Error [m]')
            legend('Cut-off at 0.1\cdot Fn','Cut-off at 0.25\cdot Fn','location','northeast')
    subplot(6,3,[3 6 9 12 15])
        plot(tVec_SP6,MBFRC_RC_NS_48_SP6_Q01.e);hold on;grid minor
        plot(tVec_SP6,MBFRC_RC_NS_48_SP6_Q025.e)
        xlim([170 180])
        ylim([-10e-6 10e-6])
            xlabel('Time [s]')
            ylabel('Error [m]')
print('./reportFigures/Q-filter/comp_48freq_Err_2','-depsc')

%% Initialization of alphas
MBFRC_RC_NS_48_noInit_SP4 = loadExperiment('./_rawData\MBFRC_initTests\data_LC_2025_6_20_meas8_withoutInit.mat');
MBFRC_RC_NS_48_init_SP4   = loadExperiment('./_rawData\MBFRC_initTests\data_LC_2025_6_20_meas9_withInit.mat');

[MBFRC_RC_NS_48_noInit_SP4.psd,MBFRC_RC_NS_48_noInit_SP4.cas,MBFRC_RC_NS_48_noInit_SP4.freqVec] = fftCas_V2(MBFRC_RC_NS_48_noInit_SP4,30000,Fs,4);
[MBFRC_RC_NS_48_init_SP4.psd,MBFRC_RC_NS_48_init_SP4.cas,MBFRC_RC_NS_48_init_SP4.freqVec] = fftCas_V2(MBFRC_RC_NS_48_init_SP4,30000,Fs,4);

figure(801);clf
    set(gcf,'Position',stndFig_2)
    subplot(211)
        plot(MBFRC_RC_NS_48_noInit_SP4.tVec,MBFRC_RC_NS_48_noInit_SP4.e);hold on;grid minor
        plot(MBFRC_RC_NS_48_init_SP4.tVec,MBFRC_RC_NS_48_init_SP4.e);hold on
            title('Error signals of non-simplified MBFRC with and without initialization')
            xlabel('Time [s]')
            ylabel('Error [m]')
            legend('With initialization','Without initialization')
    subplot(212)
        plot(MBFRC_RC_NS_48_init_SP4.tVec,MBFRC_RC_NS_48_init_SP4.alpha(1:6,:));hold on;grid minor
            title("First 6 alpha's of non-simplified MBFRC with alpha initialization")
            xlabel('Time [s]')
            ylabel('Error [m]')
print('./reportFigures/Initialize/comp_withWithoutInit_Err_2','-depsc')

