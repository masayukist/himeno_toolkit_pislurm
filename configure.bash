#!/bin/bash

if [ ! -e params.sh ]
then
	echo "ERROR: generate params.sh before executing this script."
	exit 1
fi

# Configure the parameters
source params.sh

### Do not edit the following codes ###

N_PROC=`expr $IDIV \* $JDIV \* $KDIV`
N_PROC_PER_NODE=`expr $N_PROC / $N_NODE`

echo himeno Size: $SIZE
echo himeno DDM: $IDIV-$JDIV-$KDIV
echo Nodes: $N_NODE
echo MPI processes: $N_PROC
echo Processes per node: $N_PROC_PER_NODE

OUTPUT_SUFFIX=nn_${N_NODE}_np_${N_PROC}_${SIZE}_${IDIV}-${JDIV}-${KDIV}

INFILE=./autogen/himeno.${OUTPUT_SUFFIX}.in
SOURCE=./autogen/himeno.${OUTPUT_SUFFIX}.f90
BIN=./autogen/himeno.${OUTPUT_SUFFIX}.bin
JOB=./autogen/himeno.${OUTPUT_SUFFIX}.sh


mkdir -p ./autogen

sed -e s/himeno.in/himeno.${OUTPUT_SUFFIX}.in/ himenoBMTxpr.f90 > ${SOURCE}

cat <<EOF > ${INFILE}
$SIZE
$IDIV
$JDIV
$KDIV
EOF

cat <<EOF > ./autogen/Makefile.in
INFILE=${INFILE}
SOURCE=${SOURCE}
BIN=${BIN}
JOB=${JOB}
EOF

echo ${INFILE} is set.

################ job script

cat <<EOF > ${JOB}
#!/bin/bash
#SBATCH -N $N_NODE
#SBATCH -n $N_PROC
#SBATCH -o result.${OUTPUT_SUFFIX}.txt
#SBATCH --exclusive

mpirun -np $N_PROC ${BIN}
EOF

chmod 755 ${JOB}

echo ${JOB} is set.
