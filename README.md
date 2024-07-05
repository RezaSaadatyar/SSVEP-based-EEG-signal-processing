:one: **Introduction**

- [x] **Brain-Computer Interfaces (BCI):**<br/>
"BCI" is a method of measuring central nervous system activity and converting it into artificial output that can replace, restore, enhance, supplement, or improve natural CNS output and alter the ongoing interactions between the CNS and its external or internal environment. BCIs can be categorized based on their dependability as ***dependent*** or ***independent***. ***Dependent BCIs*** are those that enable individuals to use some form of ***motor control***, such as gaze. The use of BCIs based on ***motor imagery*** is a common example of dependent BCIs. A BCI without motor control, on the other hand, can be used by ***stroke survivors*** or those with ***locked-in syndrome***. Synchronous BCI involves the subject responding to cues imposed by the system over a set period. As opposed to synchronous BCI, asynchronous BCI allows the subject to communicate with the application at any time. BCIs that are synchronous have a lower usability than those that are asynchronous.

- [x] **EEG Paradigms used in BCI:**<br/>
         Motor Imagery (MI) ***[(Further information)](https://github.com/RezaSaadatyar/Motor-imagery-based-EEG-signal-processing)***<br/>
         Event‑Related Potential (ERP)<br/>
         Steady‑State Evoked Potentials (SSEP)<br/>
![Blank diagram - Page 1 (2)](https://user-images.githubusercontent.com/96347878/209584607-b819be1b-70a0-4706-9d5a-fed87ef27aef.png) ![Blank diagram - Page 1 (1)](https://user-images.githubusercontent.com/96347878/209584696-fb5f1cde-1271-40ba-bd23-e80a74f3b284.png)

- [x] **Steady‑State Evoked Potentials (SSEP):**<br/>
According to visual, auditory, and somatosensory stimulation, SSEP are classified as *Steady-State Visually Evoked Potentials (SSVEP)*, *Steady-State Auditory Evoked Potentials (SSAEP)*, and *Steady-State Somatosensory Evoked Potentials (SSSEP)*.<br/>
     ***SSAEP:***<br/>The SSAEP are usually extracted using trains of click stimuli, tone pulses, or amplitude-modulated tones, at a repetition or modulation rate between 20 and 100 Hz.<br/>
     ***SSSEP***<br/>
The SSSEP paradigm uses vibrotactile sensors to produce stimulation at distant frequencies, which are mounted on predetermined parts of the body.<br/> 
     ***SSVEP:***<br/>
In SSVEP-based BCIs, visual stimuli are triggered at constant frequencies between 3.5 and 75 Hz. The best response for this stimulus are obtained for stimulation frequencies between 5 and 20 Hz. Focusing on a flickering stimulus generates an SSVEP with the same frequency as the target ficker.  One of the most widely used BCI applications is speller recognition since it transmits information faster than other paradigms. Since an SSVEP can transmit information at a high rate and requires little training, it is widely used in numerous applications, like spellers, smart homes, games, robot control, and exoskeleton control.<br/>

- [x] In a biological visual system, the visual pathway starts with the retina and each unit has a corresponding function. ![Blank diagram - Page 1](https://user-images.githubusercontent.com/96347878/209627515-0b65056e-daa5-4e82-85ff-f630d3e19f53.png)

----
:two: **Methods**

- [x] **Experimental setup**<br/>
  - [Dataset](https://github.com/sylvchev/dataset-ssvep-led)
  - Sampling rate: 256 Hz
  - Stimulus frequencies: 13, 17, 21 Hz
  - Number of channels : 9 (Oz, O1, O2, POz, PO3, PO4, PO7 and PO8; Fz: Reference)
  - For each trial, a 5-second were used for stimuli and a 3-second for pauses, and a total of 160 trials were recorded for each subject.
  - Trial length: 256*5=1280 ---> 1280*8 (Number channels)
  - A trial starts with a Label_XX stimulation code indicating the class of the example. 
    - Label_01 ---> 13Hz stimulation (33025)
    - Label_02 ---> 21Hz stimulation (33026) 
    - Label_03 ---> 17Hz stimulation (33027)

- [x] **Data pre-processing**<br/>
        ***Convert gdf data to mat:***<br/>
Put the "biosig4format" folder on the desktop ---> [biosig4octmat](https://sourceforge.net/projects/biosig/files/BioSig%20for%20Octave%20and%20Matlab/) ---> biosig ---> run the *install* code ---> run [Signal, Inform] = sload('file name.gdf ') in command window then save Signal and Inform (*App1_Data_Preprocessing_a_trial.m; App2_Data_Preprocessing_all_trial.m*).<br/>
       Inform.EVENT.TYP ---> Label trials<br/>
       Inform.EVENT.Pos ---> Time start the trials<br/>

*App3_Plot_Trial.m;  App4_Filter_Signal.m:* :arrow_lower_right:<br/>

![1](https://user-images.githubusercontent.com/96347878/218717042-02bdc58d-5a73-4cb2-981a-d049119ce0ed.png) ![2](https://user-images.githubusercontent.com/96347878/218717022-2f2673fa-76e8-4b85-a51f-f16a3420115f.png)



- [x] **Algorithms proposed** 
  - [ ] **Spatial filtering approaches:**<br/>Spatial filters are commonly used to improve the signal-to-noise ratio (SNR) of EEG. In a spatial filter, the signal from the EEG electrodes is mixed in such a way that the signal of interest is enhanced, while noise or artifact components are reduced.
     - Common average reference (CAR)
     - Small Laplacian
     - Large Laplacian 
     
  - [ ] **SSVEP frequency recognition algorithms**<br/>***Power Spectral Density Analysis (PSDA):***<br/>The PSDA method is often used for SSVEP detection, which is related to frequency domain signal processing. The power spectral density analysis is implemented by calculating the signal/noise ratio based on the power densities around the stimulus frequencies.<br/>***Canonical correlation analysis (CCA) method:*** <br/>The CCA-based frequency recognition method is one of the widely used methods in SSVEP-based BCI, and several extended versions were proposed in the past decade. CCA measures the correlation between two multidimensional variables, and it can produce multiple canonical correlation coefficients. The largest coefficient was usually used for frequency recognition, the remaining coefficients were optionally discarded. The scalp EEG data often contain noise and artifacts. Scalp EEG data often contain noise and artifacts. When using CCA for frequency detection with EEG data, noise and artifacts may result in discriminative information spanning all or parts of the canonical correlation coefficients, and discarding other coefficients may result in the loss of useful information for frequency detection.
    - *Fusing Canonical Coefficients of CCAs (FoCCA):*<br/>To begin using the FoCCA method, use the standard CCA to obtain the canonical coefficients for each individual test sample and reference signal at each given frequency. Then, for each given frequency, use formula (1) to calculate a new feature for the test sample and $f_{test} = max βi( f ), i = 1, 2, . . . , Nf$ to identify the frequency.<br/>$$βi( f )=\sum_{k=0}^D φk.(\lambda_k)^2  \leftarrow φk=k^{-a}+b   \Longleftarrow (1)$$ 
    - *Filter bank CCA (FBCCA):* <br/>A filter bank is a collection of band-pass filters that divide an input signal into multiple sub-band components. Given the distinct spectral properties of multiple harmonic frequencies in SSVEPs, the filter bank method has significant potential to improve SSVEP CCA-based frequency detection. Three methods were proposed to optimize the filter bank design.
      - Method 1: sub-bands with equally spaced bandwidths
      - Method 2: sub-bands corresponding to individual harmonic frequency bands
      - Method 3: sub-bands covering multiple harmonic frequency bands

    ***Multivariate synchronization index method (MSI):*** <br/>The MSI was proposed based on the theory of S-estimator. It calculates correlation based on the entropy of the normalized eigenvalues of a multichannel signal's covariance matrix. The estimation of the covariance matrix in the MSI method ignores the temporally local structure of samples.<br/>
    ***Fast Fourier Transform (FFT)***<br/>
    
    *App5_Filter_CAR.m; App6_PSDA_a_trial.m:* :arrow_lower_right:

![3](https://user-images.githubusercontent.com/96347878/218726457-8b5d6773-f33a-4e97-9a76-166e3654d6dc.png) ![4](https://user-images.githubusercontent.com/96347878/218726433-d36dbd69-167a-41c4-8b06-26c3fa3104b8.png) ![7](https://user-images.githubusercontent.com/96347878/219160845-8f3734a9-dc42-460d-b4d6-be562039e245.JPG)

----
:three: **Results**

- [x] **Performance of Methods:**<br/>
 
   *App7_PSDA_all_trial.m; App9_CCA_all_trial.m; App10_FOCCA_all_trial.m; App11_FBCCA_all_trial.m; App12_MSI_all_trial.m:* :arrow_lower_right:
![10](https://user-images.githubusercontent.com/96347878/219172400-b1076ac9-e282-4d57-8132-6ebd629cc9df.JPG)

    *App13_CCA_FeatureExtraction.m:* :arrow_lower_right:<br/>
![10](https://user-images.githubusercontent.com/96347878/219229769-1896befc-7be7-4bc1-aa92-611590491bb0.png)![11](https://user-images.githubusercontent.com/96347878/219230051-79ab3f43-be78-4ddf-8e9f-f6fe5961f41a.png)

   *App15_FeatureExtraction_Classification.m:* :arrow_lower_right:<br/>
![12](https://user-images.githubusercontent.com/96347878/219234156-31c77e8a-0369-4fda-9b7d-b0928675e5bf.png)![13](https://user-images.githubusercontent.com/96347878/219234169-c2ac863e-77fd-4704-b438-7c8d52b2ab8d.png)
   
