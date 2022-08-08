function makeGIF(imgFolder, saveFolder, filename)

if nargin < 2
    if ispc 
        temp = strsplit(imgFolder,'\');
    else
        temp = strsplit(imgFolder,'/');
    end
    saveFolder = imgFolder;
    filename = temp{end};
elseif nargin < 3
    if ispc 
        temp = strsplit(imgFolder,'\');
    else
        temp = strsplit(imgFolder,'/');
    end
    filename = temp{end};
end

if ~isdir(saveFolder)
    mkdir(saveFolder);
end
    
saveFile = fullfile(temp{1:end-1},[filename,'.gif']);
fileList = dir(fullfile(imgFolder,'*.png'));

loops = 1;
delay = 0.5; % delay in seconds

for i=1:length(fileList)
    
    a=imread(fullfile(imgFolder,fileList(i).name));
    [M  c_map]= rgb2ind(a,256);

    if i==1
        imwrite(M,c_map,saveFile,'gif','LoopCount',loops,'DelayTime',delay)
    else
        imwrite(M,c_map,saveFile,'gif','WriteMode','append','DelayTime',delay)
    end
end

end