# AirSAS (In-air Synthetic Aperture Sonar)

This code accompanies "In-air synthetic aperture sonar observations of target scattering in environments of varying complexity" by Blanford et al., published in XXX. The paper is available here\: Insert link when available.

## Background 
---
Synthetic aperture sonar (SAS) is a coherent acoustic remote sensing technique that is typically used to produce high resolution images of objects in underwater environments. SAS arrays are mounted to a moving platform, transmit pulses at regular intervals, and record the backscattered echoes on one or more receivers. Using the estimated motion of the platform and an estimate of the local sound speed, these echoes are reconstructed into imagery that is a spatial map of the acoustic reflectivity of the scene. SAS data contains significant physical complexity. Targets have complicated scattering behavior that depends on their shape and material composition. They often lie proud or partially buried on seafloors with multiple scales of roughness and inhomogeneous acoustic properties. Both the raw echoes and the reconstructed imagery contain information about the targets, the environment, and how the two interact with acoustic stimuli.

This data set consists of in-air SAS data of multiple types of targets and backgrounds collected in a controlled, quiet, indoor laboratory environment. The data contains the complex-valued SAS imagery, aswell as the raw acoustic signals and the associated non-acoustic data needed for image reconstruction. Compared to underwater experiments, in-air laboratory data collection allows for simplification of the physical phenomena contributing to a given scene, the ability to build complexity in a controlled manner, and the opportunity for rapid experimental iteration to capture (or remove) and characterize physical effects present in the data. The advantages afforded by in-air experimentation were intended to allow for accurate modeling and quantification of uncertainty in the data that would be infeasible underwater.
 
## Data Organization
---
The data is available at XXXX. The data is organized into two folders\: “scenes” and “characterization data”. Within the “scenes” folder, the acoustic and non-acoustic data from the collection of each scene, along with the reconstructed imagery of the scene, are saved in .h5 files. Each .h5 file contains data from a unique collection of aparticular target and background configuration.

### scenes
---
Within the “scenes” folder, the acoustic and non-acoustic data from the collection of each scene, along with the reconstructed imagery of the scene, are saved in .h5 files. Each .h5 file contains data from a unique collection of a particular target and background configuration.  

#### Prefix Explanation

The four character prefix in the file name identifies the configuration of the targets and the background. The first two charachters identify the target:


| Target prefix (two charachters) | Target | 
| :------------------- | :----------: | 
| t0              | No target      | 
| t1              | Solid sphere   | 
| t2              | Hollow sphere  | 
| t3              | Letter O       | 
| t4              | Letter Q       | 

Insert Images Here

The second two charachters identify the background environment:

| Background prefix (two charachters) | Target | 
| :------------------- | :----------: | 
| e1              | Free field       | 
| e2              | Flat interface   | 
| e3              | Rough interface  | 
| e4              | Partially buried in rough interface | 

Insert images here

A two digit suffix indicates the unique number of the collection. This suffix ranges from 01 to the total number of collections in that configuration. Noise recordings, where no waveform was transmitted in order to characterize the background noise in the experiment, are saved as .h5 files in the same manner using the prefix “noise”. Table 1 summarizes the naming and quantity of the h5 files in the data set.

### characterization data


## Code Organization