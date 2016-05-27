% File to run a test daq session at a specific voltage

test_session = daq.createSession('ni');
rate = 2000;
test_session.Rate = rate;
test_session.addAnalogOutputChannel('Dev2',0,'Voltage');
Duration = 100; % duration in seconds
volt = 4; % voltage to set at 
aOutWrite = volt*ones(2000*Duration,1);

test_session.queueOutputData(aOutWrite);
% fid1 = fopen('log.bin','w');
% lh = addlistener(pulser_daq_session,'DataAvailable',@(src,event)logData(src,event,fid1));
% %s.IsContinuous = true;
% pulser_daq_session.NotifyWhenDataAvailableExceeds = 2000;
% pulser_daq_session.startBackground();
% pause(pulser.ni.trialDuration);
% pulser_daq_session.stop;
% delete(lh)
% fclose(fid1)
data = test_session.startForeground();