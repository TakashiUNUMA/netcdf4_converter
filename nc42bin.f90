!
! Program of nc42bin.f90
! produced by Takashi Unuma, Kyoto Univ.
! Last modified: 2013/07/05
!

program nc42bin
  
  implicit none
  
  !--- for netcdf4 I/O
  include 'netcdf.inc'
  integer :: ncid,varid,retval
  !--- for netcdf4 I/O
  
  integer :: i,j,imax,jmax
  real, dimension(:,:), allocatable :: d_org
  character(len=20)  :: varname
  character(len=42)  :: input,output
  integer :: debug_level
  
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  ! Input parameters from namelist
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  namelist /param/ imax,jmax,varname,input,output,debug_level
  open(unit=10,file='namelist.nc42bin',form='formatted',status='old',access='sequential')
  read(10,nml=param)
  close(unit=10)
  if(debug_level.ge.100) print '(a17,i6)',  " imax         = ", imax
  if(debug_level.ge.100) print '(a17,i6)',  " jmax         = ", jmax
  if(debug_level.ge.100) print '(a17,a20)', " varname      = ", varname
  if(debug_level.ge.100) print '(a17,a80)', " input        = ", input
  if(debug_level.ge.100) print '(a17,a80)', " output       = ", output
  if(debug_level.ge.100) print '(a17,i6)',  " debug_level  = ", debug_level

  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  ! Initialization
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  allocate( d_org(imax,jmax) )
  do j=1,jmax,1
  do i=1,imax,1
     d_org(i,j) = 0.
  end do
  end do
  
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  ! Open the original file for netcdf4 format
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  retval = nf_open(input, NF_NOWRITE, ncid)
  if(retval .ne. nf_noerr) call handle_err(retval)
  if(debug_level.ge.100) print *, " ncid          = ", ncid
  retval = nf_inq_varid(ncid, varname, varid)
  if(retval .ne. nf_noerr) call handle_err(retval)
  if(debug_level.ge.100) print *, " varid         = ", varid
  retval = nf_get_var_real(ncid, varid, d_org)
  if(retval .ne. nf_noerr) call handle_err(retval)
  if(debug_level.ge.100) print *, " d_org(1,1)    = ", d_org(1,1)
  retval = nf_close(ncid)
  if(retval .ne. nf_noerr) call handle_err(retval)  
  if(debug_level.ge.100) print *, "Success read netcdf4 data"
  
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  ! Output the composit file
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  open(11, file=output,form='unformatted',access='direct',recl=imax*jmax*4)
  write(11,rec=1) d_org
  close(11)
  if(debug_level.ge.100) print *, "Success output binary data"
  
contains
  
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  !     subroutine of handle_err for netcdf4 I/O
  !ccccccccccccccccccccccccccccccccccccccccccccccccc
  subroutine handle_err(errcode)
    implicit none
    include 'netcdf.inc'
    integer :: errcode
    
    print *, 'Error: ', nf_strerror(errcode)
    
    stop
  end subroutine handle_err
  
end program nc42bin
