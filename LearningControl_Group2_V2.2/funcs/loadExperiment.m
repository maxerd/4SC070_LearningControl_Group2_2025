function dat = loadExperiment(filePath)

rawrawDat = load(filePath,'history');

rawDat = rawrawDat.history;

dat.e      = squeeze(rawDat.e(:,:,1));
dat.uhat   = squeeze(rawDat.uhat(:,:,1));

dat.f      = squeeze(rawDat.fupdate(1,:,1));

dat.r      = squeeze(rawDat.r(1,:,1));

dat.p      = squeeze(rawDat.p(:,:,1));
dat.p2     = squeeze(rawDat.p2(:,:,1));

dat.tVec   = squeeze(rawDat.t);
dat.Nref   = squeeze(rawDat.Nref);
dat.u      = squeeze(rawDat.u(:,:,1));

end