function single_band_AnaWholeSpecimen2(Mat_directory, morph_mat_directory, Code_directory, Result_directory, bandno_input, reflectanceThreshold)
%Read the file list in the Img_directory
if size(Mat_directory,2)==1 Mat_directory=Mat_directory{1};, end;
if size(morph_mat_directory,2)==1 morph_mat_directory=morph_mat_directory{1};, end;
if size(Code_directory,2)==1 Code_directory=Code_directory{1};, end;
if size(Result_directory,2)==1 Result_directory=Result_directory{1};, end;
if ~isnumeric(bandno_input) bandno_input=str2num(bandno_input);, end; 
if ~isnumeric(reflectanceThreshold) reflectanceThreshold=str2num(reflectanceThreshold);, end; 

addpath(genpath(Code_directory)) %Add the library to the path
img_ds = struct2dataset(dir(fullfile(Mat_directory,'*AllBandsMask.mat')));
img_listing=img_ds(:,1).name;
spectralNames={'740','940','UV','UVF','F','white','whitePo1','whitePo2','FinRGB','PolDiff'};
bodyPartNames={'lf_wing', 'rf_wing', 'lh_wing', 'rh_wing', 'body', 'antenna'};

bandno=bandno_input;

vdlist={'dorsal','ventral'};
if bandno <= 5
    %Handling an 1-channel BW image
    disp('Using BW 1-channel system');
    flag=num2str(-9999); %for those error results
    result  = cell2table(cell(0,8), 'VariableNames', {'Specimen_Barcode', 'Side', 'body_part', 'Area_Mask_cm2', ['Area_',spectralNames{bandno},'_cm2'], ['b_',spectralNames{bandno},'_reflectance_perCm2_mean'], ['b_',spectralNames{bandno},'_reflectance_perCm2_cv'], ['Area_',spectralNames{bandno},'_pct']});
    for spp=1:length(img_ds)
        matinname=img_listing{spp};
        [barcode, side, flag]=file_name_decoder(matinname);
        disp(['Start to analyze specimen: ', barcode,'_',vdlist{side}]);
        try
            matin=fullfile(Mat_directory, matinname);
            sppmat0=load(matin);
            fieldName=cell2mat(fieldnames(sppmat0));
            sppmat=sppmat0.(fieldName);
            clear sppmat0
            scale=sppmat{12};
            mask=sppmat{11};
            sppresult0=get_reflectance_statistic(mask, sppmat{bandno}, reflectanceThreshold, scale);
            bodyPart='all';
            sppresult=[{barcode}, {vdlist{side}}, bodyPart, sppresult0];

            %trying to summarize different wing parts
            morph_data = dir(fullfile(morph_mat_directory,[barcode,'_',vdlist{side},'*morph-seg.mat']));
            if ~isempty(morph_data)
                morphin=fullfile(morph_mat_directory, morph_data.name);
                sppmorph0=load(morphin);
                fieldName=cell2mat(fieldnames(sppmorph0));
                sppmorph=sppmorph0.(fieldName);
                clear sppmorph0
                segmented_img=sppmorph{13};
                
                for bodyPartID=1:6
                    try
                        partMask=segmented_img==bodyPartID;
                        sppresult0=get_reflectance_statistic(partMask, sppmat{bandno}, reflectanceThreshold, scale);
                        bodyPart=bodyPartNames{bodyPartID};
                        sppresult=[sppresult; [{barcode}, {vdlist{side}}, bodyPart, sppresult0]];
                    catch
                        disp(['Cannot extract reflectance of ',bodyPartNames{bodyPartID}]);
                    end
                end
            else
                disp('No corresponding morph-seg data');
            end
            
        catch
            sppresult=[];
        end
        if ~isempty(sppresult)
            result=[result; sppresult];   
        end
    end

elseif bandno <=10
    %Handling a 3-channel RGB images
    disp('Usinge RGB 3-channel system');
    result  = cell2table(cell(0,16), 'VariableNames', {'Specimen_Barcode', 'Side', 'body_part', 'Area_Mask_cm2',...
         ['Area_',spectralNames{bandno},'_R_cm2'], ['b_',spectralNames{bandno},'_R','_reflectance_perCm2_mean'], ['b_',spectralNames{bandno},'_R','_reflectance_perCm2_cv'], ['Area_',spectralNames{bandno},'_R_pct'],...
         ['Area_',spectralNames{bandno},'_G_cm2'], ['b_',spectralNames{bandno},'_G','_reflectance_perCm2_mean'], ['b_',spectralNames{bandno},'_G','_reflectance_perCm2_cv'], ['Area_',spectralNames{bandno},'_G_pct'],...
         ['Area_',spectralNames{bandno},'_B_cm2'], ['b_',spectralNames{bandno},'_B','_reflectance_perCm2_mean'], ['b_',spectralNames{bandno},'_B','_reflectance_perCm2_cv'], ['Area_',spectralNames{bandno},'_B_pct']       
         });
    for spp=1:length(img_ds)
        matinname=img_listing{spp};
        [barcode, side, flag]=file_name_decoder(matinname);
        disp(['Start to analyze specimen: ', barcode,'_',vdlist{side}]);
        try
            matin=fullfile(Mat_directory, matinname);
            sppmat0=load(matin);
            fieldName=cell2mat(fieldnames(sppmat0));
            sppmat=sppmat0.(fieldName);
            clear sppmat0
            scale=sppmat{12};
            mask=sppmat{11};
            bodyPart='all';
            sppchannelresult0=get_reflectance_statistic_RGB(mask, sppmat{bandno}, reflectanceThreshold, scale);
            sppresult=[{barcode}, {vdlist{side}}, bodyPart, sppchannelresult0];
            
            %trying to summarize different wing parts
            morph_data = dir(fullfile(morph_mat_directory,[barcode,'_',vdlist{side},'*morph-seg.mat']));
            if ~isempty(morph_data)
                morphin=fullfile(morph_mat_directory, morph_data.name);
                sppmorph0=load(morphin);
                fieldName=cell2mat(fieldnames(sppmorph0));
                sppmorph=sppmorph0.(fieldName);
                clear sppmorph0
                segmented_img=sppmorph{13};
                for bodyPartID=1:6
                    try
                        partMask=segmented_img==bodyPartID;
                        sppchannelresult0=get_reflectance_statistic_RGB(partMask, sppmat{bandno}, reflectanceThreshold, scale);
                        bodyPart=bodyPartNames{bodyPartID};
                        sppresult=[sppresult; [{barcode}, {vdlist{side}}, bodyPart, sppchannelresult0]];
                    catch
                        disp(['Cannot extract reflectance of ',bodyPartNames{bodyPartID}]);
                    end
                end
            else
                disp('No corresponding morph-seg data');
            end
            
            
        catch
              sppresult=[];
        end
        if ~isempty(sppresult)
            result=[result; sppresult];   
        end
    end
else
    disp('The layers selected does not exist.');
end

outdir0=strsplit(Mat_directory, filesep);
outfilename=strjoin([outdir0(end),datestr(now,'dd-mm-yy','local'),datestr(now,'hh-MM-ss','local'),spectralNames{bandno},'refThreshold-',num2str(reflectanceThreshold),'summary.csv'],'_');
writetable(result,fullfile(Result_directory,outfilename));
end