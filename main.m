NIFTI = 0;
VBM = 1; 
DBM = 1;
SBM = 1;
HC_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Control-T1/';%/media/veronica/DATAPART2/ACTEMOVI/Anat/Young/'; %'/media/veronica/DATAPART2/PPMI_Morpho_all/HC/';
PD_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/PD-T1/';%'/media/veronica/DATAPART2/ACTEMOVI/Anat/Old/'; %'/media/veronica/DATAPART2/PPMI_Morpho_all/PD/';

%% DICOM TO NIFTI CONVERSION 
% Usage of dcm2nii for all of the subjects in path, the anatomical scan is
% named 'Anat.nii'
% if (~NIFTI)
%     extractNorg(HC_path,1) % First argument : Path, second argument : delete dicoms after conversion ?
%     extractNorg(PD_path,1)
% end

%% SEGMENTATION
%  cat12segmentation(HC_path,DBM,SBM,1)
%  cat12segmentation(PD_path,DBM,SBM,1)

%% QUALITY CONTROL
file_to_control='mri/wmAnat.nii';
cat12quality_control(HC_path,file_to_control);
cat12quality_control(PD_path,file_to_control);

%% CHECK HOMOGENEITY
check_homogeneity(HC_path,'mri/mwp1Anat.nii');
check_homogeneity(PD_path,'mri/mwp1Anat.nii');

%% EXTRACT METADATA (COVARIATES)



%% SPECIFIC PROCESSING
% VBM 
% Smooth
cat12smooth(HC_path, 'mri/mwp1Anat.nii');
cat12smooth(PD_path, 'mri/mwp1Anat.nii');

cat12smooth(HC_path, 'mri/mwp2Anat.nii');
cat12smooth(PD_path, 'mri/mwp2Anat.nii');

% TIV estimation
cat12TIV_estimation(HC_path, 'TIV_Young.txt');
cat12TIV_estimation(PD_path, 'TIV_Old.txt');

% DBM
% Smooth
cat12smooth(HC_path, 'mri/wj_Anat.nii');
cat12smooth(PD_path, 'mri/wj_Anat.nii');

% SBM
cat12resampleNsmooth_surf(HC_path, 'surf/lh.thickness.Anat', 4);
cat12resampleNsmooth_surf(PD_path, 'surf/lh.thickness.Anat', 4);

cat12extract_lgi(HC_path, 'surf/lh.central.Anat.gii');
cat12extract_lgi(PD_path, 'surf/lh.central.Anat.gii');

cat12resampleNsmooth_surf(HC_path, 'surf/lh.gyrification.Anat', 4);
cat12resampleNsmooth_surf(PD_path, 'surf/lh.gyrification.Anat', 2);

cat12ROIsurf_values(HC_path, 'surf/lh.thickness.Anat');
cat12ROIsurf_values(PD_path, 'surf/lh.thickness.Anat');
cat12ROIsurf_values(HC_path, 'surf/lh.gyrification.Anat');
cat12ROIsurf_values(PD_path, 'surf/lh.gyrification.Anat');

cat12resampleNsmooth_surf(HC_path, 'surf/lh.sqrtsulc.Anat', 4);
cat12resampleNsmooth_surf(PD_path, 'surf/lh.sqrtsulc.Anat', 2);
cat12ROIsurf_values(HC_path, 'surf/lh.sqrtsulc.Anat');
cat12ROIsurf_values(PD_path, 'surf/lh.sqrtsulc.Anat');


%% STATISTICAL ANALYSIS
% Tailor csv with covariates
HC_file='/media/veronica/DATAPART2/ACTEMOVI/Young.csv';
A=readtable(HC_file);
Subj_dir = dir([HC_path '*']);
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
Subj_dir = dir([PD_path '*']);
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

% Stats
% HC_file='/media/veronica/DATAPART2/ACTEMOVI/Young_new.csv';
% PD_file='/media/veronica/DATAPART2/ACTEMOVI/Old_new.csv';

HC_file='/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_MNI_report.csv';
PD_file='/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/patient_MNI_report.csv';

cat12stats(HC_path, PD_path, HC_file, PD_file, 'DBM')

