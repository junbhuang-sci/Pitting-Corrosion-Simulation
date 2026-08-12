

# Pitting Corrosion Simulation

This repository contains two main components:
1.  Data for the various curves presented in the Pitting Corrosion Simulation manuscript.
2.  Monte Carlo pitting corrosion code.

This document explains the data and how to use the Monte Carlo code together with Fortran.

## Requirements
1.  LAMMPS (22 Jul 2025 or later)
2.  Linux environment
3.  gfortran

## Data Explanation

### Perform the Atomic Pitting Corrosion 
The data acquisition is as follows:
-   Initial configuration setup: 
    Use LAMMPS to create a single-crystal aluminum LAMMPS Data file with the (100) crystal plane in the Z-direction (name this file `data`), and define the surface atoms as type 2 atoms.

-   Potential configuration: 
Download the potential file 'Al_zhou.eam.alloy'.

-   Run the corrosion cycle program: 
Before running the corrosion program, you need to download the Monte Carlo Fortran code PerformCorrosion.f and compile it using:

# terminal
> gfortran PerformCorrosion.f -o PerformCorrosion

After compilation, first set the corrosion parameters in the Monte Carlo Simulation script file (using the curve in Figure 4d (E0 = -2.90 eV) as an example):

# PerformCorrosion.sh
> Cutoff=3.2			# distance between nearest neighbors
> Temperature=300		# unit K
> ECut=-2.90			# eV, atoms with pe above this value will be coroded certainly
> NLoop=200  			# Number of corrosion loops in the simulation
> FortranDir=Your executable fortran file path  # Path of the executable fortran file
> Potential=Your 'Al_zhou.eam.alloy' Potential path # Path of the potiantial file

-   Execute in the terminal:

# terminal
> mkdir /home/Username/Figure4 # Create directory
> cd /home/Username/Figure4
> mkdir /home/Username/Figure4/StartConfig # Create directory for initial configuration
> cp data /home/Username/Figure4/StartConfig # Copy initial configuration to StartConfig directory 
> cp PerformCorrosion.sh /home/Username/Figure4 # Copy Monte Carlo Simulation script file
> source PerformCorrosion.sh # Execute Monte Carlo Simulation

After waiting for the computer to run 200 Monte Carlo steps, find the `300K-2.90eV` subdirectory generated in the `Figure4` directory. In this subdirectory, the **`plot.txt` file records the number of total atoms and corrosion rate for each Monte Carlo step**. The number of corroded atoms can be plotted using these data.

**Following the above steps, we can obtain the patterns and corrosion curves for each figure in the manuscript.**

### Figure 4
The data acquisition procedure is as follows:
-   Initial configuration setup:
    Use LAMMPS to create a single-crystal aluminum with the (100) crystal plane in the Z-direction.

-   Run the corrosion cycle program:  
The parameters in the `PerformCorrosion.sh` script file are:
> Temperature=300
> ECut=-2.90

> Temperature=300
> ECut=-2.92

> Temperature=300
> ECut=-2.94

The data for this figure can be found in the `Figure 4` folder.
***
### Figure 5
The data acquisition procedure is as follows:
-   Initial configuration setup: 
    Use LAMMPS to create a single-crystal aluminum with the (100) crystal plane in the Z-direction.

-   Run the corrosion cycle program: 
The parameters in the `PerformCorrosion.sh` script file are:
> Temperature=300
> ECut=-2.90

> Temperature=450
> ECut=-2.90

> Temperature=600
> ECut=-2.90

The data for this figure can be found in the `Figure 5` folder.

### Figure 7
The data acquisition procedure is as follows:
-   Initial configuration setup:  
    Use LAMMPS to create single-crystal aluminum samples with the (100), (110), (111), and (112) crystal planes in the Z-direction.

-   Run the corrosion cycle program: 
For each of the four samples, use five different corrosion parameter sets, configured in the `PerformCorrosion.sh` script file as follows:
> Temperature=300
> ECut=-2.90

> Temperature=300
> ECut=-2.95

> Temperature=300
> ECut=-3.00

> Temperature=450
> ECut=-2.90

> Temperature=600
> ECut=-2.90
After obtaining the corrosion data, divide these data by the Z-direction surface area of the corresponding aluminum single-crystal sample (i.e., box size in the x-direction multiplied by box size in the y-direction) to obtain the No. of Corroded Atoms per Unit Area.
The data for this figure can be found in the `Figure 7` folder.

### Figure 8
The data for this figure can be found in the `Figure 8` folder, corresponding to six datasets: `N=1`, `N=2`, `N=3`, `N=4`, `N=5`, and `N=6`. Where: 
-   Energy increase ΔE：
We supposed `Ei+E0=-0.2 eV`, the energy increment ΔE = kTln(x) - (Ei + E0) = kTln(x) - 0.2.  
Since x ∈ (0,1), we divide it into 1000 data points, i.e., x = {0.001, 0.002, 0.003, ...... 0.999, 1}, and substitute these into the above formula to obtain the energy increment ΔE for each data point.

-   Corrosion probability P:
Substituting x = {0.001, 0.002, 0.003, ...... 0.999, 1} into equations (4)–(9) from the manuscript gets the corrosion probability P for each of the six data file corresponding to N = 1, 2, 3, 4, 5, and 6.






