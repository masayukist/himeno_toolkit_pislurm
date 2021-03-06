include ./autogen/Makefile.in

default: sbatch

${BIN}: ${SOURCE}
	mpif90 -fallow-argument-mismatch -O3 $< -o $@
	rm -f *.o

sbatch: ${BIN}
	sbatch ${JOB}

clean:
	rm -rf autogen *~ *.mod

distclean: clean
	rm -rf params.sh
