path = '/bcbl/home/public/Presurgical_Ileana/Benjamin_Thesis/DICOM_DTI/PacientesBatchTestOnly/pre';
% fibers = {'20','21','26','27','28','29','30','31','38','39','43'}; % List of numbers corrosponding to fiber according to convention. Look in end of fiberTracking_DSI_benj.m function

% stages for loop
%stages = {'pre','post1','post2','post3'};
%parpool(8); %start pool

image_name = 'output_src.*.fib.gz'; % choose which reconstructed image to use (ok to use partial name)
stgpath = path;

%for nstage = 1:4
%     stgpath = [path filesep stages{nstage}];
    cd(stgpath);
    sub = dir;
    
    for participant = 3:length(sub) % loop over all participants
        image_path = [stgpath, filesep, sub(participant).name, filesep, 'src_DSIStudio'];
        cd(image_path)
        image = dir(image_name);
        
        fiberzz = dir('*.output.trk.gz');
        
        for ff = 1:length(fiberzz)
            cur_fib = fiberzz(ff).name;
            output_name = [cur_fib(1:2) '.jpg"'];
            
            if  sum(strcmp(cur_fib(1:2), {'20','26','28','30','38'})) > 0 % left fiber
                system(['dsi_studio --action=vis --source=' image.name...
                    ' --track=' cur_fib ' --cmd="set_view,0+save_image,' output_name]); % left view
                
            elseif  sum(strcmp(cur_fib(1:2), {'21','27','29','31','39'})) > 0 % right fiber
                system(['dsi_studio --action=vis --source=' image.name...
                    ' --track=' cur_fib ' --cmd="set_view,0+set_view,0+save_image,' output_name]); % right view
                
            elseif sum(strcmp(cur_fib(1:2), {'43'})) > 0 % CC
                system(['dsi_studio --action=vis --source=' image.name...
                    ' --track=' cur_fib ' --cmd="set_view,2+set_view,2+save_image,' output_name]); % top view
            end
        end
    end
% end

delete(gcp('nocreate')) % end pool