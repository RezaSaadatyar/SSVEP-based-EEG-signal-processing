:one: **Brain Computer Interfaces (BCI):**<br/>
"BCI" is a method of measuring central nervous system activity and converting it into artificial output that can replace, restore, enhance, supplement, or improve natural CNS output and alter the ongoing interactions between the CNS and its external or internal environment. BCIs can be categorized based on their dependability as ***dependent*** or ***independent***. ***Dependent BCIs*** are those that enable individuals to use some form of ***motor control***, such as gaze. The use of BCIs based on ***motor imagery*** is a common example of dependent BCIs. A BCI without motor control, on the other hand, can be used by ***stroke survivors*** or those with ***locked-in syndrome***. Synchronous BCI involves the subject responding to cues imposed by the system over a set period of time. As opposed to synchronous BCI, asynchronous BCI allows the subject to communicate with the application at any time. BCIs that are synchronous have a lower usability than those that are asynchronous.

:black_medium_square: **EEG Paradigms used in BCI:**<br/>
- Motor Imagery (MI) ***[(Further information)](https://github.com/RezaSaadatyar/Motor-imagery-based-EEG-signal-processing)***
- Event‑Related Potential (ERP)
- Steady‑State Evoked Potentials (SSEP)

![Blank diagram - Page 1 (2)](https://user-images.githubusercontent.com/96347878/209584607-b819be1b-70a0-4706-9d5a-fed87ef27aef.png)

![Blank diagram - Page 1 (1)](https://user-images.githubusercontent.com/96347878/209584696-fb5f1cde-1271-40ba-bd23-e80a74f3b284.png)

---

:two: **Steady‑State Evoked Potentials (SSEP):**<br/>
According to visual, auditory, and somatosensory stimulation, SSEP are classified as ***Steady-State Visually Evoked Potentials (SSVEP)***, ***Steady-State Auditory Evoked Potentials (SSAEP)***, and ***Steady-State Somatosensory Evoked Potentials (SSSEP)***.
- ***SSAEP:***<br/>
The SSAEP are usually extracted using trains of click stimuli, tone pulses, or amplitude-modulated tones, at a repetition or modulation rate between 20 and 100 Hz.
- ***SSSEP***<br/>
The SSSEP paradigm uses vibrotactile sensors to produce stimulation at distant frequencies, which are mounted on predetermined parts of the body.  
- ***SSVEP:***<br/>
In SSVEP-based BCIs, visual stimuli are triggered at constant frequencies between 3.5 and 75 Hz. The best response for these stimulus are obtained for stimulation frequencies between 5 and 20 Hz. Focusing on a fickering stimulus generates an SSVEP with the same frequency as the target ficker.  One of the most widely used BCI applications is speller recognition, since it transmits information at a higher rate compared to other paradigms. Since a SSVEP can transmit information at a high rate and require little training, it is widely used in numerous applications, like spellers, smart homes, games, robot control, and exoskeleton control

In a biological visual system, the visual pathway starts with the retina and each unit has a corresponding function.

![Blank diagram - Page 1](https://user-images.githubusercontent.com/96347878/209627515-0b65056e-daa5-4e82-85ff-f630d3e19f53.png)

----

:three:**Experimental setup**<br/>
For SSVEP stimulation, flash stimulus (F=13, 17, 21 Hz) technique has been chosen. The eight electrodes are placed according to the 10/20 system on Oz, O1, O2, POz, PO3, PO4, PO7 and PO8. The ground was placed on Fz and the reference was located on the right (or left) hear mastoid.<br/>
[Dataset](https://github.com/sylvchev/dataset-ssvep-led)

![image](https://user-images.githubusercontent.com/96347878/205325207-ced004db-8d81-42ac-bd2b-b328e55de82c.png)

![image](https://user-images.githubusercontent.com/96347878/205325217-3242090d-1437-4d42-8a38-0b86f755aeb7.png)


***Power Spectral Density Analysis (PSDA):*** The PSDA method is often used for SSVEP detection, which is related to frequency domain signal processing. The power spectral density analysis is implemented by calculating the signal/noise ratio based on the power densities around the stimulus frequencies

![image](https://user-images.githubusercontent.com/96347878/205339199-b8f1ccc2-d97e-4552-a773-150e8c0900ed.png)


***canonical correlation analysis (CCA) method:***

***multivariate synchronization index method (MSI)***
