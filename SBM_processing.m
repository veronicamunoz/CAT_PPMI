function SBM_processing(Path)

%% Resample and Smooth surfaces
Anat_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/';
Subj_dir = dir([Anat_path 'Control-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat_c={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'surf', 'lh.thickness.Anat');
    if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

Subj_dir = dir([Anat_path 'PD-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat_p={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'surf', 'lh.thickness.Anat');
    if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

spm_jobman('initcfg');
matlabbatch{1}.spm.tools.cat.stools.surfresamp.data_surf = [liste_anat_c'; liste_anat_p'];
matlabbatch{1}.spm.tools.cat.stools.surfresamp.merge_hemi = 1;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.mesh32k = 1;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.fwhm_surf = 15;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.nproc = 4;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

%% Extract optional surface parameters

Anat_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/';
Subj_dir = dir([Anat_path 'Control-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat_c={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'surf', 'lh.central.Anat.gii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

Subj_dir = dir([Anat_path 'PD-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat_p={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'surf', 'lh.central.Anat.gii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

spm_jobman('initcfg');
matlabbatch{1}.spm.tools.cat.stools.surfextract.data_surf = [liste_anat_c'; liste_anat_p'];
matlabbatch{1}.spm.tools.cat.stools.surfextract.GI = 1;
matlabbatch{1}.spm.tools.cat.stools.surfextract.FD = 0;
matlabbatch{1}.spm.tools.cat.stools.surfextract.SD = 1;
matlabbatch{1}.spm.tools.cat.stools.surfextract.nproc = 4;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

%% Statistical analysis

A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_report.csv');
name_c=A.PatientID;
age_c=A.Age;
sex_c=double(contains(A.Sex, 'Male'));
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/patient_report.csv');
name_p=A.PatientID;
age_p=A.Age;
sex_p=double(contains(A.Sex, 'Male'));
T=readtable('/home/veronica/Donnees/PPMI/All_T1_TIV.txt');
TIV=T{:,1};

Control_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Control-T1/';
liste_anat_c={};
for i = 1 : size(name_c,1)
    folder_path=fullfile(Control_path, char(string(name_c(i))), 'surf', 's15.mesh.thickness.resampled_32k.Anat.gii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

Patient_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/PD-T1/';
liste_anat_p={};
for i = 1 : size(name_p,1)
    folder_path=fullfile(Patient_path, char(string(name_p(i))), 'surf', 's15.mesh.thickness.resampled_32k.Anat.gii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat/')
mkdir('SBM_CAT');
cd(strcat('./','SBM_CAT'));

spm_jobman('initcfg');

matlabbatch{1}.spm.stats.factorial_design.dir = {pwd};
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = liste_anat_c';
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = liste_anat_p';
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [age_c;age_p];
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Age';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [sex_c;sex_p];
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'Sex';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

%% Resample and Smooth surfaces GI
Anat_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/';
Subj_dir = dir([Anat_path 'Control-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat_c={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'surf', 'lh.gyrification.Anat');
    if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

Subj_dir = dir([Anat_path 'PD-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat_p={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'surf', 'lh.gyrification.Anat');
    if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

spm_jobman('initcfg');
matlabbatch{1}.spm.tools.cat.stools.surfresamp.data_surf = [liste_anat_c'; liste_anat_p'];
matlabbatch{1}.spm.tools.cat.stools.surfresamp.merge_hemi = 1;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.mesh32k = 1;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.fwhm_surf = 20;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.nproc = 4;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

%% Statistical analysis GI

A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_report.csv');
name_c=A.PatientID;
age_c=A.Age;
sex_c=double(contains(A.Sex, 'Male'));
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/patient_report.csv');
name_p=A.PatientID;
age_p=A.Age;
sex_p=double(contains(A.Sex, 'Male'));
T=readtable('/home/veronica/Donnees/PPMI/All_T1_TIV.txt');
TIV=T{:,1};

Control_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Control-T1/';
liste_anat_c={};
for i = 1 : size(name_c,1)
    folder_path=fullfile(Control_path, char(string(name_c(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

Patient_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/PD-T1/';
liste_anat_p={};
for i = 1 : size(name_p,1)
    folder_path=fullfile(Patient_path, char(string(name_p(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat/')
mkdir('SBM_CAT_gi');
cd(strcat('./','SBM_CAT_gi'));

spm_jobman('initcfg');

matlabbatch{1}.spm.stats.factorial_design.dir = {pwd};
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = liste_anat_c';
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = liste_anat_p';
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [age_c;age_p];
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Age';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [sex_c;sex_p];
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'Sex';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

end