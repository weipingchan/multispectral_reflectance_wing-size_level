function sppchannelresult=get_reflectance_statistic_RGB(mask, layerImg, reflectanceThreshold, scale)
    channels=size(layerImg,3);
    sppchannelresult=[];
    for channel=1:channels
        channelimg=layerImg;
        channelresult0=get_reflectance_statistic(mask, channelimg(:,:,channel), reflectanceThreshold, scale);
%         bodyPart='all';
        channelresult=channelresult0(2:end);
        maskresult=channelresult0(1);
        sppchannelresult=[sppchannelresult, channelresult];
    end
    sppchannelresult=[maskresult, sppchannelresult];
end