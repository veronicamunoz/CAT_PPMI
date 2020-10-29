function DBM_processing(Path)

%% Smooth
% Anat_path = '/home/veronica/Donnees/Volumetrie_PPMI/masques_PPMI_MNI/wm/';
% Subj_dir = dir([Anat_path '*']);
% Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
% liste_anat={};
% for i = 1 : size(Subj_dir,1)
%     folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name);
%     liste_anat{end+1}=folder_path;
% end

Subj_dir = dir([Anat_path 'Control-T1/' '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat_c={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'mri', 'wj_Anat.nii');
    if (exist(folder_path, 'file')~=0)
    liste_anat_c{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

% Subj_dir = dir([Anat_path 'PD-T1/' '*']);
% Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
% liste_anat_p={};
% for i = 1 : size(Subj_dir,1)
%     folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'mri', 'wj_Anat.nii');
%     if (exist(folder_path, 'file')~=0)
%     liste_anat_p{end+1}=folder_path;
%     else
%         disp(Subj_dir(i,1).name);
%     end
% end

spm_jobman('initcfg');
matlabbatch{1}.spm.spatial.smooth.data = [liste_anat_c'; liste_anat_p'];%liste_anat';%
matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

%% CAT12
%% Ecriture du tableau avec l'id, l'age, le sex et le volume intra-crânien
Control_folder = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Control-T1';
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_report.csv');

for i = 1 : size(A,1)
    tissue_path=fullfile(Control_folder, char(string(A.PatientID(i))), 'mri', 'swj_Anat.nii');
    if (~exist(tissue_path, 'file')~=0)
        disp(A.PatientID(i));
        %A(i,:)=[];
    end
end

n=0;
Subj_dir = dir([Control_folder '/*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'mri', 'swj_Anat.nii');
    if (exist(folder_path, 'file')~=0)
        n=n+1;
        if isempty(A(string(A.PatientID)==Subj_dir(i,1).name,:))
            disp(Subj_dir(i,1).name);
            
        end
    end
end

Patient_folder = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/PD-T1';
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/patient_report.csv');

for i = 1 : size(A,1)
    tissue_path=fullfile(Patient_folder, char(string(A.PatientID(i))), 'mri', 'swj_Anat.nii');
    if (~exist(tissue_path, 'file')~=0)
        disp(A.PatientID(i));
        %A(i,:)=[];
    end
end


%% volBRAIN
%% Ecriture du tableau avec l'id, l'age, le sex et le volume intra-crânien 
% A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_report.csv');
% name_c=A.PatientID;
% age_c=A.Age;
% sex_c=string(A.Sex);

A=readtable('/home/veronica/Donnees/Volumetrie_PPMI/report_PPMI/patient_report.csv');
name_p=A.PatientID;
age_p=A.Age;
sex_p=string(A.Sex);

tiv_c={};
for i = 1 : size(name_c,1)
    folder_path=fullfile('/home/veronica/Donnees/Volumetrie_PPMI/masques_PPMI_MNI/tiv',strcat('mask_n_mmni_f', char(string(name_c(i))), '.nii'));
    if (exist(folder_path, 'file')~=0)
        iv=niftiread(folder_path);
        tiv_c{end+1}=size(iv(iv~=0),1);
    else
        disp(name_c(i));
    end
end

tiv_p={};
for i = 1 : size(name_p,1)
    folder_path=fullfile('/home/veronica/Donnees/Volumetrie_PPMI/masques_PPMI_MNI/tiv',strcat('mask_n_mmni_f', char(string(name_p(i))), '.nii'));
    if (exist(folder_path, 'file')~=0)
        iv=niftiread(folder_path);
        tiv_p{end+1}=size(iv(iv~=0),1);
    else
        disp(name_p(i));
    end
end

t2={'PatientID', 'Age', 'Sex', 'TIVmm3'};
commaHeader = [t2;repmat({','},1,numel(t2))]; %insert commaas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas
T=[name_p age_p sex_p cell2mat(tiv_p')];  
T=T';
% %write header to file
fid = fopen('/home/veronica/Donnees/Volumetrie_PPMI/report_PPMI/patient_MNI_report.csv','w'); 
fprintf(fid,'%s\n',textHeader);
fprintf(fid,'%s,%s,%s,%s\n', T(:,:));
fclose(fid);



%% Statistical Analysis
A=readtable('/home/veronica/Donnees/Volumetrie_PPMI/report_PPMI/control_MNI_report.csv');
name_c=A.PatientID;
age_c=A.Age;
sex_c=double(contains(A.Sex, 'Male'));
A=readtable('/home/veronica/Donnees/Volumetrie_PPMI/report_PPMI/patient_MNI_report.csv');
name_p=A.PatientID;
age_p=A.Age;
sex_p=double(contains(A.Sex, 'Male'));
T=readtable('/home/veronica/Donnees/PPMI/All_T1_TIV.txt');
TIV=T{:,1};

% liste_anat_c={};
% for i = 1 : size(name_c,1)
%     folder_path=fullfile('/home/veronica/Donnees/Volumetrie_PPMI/masques_PPMI_DARTEL/gm_struct_volbrain',strcat('sdwm_native_f', char(string(name_c(i))), '.nii'));
%     if (exist(folder_path, 'file')~=0)
%         liste_anat_c{end+1}=folder_path;
%     else
%         disp(name_c(i));
%     end
% end
% 
% liste_anat_p={};
% for i = 1 : size(name_p,1)
%     folder_path=fullfile('/home/veronica/Donnees/Volumetrie_PPMI/masques_PPMI_DARTEL/gm_struct_volbrain',strcat('sdwm_native_f', char(string(name_p(i))), '.nii'));
%     if (exist(folder_path, 'file')~=0)
%         liste_anat_p{end+1}=folder_path;
%     else
%         disp(name_p(i));
%     end
% end

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
    folder_path=fullfile(Control_path, char(string(name_c(i))), 'mri', 'swj_Anat.nii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

Patient_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/PD-T1/';
liste_anat_p={};
for i = 1 : size(name_p,1)
    folder_path=fullfile(Patient_path, char(string(name_p(i))), 'mri', 'swj_Anat.nii');
    if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat/')
mkdir('GM_DBM_CAT');
cd(strcat('./','GM_DBM_CAT'));

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
matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/usr/local/MATLAB/spm12/tpm/mask_ICV.nii,1'};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
% matlabbatch{2}.spm.tools.cat.tools.check_SPM.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
% matlabbatch{2}.spm.tools.cat.tools.check_SPM.check_SPM_cov.do_check_cov.use_unsmoothed_data = 1;
% matlabbatch{2}.spm.tools.cat.tools.check_SPM.check_SPM_cov.do_check_cov.adjust_data = 1;
% matlabbatch{2}.spm.tools.cat.tools.check_SPM.check_SPM_ortho = 1;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

%% Estimate model
spm_jobman('initcfg');
matlabbatch{1}.spm.stats.fmri_est.spmmat = {'./SPM.mat'};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

end