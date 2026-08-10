

# Pitting Corrosion Simulation
本repository包含两个内容：2. 蒙特卡洛点蚀代码。1. Pitting Corrosion Simulation手稿中各个曲线中的数据。本文分别解释了这些数据，以及怎么搭配Monte Carlo和Fortran一起使用。

## Data Explanation
本节针对手稿中对应图片的数据进行说明。
### Figure 4
该图片数据处于[Figure 4](https://github.com/junbhuang-sci/Pitting-Corrosion-Simulation/tree/main/Figure4)文件夹中，其中包含对应的分子动力学样品生成脚本`Figure4_CreateStartConfig.sh`，以及分别存储在`Figure 4d`, `Figure 4e`两个子文件夹的对应的图片数据。
***
数据获取流程如下：
(其中Monte Carlo Simulation脚本文件位于[junbhuang-sci/Pitting-Corrosion-Simulation](https://github.com/junbhuang-sci/Pitting-Corrosion-Simulation/tree/main))

- 对于曲线Figure 4d, E0 = -2.90 eV，
Monte Carlo Simulation脚本文件的参数分别为：
```bash
# PerformCorrosion.sh
> Cutoff=3.2			# distance between nearest neighbors
> Temperature=300	# unit K
> ECut=-2.90			# eV, atoms with pe above this value will be coroded certainly
> NLoop=200  			# Number of corrosion loops in the simulation 
```
- 运行程序：
```bash
# terminal
> mkdir  Figure4 #创建目录
> cp Figure4_CreateStartConfig Figure4 #复制初始构型生成脚本文件
> cp PerformCorrosion.sh Figure4 #复制Monte Carlo Simulation脚本文件
> source Figure4_CreateStartConfig.sh #获取样品初始构型
> source PerformCorrosion.sh #执行Monte Carlo Simulation
```
等待计算机运行200蒙特卡洛步后，在`Figure4`目录下找到生成的`300K-2.90eV`
子目录，并在此目录中找到`plot.txt`文件。此文件记录了每一蒙特卡洛步中样品的总原子数量和被腐蚀原子数量。根据这些数据即可作图。







# Pitting Corrosion Simulation
本repository包含两个内容：2. 蒙特卡洛点蚀代码。1. Pitting Corrosion Simulation手稿中各个曲线中的数据。本文分别解释了这些数据，以及怎么搭配Monte Carlo和Fortran一起使用。

## Data Explanation
本节针对手稿中对应图片的数据进行说明。
### Figure 4
该图片数据处于[Figure 4](https://github.com/junbhuang-sci/Pitting-Corrosion-Simulation/tree/main/Figure4)文件夹中，其中包含对应的分子动力学样品生成脚本`Figure4_CreateStartConfig.sh`，以及分别存储在`Figure 4d`, `Figure 4e`两个子文件夹的对应的图片数据。
***
数据获取流程如下：
(其中Monte Carlo Simulation脚本文件位于[junbhuang-sci/Pitting-Corrosion-Simulation](https://github.com/junbhuang-sci/Pitting-Corrosion-Simulation/tree/main))

- 对于曲线Figure 4d, E0 = -2.90 eV，
Monte Carlo Simulation脚本文件的参数分别为：
```bash
# PerformCorrosion.sh
> Cutoff=3.2			# distance between nearest neighbors
> Temperature=300	# unit K
> ECut=-2.90			# eV, atoms with pe above this value will be coroded certainly
> NLoop=200  			# Number of corrosion loops in the simulation 
```
- 运行程序：
```bash
# terminal
> mkdir  Figure4 #创建目录
> cp Figure4_CreateStartConfig Figure4 #复制初始构型生成脚本文件
> cp PerformCorrosion.sh Figure4 #复制Monte Carlo Simulation脚本文件
> source Figure4_CreateStartConfig.sh #获取样品初始构型
> source PerformCorrosion.sh #执行Monte Carlo Simulation
```
等待计算机运行200蒙特卡洛步后，在`Figure4`目录下找到生成的`300K-2.90eV`
子目录，并在此目录中找到`plot.txt`文件。此文件记录了每一蒙特卡洛步中样品的总原子数量和被腐蚀原子数量。根据这些数据即可作图。









## Monte Carlo Fortran Code
### Requirements
1. lammps-22Jul2025或更晚
2. linux  environment
3. gfortran

## 







## Monte Carlo Fortran Code
### Requirements
1. lammps-22Jul2025或更晚
2. linux  environment
3. gfortran

## 



