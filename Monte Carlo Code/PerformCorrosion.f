      program PerformCorrosion

c---- Define variables -------------------------------------------------
      integer i,j,k,Total,CurPos1,CurPos2,GBTotal,nbin,NewTotal,
     &      Corroded_Atoms
      integer jx,jy,jz,idx0,idx1,ix,iy,iz,kx,ky,kz,nx,ny,nz,idx2
      double precision, allocatable:: x(:),y(:),z(:)
      double precision, allocatable:: x0(:),y0(:),z0(:),pe(:)
      double precision x1,y1,z1
      
      integer, allocatable:: idx(:,:,:,:),typ(:),id(:)      
      integer, allocatable:: id0(:),mdx(:,:,:),id2(:)
      integer, allocatable:: cid(:),catom(:),natom(:)
      integer cnum,i0,j0,k0
      double precision xlo,xhi,ylo,yhi,zlo,zhi,bx,by,bz,bx1,by1,bz1
      double precision Cutoff, ECut,Temp,Threshold
      double precision kB
      integer flag
      
      character*80 DmpFile
      character*80 ProgInputString,String(16)

      character(len=:),allocatable:: InputString
      character*80, allocatable:: OutputString(:)
      integer :: iunit,istat,filesize
      character(len=1) :: c

      real :: start, finish
      real InputTime,OutputTime,AnalysisTime,TotalTime

c---- Get the input file name ------------------------------------------#Read the parameters in $HOME/Fortran/PerformCorrosion \$DmpFile $Cutoff $ECut $Temperature     

      call getarg(1,ProgInputString)
      if(ProgInputString.eq.'') stop "ERROR: No DmpFile!"
      read(ProgInputString,'(A)')DmpFile
      
      call getarg(2,ProgInputString)
      if(ProgInputString.eq.'') stop "ERROR: No Cutoff!"
      read(ProgInputString,*)cutoff

      call getarg(3,ProgInputString)
      if(ProgInputString.eq.'') stop "ERROR: No Energy Cutoff!"
      read(ProgInputString,*)ECut

      call getarg(4,ProgInputString)
      if(ProgInputString.eq.'') stop "ERROR: No Temperature!"
      read(ProgInputString,*)Temp
      
c---- Read input files -------------------------------------------------
      call cpu_time(start)
      
      open(unit = 111,file = DmpFile,status = 'unknown')
      do i = 1, 9
        read(111,'(A)')String(i)            
      enddo
      read(String(4),*)Total
      read(String(6),*)xlo,xhi
      read(String(7),*)ylo,yhi
      read(String(8),*)zlo,zhi

      inquire(file=DmpFile, pos=CurPos1)
      close(111)

      allocate(id(Total))
      allocate(id0(Total))
      allocate(typ(Total))
      allocate(x(Total))
      allocate(y(Total))
      allocate(z(Total))
      allocate(pe(Total))    ! indexed based on atom id
      allocate(id2(Total))

      print '(A)', "Reading DmpFile"
      open(unit=222,file=DmpFile,status='OLD',form='UNFORMATTED',
     &     access='STREAM',iostat=istat)
      if (istat==0) then
        inquire(file=DmpFile,size=filesize)
        if(filesize>0) then
          ! read the file all at once
          allocate(character(len=filesize-CurPos1)::InputString)
          read(222,pos=CurPos1,iostat=istat) InputString
          if(istat==0) then
            !make sure it was all read by trying to read more:
            read(222,pos=filesize+1,iostat=istat) c
            if (.not. IS_IOSTAT_END(istat))  then
              write(*,*) 'Error: DmpFile was not completely read.'
            else
              read(InputString,*)(id(i),typ(i),x(i),y(i),z(i),
     &             pe(i),i=1,Total)
              deallocate(InputString)              
            end if  !(.not.)        
            close(222, iostat=istat)
          else
            stop 'ERROR: Cannot read DmpFile'
          endif !(istat==0)
        else
          stop 'ERROR: Cannot get DmpFile size'
        endif !(filesize>0)
      else
        stop 'ERROR: cannot open DmpFile!'
      endif !(istat==0)
            
      call cpu_time(finish)
      InputTime = finish-start

c---- Store data -----------------------------------------------------
      print '(A)', "Store the data"
      call cpu_time(start)

      bx = xhi - xlo
      by = yhi - ylo
      bz = zhi - zlo

      nx = bx / cutoff
      ny = by / cutoff
      nz = bz / cutoff

      dx = bx/nx
      dy = by/ny
      dz = bz/nz
      
      ! max number of atoms stored in each bin
      nbin = 20.0*Total/(nx*ny*nz)

      allocate(idx(1:nx,1:ny,1:nz,1:nbin))
      allocate(mdx(1:nx,1:ny,1:nz))      

      ! Index the atoms to a 3D bin
      print '(A)', "Maping the atoms into a 3D array"
      mdx = 0
      idx = 0
      idx2 = 0
      Corroded_Atoms = 0
      
      do i = 1, Total
        if(typ(i).eq.2) then
          ! Store surface atom list
          idx2 = idx2 + 1
          id2(idx2) = i
        endif
        
        if(x(i).lt.xlo) x(i) = x(i) + bx
        if(x(i).ge.xhi) x(i) = x(i) - bx
        if(y(i).lt.ylo) y(i) = y(i) + by
        if(y(i).ge.yhi) y(i) = y(i) - by
        if(z(i).lt.zlo) z(i) = zlo
        if(z(i).ge.zhi) z(i) = zhi      

        jx = int((x(i) - xlo)/dx) + 1
        if(jx.gt.nx) jx = nx
        jy = int((y(i) - ylo)/dy) + 1
        if(jy.gt.ny) jy = ny
        jz = int((z(i) - zlo)/dz) + 1    
        if(jz.gt.nz) jz = nz    

        mdx(jx,jy,jz) = mdx(jx,jy,jz) + 1    
        if(mdx(jx,jy,jz).gt.nbin)then
          print *,"ERROR!TOO MAmax_bin_y ATOMS IN A BIN!"
          print *,"ERROR!TOO MAmax_bin_y ATOMS IN A BIN!"
          print *,"ERROR!TOO MAmax_bin_y ATOMS IN A BIN!"
          print *,"Current BIN:"
          print *,mdx(jx,jy,jz)
          print *,"MAmax_bin_y:"
          print *,nbin
        endif    

        idx(jx,jy,jz,mdx(jx,jy,jz)) = i        
      enddo
c---- Do the corrosion -------------------------------------------------
      print '(A)', "Perform the corosion"
      kB = 8.6173303e-5  !! eV/K
      call srand(int(start*1e8))

      iLoop = 0
      idx0 = 0
      NewTotal = Total
      do while(Total.eq.NewTotal)
        iLoop = iLoop + 1
        do j = 1, idx2
          i = id2(j)
          if(pe(i).ge.ECut) then ! corode this atom
            typ(i) = 0
            idx0 = idx0 + 1
            id0(idx0) = i
            NewTotal = NewTotal - 1
          else
            Threshold=exp((pe(i)-ECut)/kB/Temp)
            if(rand().lt.Threshold) then ! corode this atom
              typ(i)=0
              idx0 = idx0 + 1  ! number of coroded atoms
              id0(idx0) = i
              NewTotal = NewTotal - 1
              Corroded_Atoms = Corroded_Atoms + 1
            endif
          endif 
        enddo !j=1
      enddo !while
      
c---- Search neighbor of coroded atoms ---------------------------------
      do iatom = 1, idx0
      jdx = id0(iatom)
      ! Search neighbors of this atom
      i0 = 1 + int((x(jdx)-xlo)/dx)
      j0 = 1 + int((y(jdx)-ylo)/dy)
      k0 = 1 + int((z(jdx)-zlo)/dz)
      
      do ix = -1, 1
      do iy = -1, 1
      do iz = -1, 1
        i1 = i0 + ix
        if(i1.lt.1) then
          i1 = i1 + nx
        else if(i1.gt.nx) then
          i1 = i1 - nx
        endif
            
        j1 = j0 + iy
        if(j1.lt.1) then
          j1 = j1 + ny
        else if(j1.gt.ny) then
          j1 = j1 - ny
        endif

        k1 = k0 + iz
        if(k1.lt.1) then
          cycle
        else if(k1.gt.nz) then
          cycle
        endif
        
        ! Search atoms in each bin
        do l1 = 1, mdx(i1,j1,k1)
          jdx1 = idx(i1,j1,k1,l1)
          if(typ(jdx1).eq.2) cycle
          if(typ(jdx1).eq.0) cycle

          ! Calculate projected distance between jdx1 and jdx                  
          d1 = abs(x(jdx)-x(jdx1))    
          if(d1.gt.bx/2.0) d1 = bx - d1              
          if(d1.gt.cutoff) cycle
                  
          d2 = abs(y(jdx)-y(jdx1))
          if(d2.gt.by/2.0) d2 = by - d2
          if(d2.gt.cutoff) cycle

          d3 = abs(z(jdx)-z(jdx1))
c          if(d3.gt.bz/2.0) d3 = bz - d3
          if(d3.gt.cutoff) cycle
                  
          d = sqrt(d1*d1 + d2*d2 + d3*d3)
          if(d.gt.cutoff) cycle

          ! Now jdx1 is a neighbor of jdx and a new surface atom
          typ(jdx1) = 2               
        enddo  ! l1 loop
      enddo !iz
      enddo !iy
      enddo !ix
      enddo !iatom

      call cpu_time(finish)
      AnalysisTime = finish-start  

c---- Output data ------------------------------------------------------
      call cpu_time(start)

      print '(A)',"Output Data file after corrosion"
      allocate(OutputString(NewTotal))

      idx0 = 0
      do i = 1, Total
        if(typ(i).eq.0) cycle  
        idx0 = idx0 + 1     
        write(OutputString(idx0),100)id(i),typ(i),x(i),y(i),z(i)
      enddo

      ! Update data head file
      open(unit = 111,file = 'DataHead',status = 'unknown')
      do i = 1, 16
        read(111,'(A)')String(i)            
      enddo
      close(111)

      String(1)='Data file right after corosion'
      write(String(3),'(I0,A)')NewTotal,' atoms'

      write(String(6),'(F14.7,1X,F14.7,A)')xlo,xhi,' xlo xhi'
      write(String(7),'(F14.7,1X,F14.7,A)')ylo,yhi,' ylo yhi'
      write(String(8),'(F14.7,1X,F14.7,A)')zlo-1,zhi+1,' zlo zhi'
      

      open(unit = 333, file = 'data', status = 'unknown')
      write(333,'(A)')(trim(String(i)),i = 1, 16)
      write(333,'(A)')(trim(OutputString(i)),i=1,NewTotal)

      deallocate(OutputString)
      
      call cpu_time(finish)
      OutputTime = finish-start

      open(unit = 444,file = 'plot.txt',status = 'unknown' ,
     &     position = 'APPEND')	
          write(444,*) NewTotal , Corroded_Atoms
      close(444)
c---- End of the program -----------------------------------------------
100   FORMAT(I0,1X,I0,1X,F14.7,1X,F14.7,1X,F14.7)  
      end
      
