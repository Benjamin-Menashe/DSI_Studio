clear all; clc;
path = 'G:\Presurgical_Ileana\Benjamin_Thesis\DICOM_DTI\Pacientes\';
stages = {'pre','post1','post2','post3'};

for stg = 1:4
    stgpath = [path stages{stg}];
    cd(stgpath);
    sub = dir;
    for pp = 3:length(sub)
        mo_path = [stgpath, filesep, sub(pp).name, filesep, 'src_DSIStudio'];
        cd(mo_path)
        pp_file = dir('*ns_seg*.mat');
        load(pp_file.name)
        new_aff = Affine(1:3,:);
        dlmwrite('affine.txt',new_aff, 'delimiter', '\t', 'newline', 'pc');
    end
end