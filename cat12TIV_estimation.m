function cat12TIV_estimation(Path, Name)

Subj_dir = dir([Path '*']);
Subj_dir = Subj_dir(arrayfun(@(x) ~strcmp(x.name(1),'.'),Subj_dir));
liste_anat={};
for i = 1 : size(Subj_dir,1)
    report_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'report', 'cat_Anat.xml');
    tissue_path=fullfile(Subj_dir(i,1).folder, Subj_dir(i,1).name, 'mri', 'smwp1Anat.nii');
    
    if (exist(report_path, 'file')~=0) && (exist(tissue_path, 'file')~=0)
        if isfield(cat_io_xml(report_path),'subjectmeasures')
            liste_anat{end+1}=report_path;
        else
            disp(strcat('No subjectmeasures ', Subj_dir(i,1).name))
        end
    else
        disp(strcat('No file ', Subj_dir(i,1).name));
    end
end
% 
spm_jobman('initcfg');
matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = liste_anat';
matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 0;
matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = Name;
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
clear matlabbatch

%cat_io_xml(deblank(p.data_xml{i})); 


% matlabbatch{1}.spm.tools.cat.tools.calcvol.data_xml = {
%                                                        '/media/veronica/DATAPART2/PPMI_Morpho_all/HC/3000/report/cat_Anat.xml'
%                                                        '/media/veronica/DATAPART2/PPMI_Morpho_all/HC/3004/report/cat_Anat.xml'
%                                                        };
% matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_TIV = 0;
% matlabbatch{1}.spm.tools.cat.tools.calcvol.calcvol_name = 'TIV.txt';
% spm('defaults', 'FMRI');
% spm_jobman('run', matlabbatch);
% clear matlabbatch
end