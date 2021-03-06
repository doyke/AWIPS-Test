C MEMBER PPTSIC
C  (from old member PRDINCOR)
C-----------------------------------------------------------------------
C
       SUBROUTINE PPTSIC (TSARRY,LENGTH,IREC,ISTAT)
C
C          SUBROUTINE:  PPTSIC
C
C  4/7/88   GFS FIX 0C4 WHEN LONGER T.S. REPLACES SHORTER OF
C               SAME DATA TYPE INCORE - ADD VARIABLE TSLENG
C               TO COMMON /PICPTR/.
C  10/27/87 SRS UPDATE USE OF DEBUG TO USE COMMON/UDEBUG/
C  **VERSION 5.0.13 8-6-82 MAKE SURE STATUS IS ALWAYS 0
C  **VERSION 5.0.12 6-16-82 CHANGE REPLACEMENT ALGORITHM TO FIRST IN
C     FIRST OUT.  REMOVE TSUSED ARRAY AS IT IS NO LONGER NEEDED.
C   **VERSION 5.0.11 5-10-82 ADD FLAG SO BUFFER FULL MSGS ONLY PRINTED
C             ONCE. (ICBPRF IN COMMON PICPTR)
C  **VERSION 1.1.0 1-8-82 MOD TO ALLOW RECORD NUMBER TO REPLACE NAME
C            IN SEARCH (ADD IREC TO CALL OF PPTSIC AND INTERAL CHECK
C            IN PGTSIC)
C             VERSION:  1.0.0
C
C              AUTHOR:  SONJA R SIEGEL
C                       DATA SCIENCES INC
C                       8555 16TH ST, SILVER SPRING, MD 587-3700
C***********************************************************************
C
C          DESCRIPTION:
C
C    THIS ROUTINE CHECKS TO SEE IF A TIME SERIES SHOULD GO INTO
C    THE INCORE BUFFER AND PUTS IT THERE
C    IF IT SHOULD
C
C***********************************************************************
C
C          ARGUMENT LIST:
C
C         NAME    TYPE  I/O   DIM   DESCRIPTION
C
C       TSARRY    I      I     ?    TIME SERIES ARRAY
C       LENGTH    I      I     1    LENGTH OF TSARRY
C       IREC      I      I     1    RECORD NUMBER IF TO BE SEARCHED BY
C                                   RECORD NUMBER INSTEAD OF TSID
C       ISTAT     I      O     1    STATUS, 0 =OK
C                                           -1=PROBLEM
C
C***********************************************************************
C
C          COMMON:
C
      INCLUDE 'uio'
      INCLUDE 'udebug'
      INCLUDE 'prdcommon/pdftbl'
      INCLUDE 'prdcommon/picdmg'
      INCLUDE 'prdcommon/picptr'
      INCLUDE 'prdcommon/ptsicb'
C
C***********************************************************************
C
C          DIMENSION AND TYPE DECLARATIONS:
C
      INTEGER TSARRY(1),ITSID(2)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/db_prdrw/RCS/pptsic.f,v $
     . $',                                                             '
     .$Id: pptsic.f,v 1.1 1995/09/17 18:45:45 dws Exp $
     . $' /
C    ===================================================================
C
C
C***********************************************************************
C
C          DATA:
C
C***********************************************************************
C
C
      ISTAT=0
C
      IF (IPRDB.GT.0) WRITE (IOGDB,2006) (TSARRY(I),I=8,10)
2006  FORMAT (' TRYING TO PUT TIME SERIES ',2A4,1X,A4,' IN BUFFER')
C
C FIND TYPE IN TABLE
C
      ITYPE=TSARRY(10)
      CALL PFDTIC (ITYPE,INDXD,IDD)
      IF (INDXD.EQ.0) GO TO 900
C
C CHECK IF NEED TO ENTER
C
      IF (DATFIL(3,INDXD).NE.0) GO TO 30
      IF (IPRDB.GT.0) WRITE (IOGDB,2001) (TSARRY(I),I=8,10)
2001  FORMAT (' TIME SERIES ',2A4,1X,A4,' DOES NOT GO INCORE')
      GO TO 999
C
C YES, IS IT ALREADY THERE?
C IF IREC IS 0 LOOKING FOR NAME, IF IREC>0 LOOKING FOR RECORD
C
30    IF (IREC.LE.0) GO TO 35
      ITSID(1)=IREC
      ITSID(2)=0
      IF (IPRDB.GT.0) WRITE (IOGDB,2009) (TSARRY(J),J=8,10),IREC
2009  FORMAT (' TIME SERIES ',2A4,1X,A4,' IS RECORD',I7)
      GO TO 37
35    CALL UMEMOV (TSARRY(8),ITSID(1),2)
37    CALL PGTSIC (ITSID,ITYPE,INDXTS)
      IF (INDXTS.EQ.0) GO TO 40
C
C ALREADY THERE
C
      IF (IPRDB.GT.0) WRITE (IOGDB,2002) (TSARRY(I),I=8,10),INDXTS
2002  FORMAT (' TIMES SERIES ',2A4,1X,A4,' ALREADY AT SLOT ',I4)
      GO TO 999
C
C NOT THERE BUT SHOULD BE
C
C CHECK TO SEE IF DATA TYPE IS IN MANAGEMENT TABLE
C
40    IF (IDD.NE.0) GO TO 100
C
C DATA TYPE NOT THERE, PUT IT IN
C
      IF (NTSICD.GE.MTSICD) GO TO 60
C
C THERE IS ROOM HERE, CHECK OTHERS
C
        NTSICD=NTSICD+1
      TSICDT(NTSICD)=ITYPE
C
C LOOK FOR ROOM IN BUFFER AND TABLE
C
      CALL PCICRM (LENGTH,ISTAT)
      IF (ISTAT.EQ.0) GO TO 65
C
C REMOVE TYPE
C
      ISTAT=0
      NTSICD=NTSICD-1
60    IF (ICBPRF.EQ.1) GO TO 999
      WRITE (LPE,2010) ITYPE,NTSICD,NTSICP,NTSICB
2010  FORMAT (' **NOTE** NO ROOM FOR ',A4,' TIMES SERIES IN ',
     *  'INCORE BUFFER. POINTERS ARE: NUM TYPES=',I3,' NUM TS=',I3,
     * ' LAST WORD IN BUFFER=',I5)
      ICBPRF=1
      GO TO 999
65    NTSICP=NTSICP+1
C
C FILL IN DATA TYPE MANAGEMNT INFO
C
70    TSICD1(NTSICD)=NTSICP
      TSICDN(NTSICD)=1
      TSICDL(NTSICD)=NTSICP
C
C SET DATA DICTIONARY TO POINT HERE
C
      DATFIL(10,INDXD)=NTSICD
C
C ENTER INTO POINTER TABLE
C
80    ISLOT=NTSICP
      ISLOTB=NTSICB+1
      NTSICB=NTSICB+LENGTH
      TSBUPT(ISLOT)=ISLOTB
C
C  ONLY STORE LENGTH OF T.S. WHEN FIRST ENTERED IN SLOT --
C   DO NOT GO THROUGH THIS CODE WHEN REPLACING T.S. INCORE.
C
      TSLENG(ISLOT)=LENGTH
C
C MOVE THE ID
C
90    CALL UMEMOV (ITSID,TSIDIC(1,ISLOT),2)
      TSTYPE(ISLOT)=ITYPE
C
C MOVE THE TIME SERIES INTO THE BUFFER
C
      CALL UMEMOV (TSARRY,TSICBU(ISLOTB),LENGTH)
      IF (IPRDB.LT.1) GO TO 999
      IF (ITSID(2).EQ.0) WRITE (IOGDB,2104) ITSID,ITYPE,ISLOTB
2104  FORMAT (' TIME SERIES ',2I7,1X,A4,' IN TSICBU AT ',I4)
      IF (ITSID(2).NE.0) WRITE (IOGDB,2004) ITSID,ITYPE,ISLOTB
2004  FORMAT (' TIME SERIES ',2A4,1X,A4,' IN TSICBU AT ',I4)
      GO TO 999
C
C DATA TYPE IS IN TABLE- GO THERE TO FIND WHERE TO PUT NEXT ON
C
100   CONTINUE
C
C FIND A SLOT FOR THIS TIME SERIES
C
C ANY EMPTY SLOTS?
C
      IF (TSICDN(IDD).EQ.DATFIL(3,INDXD)) GO TO 120
C
C YES THERE SHOULD STILL BE ROOM WITHOUT REPLACING
C
      CALL PCICRM (LENGTH,ISTAT)
      IF (ISTAT.EQ.0) GO TO 105
C NO ROOM, START REPLACING
      IF (ICBPRF.EQ.0)WRITE (LPE,2011) TSICDN(IDD),ITYPE,DATFIL(3,INDXD)
2011  FORMAT (' **NOTE** INCORE BUFFER CAN ONLY KEEP',I3,1X,A4,
     *   ' TIME SERIES FOR THIS RUN. DATA TYPE WAS DEFINED TO KEEP ',I3,
     *   '.')
      ICBPRF=1
      ISTAT=0
      GO TO 120
105   NTSICP=NTSICP+1
C
C SET POINTERS IN DATA TYPE MANAGEMENT
C
      TSICDN(IDD)=TSICDN(IDD)+1
      LAST=TSICDL(IDD)
      TSICDL(IDD)=NTSICP
C
C SET POINTER IN LAST OF THIS TYPE
C
      TSPTNX(LAST)=NTSICP
C
C
C MOVE IN OTHER STUFF
C
      GO TO 80
C
C HAVE MAX TS OF THIS TYPE IN BUFFER, MUST REPLACE OLDEST ENTRY.
C USE TSICDL TO FIND LAST ENTRY AND THEN GO TO NEXT IN SEQUENCE.
C IF POINTER TO NEXT IS 0, GO TO FIRST AND USE THAT ONE.
C IF THERE IS ONLY 1 ENTRY, IT WILL BE REPLACED THIS WAY.
C
120   N=TSICDL(IDD)
C
C NOW GET NEXT IN SEQUENCE
C
      ISLOT=TSPTNX(N)
C
C THIS COULD BE ZERO, IF LAST IN LINE SO GET FIRST
C
      IF (ISLOT.EQ.0) ISLOT=TSICD1(IDD)
C
C  SEE IF LENGTH OF T.S. TO BE PUT IN INCORE BUFFER IS LARGER
C  THAN THE FIRST T.S. WRITTEN TO THIS SLOT.
C
      IF(LENGTH.LE.TSLENG(ISLOT))GO TO 150
C
C  NOT ENOUGH ROOM IN THIS SLOT IN INCORE BUFFER.
C   ********  DO NOT STORE INCORE. ********
C  MUST READ THIS T.S. FROM PRD FILE WHEN WANTED.
C
      WRITE(LPE,2012)(TSARRY(I),I=8,10),LENGTH,ISLOT,
     1 (TSIDIC(I,ISLOT),I=1,2),TSLENG(ISLOT)
 2012 FORMAT('0**NOTE** TIME SERIES ',2A4,1X,A4,' NOT PUT INCORE ',
     1 'BECAUSE IT NEEDS',I6,' WORDS IN INCORE BUFFER.'/
     2 10X,'SLOT',I3,' (HOLDING ',2A4,') FOR THIS DATA TYPE ONLY HAS',
     3 I6,' WORDS AVAILABLE.')
      GO TO 999
C
C SET UP FOR ISLOT
C
 150  ISLOTB=TSBUPT(ISLOT)
      IF (IPRDB.GT.0.AND.IREC.LE.0) WRITE (IOGDB,2007) (TSIDIC(J,ISLOT),
     * J=1,2),TSTYPE(ISLOT),ITSID,ITYPE,ISLOT
2007  FORMAT (' REPLACING ',2A4,1X,A4,' WITH ',2A4,1X,A4,' ISLOT=',I4)
      IF (IPRDB.GT.0.AND.IREC.GT.0) WRITE (IOGDB,2008) (TSIDIC(J,ISLOT),
     * J=1,2),TSTYPE(ISLOT),ITSID,ITYPE,ISLOT
2008  FORMAT (' REPLACING ',2I7,A4,' WITH ',2I7,A4,' ISLOT=',I4)
C
C SET POINTER TO LAST
C
      TSICDL(IDD)=ISLOT
      GO TO 90
C
C ERROR CONDITION
C
900    WRITE (LPE,2005) (TSARRY(J),J=8,10)
2005  FORMAT (' **ERROR** TIME SERIES ',2A4,1X,A4,' NOT ENTERED ',
     *  'INTO INCORE BUFFER.')
 999  CONTINUE
C
      RETURN
C
      END
