function check_homogeneity(Path, File)

Subj_dir = dir([Path '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat={};

for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, File);
    if (exist(folder_path, 'file')~=0)
        liste_anat{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end

spm_jobman('initcfg');
% matlabbatch{1}.spm.tools.cat.tools.check_cov.data_vol = liste_anat';
% matlabbatch{1}.spm.tools.cat.tools.check_cov.data_xml = {''};
% matlabbatch{1}.spm.tools.cat.tools.check_cov.gap = 3;
% matlabbatch{1}.spm.tools.cat.tools.check_cov.c = {
%                                                   [15
%                                                   22]
%                                                   [0
%                                                   1]
%                                                   }';
                                              
matlabbatch{1}.spm.tools.cat.tools.check_cov.data_vol = {liste_anat'}';
matlabbatch{1}.spm.tools.cat.tools.check_cov.data_xml = {''};
matlabbatch{1}.spm.tools.cat.tools.check_cov.gap = 3;
matlabbatch{1}.spm.tools.cat.tools.check_cov.c = {};                                              
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch