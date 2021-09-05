function [] = reconstruction_DSI_benj(method, src_path, varargin)

% DSI Studio - IMAGE RECONSTRUCTION: Load .src file and reconstruct image
% parameters can be changed manually inside the function. Default
% parameters are taken from DSI Studio website recommendations.

%   Inputs:
%       method = '0'=DSI, '1'=DTI, '4'=GQI, '7'=QSDR. Explanations on each
%       method provided below afte END.
%       src_path = path to subject folder with .src file inside.
%       {'affine', affine_path} = only if an affine matrix is used. Make
%       sure it is a 3x4 transformation matrix .txt file. 
%       {'t1', t1_name} = only if wrapping QSDR with t1W image.

%   Output: reconstructed image in the same folder as the .src file


cd(src_path)
src_file = 'output_src.src.gz';
cmd = [' --source=' src_file ' --method=' method];
    
%% General params (Method-Specific params below)
% to cange the param, change the value inside 2nd ''.
% e.g. cmd = [cmd ' --param2' '0']; change the 0 only.

if ~isempty(contains(varargin, 'affine'))
    c = contains(varargin, 'affine');
    cmd = [cmd ' --affine=' varargin{c+1}];
end
% cmd = [cmd ' --check_btable=' ''];  % set "--check_btable=0" to disable automatic b-table flipping
% cmd = [cmd ' --decomposition=' '1']; % set "--decomposition=1" to apply decomposition. Use --param3=0.05 to assign the decomposition fraction and --param4=10 to assign the m value
% cmd = [cmd ' --deconvolution=' '1']; % set "--deconvolution=1" to apply deconvolution. Use --param2=0.5 to assign the regularization parameter
% cmd = [cmd ' --mask=' '']; % assign the mask file in nifti format. You may skip this parameter to use the default mask
% cmd = [cmd ' --num_fiber=' '5']; % the maximum count of the resolving fibers for each voxel, default=5
% cmd = [cmd ' --odf_order=' '8']; % assign the tesellation number of the odf. Supported values include 4, 5, 6, 8, 10, 12, 16, 20. The default value is 8.
% cmd = [cmd ' --other_src=' '']; % assign the src file for correcting the phase distortion (e.g. --source=PA_scan.src.gz --other_src=AP_scan.src.gz). It does not matter whether the other src is AP or PA
% cmd = [cmd ' --param2=' '0.5']; % regularization parameter for doconvolution
% cmd = [cmd ' --param3=' '']; % composition value for decomposition
% cmd = [cmd ' --param4=' '']; % m value for decomposition
% cmd = [cmd ' --record_odf=' '1']; % set "--record_odf=1" to output the ODF for connectometry analysis
% cmd = [cmd ' --rotate_to=' '']; % specify a T1W or T1W to rotate DWI to its space.
% cmd = [cmd ' --scheme_balance=' '']; % set "--scheme_balance=1" to enable scheme balance
% cmd = [cmd ' --t1=' full_template_file_path]; % specify a different template file for spatial normalization
cmd = [cmd ' --thread_count=' '16']; % number of multi-thread used to conduct reconstruction


%% Methods specific params
% Any change in commented parameters must be also added in the appropriate
% "system" commands.

switch method
    case '0' % DSI
        cmd = [cmd ' --param0=' '1.25']; % width of the hanning filter 
        
%         system(['dsi_studio.exe --action=rec --source=' src_file ' --method=' method ...
%             ' --param0=' param0 ' --deconvolution=' deconvolution ' --record_odf=' record_odf ...
%             ' --param2=' param2 ' --thread_count=' thread_count ' --affine=' affine_per]);
    
    case '1' % DTI
        cmd = [cmd ' --motion_correction=' '1'];  % set "--motion_correction=1" to apply motion and eddy current correction. This correction works only on DTI dataset
        cmd = [cmd ' --output_dif=' '1']; % used in DTI to output diffusivity (default is 1)
        cmd = [cmd ' --output_tensor=' '1']; % used in DTI to output the whole tensor
        
%         system(['dsi_studio.exe --action=rec --source=' src_file ' --method=' method ...
%             ' --deconvolution=' deconvolution ' --record_odf=' record_odf ...
%             ' --motion_correction=' motion_correction ' --output_dif=' output_dif ...
%             ' --output_tensor=' output_tensor ' --thread_count=' thread_count ...
%             ' --param2=' param2 ' --affine=' affine_per]);

    case '4' % GQI
%         cmd = [cmd ' --output_rdi=' '1']; % used in GQI to output restricted diffusion imaging
        cmd = [cmd ' --param0=' '1.5']; % ratio of the mean diffusion distance
        cmd = [cmd ' --csf_calibration=' '1']; % set "--csf_calibration=1" to enable CSF calibration in GQI
%         cmd = [cmd ' --r2weighted=' '1']; % set "--r2_weighted=1" to apply r2-weighted GQI reconstruction
 
% %         system(['dsi_studio.exe --action=rec --source=' src_file ' --method=' method ...
% %             ' --param0=' param0 ' --deconvolution=' deconvolution ' --record_odf=' record_odf ...
% %             ' --param2=' param2 ' --r3weighted=' r2weighted ' --thread_count=' thread_count]);
% %         
    case '7' % QSDR
        cmd = [cmd ' --interpo_method=' '0']; % assign the interpolation method used in QSDR. 0:trilinear 1:gaussian radial basis 2: tricubic interpolation
        if ~isempty(contains(varargin, 't1'))
            t = contains(varargin, 't1');
            cmd = [cmd ' --other_image=t1w,' varargin{t+1}]; % assign other image volumes (e.g., T1W, T2W image) to be wrapped with QSDR
        end
        cmd = [cmd ' --output_jac=' '1']; % used in QSDR to output jacobian determinant
        cmd = [cmd ' --output_mapping=' '1']; % used in QSDR to output mapping for each voxel
        cmd = [cmd ' --param0=' '1.25']; % mean diffusion distance ratio

%         system(['dsi_studio.exe --action=rec --source=' src_file ' --method=' method ...
%             ' --deconvolution=' deconvolution ' --record_odf=' record_odf ...
%             ' --interpo_method=' interpo_method ' --output_jac=' output_jac ...
%             ' --output_mapping=' output_mapping ' --thread_count=' thread_count ...
%             ' --param0=' param0 ' --param2=' param2 ' --affine=' affine_per]);
        
end

system(['dsi_studio.exe --action=rec' cmd]);

end

%% Short Explanations for Methods:

% Diffustion Spectrum Imaging (DSI) ('0')
    % DSI uses Fourier transformation and numerical integration to
    % calculate the orientation distribution function (ODF, which is the
    % empirical distribution of water diffusion at different orientations)
    % of water diffusion. The Fourier transform requires a specific grid
    % diffusion sampling scheme (multiple b-values multiple directions).

% Diffusion Tensor Imaging (DTI) ('1')
    % The DTI was proposed by Basser et.al. [1]. It is able to characterize
    % the major diffusion direction of the fiber in human brains. The
    % reconstruction performs eigenanalysis on the calculated tensor, and
    % the indices such as FA, MD (in 10-3 mm2/s), and three eigenvalues are
    % also exported.
    
% Generalized Q-sampling Imaging (GQI) ('4')
    % Generalized q-sampling imaging (GQI) is a model-free reconstruction
    % method that quantifies the density of diffusing water at different
    % orientations. This measurement, termed spin distribution function
    % (SDF), is an orientation distribution function of diffusing spins.
    % Studies have shown its greater sensitivity and specificity to white
    % matter characteristics and pathology. GQI can calculate SDF from a
    % variety of diffusion data sets, including DSI dataset, HARDI,
    % multiple-shell, combined DTI dataset or even body center cubic (BCC)
    % dataset.

% Q-space diffeormophic reconstruction (QSDR) ('7')
    % Q-Space diffeomorphic reconstruction (QSDR) [11] is the
    % generalization of GQI that allows users to construct spin
    % distribution functions (SDFs, a kind of ODF) in any given template
    % space (e.g. MNI space). By reconstructing SDFs in the template space,
    % QSDR provides a direct way to analyze the group difference (see Group
    % connectometry analysis). QSDR can be applied to DTI data, multi-shell
    % data, DSI data, none-shell-none-grid data, or a combination of the
    % above-mentioned data sets. In QSDR, DSI Studio first calculates the
    % quantitative anisotropy (QA) mapping in the native space and then
    % normalizes it to the MNI QA map. QSDR also records the R-squared
    % value between the subject QA and MNI QA map in the filename (e.g.
    % .R72.fib.gz means a R-squared value of 0.72). A value greater than
    % 0.6 suggests good registration results, whereas a low value may
    % indicate a possible error in the registration. The most common cause
    % for low R2 value is a flipping of the slice order at the Z direction,
    % which causes the brain volume to be placed upside down. This can be
    % corrected using the [Edit][Flip z] function provided in the
    % reconstruction window. The QSDR reconstruction requires the
    % assignment of a template (e.g. human, monkey, rat, mouse).