function cat12resampleNsmooth_surf(Path, File, nproc)

Subj_dir = dir([Path '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat={};
for i = 1 : size(Subj_dir,1)
    folder_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, File);
    %mesh_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'surf/s15.mesh.thickness.resampled_32k.Anat.gii');
    
    if (exist(folder_path, 'file')~=0) %&& (exist(mesh_path, 'file')==0)
        liste_anat{end+1}=folder_path;
    else
        disp(Subj_dir(i,1).name);
    end
end


spm_jobman('initcfg');
matlabbatch{1}.spm.tools.cat.stools.surfresamp.data_surf = liste_anat';
matlabbatch{1}.spm.tools.cat.stools.surfresamp.merge_hemi = 1;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.mesh32k = 1;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.fwhm_surf = 20;
matlabbatch{1}.spm.tools.cat.stools.surfresamp.nproc = nproc;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch



end