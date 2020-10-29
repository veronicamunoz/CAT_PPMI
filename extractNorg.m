function extractNorg(Path,clean)
cd(Path)
Doss= dir([Path '*']); % Every subfolder has the scans of one subject
Doss = Doss(arrayfun(@(x) ~strcmp(x.name(1),'.'),Doss));

for i = 1 : size(Doss,1)
    if Doss(i,1).isdir==1 && exist(fullfile(Doss(i,1).folder, Doss(i,1).name, 'Anat.nii'), 'file')==0 % we verify that we have a folder and that the extraction hasn't been made yet
        disp(Doss(i,1).name)
        dcm_files = dir([Doss(i,1).folder '/' Doss(i,1).name '/**/*.dcm']); % We extract the names of all of the dicom files
        status = system( ['dcm2nii -4 N -d N -e N -f N -g N -i N -p Y -o ' Doss(i,1).name ' ' dcm_files(1,1).folder]); % we use dcm2nii and save the nifti files with the name of their protocol
        if status 
            disp([' *** There was a problem with subject ' Doss(i,1).name ', please check your files *** ']);
        else
            if clean % Do we clean up the dicom files? They are always in a subsubfolder
                files = dir([Doss(i,1).name '/*']);
                files = files(arrayfun(@(x) ~strcmp(x.name(1),'.'),files));
                dir_name = files([files.isdir]); %Find the folders
                rmdir(fullfile(dir_name.folder,dir_name.name),'s'); % Delete the folders
            end 
            files = dir([Doss(i,1).name '/*.nii']);
            name = {files.name};
            [~,ind] = min(strlength(name)); % Our Anat scan always has the smallest name (all reconstructions add letters to the name ex. MPRAGE -> coMPRAGE)
            if length(files)>1 % Did we extract any unwanted reconstructions? We proceed to delete them
                mkdir([files(ind).folder '/Tmp'])
                movefile([files(ind).folder '/' files(ind).name], [files(ind).folder '/Tmp/Anat.nii']); %Move the Anat file in a Tmp folder for save keeping
                delete([files(ind).folder '/*.nii']); % Delete all other nifti files
                movefile([files(ind).folder '/Tmp/Anat.nii'], [files(ind).folder '/Anat.nii']); % Bring back the Anat file
                rmdir(fullfile(files(ind).folder,'Tmp'),'s'); % Delete the empty Tmp folder
            else % If there are no unwanted reconstructions, we simply rename the unique nifti file to 'Anat' 
                movefile([files(ind).folder '/' files(ind).name], [files(ind).folder '/Anat.nii']);         
            end  
        end
    end
end

end