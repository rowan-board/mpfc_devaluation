#!/bin/bash

# Generate the subject list to make modifying this script
# to run just a subset of subjects easier.

for id in `seq -w 2 22` ; do
    subj="sub_$id"
    echo "===> Starting processing of $subj"
    echo
    cd $subj 

        # If the brain mask doesn’t exist, create it
        if [ ! -f anat/${subj}_T1_brain_f02.nii.gz ]; then
            echo "Skull-stripped brain not found, using bet with a fractional intensity threshold of 0.2"
            # Note: This fractional intensity appears to work well for most of the subjects in the
            # Flanker dataset. You may want to change it if you modify this script for your own study.
            bet2 anat/${subj}_T1.nii.gz \
                anat/${subj}_T1_brain_f02.nii.gz -f 0.2
        fi

        # Copy the design files into the subject directory, and then
        # change “sub-02” to the current subject number
        cp ../design_1.fsf .
        cp ../design_2.fsf .

        # Note that we are using the | character to delimit the patterns
        # instead of the usual / character because there are / characters
        # in the pattern.
        sed -i "s|sub_02|${subj}|g" design_1.fsf
        sed -i "s|sub_02|${subj}|g" design_2.fsf
		
		# now change the number of volumes for the two design files
		nvols1=`fslnvols func/${subj}_run1.nii.gz`
		echo $nvols1
		nvols2=`fslnvols func/${subj}_run2.nii.gz`
		echo $nvols2
		
		sed -i "s|#VOLS#|${nvols1}|g" design_1.fsf
		sed -i "s|#VOLS#|${nvols2}|g" design_2.fsf
		
        # Now everything is set up to run feat
        echo "===> Starting feat for run 1"
        feat design_1.fsf
        echo "===> Starting feat for run 2"
        feat design_2.fsf
                echo

    # Go back to the directory containing all of the subjects, and repeat the loop
    cd ..
done

echo