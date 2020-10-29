function cat12smooth(Path, File)

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
matlabbatch{1}.spm.spatial.smooth.data = liste_anat';
matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch



end