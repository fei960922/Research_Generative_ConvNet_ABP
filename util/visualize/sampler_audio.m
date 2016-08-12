function [syn_mat ] = sampler_audio( opts, config, net_cpu, iter, z, audiodb )
%Used to visulize the images generated by generator network

% set up initial z
net = vl_simplenn_move(net_cpu, 'gpu');
fz = vl_simplenn(net, gpuArray(z), [], [], ...
    'accumulate', false, ...
    'disableDropout', true, ...
    'conserveMemory', opts.conserveMemory, ...
    'backPropDepth', opts.backPropDepth, ...
    'sync', opts.sync, ...
    'cudnn', opts.cudnn);
syn_mat = gather(fz(end).x);

numAudios = config.nTileRow * config.nTileCol;
info = audioinfo([config.inPath, 'training.wav']);
t = 0:seconds(1/config.Fs):seconds(info.Duration);
t = t(1:end-1);
t_syn = 0:seconds(1/config.Fs):seconds(info.Duration*config.extend_factor);
t_syn = t_syn(1:end-1);
index = 1;
subplot(config.nTileRow+1, config.nTileCol, index);
%set(gca, 'DataAspectRatioMode', 'manual');
%set(gca, 'DataAspectRatio', [2, 1, 1]);
%set(gca, 'XLim', [0, 6]);
plot(t, audiodb.audios.data);
%set(gca, 'DataAspectRatioMode', 'manual');
%set(gca, 'DataAspectRatio', [2, 1, 1]);
%set(gca, 'XLimMode', 'manual');
%set(gca, 'XLim', [0, 6]);
%set(gca, 'xlim', [0 6]);
xlabel('Time');
ylabel('Training Audio Signal');
for iRow = 1:config.nTileRow
    for iCol = 1:config.nTileCol
       %audiowrite([config.Synfolder, num2str(iter, 'synthesis_%02d.wav')], syn_mat(:,:,:,iAudio), config.Fs);
       %info = audioinfo([config.Synfolder, num2str(iter, 'synthesis_%02d.wav')]);
       %t = 0:seconds(1/config.Fs):seconds(info.Duration);
       %t = t(1:end-1);
       index = index + 1;
       subplot(config.nTileRow+1, config.nTileCol, index);
       %set(gca, 'DataAspectRatio', [1, 2, 1]);
       plot(t_syn, syn_mat(:,:,:,index-1));
       
      % set(gca, 'DataAspectRatioMode', 'manual');
 %      set(gca, 'XLimMode', 'manual');
 %      set(gca, 'XLim', [0, 12]);
       %axis([0,12,0,1]);
       xlabel('Time');
       ylabel('Audio Signal');
       saveas(gcf, fullfile(config.Synfolder, num2str(iter, 'synthesis_%02d.png')));
       %audiowrite([config.Synfolder, num2str(iter, 'synthesis_%02d.wav')], syn_mat(:,:,:,index-1), config.Fs);
    end
end

if iter == config.nIteration
    for iAudio = 1:numAudios
       audiowrite([config.Synfolder, num2str(iAudio, 'synthesis_%02d.wav')], syn_mat(:,:,:,iAudio), config.Fs)
    end
end