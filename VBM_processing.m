function VBM_processing(Path)

Subj_dir = dir([Path 'Control-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_report.csv');
liste_anat_c={};
for i = 1 : size(Subj_dir,1)
    report_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'report', 'cat_Anat.xml');
    tissue_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'mri', 'smwp1Anat.nii');
    
    if (exist(report_path, 'file')~=0) && (exist(tissue_path, 'file')~=0) && (~isempty(A(string(A.PatientID)==Subj_dir(i,1).name,:)))
        liste_anat_c{end+1}=report_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

Subj_dir = dir([Path 'PD-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/patient_report.csv');
liste_anat_p={};
for i = 1 : size(Subj_dir,1)
    report_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'report', 'cat_Anat.xml');
    tissue_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'mri', 'smwp1Anat.nii');
    
     if (exist(report_path, 'file')~=0) && (exist(tissue_path, 'file')~=0) && (~isempty(A(string(A.PatientID)==Subj_dir(i,1).name,:)))
        liste_anat_p{end+1}=report_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

spm_jobman('initcfg');
matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = [liste_anat_c'; liste_anat_p'];
matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 0;
matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = 'All_T1_TIV.txt';
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch
end