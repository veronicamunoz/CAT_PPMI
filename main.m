%--------------------------------------------------------------------------
%
%            CAT12 NEUROMORPHOMETRIC IMPLEMENTATION PIPELINE
%                    Veronica Munoz Ramirez 2019      
%
%   Used for MEDINFO conference paper DOI: 10.3233/SHTI190225
%   Built from CAT12 manual: dbm.neuro.uni-jena.de/cat12/CAT12-Manual.pdf
%
%   PARAMS : 
%       NIFTI: Are your images already in Nifti format ? [1:yes, 0:no]. If
%       not DICOM to NIFTI conversion will take place
%       DBM : Do you want to do deformation-based analysis ? [1:yes, 0:no]
%       SMB : Do you want to do surface-based analysis ? [1:yes, 0:no]. If
%       both DBM=SBM=0 only VBM will be possible.
%       Path1 and Path2: Paths with the subject folders for the first and
%       second population
%
%--------------------------------------------------------------------------

NIFTI = 1;
DBM = 1; 
SBM = 1; 
Path1 = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Control-T1/'; 
Path2 = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/PD-T1/'; 

%% DICOM TO NIFTI CONVERSION 
% Usage of dcm2nii for all of the subjects in path, the anatomical scan is named 'Anat.nii'
if (~NIFTI)
    extractNorg(Path1,1) % 1st argument : Path, 2nd argument : delete dicoms after conversion ?
    extractNorg(Path2,1)
end

%% SEGMENTATION
% Brain segmentation using SPM/CAT12 functions
cat12segmentation(Path1,DBM,SBM,2) % 1st : Path to files, 2 and 3rd: defined above, 4th: How many simultaneous processes ? 
cat12segmentation(Path2,DBM,SBM,2)

%% QUALITY CONTROL
% Display of all subjects from the population for quality control in one
% image
file_to_control='mri/wmAnat.nii';
slice = 125; % Slice to display
cat12quality_control(Path1,file_to_control,slice);
cat12quality_control(Path2,file_to_control,slice);

%% CHECK HOMOGENEITY
% 
check_homogeneity(Path1,'mri/mwp1Anat.nii');
check_homogeneity(Path2,'mri/mwp1Anat.nii');

%% SPECIFIC PROCESSING
%%% VBM 
% Smooth
cat12smooth(Path1, 'mri/mwp1Anat.nii');
cat12smooth(Path2, 'mri/mwp1Anat.nii');

cat12smooth(Path1, 'mri/mwp2Anat.nii');
cat12smooth(Path2, 'mri/mwp2Anat.nii');

% TIV estimation
cat12TIV_estimation(Path1, 'Control_TIV.txt');
cat12TIV_estimation(Path2, 'PD_TIV.txt');

%%% DBM
% Smooth
cat12smooth(Path1, 'mri/wj_Anat.nii');
cat12smooth(Path2, 'mri/wj_Anat.nii');

%%% SBM
cat12resampleNsmooth_surf(Path1, 'surf/lh.thickness.Anat', 4);
cat12resampleNsmooth_surf(Path2, 'surf/lh.thickness.Anat', 4);

cat12extract_lgi(Path1, 'surf/lh.central.Anat.gii');
cat12extract_lgi(Path2, 'surf/lh.central.Anat.gii');

cat12resampleNsmooth_surf(Path1, 'surf/lh.gyrification.Anat', 4);
cat12resampleNsmooth_surf(Path2, 'surf/lh.gyrification.Anat', 2);

cat12ROIsurf_values(Path1, 'surf/lh.thickness.Anat');
cat12ROIsurf_values(Path2, 'surf/lh.thickness.Anat');
cat12ROIsurf_values(Path1, 'surf/lh.gyrification.Anat');
cat12ROIsurf_values(Path2, 'surf/lh.gyrification.Anat');

cat12resampleNsmooth_surf(Path1, 'surf/lh.sqrtsulc.Anat', 4);
cat12resampleNsmooth_surf(Path2, 'surf/lh.sqrtsulc.Anat', 2);
cat12ROIsurf_values(Path1, 'surf/lh.sqrtsulc.Anat');
cat12ROIsurf_values(Path2, 'surf/lh.sqrtsulc.Anat');


%% Tailor csv with covariates for statistical analysis
% Construct a CSV file with the transcranial volumes corresponding to each
% subject in the study
HC_file='/media/veronica/DATAPART2/ACTEMOVI/Young.csv';
A=readtable(HC_file);
Subj_dir = dir([Path1 '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));

for i = 1 : size(A.SUBJECT,1)
    folder_path=fullfile(Subj_dir(i,1).folder, char(string(A.SUBJECT(i))));
    
    if (exist(folder_path, 'dir')==0)
        A(A.SUBJECT==A.SUBJECT(i),:)=[]
    end
end

TIV_HC=readtable('/media/veronica/DATAPART2/ACTEMOVI/TIV_Young.txt');
TIV_HC.Properties.VariableNames(1)={'TIV'};

writetable([A TIV_HC(:,1)],'/media/veronica/DATAPART2/ACTEMOVI/Young_new.csv')

PD_file='/media/veronica/DATAPART2/ACTEMOVI/Old.csv';
A=readtable(PD_file);
Subj_dir = dir([Path2 '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_vide={};

for i = 1 : size(A.SUBJECT,1)
    folder_path=fullfile(Subj_dir(1,1).folder, char(string(A.SUBJECT(i))));
  
    if (exist(folder_path, 'dir')==0)
       liste_vide{end+1}=A.SUBJECT(i);
    end
end

for j = 1 : size(liste_vide,2)
 A(A.SUBJECT==liste_vide{j},:)=[];
end

TIV_PD=readtable('/media/veronica/DATAPART2/ACTEMOVI/TIV_Old.txt');
TIV_PD.Properties.VariableNames(1)={'TIV'};

writetable([A TIV_PD(:,1)],'/media/veronica/DATAPART2/ACTEMOVI/Old_new.csv')

%% STATISTICAL ANALYSIS
% HC_file='/media/veronica/DATAPART2/ACTEMOVI/Young_new.csv';
% PD_file='/media/veronica/DATAPART2/ACTEMOVI/Old_new.csv';

% Covariate file 
HC_file='/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_MNI_report.csv';
PD_file='/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/patient_MNI_report.csv';

cat12stats(Path1, Path2, HC_file, PD_file, 'DBM')

% This is the one pass statistical alternative, an iterative analysis is
% also possible (see iterative_analysis.m)