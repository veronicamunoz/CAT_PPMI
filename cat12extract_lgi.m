function cat12extract_lgi(Path, File)

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
matlabbatch{1}.spm.tools.cat.stools.surfextract.data_surf = liste_anat';
matlabbatch{1}.spm.tools.cat.stools.surfextract.GI = 1;
matlabbatch{1}.spm.tools.cat.stools.surfextract.FD = 0;
matlabbatch{1}.spm.tools.cat.stools.surfextract.SD = 1;
matlabbatch{1}.spm.tools.cat.stools.surfextract.nproc = 4;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

end