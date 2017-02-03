C MODULE PLOTD
C-----------------------------------------------------------------------
C
      SUBROUTINE  PLOTD  (NSTA,STNAME,IMO,IYR,UNITS,IMOW,IMOS,IGS,NG,
     *          NPG,BASE,OPT6,PX,NMO,ORD,MONTHLY_FLAG)
C
C     CONSISTENCY CHECK COMPUTATIONAL SUBROUTINE.
C
      INCLUDE 'uiox'
      COMMON  /DIM/  M1,M2,M3,M4,M5,M6
C
      INTEGER*2    MONTHLY_FLAG(200,600),IFLAG(5)
      DIMENSION    STNAME(7,M1),IGS(3,M1),BASE(3,M3),PX(M1,M3)
      DIMENSION    BSTA(5),ACCUM(5),IGN(5),SYM(5),S(11),NPG(3),NPLUS(3)
      DIMENSION    ORD(101,101)
      DIMENSION    WNTR(2),SUMR(2),BLNK(2),SN(2)
C
      INTEGER      OPT6
c
      CHARACTER*132  DMA_FNAME
C
      COMMON  /MAP/  DEBUG,DEBUGA
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/calb/src/map/RCS/plotd.f,v $
     . $',                                                             '
     .$Id: plotd.f,v 1.4 2001/06/12 15:37:26 aivo Exp $
     . $' /
C    ===================================================================
C
      DATA BLANK,DOT,ASTER/1H ,1H.,1H*/
      DATA SYM/1H1,1H2,1H3,1H4,1H5/
      DATA         WNTR/4HWINT,4HER  /,SUMR/4HSUMM,4HER  /
      DATA         BLNK/4H    ,4H    /
C
C
      IF (DEBUG.EQ.1.OR.DEBUGA.EQ.1) WRITE (LP,*) 'ENTER PLOTD'
C
      LMOW=IMOS-1
      LMOS=IMOW-1
      IYR=IYR+1900
c
C  SET FILE NAME FOR IDMA OUTPUT
      CALL USUFIT (LP,'_dma',DMA_FNAME,ISTAT)
      IF (ISTAT.NE.0) THEN
         WRITE (LP,315) 'USUFIT',ISTAT
         CALL UWARN (LP,0,-1)
         ENDIF
C
C  OPEN FILE NAME FOR IDMA OUTPUT
      LSYS=99
      CALL UPOPEN (LSYS,DMA_FNAME,0,'F',ISTAT)
      IF (ISTAT.NE.0) THEN
         WRITE (LP,315) 'UPOPEN',ISTAT
         CALL UWARN (LP,0,-1)
         ENDIF
C
C  IF NO GROUPS SPECIFIED, PUT ALL STATIONS IN ONE GROUP
      IF (NG.GT.0)  GO TO 20
      NG=1
      NPG(1)=NSTA
      NPLUS(1)=NSTA
      DO 10 I=1,NSTA
10    IGS(1,I)=I
      GO TO 50
C
20    DO 40 IG=1,NG
         NUM=NPG(IG)
         NP=0
         DO 30 I=1,NUM
            N=IGS(IG,I)
            IF (N.GT.0) NP=NP+1
            N=IABS(N)
30          CONTINUE
         NPLUS(IG)=NP
40       CONTINUE
C
C  PRINT TITLE PAGE
50    WRITE(LP,330)
      WRITE(LP,340)
      WRITE(LP,350)
      WRITE(LP,360)
      DO 60 IG=1,NG
      WRITE(LP,370) IG
      WRITE(LP,380)
      NUM=NPG(IG)
      DO 60 I=1,NUM
      N=IGS(IG,I)
      NN=IABS(N)
      WRITE(LP,390) N,(STNAME(J,NN),J=1,5)
60    CONTINUE
C
C  COMPUTE BASE FOR EACH GROUP
      DO 90 IG=1,NG
         NUM=NPG(IG)
         FNP=NPLUS(IG)
         FNP=1.0/FNP
         BS=0.0
            DO 80 M=1,NMO
            BMO=0.0
            DO 70 I=1,NUM
               N=IGS(IG,I)
               IF (N.LT.0)GO TO 70
               BMO=BMO+PX(N,M)*FNP
70             CONTINUE
            BS=BS+BMO
            BASE(IG,M)=BS
80          CONTINUE
90       CONTINUE
C
C  SET-UP PLOTS
C
      DO 310 IG=1,NG
C
      NUM=NPG(IG)
      FNP=NPLUS(IG)
      NPLOTS=(NUM-1)/5+1
C
      DO 300 IP=1,NPLOTS
      II=(IP-1)*5+1
      IL=IP*5
      IF (IL.GT.NUM)IL=NUM
      NN=IL-II+1
C
      DO 100 I=II,IL
      J=I-II+1
      N=IGS(IG,I)
      IGN(J)=IABS(N)
100   CONTINUE
C
      IPASS=1
110   WRITE(LP,400)
      WRITE(LP,410)  ((STNAME(I,IGN(J)),I=1,5),J=1,NN)
      WRITE(LSYS,415) ((STNAME(I,IGN(J)),I=1,5),J=1,NN)
      WRITE(LP,420)
C
      DO 120 I=1,2
         IF (OPT6.EQ.1) SN(I)=BLNK(I)
         IF (OPT6.EQ.2.AND.IPASS.EQ.1) SN(I)=WNTR(I)
         IF (OPT6.EQ.2.AND.IPASS.EQ.2) SN(I)=SUMR(I)
120      CONTINUE
      WRITE (LP,430) SN
C
C     COMPUTE PLOT SCALES AND PRINT ACCUMULATIONS.
      DMAX=0.0
      DMIN=0.0
      BMAX=0.0
      BP=0.0
C
      DO 180 M=1,NMO
      BMO=BASE(IG,M)
      JYR=(M-1)/12
      MO=M-JYR*12
      MO=IMO+MO-1
      JYR=IYR+JYR
      IF (MO.LE.12)GO TO 130
      MO=MO-12
      JYR=JYR+1
c
  130 continue
      LPT=1
C
      IF (OPT6.EQ.1)GO TO 150
      IF (IPASS.EQ.2)GO TO 140
C
C     WINTER SEASON
      IF ((MO.GT.LMOW).AND.(MO.LT.IMOW)) LPT=0
      GO TO 150
C
C     SUMMER SEASON
140   IF ((MO.LT.IMOS).OR.(MO.GT.LMOS)) LPT=0
150   CONTINUE
C
      DO 170 I=II,IL
      J=I-II+1
      iflag(j)=0
      IF (M.GT.1)GO TO 160
      BSTA(J)=0.0
      ACCUM(J)=0.0
c
  160 continue
      N=IGS(IG,I)
      BS=BMO-BP
      NA=IABS(N)
      PXS=PX(NA,M)
      if(monthly_flag(na,m).eq.1) iflag(j)=1
      IF (N.GT.0)BS=(BS*FNP-PXS)/(FNP-1.0)
      IF (LPT.EQ.0)GO TO 170
      ACCUM(J)=ACCUM(J)+PXS
      BSTA(J)=BSTA(J)+BS
      DEV=ACCUM(J)-BSTA(J)
      IF (DEV.GT.DMAX)DMAX=DEV
      IF (DEV.LT.DMIN)DMIN=DEV
      IF (BSTA(J).GT.BMAX)BMAX=BSTA(J)
170   CONTINUE
C
      BP=BMO
      IF (LPT.EQ.0)GO TO 180
      WRITE(LP,440) MO,JYR,(ACCUM(J),BSTA(J),J=1,NN)
      WRITE(LSYS,445) MO,JYR,(ACCUM(J),IFLAG(J),BSTA(J),J=1,NN)
180   CONTINUE
C
C  PRINT PLOT TITLE.
      WRITE(LP,450) IG
      WRITE(LP,460)
C
      DO 190 I=II,IL
         J=I-II+1
         N=IGS(IG,I)
         NA=IABS(N)
         WRITE(LP,470) N,J,(STNAME(K,NA),K=1,5)
190      CONTINUE
C
C  COMPUTE AND PRINT DEVIATION SCALE.
      T=DMAX-DMIN
      T25=0.25*BMAX
      IF (T.LT.T25)  T=T25
      KA=T*0.001+2.0
      K=T*0.1
      K=K+KA
      T=K*10.0
      DPL=T*0.01
      K=DMAX/DPL+1.0
      DMAX=K*DPL
      DMIN=DMAX-T
C  K IS LOCATION OF ZERO DEVIATION.
      K=101-K
      WRITE(LP,480) UNITS,SN
      KA=0
C
      DO 200 IY=1,101,10
         KA=KA+1
         S(KA)=DMIN+DPL*(IY-1)
200      CONTINUE
C
      WRITE(LP,490) S
C
C  COMPUTE BASE PX SCALE
      KA=BMAX*0.1+1.0
      T=KA*10.0
      FINC=T*0.01
C
C  INITIALIZE GRID ARRAY
      DO 230 IX=1,101
         DO 210 IY=2,100
210         ORD(IX,IY)=BLANK
         DO 220 IY=1,101,10
220         ORD(IX,IY)=DOT
         ORD(IX,K)=ASTER
230      CONTINUE
C
C  FILL IN GRID ARRAY
      BP=0.0
      DO 280 M=1,NMO
      BMO=BASE(IG,M)
      JYR=(M-1)/12
      MO=M-JYR*12
      MO=IMO+MO-1
      IF (MO.GT.12)MO=MO-12
      LPT=1
      IF (OPT6.EQ.1)GO TO 250
      IF (IPASS.EQ.2)GO TO 240
      IF ((MO.GT.LMOW).AND.(MO.LT.IMOW)) LPT=0
      GO TO 250
240   IF ((MO.LT.IMOS).OR.(MO.GT.LMOS)) LPT=0
250   CONTINUE
C
      DO 270 I=II,IL
      J=I-II+1
      IF (M.GT.1)GO TO 260
      BSTA(J)=0.0
      ACCUM(J)=0.0
260   N=IGS(IG,I)
      BS=BMO-BP
      NA=IABS(N)
      PXS=PX(NA,M)
      IF (N.GT.0)BS=(BS*FNP-PXS)/(FNP-1.0)
      IF (LPT.EQ.0)GO TO 270
      ACCUM(J)=ACCUM(J)+PXS
      BSTA(J)=BSTA(J)+BS
      DEV=ACCUM(J)-BSTA(J)
      IY=(DPL*0.5+DEV)/DPL
      IY=IY+K
      IF (DEV.LT.-0.5*DPL)IY=IY-1
      IX=BSTA(J)/FINC+1.5
      ORD(IX,IY)=SYM(J)
270   CONTINUE
C
      BP=BMO
280   CONTINUE
C
C  PRINT GRID ARRAY.
      DO 290 IX=1,101
         FIX=IX-1
         BS=FIX*FINC
         WRITE(LP,500) BS,(ORD(IX,IY),IY=1,101)
290      CONTINUE
C
      IF (OPT6.EQ.1)GO TO 300
C
      IF (IPASS.EQ.2)GO TO 300
      IPASS=2
      GO TO 110
C
300   CONTINUE
C
310   CONTINUE
C
C  CLOSE IDMA OUTPUT FILE
      CALL UPCLOS (LSYS,' ',ISTAT)
      IF (ISTAT.NE.0) THEN
         WRITE (LP,315) 'UPCLOS',ISTAT
         CALL UWARN (LP,0,-1)
         ENDIF
C
      IYR=IYR-1900
C
      RETURN
C
315   FORMAT ('0*** WARNING - IN PLOTD - STATUS FROM ROUTINE ',A,
     *   ' IS ',I2,'.')
330   FORMAT(1H1 ///// 34X,32HPRECIPITATION CONSISTENCY CHECK.)
340   FORMAT(1H0,56HSTATIONS WITH POSITIVE NUMBERS CONSTITUTE THE GROUP
     *BASE,1X,60HAND ARE PLOTTED AGAINST THE OTHER STATIONS IN THE GROUP
     2 BASE)
350   FORMAT(1H0,69HSTATIONS WITH NEGATIVE RUN NUMBERS ARE PLOTTED AGAIN
     *ST THE GROUP BASE)
360   FORMAT(1H0)
370   FORMAT(1H0,10X,17HSTATIONS IN GROUP,I2)
380   FORMAT(1H0,12HSTA. RUN NO.,8X,12HSTATION NAME)
390   FORMAT(1H ,5X,I3,12X,5A4)
400   FORMAT(1H1,68HMONTHLY LISTING OF ACCUMULATED PRECIPITATION AND BAS
     *E PRECIPITATION.)
410   FORMAT(1H0,10X,5(3X,5A4))
415   FORMAT(1H0,11X,5(7X,5A4))
420   FORMAT(1H ,7HMO/YEAR,3X,5(6X,7HACC. PX,3X,7HBASE PX))
430   FORMAT (1H0,2A4  /  )
440   FORMAT(1H ,I2,1H/,I4,3X,5(3X,2F10.1))
445   FORMAT(1H ,I2,1H/,I4,3X,5(3X,F10.1,i3,f10.1))
450   FORMAT(1H1,69HDEVIATION OF ACCUMULATED PRECIPITATION FROM THE GROU
     *P BASE-----GROUP=,I1)
460   FORMAT(1H0,5X,12HSTA. RUN NO.,8X,13HSTA. PLOT NO.,7X,12HSTATION NA
     *ME)
470   FORMAT(1H ,9X,I3,19X,I2,12X,5A4)
480   FORMAT(1H0,10X,33HASTERISKS INDICATE ZERO DEVIATION,15X,9HUNITS AR
     *E,1X,A4,T120,2A4)
490   FORMAT(1H0,7HBASE PX,11F10.1)
500   FORMAT(1H ,F10.1,5X,101A1)
C
      END