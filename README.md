# Biological-Signal-Processing
Summary: fMRI algorithm that will analyze a subject's visual cortex as they view pictures of famous &amp; non-famous people.

The dataset used has been published by Henson et al. (2011)1 . This dataset contains EEG, MEG, functional MRI, and structural MRI data from 16 subjects who undertook multiple runs of a simple task performed on a large number of Famous, Unfamiliar, and Scrambled faces. There were 9 runs (sessions) per subject for the fMRI experiment. During this project, you will be only analyzing the functional MRI data.
More information about the data acquisition can be found here: https://www.nature.com/articles/sdata20151

Using the same pipeline shown in the tutorial report the following activation maps for one subject (assigned based on your group number) and for the group :
- Famous face > 0
- Unfamiliar face > 0
- Faces > Scrambled Faces
For the group analysis, report the result on the MNI template. For the subject result, report the result on the subject-specific anatomy (skip normalization). For both, report all statistically significant results with a threshold of p < 0.05 (FWE corrected).
