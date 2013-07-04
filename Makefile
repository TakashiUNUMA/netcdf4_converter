#
# Makefile for bin2nc4.f90
# original makefile coded by Takashi Unuma, Kyoto Univ.
# Last modified: 2013/07/05
#

#-------------------------------------------------
# Make for Intel Compiler on Linux x86_64 system
#FC      = ifort
#NETCDF  = /home/unuma/usr/local/netcdf-4.1.3
#ZLIB    = /home/unuma/usr/local/zlib-1.2.5
#HDF5    = /home/unuma/usr/local/hdf5-1.8.7
#FFLAGS  = -I$(NETCDF)/include -FR -O3 -xSSE4.2 -assume byterecl -i-dynamic -fno-alias -unroll0 -ipo
#FFLAGS  = -I$(NETCDF)/include -FR -g -O0 -assume byterecl -i-dynamic -warn all -check all
# -----
# Make for GNU Compiler on Linux x86_64 system
FC      = gfortran44
NETCDF  = /home/unuma/usr/local/netcdf-4.1.3-gnu
ZLIB    = /home/unuma/usr/local/zlib-1.2.5-gnu
HDF5    = /home/unuma/usr/local/hdf5-1.8.7-gnu
#FFLAGS	= -I$(NETCDF)/include -frecord-marker=4 -ffree-form -O3 -ftree-vectorize -funroll-loops -fno-range-check
FFLAGS	= -I$(NETCDF)/include -frecord-marker=4 -ffree-form -O0 -Wall -Wuninitialized -ffpe-trap=invalid,zero,overflow -fbounds-check -fno-range-check
#-------------------------------------------------


LDFLAGS = $(NETCDF)/lib/libnetcdff.la $(NETCDF)/lib/libnetcdf.la -L$(ZLIB)/lib -L$(HDF5)/lib
LIBS    = -lhdf5_hl -lhdf5 -lm -lcurl -lnetcdf

OBJECT = bin2nc4.o

.SUFFIXES:
.SUFFIXES: .f90 .o

all: bin2nc4

bin2nc4: $(OBJECT)
	libtool --tag=F77 --mode=link $(FC) $(FFLAGS) $(LDFLAGS) -o $@ $(OBJECT) $(LIBS)

clean:
	rm -rf *.o *genmod.* *.f90~ Makefile~ bin2nc4 .libs

.f90.o:
	$(FC) $(FFLAGS) -c -o $@ $*.f90

############################################################ end
.NOEXPORT:
