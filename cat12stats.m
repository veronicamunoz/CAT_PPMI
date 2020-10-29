function cat12stats(Path1, Path2, File1, File2, Type)

A=readtable(File1);
name_1=A.PatientID;%SUBJECT;
age_1=A.Age;%AGE;
%sex_1=double(contains(A.SEX, 'H'));
sex_1=double(contains(A.Sex, 'Male'));
%man_1=strcmp(A.MANUFACTURER, 'GE MEDICAL SYSTEMS') + 2*strcmp(A.MANUFACTURER, 'Philips Medical Systems') + 3*strcmp(A.MANUFACTURER, 'SIEMENS');
TIV_1=A.TIVmm3;
A=readtable(File2);
name_2=A.PatientID;
age_2=A.Age;
%sex_2=double(contains(A.SEX, 'H'));
sex_2=double(contains(A.Sex, 'Male'));
%man_2=strcmp(A.MANUFACTURER, 'GE MEDICAL SYSTEMS') + 2*strcmp(A.MANUFACTURER, 'Philips Medical Systems') + 3*strcmp(A.MANUFACTURER, 'SIEMENS');
TIV_2=A.TIVmm3;

%T=readtable('/home/veronica/Donnees/PPMI/All_T1_TIV.txt');
%TIV=T{:,1};

if (Type == 'VBM')
    
    liste_anat1={};
    for i = 1 : size(name_1,1)
        folder_path=fullfile(Path1, char(string(name_1(i))), 'mri', 'smwp1Anat.nii');
        if (exist(folder_path, 'file')~=0)
            liste_anat1{end+1}=folder_path;
        else
            disp(char(string(name_1(i))));
        end
    end

    liste_anat2={};
    for i = 1 : size(name_2,1)
        folder_path=fullfile(Path2, char(string(name_2(i))), 'mri', 'smwp1Anat.nii');
        if (exist(folder_path, 'file')~=0)
            liste_anat2{end+1}=folder_path;
        else
            disp(char(string(name_2(i))));
        end
    end
    
    cd('/media/veronica/DATAPART2/ACTEMOVI/Stat/')
    mkdir(Type);
    cd(strcat('./',Type));
    
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {pwd};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = liste_anat1';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = liste_anat2';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [age_1;age_2];
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Age';
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [sex_1;sex_2];
    matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Sex';
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [TIV_1;TIV_2];
    matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'TIV';
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/usr/local/MATLAB/spm12/tpm/mask_ICV.nii,1'};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
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


if (Type == 'DBM')
    
    liste_anat1={};
    for i = 1 : size(name_1,1)
        folder_path=fullfile(Path1, char(string(name_1(i))), 'mri', 'swj_Anat.nii');
        if (exist(folder_path, 'file')~=0)
            liste_anat1{end+1}=folder_path;
        else
            disp(char(string(name_1(i))));
        end
    end

    liste_anat2={};
    for i = 1 : size(name_2,1)
        folder_path=fullfile(Path2, char(string(name_2(i))), 'mri', 'swj_Anat.nii');
        if (exist(folder_path, 'file')~=0)
            liste_anat2{end+1}=folder_path;
        else
            disp(char(string(name_2(i))));
        end
    end
    
%     cd('/media/veronica/DATAPART2/ACTEMOVI/Stat/')
%     mkdir(Type);
%     cd(strcat('./',Type));
    
    spm_jobman('initcfg');
    matlabbatch{1}.spm.stats.factorial_design.dir = {pwd};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = liste_anat1';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = liste_anat2';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [age_1;age_2];
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Age';
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(2).c = [sex_1;sex_2];
%     matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'Sex';
%     matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).c = [man_1;man_2];
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'Manufacturer';
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {'/usr/local/MATLAB/spm12/tpm/mask_ICV.nii,1'};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
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


if (Type == 'SBM')
    
    liste_anat1={};
    disp('Group 1')
    for i = 1 : size(name_1,1)
        folder_path=fullfile(Path1, char(string(name_1(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
        if (exist(folder_path, 'file')~=0)
            liste_anat1{end+1}=folder_path;
        else
            disp(char(string(name_1(i))));
        end
    end

    liste_anat2={};
    disp('Group 2')
    for i = 1 : size(name_2,1)
        folder_path=fullfile(Path2, char(string(name_2(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
        if (exist(folder_path, 'file')~=0)
            liste_anat2{end+1}=folder_path;
        else
            disp(char(string(name_2(i))));
        end
    end
    
    cd('/media/veronica/DATAPART2/ACTEMOVI/Stat/')
    mkdir(Type);
    cd(strcat('./',Type));
    
    spm_jobman('initcfg');
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {pwd};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = liste_anat1';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = liste_anat2';
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [age_1;age_2];
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Age';
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [sex_1;sex_2];
    matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'Sex';
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).c = [man_1;man_2];
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'Manufacturer';
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
%     matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 1;
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
    
    %% Estimate model
%     spm_jobman('initcfg');
%     matlabbatch{1}.spm.stats.fmri_est.spmmat = {'./SPM.mat'};
%     matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
%     matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
%     spm('defaults', 'FMRI');
%     spm_jobman('run', matlabbatch);
%     clear matlabbatch
end

    
end