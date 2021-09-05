function [] = openSourceImages_DSI_benj(input_path)

% DSI Studio - OPEN SOURCE IMAGES: Load .dcm files and create .src file
% If .src file exists by the same name, this function does nothing

%   Input: path to subject folder with 65 / 105 .dcm files of DTI scan

%   Output: folder within the subject folder called "src_DSIStudio"
%   containing the .src file named "output_src.src.gz", to be used later in reconsturction

output_path = [input_path,filesep,'src_DSIStudio'];
mkdir(output_path);
output_src = [output_path,filesep,'output_src.src.gz'];
system(['dsi_studio.exe --action=src --source=' input_path ' --output=' output_src]);

end