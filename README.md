# Modeling Specular Goniochromatic Materials Using Near-Specular and Diffuse Reflectance
 
**Bita Panahi, Ivar Farup, Aditya Sole**  
Norwegian University of Science and Technology (NTNU), Gjøvik, Norway
 
Published in **Optics Express**, Vol. 33, No. 18, pp. 38268–38283, 2025  
DOI: [10.1364/OE.568761](https://doi.org/10.1364/OE.568761)
 
---

## Overview

Goniochromatic materials, such as effect pigments and metallic coatings, exhibit strong view- and illumination-dependent colour shifts that challenge standard BRDF estimation. This work presents a separation-based fitting method that treats near-specular (NS) and diffuse (D) reflectance independently to better capture the complex angular behaviour of these materials.

---

## Requirements

- MATLAB R2021b or later
- Optimization Toolbox (`lsqnonlin`)
- Statistics and Machine Learning Toolbox (for `signtest`)

---

## Getting started

### 1. Set up the path

At the start of MATLAB, add all subfolders to the path:

```matlab
addpath(genpath(pwd))
```

### 2. Point to your measurement data

Open the main script and update the data paths at the top:

```matlab
% In Separated_All_for_D_LogCF_LOO.m
sample_data = readmatrix("YOUR_PATH/GonioXX.xlsx", "Sheet","ALL", 'Range', 'E3:AI14');
angles      = readmatrix("YOUR_PATH/GonioXX.xlsx", "Sheet","ALL", 'Range', 'B3:C14');
```

Input data format:
- **Spectral BRDF values**: rows = measurement angles, columns = wavelengths (400-700 nm, 10 nm steps = 31 bands)
- **Angles**: two-column matrix `[theta_i, theta_o]` in degrees

### 3. Run

```matlab
run('scripts/Separated_All_for_D_LogCF_LOO.m')
```

---

## Model

The BRDF model (`MAT12_gonio_brdf.m`) is:

```
Fr(theta_i, theta_o, lambda) =
    alpha^2 * rho(lambda) * exp( c(lambda) * (1 - cos((theta_i+theta_o)/2)) )
    -----------------------------------------------------------------------
    4*pi * [ (alpha^2 - 1)*cos^2(theta_h) + 1 ]^2
```

with `rho` (31 spectral weights) and `c` (31 specular coefficients) as the fitted parameters, and alpha being optimized before.

---

## Separation method

- **Near-specular (NS):** angles within 15 degrees of the specular direction; fitted using CWRMSE on raw BRDF values of near-specular angles.
- **Diffuse (D):** all angles; fitted using CWRMSE on log-transformed BRDF values to better capture the low-reflectance diffuse lobe.

---

## Leave-One-Out (LOO)

For each material, one measurement angle is held out at a time. The model is fitted on the remaining angles and evaluated on the held-out one. 

---

## Dependencies

The following are not included in this repository and must be obtained separately.

**Colour science utilities** the following functions are from the [Colour Engineering Toolbox](http://www.digitalcolour.org) by Phil Green (v1.1, 2001):
- `ciede2000.m` - CIEDE2000 colour difference
- `xyz2srgb.m` - XYZ to sRGB conversion
- `xyz2lab.m` - XYZ to LAB conversion

The **Genetic Algorithm** implementation is originally based on the framework from [Practical Genetic Algorithms in Python and MATLAB](https://yarpiz.com/632/ypga191215-practical-genetic-algorithms-in-python-and-matlab) (Yarpiz) and modified for this application.

**Others:**
- `showpatchgrid.m` - To plot the RGB patches.
  
---

## Citation

If you use this work, please cite:

```bibtex
@article{panahi2025goniochromatic,
  title   = {Modeling specular goniochromatic materials using near-specular and diffuse reflectance},
  author  = {Panahi, Bita and Farup, Ivar and Sole, Aditya},
  journal = {Optics Express},
  volume  = {33},
  number  = {18},
  pages   = {38268--38283},
  year    = {2025},
  doi     = {10.1364/OE.568761},
  pmid    = {40984239}
}
```
---

## License

The code written by the authors is released for research and educational use. If you use this work, please cite the paper above. Third-party functions included or referenced in this repository remain under their respective original licenses.

