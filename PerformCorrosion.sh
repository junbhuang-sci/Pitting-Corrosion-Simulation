Cutoff=3.2   		  # distance between nearest neighbors
Temperature=300  	# unit K
ECut=-2.7      		# eV, atoms with pe above this value will be coroded certainly

NLoop=200      		# Number of corrosion loops in the simulation

Potential=/home/Username/Potentials/Al_zhou.eam.alloy # Path of the potiantial file
NumNode=1         # number of adopted node 
NumCore=52        # number of adopted cores 
#--- End of Input --------------------------------------------
CurDir=$PWD

DataFile="$CurDir/StartConfig/data"
if [ ! -e $DataFile ];then
  echo "ERROR: DataFile in StartConfig does not exist!"
  return
fi

WorkDir=${Temperature}K${ECut}eV
echo "Performing pit corrosion in $WorkDir"
test -e $WorkDir||mkdir $WorkDir
cd $WorkDir
rm -f *

cp $DataFile data

InputFile="$CurDir/StartConfig/input"
if [ ! -e $InputFile ];then
  echo "ERROR: InputFile in StartConfig does not exist!"
  return
fi

#Create lammps input file
cat >input<<EOF
units		metal
boundary	  p p s
atom_style	atomic
neighbor	  2.0 bin

#Define simulation box
read_data	  data

# set up interaction
pair_style	eam/alloy
pair_coeff	* * $Potential Al Al

compute 	  pe all pe/atom
thermo		  100

dump		    1 all custom 20000 config.*.dmp id type x y z c_pe

min_style	  cg
minimize 	  1.0e-4 1.0e-6 100000 1000000
EOF

RunMpiFile="$CurDir/StartConfig/run_mpi"
if [ ! -e $RunMpiFile ];then
  echo "ERROR: run_mpi in $NEdge/StartConfig does not exist!"
  cd $CurDir
  return
fi

cat>run_mpi<<EOF
#!/bin/bash
#SBATCH --nodes=$NumNode
#SBATCH --ntasks-per-node=$NumCore
#SBATCH --cpus-per-task=1
#SBATCH --time="600:00:00"
#SBATCH -J $WorkDir
source /ndata/software/intel/oneapi/setvars.sh intel64
source /ndata/software/intel/oneapi/mpi/2021.4.0/env/vars.sh intel64

export I_MPI_PMI_LIBRARY="/usr/lib64/libpmi.so"

# Perform lammps calculations
echo "Perform lammps --------------------------------------------------------------"

srun -n \$SLURM_NTASKS /ndata/software/lammps-10Feb15/lmp_mpi_meam -in input

DmpFile=\`ls config.*.dmp -t|awk '{print $1}'|head -1\`
head -16 data>DataHead

mv \$DmpFile corrosion.0.dmp
DmpFile=corrosion.0.dmp
rm config.*.dmp
echo 


# Perform corrosion simulations
for (( iLoop=1; iLoop<=$NLoop; iLoop++ )); do

echo "Perform corrosion------------------------------------------------------------"
$HOME/Fortran/PerformCorrosion \$DmpFile $Cutoff $ECut $Temperature
echo

echo "Perform lammps --------------------------------------------------------------"
srun -n \$SLURM_NTASKS /ndata/software/lammps-10Feb15/lmp_mpi_meam -in input
DmpFile=\`ls config.*.dmp -t|awk '{print $1}'|head -1\`
mv \$DmpFile corrosion.\$iLoop.dmp
DmpFile=corrosion.\$iLoop.dmp
rm config.*.dmp
head -16 data>DataHead
echo
done
EOF

sbatch run_mpi

cd $CurDir

squeue -u zpan