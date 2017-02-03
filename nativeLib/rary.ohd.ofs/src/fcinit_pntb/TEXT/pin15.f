C MODULE PIN15
C-----------------------------------------------------------------------
C
      SUBROUTINE PIN15 (PO,LEFTP,IUSEP,P,MP)
C
C  THIS IS THE INPUT ROUTINE FOR THE FOR THE WEIGH-TS OPERATION.
C
C  ROUTINE WAS WRITTEN BY JAN LEWIS - HRL - 4/1980

C  THE CONTENTS OF THE PO ARRAY IS:
C
C   POSITION             CONTENTS
C   --------             --------
C       1                VERSION NUMBER OF THE OPERATION.
C       2                NUMBER OF TIME SERIES TO BE WEIGHTED.
C       3                '    ' IF WEIGHT ARE READ IN , OR 'AREA' IF
C                        NAME OF 'UNIT-HG ' OPERATION IS READ IN.
C      4-5               OUTPUT TIME SERIES IDENTIFIER.
C       6                OUTPUT TIME SERIES DATA TYPE.
C       7                TIME INTERVAL.
C       8                NUMBER OF VALUES PER TIME INTERVAL.
C       9                0 IF NO MISSING DATA IS ALLOWED.
C                        1 IF MISSING DATA IS ALLOWED.
C      10                UNITS
C     11-12              INPUT TIME SERIES IDENTIFIER.
C      13                INPUT TIME SERIES DATA TYPE.
C      14                WEIGHTING FACTOR.
C     15-16              NAME OF 'UNIT-HG ' OPERATION (ONLY IF
C                        PO(3) = 'AREA').
C     PO(11)-PO(16) ARE REPEATED FOR EACH INPUT TIME SERIES.
C
      CHARACTER*8 SNAME/'PIN15'/
C
      INCLUDE 'common/fdbug'
      INCLUDE 'common/ionum'
C
      DIMENSION PO(*),P(MP),XIDT(2),XID(2),XNAME(2),SWITCH(2)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_pntb/RCS/pin15.f,v $
     . $',                                                             '
     .$Id: pin15.f,v 1.2 2001/06/13 10:13:41 mgm Exp $
     . $' /
C    ===================================================================
C
      DATA SWITCH/4H    ,4HAREA/
C
C
      CALL FPRBUG (SNAME,1,15,IBUG)
      IF(IBUG.EQ.1) WRITE(IODBUG,10)
10    FORMAT(1H0,10X,62HDEBUG INPUT SUBROUTINE FOR WEIGH-TS OPERATION:
     1   CARD IMAGES)
      IF(IBUG.EQ.1) WRITE(IODBUG,20)
20    FORMAT(1H ,18X,2H10,8X,2H20,8X,2H30)
      IF(IBUG.EQ.1) WRITE(IODBUG,30)
30    FORMAT(1H ,10X,30H----+----+----+----+----+----+)
C
      TAREA=0.
      NVAL=0
      NWARN=0
      ISTOP=0
C
C  READ THE TOTAL NUMBER OF T.S. TO BE WEIGHTED;TYPE OF WEIGHTING
C  TO BE USED; AND OUTPUT T.S. INFORMATION.
      READ (IN,40) NTS,WTS,XIDT,DATYP,IDT
40    FORMAT(I5,1X,A4,2X,2A4,1X,A4,I5)
50    FORMAT(1H ,10X,I5,1X,A4,2X,2A4,1X,A4,I5)
      IF(IBUG.EQ.1) WRITE(IODBUG,50) NTS,WTS,XIDT,DATYP,IDT
C
C  CHECK T.S. INFORMATION
      CALL CHEKTS (XIDT,DATYP,IDT,0,DIMS,1,NVAL,NERR)
      CALL FDCODE (DATYP,UNITS,DIMS,MSG,NVAL,TSCALE,NELSE,NERR)
C
C  CHECK FOR AVAILABLE SPACE IN THE P ARRAY
      IUSEP=10
      CALL CHECKP (IUSEP,LEFTP,NERR)
      IF(NERR.EQ.1) IUSEP=0
C
C  STORE DATA IN THE PO ARRAY
      PO(1)=1.
      PO(2)=NTS+0.01
      PO(3)=WTS
      PO(4)=XIDT(1)
      PO(5)=XIDT(2)
      PO(6)=DATYP
      PO(7)=IDT+0.01
      PO(8)=NVAL+0.01
      PO(9)=MSG+0.01
      PO(10)=UNITS
C
      K=IUSEP
C
C  READ IN T.S. ID AND WEIGHT
      DO 180 I=1,NTS
      IF(WTS.EQ.SWITCH(1)) READ(IN,60) XID,DTYPE,WT
      IF(WTS.EQ.SWITCH(1).AND.IBUG.EQ.1) WRITE(IODBUG,70) XID,DTYPE,WT
      IF(WT.EQ.0.) NWARN=NWARN+1
C
C  READ IN T.S. ID; DATA TYPE; AND NAME OF UNIT-HG OPERATION
      IF(WTS.EQ.SWITCH(2)) READ(IN,140) XID,DTYPE,XNAME
140   FORMAT(2A4,2X,A4,1X,2A4)
      IF(WTS.EQ.SWITCH(2).AND.IBUG.EQ.1) WRITE(IODBUG,150) XID,DTYPE,
     1 XNAME
150   FORMAT(1H ,10X,2A4,2X,A4,1X,2A4)
60    FORMAT(2A4,2X,A4,1X,F10.3)
70    FORMAT(1H ,10X,2A4,2X,A4,1X,F10.2)
      IF(WTS.EQ.SWITCH(1).OR.WTS.EQ.SWITCH(2)) GO TO 100
      IF(I.EQ.1) THEN
         WRITE(IPR,80) WTS,SWITCH
80    FORMAT('0**ERROR** WEIGHTING FACTOR SWITCH (',A4,' IS NOT ',
     * 'EQUAL TO ',A4,' OR ',A4,'.')
         CALL ERROR
         ENDIF
      ISTOP=1
      READ(IN,90) XID,DTYPE
90    FORMAT(2A4,1X,A4)
C
C   CHECK T.S.INFORMATION
100   CALL CHEKTS (XID,DTYPE,IDT,1,DIMS,MSG,NVAL,NERR)
      IF(NERR.EQ.1) GO TO 120
      IF(DTYPE.EQ.DATYP)GO TO 120
      CALL FDCODE(DTYPE,UNTS,DIMS,MSG,NVAL,TSCALE,NELSE,NERR)
      IF(UNTS.EQ.UNITS) GO TO 120
      WRITE(IPR,110) XID,DTYPE,UNTS,UNITS
110   FORMAT('0**ERROR** UNITS FOR INPUT TIME SERIES (ID= ',2A4,
     1 ' TYPE=',A4,') (',A4,
     2 ') DOES NOT MATCH UNITS FOR THE OUTPUT TIME SERIES (',A4,').')
      CALL ERROR
C
C  CHECK SPACE AVAILABLE
120   IUSEP=IUSEP+3
      CALL CHECKP (IUSEP,LEFTP,NERR)
      IF(NERR.EQ.1) IUSEP=0
      IF(NERR.EQ.1) GO TO 340
C
C   STORE DATA IN PO ARRAY
      DO 130 J=1,2
         K=K+1
130      PO(K)=XID(J)
      KK=K-1
      K=K+1
      PO(K)=DTYPE
C
C  CHECK FOR SPACE AVAILABLE
      IF(WTS.EQ.SWITCH(1)) IUSEP=IUSEP+1
      IF(WTS.EQ.SWITCH(2)) IUSEP=IUSEP+3
      CALL CHECKP (IUSEP,LEFTP,NERR)
      IF(NERR.EQ.1) IUSEP=0
      IF(NERR.EQ.1) GO TO 340
C
C  STORE DATA IN PO ARRAY
      K=K+1
      IF(WTS.EQ.SWITCH(1)) PO(K)=WT
      IF(WTS.NE.SWITCH(2)) GO TO 180
C
C  FIND AREA PERTAINING TO UNIT-HG; STORE AREA AND UNIT-HG NAME IN
C  PO ARRAY
      NWARN=0
      LP=0
      CALL FSERCH(2,XNAME,LP,P,MP)
      IF (LP.NE.0) GO TO 170
         WRITE(IPR,160) XNAME
160   FORMAT('0**ERROR** UNIT-HG OPERATION NAME ',2A4,
     * ' DOES NOT EXIST.')
         CALL ERROR
         ISTOP=2
         GO TO 180
170   LP=LP+6
      AREA=P(LP)
      IF(AREA.EQ.0) NWARN=NWARN+1
      TAREA=TAREA+AREA
      PO(K)=AREA
      K=K+1
      PO(K)=XNAME(1)
      K=K+1
      KK=K-1
      PO(K)=XNAME(2)
180   CONTINUE
C
      IF (NWARN.EQ.NTS) THEN
         WRITE(IPR,190)
190   FORMAT ('0**ERROR** ALL INPUT TIME SERIES HAVE ZERO WEIGHTS.')
         CALL ERROR
         GO TO 250
         ENDIF
C
      IF (NWARN.LT.NTS.AND.NWARN.GT.0) THEN
         WRITE(IPR,200) NWARN
200   FORMAT ('0**WARNING**',I5,' INPUT TIME SERIES HAVE ZERO WEIGHTS.')
         CALL WARN
         ENDIF
C
      IF(WTS.NE.SWITCH(2)) GO TO 240
      IF(ISTOP.NE.2) GO TO 220
      WRITE(IPR,210)
210   FORMAT ('0**ERROR** DUE TO PRECEEDING ERRORS WEIGHTS CANNOT BE ',
     * 'COMPUTED.')
      CALL ERROR
      GO TO 250
C
C  COMPUTE WEIGHT FOR EACH T.S.FROM AREA; STORE WT IN AREA LOCATION
C  OF PO ARRAY
220   LA=14
      DO 230 I=1,NTS
         PO(LA)=PO(LA)/TAREA
         LA=LA+6
230      CONTINUE
C
240   IF (ISTOP.NE.1) GO TO 270
250   WRITE (IPR,260)
260   FORMAT ('0**ERROR** DUE TO PRECEEDING ERRORS THIS OPERATION ',
     *  'IS SKIPPED.')
      CALL ERROR
      IUSEP=0
      GO TO 340
C
270   IF (IBUG.EQ.1) THEN
         WRITE (IODBUG,280)
280   FORMAT (' PO ARRAY:')
         WRITE (IODBUG,290) (PO(K),K=1,10)
290   FORMAT(1H ,10X,F5.0,2X,F6.2,2X,A4,2X,A4,2X,A4,2X,A4,2X,F6.2,2X,
     1 F6.2,2X,F6.2,2X,A4)
         K=11
         DO 330 I=1,NTS
            IF(WTS.EQ.SWITCH(2)) GO TO 310
               WRITE( IODBUG,300) PO(K),PO(K+1),PO(K+2),PO(K+3)
300   FORMAT(1H ,10X,A4,3X,A4,3X,A4,3X,F5.3)
               K=K+4
               GO TO 330
310         WRITE (IODBUG,320) PO(K),PO(K+1),PO(K+2),PO(K+3),PO(K+4),
     *         PO(K+5)
320   FORMAT(1H ,10X,A4,3X,A4,3X,A4,3X,F5.3,2X,A4,3X,A4)
            K=K+6
330         CONTINUE
         ENDIF
C
340   IF (ITRACE.EQ.1) WRITE (IODBUG,*) 'EXIT ',SNAME
C
      RETURN
C
      END