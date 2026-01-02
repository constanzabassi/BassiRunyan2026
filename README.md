# BassiRunyan2026
Code for Bassi et al. manuscript

This repository contains MATLAB code used to analyze calcium imaging and behavioral data and to generate the main and supplementary figures for **Bassi et al.**

## Basic details

PV-Cre × SOM-Flp mice expressed GCaMP6f in all neurons, tdTomato in parvalbumin-expressing (PV) neurons, and mCherry in somatostatin-expressing (SOM) neurons. GCaMP6f activity was imaged in layer 2/3 of posterior parietal cortex (PPC) at 30 Hz using two-photon microscopy while mice performed an auditory-guided navigation task in virtual reality.
On approximately one-third of trials, ChrimsonR-expressing axons from auditory cortex (AC) were photostimulated, providing an additional sensory input to PPC. Imaging was performed across multiple behavioral contexts (active task, passive listening, and spontaneous activity).

### Figure 1
Cell-type-specific encoding of task variables in an auditory decision-making task. Code used to generate heatmaps, mean activity traces, and population decoding accuracy plots.

### Figure 2
Auditory-driven responses in PPC are modulated by behavioral context. Code used to plot modulation indices and to analyze post-stimulus response interactions between sound and photostimulation.

### Figure 3
Pre-stimulus engagement predicts trial-by-trial sensory responses and behavioral performance. Code used to analyze and plot pre-stimulus activity, population axis projections, and relationships to behavioral performance.

### Reproducing figures

**Main figures**: Main figures (Figures 1–3) are reproduced by running:

```
run_main_figures_1_3.m
```

**Supplementary figures**: Supplementary figures are generated using scripts named:

```
run_supplemental_*.m
```

Each script loads the shared processed data structures and generates the corresponding figures without requiring access to raw imaging data.
