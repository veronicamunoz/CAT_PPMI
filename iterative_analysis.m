%--------------------------------------------------------------------------
%
%            CAT12 NEUROMORPHOMETRIC IMPLEMENTATION PIPELINE
%                    Veronica Munoz Ramirez 2019      
%
%   Used for MEDINFO conference paper DOI: 10.3233/SHTI190225
%   Built from CAT12 manual: dbm.neuro.uni-jena.de/cat12/CAT12-Manual.pdf
%
%--------------------------------------------------------------------------

% Subj_dir = dir(['/media/veronica/Disk_5/Donnees/Volumetrie_PPMI/masques_PPMI_DARTEL/gm_volbrain/' 'd*']);
% Subj_dir = dir(['/media/veronica/Disk_5/Donnees/Volumetrie_PPMI/masques_PPMI_DARTEL/wm_volbrain/' 'd*']);
% Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
% liste_anat_p={};
% for i = 1 : size(Subj_dir,1)
%     liste_anat_p{end+1}=[Subj_dir(1,1).folder '/' Subj_dir(1,1).name];
% end
% spm_jobman('initcfg');
% matlabbatch{1}.spm.tools.cat.tools.showslice.data_vol = [liste_anat_p'];
% matlabbatch{1}.spm.tools.cat.tools.showslice.scale = 0;
% matlabbatch{1}.spm.tools.cat.tools.showslice.orient = 3;
% matlabbatch{1}.spm.tools.cat.tools.showslice.slice = 125;
% 
% spm('defaults', 'FMRI');
% spm_jobman('run', matlabbatch);
% clear matlabbatch


%% Statistical Analysis
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/control_MNI_report.csv');
name_c=A.PatientID;
age_c=A.Age;
sex_c=double(contains(A.Sex, 'Male'));
TIV_c=A.TIVmm3;
A=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/report_PPMI/patient_MNI_report.csv');
name_p=A.PatientID;
age_po=A.Age;
sex_po=double(contains(A.Sex, 'Male'));
TIV_po=A.TIVmm3;
T=readtable('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/All_T1_TIV.txt');
TIVo=T{:,1};

mean_age={};
var_age={};
men={};
Y={};

for k=1:5
    y=randsample(size(name_p,1),66);
    % %TIV_vol=[TIVo(1:66);TIVo(y+66)];
    TIV_p=TIV_po(y);
    age_p=age_po(y);
    sex_p=sex_po(y);

    Y{end+1}=y;
    mean_age{end+1}=mean(age_p);
    var_age{end+1}=std(age_p);
    men{end+1}=sum(sex_p);

    % % load(['/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat_iter/SBM' char(string(k)) '/SPM.mat']);
    % % B = cellfun(@(x) x(51:54),SPM.xY.P(67:length(SPM.xY.P)),'un',0);
    % % C = cell2mat(B);
    % % C = string(C);
    % % C = str2double(C);
    % % [~, y] = intersect(name_p,C,'stable');
    % % clear('SPM');
    % % 
    % % y = [24 28 32 33 58 74 75 79 91 96 97 98 99 102 109 112 124 128 129 135 137 139 140 143];
    % % TIV_p=TIV_po(y);
    % % age_p=age_po(y);
    % % sex_p=sex_po(y);
    % % 
    % % Y{end+1}=y;
    % % mean_age{end+1}=mean(age_p);
    % % var_age{end+1}=std(age_p);
    % % men{end+1}=sum(sex_p);
    % % 
    % % y2 = randsample(size(name_c,1),24);
    % % TIV_c=TIV_c(y2);
    % % age_c=age_c(y2);
    % % sex_c=sex_c(y2);
    % 
    %% CAT GM
    Anat_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/';
    liste_anat_c={};
    for i = 1 : size(name_c,1)
        folder_path=fullfile(Anat_path, 'Control-T1', char(string(name_c(i))), 'mri', 'smwp1Anat.nii');
        if (exist(folder_path, 'file')~=0)
            liste_anat_c{end+1}=folder_path;
        else
            disp(string(name_c(i)));
        end
    end

    liste_anat_p={};

    for i = y'
        folder_path=fullfile(Anat_path, 'PD-T1', char(string(name_p(i))), 'mri', 'smwp1Anat.nii');
        if (exist(folder_path, 'file')~=0)
            liste_anat_p{end+1}=folder_path;
        else
            disp(string(name_p(i)));
        end
    end

    cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat_iter/')
    mkdir(char(strcat('GM_CAT', string(k))));
    cd(char(strcat('./','GM_CAT', string(k))));

    stat_vbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p,TIV_c,TIV_p);

    %% volbrain GM
    liste_anat_c={};
    for i = 1 : size(name_c,1)
        folder_path=fullfile('/media/veronica/Disk_5/Donnees/Volumetrie_PPMI/masques_PPMI_DARTEL/gm_volbrain',strcat('sdgm_native_f', char(string(name_c(i))), '.nii'));
        if (exist(folder_path, 'file')~=0)
            liste_anat_c{end+1}=folder_path;
        else
            disp(name_c(i));
        end
    end

    liste_anat_p={};
    for i = y'
        folder_path=fullfile('/media/veronica/Disk_5/Donnees/Volumetrie_PPMI/masques_PPMI_DARTEL/gm_volbrain',strcat('sdgm_native_f', char(string(name_p(i))), '.nii'));
        if (exist(folder_path, 'file')~=0)
            liste_anat_p{end+1}=folder_path;
        else
            disp(name_p(i));
        end
    end


    cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat_iter/')
    mkdir(char(strcat('GM_volbrain', string(k))));
    cd(char(strcat('./','GM_volbrain', string(k))));

    stat_vbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p,TIVo(1:66),TIVo(y+66));

    %% DBM
    liste_anat_c={};
    for i = 1 : size(name_c,1)
        folder_path=fullfile(Anat_path, 'Control-T1', char(string(name_c(i))), 'mri', 'swj_Anat.nii');
        if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
        else
            disp(string(name_c(i)));
        end
    end

    liste_anat_p={};

    for i = y'
        folder_path=fullfile(Anat_path, 'PD-T1', char(string(name_p(i))), 'mri', 'swj_Anat.nii');
        if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
        else
            disp(string(name_p(i)));
        end
    end

    cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat_iter/')
    mkdir(char(strcat('DBM', string(k))));
    cd(char(strcat('./','DBM', string(k))));

    stat_dbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p);

    %% SBM
    liste_anat_c={};
    for i = 1 : size(name_c,1)
        folder_path=fullfile(Anat_path, 'Control-T1', char(string(name_c(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
        if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
        else
            disp(string(name_c(i)));
        end
    end

    liste_anat_p={};

    for i = y'
        folder_path=fullfile(Anat_path, 'PD-T1', char(string(name_p(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
        if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
        else
            disp(string(name_p(i)));
        end
    end

    cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat_iter/')
    mkdir(char(strcat('SBMg', string(k))));
    cd(char(strcat('./','SBMg', string(k))));

    stat_sbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p);

    %% SBM2
    liste_anat_c={};
    for i = 1 : size(name_c,1)
        folder_path=fullfile(Anat_path, 'Control-T1', char(string(name_c(i))), 'surf', 's15.mesh.thickness.resampled_32k.Anat.gii');
        if (exist(folder_path, 'file')~=0)
        liste_anat_c{end+1}=folder_path;
        else
            disp(string(name_c(i)));
        end
    end

    liste_anat_p={};

    for i = y'
        folder_path=fullfile(Anat_path, 'PD-T1', char(string(name_p(i))), 'surf', 's15.mesh.thickness.resampled_32k.Anat.gii');
        if (exist(folder_path, 'file')~=0)
        liste_anat_p{end+1}=folder_path;
        else
            disp(string(name_p(i)));
        end
    end

    cd('/home/veronica/Donnees/PPMI/Volumetrie_PPMI/Stat_iter/')
    mkdir(char(strcat('SBMt', string(k))));
    cd(char(strcat('./','SBMt', string(k))));

    stat_sbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p);
end

% %% mild cognitive impairment
% Anat_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/';
% y = [24 28 32 33 58 74 75 79 91 96 97 98 99 102 109 112 124 128 129 135 137 139 140 143];
% y2 = [46 63 43 30 38 20 26 18 13 37 19 21 16 56 51 31 34 44 39 14 23 40 7 61];
% % y2 = randsample(size(name_c,1),24);
% TIV_c=TIV_c(y2);
% age_c=age_c(y2);
% sex_c=sex_c(y2);
% TIV_p=TIV_po(y);
% age_p=age_po(y);
% sex_p=sex_po(y);
% 
% liste_anat_c={};
% for i = y2 %1 : size(name_c,1)
%     folder_path=fullfile(Anat_path, 'Control-T1', char(string(name_c(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
%     if (exist(folder_path, 'file')~=0)
%     liste_anat_c{end+1}=folder_path;
%     else
%         disp(string(name_c(i)));
%     end
% end
% 
% liste_anat_p={};
% for i = y
%     folder_path=fullfile(Anat_path, 'PD-T1', char(string(name_p(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
%     if (exist(folder_path, 'file')~=0)
%     liste_anat_p{end+1}=folder_path;
%     else
%         disp(string(name_p(i)));
%     end
% end
% % 
% %  stat_dbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p);
% % stat_vbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p,TIV_c,TIV_p);
% stat_sbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p);

% %% all
% Anat_path = '/home/veronica/Donnees/PPMI/Volumetrie_PPMI/';
% liste_anat_c={};
% for i = 1 : size(name_c,1)
%     folder_path=fullfile(Anat_path, 'Control-T1', char(string(name_c(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
%     if (exist(folder_path, 'file')~=0)
%     liste_anat_c{end+1}=folder_path;
%     else
%         disp(string(name_c(i)));
%     end
% end
% 
% liste_anat_p={};
% for i = 1 : size(name_p,1)
%     folder_path=fullfile(Anat_path, 'PD-T1', char(string(name_p(i))), 'surf', 's20.mesh.gyrification.resampled_32k.Anat.gii');
%     if (exist(folder_path, 'file')~=0)
%     liste_anat_p{end+1}=folder_path;
%     else
%         disp(string(name_p(i)));
%     end
% end



function [] = stat_vbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p,TIV_c, TIV_p)
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
    matlabbatch{1}.spm.stats.factorial_design.cov(3).c = [TIV_c;TIV_p];
    matlabbatch{1}.spm.stats.factorial_design.cov(3).cname = 'TIV';
    matlabbatch{1}.spm.stats.factorial_design.cov(3).iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov(3).iCC = 1;
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

function [] = stat_dbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p)
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

function [] = stat_sbm(liste_anat_c,liste_anat_p,age_c,age_p,sex_c,sex_p)
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
  