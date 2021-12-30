function sppresult=get_reflectance_statistic(mask, layerImg, UVthreshold, scale)
    UVchannel=immultiply(layerImg,mask);
    UVbinary=imbinarize(UVchannel,UVthreshold);
    maskarea = bwarea(mask); 
    UVarea = bwarea(UVbinary);
    UVreflectance=mean(UVchannel(UVbinary));
    UVareaNorm=round(UVarea/maskarea*100,2);
    if UVarea<=0
        UVsd=0;
    else
        UVsd=std(UVchannel(UVbinary));
    end
    sppresult=[{num2str(maskarea/scale^2)}, {num2str(UVarea/scale^2)}, {num2str(UVreflectance)}, {num2str(UVsd/UVreflectance)}, {num2str(UVareaNorm)}];
end