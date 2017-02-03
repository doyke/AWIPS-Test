C MEMBER SPTSHD
C-----------------------------------------------------------------------
C
C                             LAST UPDATE: 09/15/94.13:59:23 BY $WC20SV
C
C @PROCESS LVL(77)
C
C DESC PRINT PROCESSED DATA BASE TIME SERIES HEADER
C
      SUBROUTINE SPTSHD (TSID,TYPE,IPRERR,IPTRNX,ISTAT)
C
      REAL XFMAP/4HFMAP/
      REAL XMAP/4HMAP /
C
      DIMENSION TSID(2),FTSID(2),IHEAD(22)
C
      INCLUDE 'uio'
      INCLUDE 'scommon/sudbgx'
      INCLUDE 'hclcommon/hdflts'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/ppinit_print/RCS/sptshd.f,v $
     . $',                                                             '
     .$Id: sptshd.f,v 1.1 1995/09/17 19:14:26 dws Exp $
     . $' /
C    ===================================================================
C
C
C
      IF (ISTRCE.GT.0) WRITE (IOSDBG,90)
      IF (ISTRCE.GT.0) CALL SULINE (IOSDBG,1)
C
C  SET DEBUG LEVEL
      LDEBUG=ISBUG('TSHD')
C
      ISTAT=0
      NUMERR=0
C
C  CHECK NUMBER OF LINES LEFT ON PAGE
      IF (ISLEFT(5).GT.0) CALL SUPAGE
C
C  OPEN DATA BASE
      CALL SUDOPN (1,'PRD ',IERR)
      IF (IERR.EQ.0) GO TO 10
         ISTAT=1
         GO TO 70
C
10    MAXX=1
      XTYPE=TYPE
C
C  CHECK IF FUTURE TIME SERIES
      IF (TYPE.NE.XFMAP) GO TO 20
C
C  READ FUTURE TIME SERIES HEADER
      XTYPE=XMAP
      CALL RPRDFH (TSID,XTYPE,MAXX,IHEAD,NUMX,XBUF,IERR)
      IF (IERR.EQ.0) GO TO 30
         ISTAT=IERR
         IF (IPRERR.EQ.0) GO TO 80
            CALL SRPRST ('RPRDFH  ',TSID,XTYPE,MAXX,NUMERR,IERR)
            WRITE (LP,100) XTYPE,TSID
            CALL SUERRS (LP,2,-1)
            GO TO 80
C
C  READ TIME SERIES HEADER
20    CALL RPRDH (TSID,XTYPE,MAXX,IHEAD,NUMX,XBUF,FTSID,IERR)
      IF (IERR.EQ.0) GO TO 30
         ISTAT=IERR
         IF (IPRERR.EQ.0) GO TO 80
            CALL SRPRST ('RPRDH   ',TSID,XTYPE,MAXX,NUMERR,IERR)
            WRITE (LP,100) XTYPE,TSID
            CALL SUERRS (LP,2,-1)
            GO TO 80
C
C  PRINT HEADING
30    WRITE (LP,120)
      CALL SULINE (LP,2)
      WRITE (LP,130) TYPE
      CALL SULINE (LP,2)
      WRITE (LP,140)
      CALL SULINE (LP,1)
C
C  PRINT HEADER
      IF (LDEBUG.EQ.0) GO TO 40
         WRITE (LP,150) IHEAD
         CALL SULINE (LP,1)
         WRITE (LP,160) IHEAD
         CALL SULINE (LP,1)
40    CALL SUBSTR (IHEAD(12),1,4,XLAT,1)
      CALL SUBSTR (IHEAD(13),1,4,XLON,1)
      WRITE (LP,170) (IHEAD(I),I=8,9),XLAT,XLON,
     *   (IHEAD(I),I=18,22)
      CALL SULINE (LP,2)
      WRITE (LP,180) IHEAD(2),IHEAD(10),IHEAD(11)
      CALL SULINE (LP,2)
C
C  CHECK IF FUTURE TIME SERIES
      IF (TYPE.EQ.XFMAP) GO TO 50
      CALL SUBLID (FTSID,IERR)
      WRITE (LP,190) FTSID
      CALL SULINE (LP,2)
C
C  SET RECORD NUMBER OF NEXT RECORD OF SAME TYPE
50    IPTRNX=IHEAD(17)
C
      IF (LDEBUG.EQ.0) GO TO 60
C
C  DETERMINE DATE DATA BEGINS
      JHOUR=IHEAD(14)
      JDAY=JHOUR/24
      IHOUR=JHOUR-JDAY*24
      JDAY=JDAY+1
      CALL MDYH2 (JDAY,IHOUR,NBMO,NBDA,NBYR,NBHR,NTZC,IDLS,TIME(3))
C
C  DETERMINE DATE DATA ENDS
      NHOUR=IHEAD(5)/IHEAD(3)*IHEAD(2)
      JHOUR=IHEAD(14)+NHOUR
      JDAY=JHOUR/24
      IHOUR=JHOUR-JDAY*24
      JDAY=JDAY+1
      CALL MDYH2 (JDAY,IHOUR,NEMO,NEDA,NEYR,NEHR,NTZC,IDLS,TIME(3))
      WRITE (LP,200) NBMO,NBDA,NBYR,NBHR,TIME(3),NEMO,NEDA,NEYR,NEHR,
     *   TIME(3)
      CALL SULINE (LP,2)
C
60    WRITE (LP,120)
      CALL SULINE(LP,2)
C
70    IF (LDEBUG.GT.0.AND.ISTAT.EQ.0) WRITE (IOSDBG,110)
      IF (LDEBUG.GT.0.AND.ISTAT.EQ.0) CALL SULINE (IOSDBG,1)
C
80    IF (ISTRCE.GT.0) WRITE (IOSDBG,210)
      IF (ISTRCE.GT.0) CALL SULINE (IOSDBG,1)
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
90    FORMAT (' *** ENTER SPTSHD')
100   FORMAT ('0*** ERROR - ',A4,' TIME SERIES NOT SUCCESSFULLY ',
     *   'READ FOR IDENTIFIER ',2A4,'.')
110   FORMAT (' *** NOTE - FUTURE MAP TIME SERIES SUCCESSFULLY ',
     *     'READ.')
120   FORMAT ('0',132('-'))
130   FORMAT ('0*--> ',A4,' TIME SERIES HEADER')
140   FORMAT (' ')
150   FORMAT (' ',22(A4,1X))
160   FORMAT (' ',22(I4,1X))
170   FORMAT ('0TIME SERIES ID = ',2A4,5X,'LAT = ',F6.2,3X,
     *   'LON = ',F6.2,5X,'DESCRIPTION = ',5A4)
180   FORMAT ('0TIME INTERVAL = ',I2,10X,'DATA TYPE = ',A4,10X,
     *   'DATA UNITS = ',A4)
190   FORMAT ('0FUTURE TIME SERIES IDENTIFIER = ',2A4)
200   FORMAT ('0',
     *   'DATE OF FIRST DATA VALUE = ',I2,'/',I2,'/',I4,'-',I2,1X,A4,
     *   3X,'DATE OF LAST DATA VALUE = ',I2,'/',I2,'/',I4,'-',I2,1X,
     *   A4)
210   FORMAT(' *** EXIT SPTSHD')
C
      END