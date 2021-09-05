function [] = fiberTracking_DSI_benj(image_path, image_name, fibers)

% DSI Studio - Tracking SUBJECT BY SUBJECT: Load .fib.gz file and track
% fibers using automatic fibers. Automatic fibers are done using the number
% conventions found in "HCP842_tractography.txt" included in the DSI Studio
% package under the atlas folder. Atlas also commented below.

%   Inputs:
%       image_path = path to the subject folder with the .fib.gz file.
%       image_name = name of the .fib.gz image to be used (in case there
%       are mutliple ones)
%       fibers = cell with numbers corrosponding to fibers, e.g. {'20','21'}

%   Outputs:
%       2 files for each fiber in the list (inside image_path folder):
%       a trk.gz file and fiber statistics in .txt format (additional
%       outputs such as nii.gz or other files can be easily added in the
%       export command below)

cd(image_path)
% mkdir('fibers');
% cd([image_path, filesep, 'fibers']);
image = dir(image_name);
cmd = [' --source=' image_path filesep image.name];

%% General Params
% to cange the param, change the value inside 2nd ''.
% e.g. cmd = [cmd ' --method' '0']; change the 0 only.

% Tracking params:
cmd = [cmd ' --method=' '0']; % tracking methods 0:streamline/deterministic (default), 1:rk4 
% cmd = [cmd ' --fiber_count=' '500']; % specify the number of fibers to be generated. If seed number is preferred, use seed_count instead. If DSI Studio cannot find a track connecting the ROI, then the program may run forever. To avoid this problem, you may assign fiber_count and seed_count at the same time so that DSI Studio can terminate if the seed count reaches a large number.
cmd = [cmd ' --seed_count=' '100000']; % specify the number of seeds so the program doesn't run forever.
% cmd = [cmd ' --fa_threshold=' '0.08']; % the threshold for fiber tracking. In QBI, DSI, and GQI, "fa_threshold" will be applied to QA threshold. To use other index as the threshold, add "threshold_index=[name of the index]" (e.g. "--threshold_index=nqa --fa_threshold=0.01" sets a threshold of 0.01 on nqa for tract termination). If fa_threshold  is not assigned, then the default Otsu's threshold will be used.
cmd = [cmd ' --otsu_threshold=' '0.6']; % The default Otsu's threshold can be adjusted to any ratio. The default value is 0.6.
cmd = [cmd ' --initial_dir=' '2']; % initial propagation direction 0:primary fiber (default), 1:random, 2:all fiber orientations
% cmd = [cmd ' --seed_plan=' '']; % specify the seeding strategy 0:subvoxel random (default) 1:voxelwise center
cmd = [cmd ' --interpolation=' '0']; % interpolation methods (0:trilinear, 1:gaussian radial, 2:nearest neighbor)
cmd = [cmd ' --thread_count=' '8']; % specify the thread count. 1 for single thread. 2 for two threads...
cmd = [cmd ' --random_seed=' '']; % specify whether a timer is used for generating seed points. Setting it on (--random_seed=1) will make tracking random. The default is off. 
cmd = [cmd ' --step_size=' '0.25']; % mm. default is the half of the spatial resolution
cmd = [cmd ' --turning_angle=' '60']; % degrees
cmd = [cmd ' --max_length=' '400']; % mm
cmd = [cmd ' --tip_iteration=' '1']; % Topology-Informed Pruning (number of iterations 0,1,2)
% step_size, turning_angle, interpo_angle, fa_threshold, smoothing, min_length, max_length: refer to tracking manual for detail. The step_size, min_length, and max_length are at a scale of a millimeter.

% Post Processing Params:
% cmd = [cmd ' --delete_repeat=' '1']; % assign the distance for removing repeat tracks (e.g. --delete_repeat=1 removes repeat tracks with distance smaller than 1 mm)
% cmd = [cmd ' --end_point=' '']; % output end point as a txt file or mat file. specify the file name using --end_point=file_name.txt
cmd = [cmd ' --export=' 'stat']; % export along tack indices, statistics, TDI, or track analysis report. See the export option documented under --action=ana for detail.
% cmd = [cmd ' --connectivity=' 'aal']; % output connectivity matrix using ROIs or atlas as the matrix entry. For example, "--connectivity=FreeSurferDKT" uses FreeSurferDKT atlas (there should be an FreeSurferDKT.nii.gz file under the /atlas folder) as the matrix entry to get the connectivity of the tracks. 
% cmd = [cmd ' --connectivity_type=' '']; % specify whether to use "pass" or "end" to count the tracks. The default setting is "end".
% cmd = [cmd ' --connectivity_value=' 'count,ncount,trk']; % specify the way to calculate the matrix value. The default is "count", which means the number of tracks passing/ending in the regions. "ncount" is the number of tracks normalized by the median length. "mean_length" outputs the mean length of the tracks. "trk" outputs a trk file each connectivity matrix entry. Other options include "fa" (if DTI reconstruction is used), "qa", "adc" (if DTI reconstruction is used). The name of the scalar values can be found by opening the FIB file in STEP fiber tracking. There will be a list of scalar value in the region window to the left. 
% cmd = [cmd ' --connectivity_threshold=' '']; % specify the threshold for calculating binarized graph measures and connectivity values. The default value is 0.001. This means if the maximum connectivity count is 1000 tracks in the connectivity matrix, then at least 1000 x 0.001 = 1 track is needed to pass the threshold. Otherwise, the values will be set to zero.
% cmd = [cmd ' --ref=' '']; % output track coordinate based on a reference image (e.g. T1w or T2w).

for ff = 1:length(fibers)
    cur_fib = fibers{ff};
    output_name = [cur_fib '.output.trk.gz'];
        
    system(['dsi_studio --action=trk' cmd ' --track_id=' cur_fib ' --output=' output_name]);
    
end

end



%% Automatic Fiber Number Conventions

% 0 Acoustic_Radiation_L
% 1 Acoustic_Radiation_R
% 2 Cortico_Striatal_Pathway_L
% 3 Cortico_Striatal_Pathway_R
% 4 Cortico_Spinal_Tract_L
% 5 Cortico_Spinal_Tract_R
% 6 Corticothalamic_Pathway_L
% 7 Corticothalamic_Pathway_R
% 8 Fornix_L
% 9 Fornix_R
% 10 Frontopontine_Tract_L
% 11 Frontopontine_Tract_R
% 12 Occipitopontine_Tract_L
% 13 Occipitopontine_Tract_R
% 14 Optic_Radiation_L
% 15 Optic_Radiation_R
% 16 Parietopontine_Tract_L
% 17 Parietopontine_Tract_R
% 18 Temporopontine_Tract_L
% 19 Temporopontine_Tract_R
% 20 Arcuate_Fasciculus_L
% 21 Arcuate_Fasciculus_R
% 22 Cingulum_L
% 23 Cingulum_R
% 24 Extreme_Capsule_L
% 25 Extreme_Capsule_R
% 26 Frontal_Aslant_Tract_L
% 27 Frontal_Aslant_Tract_R
% 28 Inferior_Fronto_Occipital_Fasciculus_L
% 29 Inferior_Fronto_Occipital_Fasciculus_R
% 30 Inferior_Longitudinal_Fasciculus_L
% 31 Inferior_Longitudinal_Fasciculus_R
% 32 Middle_Longitudinal_Fasciculus_L
% 33 Middle_Longitudinal_Fasciculus_R
% 34 Superior_Longitudinal_Fasciculus_L
% 35 Superior_Longitudinal_Fasciculus_R
% 36 U_Fiber_L
% 37 U_Fiber_R
% 38 Uncinate_Fasciculus_L
% 39 Uncinate_Fasciculus_R
% 40 Vertical_Occipital_Fasciculus_L
% 41 Vertical_Occipital_Fasciculus_R
% 42 Anterior_Commissure
% 43 Corpus_Callosum
% 44 Posterior_Commissure
% 45 Cerebellum_L
% 46 Cerebellum_R
% 47 Inferior_Cerebellar_Peduncle_L
% 48 Inferior_Cerebellar_Peduncle_R
% 49 Middle_Cerebellar_Peduncle
% 50 Superior_Cerebellar_Peduncle
% 51 Vermis
% 52 Central_Tegmental_Tract_L
% 53 Central_Tegmental_Tract_R
% 54 Dorsal_Longitudinal_Fasciculus_L
% 55 Dorsal_Longitudinal_Fasciculus_R
% 56 Lateral_Lemniscus_L
% 57 Lateral_Lemniscus_R
% 58 Medial_Lemniscus_L
% 59 Medial_Lemniscus_R
% 60 Medial_Longitudinal_Fasciculus_L
% 61 Medial_Longitudinal_Fasciculus_R
% 62 Rubrospinal_Tract_L
% 63 Rubrospinal_Tract_R
% 64 Spinothalamic_Tract_L
% 65 Spinothalamic_Tract_R
% 66 CNII_L
% 67 CNII_R
% 68 CNIII_L
% 69 CNIII_R
% 70 CNIV_L
% 71 CNIV_R
% 72 CNV_L
% 73 CNV_R
% 74 CNVII_L
% 75 CNVII_R
% 76 CNVIII_L
% 77 CNVIII_R
% 78 CNX_L
% 79 CNX_R