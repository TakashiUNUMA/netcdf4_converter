!
! program of bin2nc4
!
! modified by Takashi Unuma, Kyoto Univ.
! last modified: 2013/07/05
!

program bin2nc4

  use netcdf
  implicit none

  integer :: NLONS, NLATS, NLVLS, deflate_level
  integer :: lat, lon, rec, i, j
  integer :: ncid, varid, lon_varid, lat_varid
  integer :: lvl_dimid, lon_dimid, lat_dimid, rec_dimid
  integer, dimension(:) :: start, count, dimids, chunks
  real :: START_LON, START_LAT, LON_INT, LAT_INT
  real, dimension(:) :: lons, lats
  real, dimension(:,:,:), allocatable :: var_out
  character (len = 10) :: VAR_UNITS, LAT_UNITS, LON_UNITS
  character (len = 10) :: LON_NAME, LAT_NAME, LVL_NAME, REC_NAME
  character (len = 20) :: VAR_NAME
  character (len = 80) :: infile
  character (len = 80) :: outfile
  real :: nan
  data nan/Z'7fffffff'/
  integer :: debug_level

  integer, parameter :: NDIMS = 4, NRECS = 1
  character (len = *), parameter :: UNITS = "units"


  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Input from namelist
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  namelist /param/ INFILE,OUTFILE,NLONS,NLATS,NLVLS,START_LON,START_LAT,LON_INT,LAT_INT, &
       LON_UNITS,LAT_UNITS,VAR_UNITS,LON_NAME,LAT_NAME,LVL_NAME,VAR_NAME,deflate_level,  &
       debug_level
  open(10,file='namelist.bin2nc4',form='formatted',status='old',access='sequential')
  read(10,nml=param)
  close(10)
  if(debug_level.ge.100) print '(a17,a80)',   " INFILE        = ", INFILE
  if(debug_level.ge.100) print '(a17,a80)',   " OUTFILE       = ", OUTFILE
  if(debug_level.ge.100) print '(a17,i6)',    " NLONS         = ", NLONS
  if(debug_level.ge.100) print '(a17,i6)',    " NLATS         = ", NLATS
  if(debug_level.ge.100) print '(a17,i6)',    " NLVLS         = ", NLEVS
  if(debug_level.ge.100) print '(a17,f10.6)', " START_LON     = ", START_LON
  if(debug_level.ge.100) print '(a17,f10.6)', " START_LAT     = ", START_LAT
  if(debug_level.ge.100) print '(a17,f10.6)', " LON_INT       = ", LON_INT
  if(debug_level.ge.100) print '(a17,f10.6)', " LAT_INT       = ", LAT_INT
  if(debug_level.ge.100) print '(a17,a10)',   " LON_UNITS     = ", LON_UNITS
  if(debug_level.ge.100) print '(a17,a10)',   " LAT_UNITS     = ", LAT_UNITS
  if(debug_level.ge.100) print '(a17,a10)',   " VAR_UNITS     = ", VAR_UNITS
  if(debug_level.ge.100) print '(a17,a10)',   " LON_NAME      = ", LON_NAME
  if(debug_level.ge.100) print '(a17,a10)',   " LAT_NAME      = ", LAT_NAME
  if(debug_level.ge.100) print '(a17,a10)',   " LVL_NAME      = ", LVL_NAME
  if(debug_level.ge.100) print '(a17,a20)',   " VAR_NAME      = ", VAR_NAME
  if(debug_level.ge.100) print '(a17,i6)',    " deflate_level = ", deflate_level
  if(debug_level.ge.100) print '(a17,i6)',    " debug_level   = ", debug_level
  if(debug_level.ge.100) print *, "Success read namelist's values"

  ! Allocate memory.
  allocate( start(NDIMS),count(NDIMS),dimids(NDIMS),chunks(NDIMS),lats(NLATS),lons(NLONS))
  allocate( var_out(NLONS, NLATS, NLVLS) )
  if(debug_level.ge.100) print *, "Success allocate memory"

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Initialization
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  do j=1,NLATS
  do i=1,NLONS
     var_out(i,j,1) = 0.
  end do
  end do

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Open the original file and read data
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  open(11,file=infile,access='direct',status='old',recl=NLONS*NLATS*4)
  read(11,rec=1) var_out(:,:,1)
  close(11)
  
  do j=1,NLATS
  do i=1,NLONS
     if(vae_out(i,j,1).lt.0.) then
        var_out(i,j,1) = nan
     end if
  end do
  end do
  if(debug_level.ge.100) print *, "Success define var_out(1,1,1): ",var_out(1,1,1)
  if(debug_level.ge.100) print *, "Success read the input data"

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Create pretend data. If this were not an example program, we would
  ! have some real data to write, for example, model output.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  do lon = 1, NLONS
     lons(lon) = START_LON + real(lon - 1) * LON_INT
  end do
  do lat = 1, NLATS
     lats(lat) = START_LAT + real(lat - 1) * LAT_INT
  end do
  if(debug_level.ge.100) print *, "Success define lons(1): ",lons(1)
  if(debug_level.ge.100) print *, "Success define lats(1): ",lats(1)

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Create the file. 
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_create(FILE_NAME, nf90_hdf5, ncid) )
  if(debug_level.ge.100) print *, "Success create the file"

  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! Define the dimensions. The record dimension is defined to have
  ! unlimited length - it can grow as needed. In this example it is
  ! the time dimension.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_def_dim(ncid, REC_NAME, NF90_UNLIMITED, rec_dimid) )
  call check( nf90_def_dim(ncid, LON_NAME, NLONS, lon_dimid) )
  call check( nf90_def_dim(ncid, LAT_NAME, NLATS, lat_dimid) )
  call check( nf90_def_dim(ncid, LVL_NAME, NLVLS, lvl_dimid) )
  if(debug_level.ge.100) print *, "Success define the dimensions"

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Define the coordinate variables. We will only define coordinate
  ! variables for lat and lon.  Ordinarily we would need to provide
  ! an array of dimension IDs for each variable's dimensions, but
  ! since coordinate variables only have one dimension, we can
  ! simply provide the address of that dimension ID (lat_dimid) and
  ! similarly for (lon_dimid).
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_def_var(ncid, LON_NAME, NF90_REAL, lon_dimid, lon_varid) )
  call check( nf90_def_var(ncid, LAT_NAME, NF90_REAL, lat_dimid, lat_varid) )
  if(debug_level.ge.100) print *, "Success define the coordinate variables"

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Assign units attributes to coordinate variables.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_put_att(ncid, lon_varid, UNITS, LON_UNITS) )
  call check( nf90_put_att(ncid, lat_varid, UNITS, LAT_UNITS) )
  if(debug_level.ge.100) print *, "Success assign units attributes"

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! The dimids array is used to pass the dimids of the dimensions of
  ! the netCDF variables. Both of the netCDF variables we are creating
  ! share the same four dimensions. In Fortran, the unlimited
  ! dimension must come last on the list of dimids.
  ! and define the chunk size.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  dimids = (/ lon_dimid, lat_dimid, lvl_dimid, rec_dimid /)
  chunks = (/ NLONS, NLATS, NLVLS, 1 /)

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Define the netCDF variables for the pressure and temperature data
  ! with compressed foemat(netcdf4).
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_def_var(ncid, VAR_NAME, NF90_REAL, dimids, varid, &
       chunksizes = chunks, shuffle = .TRUE., deflate_level = deflate_level) )
  if(debug_level.ge.100) print *, "Success define the netcdf variables"

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Assign units attributes to the netCDF variables.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_put_att(ncid, varid, UNITS, VAR_UNITS) )
  if(debug_level.ge.100) print *, "Success assign units attributes"

  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! End define mode.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_enddef(ncid) )
  if(debug_level.ge.100) print *, "End define mode"

  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! Write the coordinate variable data. This will put the latitudes
  ! and longitudes of our data grid into the netCDF file.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_put_var(ncid, lat_varid, lats) )
  call check( nf90_put_var(ncid, lon_varid, lons) )
  if(debug_level.ge.100) print *, "Success write the coordinate variable data"

  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! These settings tell netcdf to write one timestep of data. (The
  ! setting of start(4) inside the loop below tells netCDF which
  ! timestep to write.)
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  count = (/ NLONS, NLATS, NLVLS, 1 /)
  start = (/ 1, 1, 1, 1 /)

  !ccccccccccccccccccccccccccccccccccccccccccccccc
  ! Write the pretend data. This will write our surface pressure and
  ! surface temperature data. The arrays only hold one timestep worth
  ! of data. We will just rewrite the same data for each timestep. In
  ! a real :: application, the data would change between timesteps.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  do rec = 1, NRECS
     start(4) = rec
     call check( nf90_put_var(ncid, varid, var_out, start = start, count = count) )
  end do
  if(debug_level.ge.100) print *, "Success write the pretend data"

  !ccccccccccccccccccccccccccccccccccccccccccccccc  
  ! Close the file. This causes netCDF to flush all buffers and make
  ! sure your data are really written to disk.
  !ccccccccccccccccccccccccccccccccccccccccccccccc
  call check( nf90_close(ncid) )
  if(debug_level.ge.100) print *, "Success close the netcdf file"

contains

  subroutine check(status)
    integer, intent ( in) :: status
    
    if(status /= nf90_noerr) then 
       print *, trim(nf90_strerror(status))
       stop 2
    end if
  end subroutine check

end program bin2nc4
