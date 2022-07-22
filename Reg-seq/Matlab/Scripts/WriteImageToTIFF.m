function [] = WriteImageToTIFF(seq_read,Path_to_save,name,j,counter)
cd(Path_to_save);
if counter<=20000
    if exist(string(floor(counter/20000)))
        cd(string(floor(counter/20000)))
    else
        mkdir(string(floor(counter/20000)))
    end
else
    counter = 0;
    mkdir(string(floor(counter/20000)))
    cd(string(floor(counter/20000)))
end
seq_read = single(seq_read);
name = split(name,".");
fileName = name{1} + "_" + string(j) + ".tif";
tiffObject = Tiff(fileName, 'w');
% Set tags.
tagstruct.ImageLength = size(seq_read,1); 
tagstruct.ImageWidth = size(seq_read,2);
tagstruct.Compression = Tiff.Compression.None;
tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 32;
tagstruct.SamplesPerPixel = size(seq_read,3);
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tiffObject.setTag(tagstruct);
% Write the array to disk.
tiffObject.write(seq_read);
tiffObject.close;
end
