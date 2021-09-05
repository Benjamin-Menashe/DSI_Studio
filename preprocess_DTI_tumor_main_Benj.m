%% Matlab script for DTI processing of brain tumor patients ("BIO-ID Recovery" Project)

% This is the main script for accessing and using DSI Studio to preprocess
% white-matter DTI data for Benjamin's Ms thesis project.
% The script uses 3 functions: (which can be used generally for DTI preprocessing)
%   1. openSourceImages_DSI_benj - convert 65 / 105 .dcm files to src
%   2. reconstruction_DSI_benj - use src for reconstruction
%   3. fiberTracking_DSI_benj - extract individual fiber properties

clear all; clc;
addpath(genpath('G:\Presurgical_Ileana\Toolbox\spm12'));
defaults = spm_get_defaults;

% Insert Params (specific params can be changed in the functions for each step):
method = '4'; % 0=DSI, 1=DTI, 4=GQI, 7=QSDR
step1 = false; %Open Source Images
step2 = false; %Reconstruction
step3 = false; %Fiber Tracking
step4 = true; %Batching Fiber Statistics
path = 'G:\Presurgical_Ileana\Benjamin_Thesis\DICOM_DTI\Pacientes1';
fibers = {'20','21','26','27','28','29','30','31','32','33','34','35','38','39','43','47','48','49','50'}; % List of numbers corrosponding to fiber according to convention. Look in end of fiberTracking_DSI_benj.m function
% for a great list use: {'20','21','26','27','28','29','30','31','32','33','34','35','38','39','43','47','48','49','50'};

% stages for loop
stages = {'pre','post1','post2','post3'};
% parpool(6); %start pool


% Loop over all stages
for nstage = 1:4
    stgpath = [path filesep stages{nstage}];
    cd(stgpath);
    sub = dir;
    
%% Step 1 = .dcm to src
if step1 == true
    parfor participant = 3:length(sub) % loop over all participants
        input_path = [stgpath, filesep, sub(participant).name];
        openSourceImages_DSI_benj(input_path); % convert .dcm to .src
    end
end

%% Step 2 = Reconstruction
if step2 == true
    parfor participant = 3:length(sub) % loop over all participants
        src_path = [stgpath, filesep, sub(participant).name, filesep, 'src_DSIStudio'];
%         affine_path = [src_path, filesep, 'affine.txt']; % affine .txt matrix which should be inside the folder
%         t1_path = [];
        if method == '7' % when method is QSDR we add T1W image and affine matrix to the folder
            t1_dir = dir([src_path, filesep, 'w_tb*.nii']); t1_image = t1_dir.name; % T1W image which must be inside the folder
            affine_path = [src_path, filesep, 'affine.txt']; % affine .txt matrix which should be inside the folder
            reconstruction_DSI_benj(method, src_path, 'affine', affine_path, 't1', t1_image); % reconstruct image
        else
            reconstruction_DSI_benj(method, src_path); % reconstruct image
        end
    end
end

%% Step 3 = Fiber Tracking
if step3 == true
    image_name = 'output_src.*.fib.gz'; % choose which reconstructed image to use (ok to use partial name)

    parfor participant = 3:length(sub) % loop over all participants
    image_path = [stgpath, filesep, sub(participant).name, filesep, 'src_DSIStudio'];   
    fiberTracking_DSI_benj(image_path,image_name,fibers); % track all fibers per subject image
    end
end
end

%% Step 4 = Batch Statistics
% In this step all the fiber statistics from all the individual folders are
% combined into a table, to be exported to R for statistical analyses.
if step4 == true
    ThesisTable = cell(2000,50); %open table
    ThesisTable(1,1:31) = {'stage' 'patient' 'fiber' 'number of tracts' 'tract length mean(mm)' 'tract length sd(mm)' 'tracts volume (mm^3)' 'qa mean' 'qa sd' 'nqa mean' 'nqa sd' 'dti_fa mean' 'dti_fa sd' 'md mean' 'md sd' 'ad mean' 'ad sd' 'rd mean' 'rd sd' 'gfa mean' 'gfa sd' 'iso mean' 'iso sd' 'rdi mean' 'rdi sd' 'nrdi02L mean' 'nrdi02L sd' 'nrdi04L mean' 'nrdi04L sd' 'nrdi06L mean' 'nrdi06L sd'};
    jk=2; % line counter - each line for a fiber
    
    for nstage = 1:4 % loop per stage
        stgpath = [path filesep stages{nstage}];
        cd(stgpath);
        sub = dir; % sub of patients in stage
        
        for participant = 3:length(sub) % loop over all patients
            subpath = [stgpath, filesep, sub(participant).name, filesep, 'src_DSIStudio'];
            cd(subpath); % patient folder
            d = dir('*stat.txt'); % all stat.txt files (one for each fiber)
            for fib = 1:length(d) % loop for each fiber
                tempHold = importdata(d(fib).name,'\t'); % get data
                ThesisTable{jk,1} = stages{nstage}; % stage name
                ThesisTable{jk,2} = sub(participant).name; % patient name
                ThesisTable{jk,3} = d(fib).name([1 2]); % fiber number
                if length(tempHold.data) > 28
                tempHold.data(strcmp(tempHold.textdata, '(ind)')) = [];
                end
                ThesisTable(jk,4:31) = num2cell(tempHold.data'); % data
                
                jk = jk+1; % update counter
            end  
        end
    end
    
    % Saving the data as .mat and .xls files
    cd(path)
    DataName = ['ThesisTable_alldata' datestr(date)]; 
    save(DataName,'ThesisTable')
    xlswrite(DataName,ThesisTable)
end

%% End
delete(gcp('nocreate')) % end pool

