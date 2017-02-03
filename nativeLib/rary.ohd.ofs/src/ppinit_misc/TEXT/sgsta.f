C MEMBER SGSTA
C-----------------------------------------------------------------------
C
C @PROCESS LVL(77)
C
C DESC ROUTINE FOR CHANGING STATION DEFINITION.
C DESC PPINIT COMMAND :  @CHANGE STATION
C
      SUBROUTINE SGSTA (LARRAY,ARRAY,NFLD,IRUNCK,ISTAT)
C
      REAL XGENL/4HGENL/
C
      DIMENSION ARRAY(LARRAY)
      DIMENSION CHAR(5),CHK(5)
      DIMENSION OLDID(2),NEWID(2),IXBUF(4)
C
C
      INCLUDE 'uio'
      INCLUDE 'scommon/sudbgx'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/ppinit_misc/RCS/sgsta.f,v $
     . $',                                                             '
     .$Id: sgsta.f,v 1.1 1995/09/17 19:13:37 dws Exp $
     . $' /
C    ===================================================================
C
C
C
      IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,140)
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  SET DEBUG LEVEL
      LDEBUG=ISBUG('CHNG')
C
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,150) LARRAY,NFLD
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      ISTAT=0
C
      LARAY2=1000
      LARAY1=LARRAY-LARAY2
      LARAY3=0
C
      IPDENQ=0
C
      ISTRT=0
      LCHAR=5
      LCHK=5
      ILPFND=0
      IRPFND=0
      NXTFLD=1
C
      INDPPD=0
      INDPPP=0
      INDPRD=0
      NCHNGE=0
      IFIRST=1
C
C  ENQ PREPROCESSOR DATA BASE
      WRITE (LP,*) ' '
      CALL SULINE (LP,1)
      CALL PDENDQ ('ENQ',IERR)
      IF (IERR.EQ.0) THEN
         CALL SULINE (LP,1)
         IPDENQ=1
         ELSE
            WRITE (LP,185)
            CALL SUERRS (LP,2,-1)
            ISTAT=1
            GO TO 130
         ENDIF
C
C  OPEN DATA BASES
      CALL SUDOPN (1,'PPD ',IERR)
      IF (IERR.GT.0) GO TO 120
      CALL SUDOPN (1,'PPP ',IERR)
      IF (IERR.GT.0) GO TO 120
      CALL SUDOPN (1,'PRD ',IERR)
      IF (IERR.GT.0) GO TO 120
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CHECK FIELDS FOR OPTIONS
C
10    CALL UFIELD (NFLD,ISTRT,LENGTH,ITYPE,NREP,INTEGR,REAL,LCHAR,
     *   CHAR,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,IERR)
      IF (LDEBUG.GT.0)
     *   CALL UPRFLD (NFLD,ISTRT,LENGTH,ITYPE,NREP,INTEGR,REAL,LCHAR,
     *   CHAR,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,IERR)
      IF (IERR.NE.1) GO TO 20
         IF (LDEBUG.GT.0) THEN
            WRITE (IOSDBG,190) NFLD
            CALL SULINE (IOSDBG,1)
            ENDIF
         GO TO 10
C
C  CHECK FOR END OF INPUT
20    IF (NFLD.EQ.-1) GO TO 130
C
C  CHECK FOR COMMAND
      IF (LATSGN.EQ.1) GO TO 130
C
C  CHECK FOR PAIRED PARENTHESIS
      IF (ILPFND.GT.0.AND.IRPFND.EQ.0) GO TO 30
         GO TO 40
30    IF (NFLD.EQ.1) CALL SUPCRD
      WRITE (LP,200) NFLD
      CALL SULINE (LP,2)
      ILPFND=0
      IRPFND=0
40    IF (LLPAR.GT.0) ILPFND=1
      IF (LRPAR.GT.0) IRPFND=1
C
C  CHECK FOR PARENTHESIS IN FIELD
      IF (LLPAR.GT.0) CALL UFPACK (LCHK,CHK,ISTRT,1,LLPAR-1,IERR)
      IF (LLPAR.EQ.0) CALL UFPACK (LCHK,CHK,ISTRT,1,LENGTH,IERR)
C
      IF (NXTFLD.EQ.2) GO TO 50
C
C  CHECK FOR KEYWORD
      CALL SUIDCK ('CHNG',CHK,NFLD,0,IKEYWD,IERR)
      IF (IERR.EQ.2) GO TO 130
         IF (LDEBUG.GT.0) WRITE (IOSDBG,160) CHK
         IF (LDEBUG.GT.0) CALL SULINE (IOSDBG,1)
C
50    IF (NFLD.EQ.1) CALL SUPCRD
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
      IF (NXTFLD.EQ.2) GO TO 70
C
C  SET OLD IDENTIFIER
      CALL SUBSTR (CHAR,1,8,OLDID,1)
      IF (LDEBUG.GT.0) WRITE (IOSDBG,170) OLDID
      IF (LDEBUG.GT.0) CALL SULINE (IOSDBG,1)
      NXTFLD=2
      GO TO 10
C
C  SET NEW IDENTIFIER
70    CALL SUBSTR (CHAR,1,8,NEWID,1)
      IF (LDEBUG.GT.0) WRITE (IOSDBG,180) NEWID
      IF (LDEBUG.GT.0) CALL SULINE (IOSDBG,1)
C
      INDERR=0
C
C  CHECK IF OLD STATION IS DEFINED
      IFIND=1
      CALL PPFNDR (OLDID,XGENL,IFIND,IXBUF,IFREE,IERR)
      IF (IERR.EQ.0.AND.IFIND.GT.0) GO TO 110
         IF (IERR.EQ.0.AND.IFIND.EQ.0) WRITE (LP,220) OLDID
         IF (IERR.EQ.0.AND.IFIND.EQ.0) CALL SUWRNS (LP,2,-1)
         IF (IERR.GT.0) WRITE (LP,225) OLDID,IERR
         IF (IERR.GT.0) CALL SUERRS (LP,2,-1)
         INDERR=1
         GO TO 113
110   IF (LDEBUG.GT.0) WRITE (IOSDBG,230) XGENL,OLDID,IFIND
      IF (LDEBUG.GT.0) CALL SULINE (IOSDBG,2)
C
C  CHECK IF NEW STATION IS DEFINED
113   IFIND=1
      CALL PPFNDR (NEWID,XGENL,IFIND,IXBUF,IFREE,IERR)
      IF (IERR.EQ.0.AND.IFIND.EQ.0) GO TO 115
         IF (IERR.EQ.0.AND.IFIND.GT.0) WRITE (LP,227) NEWID
         IF (IERR.EQ.0.AND.IFIND.GT.0) CALL SUERRS (LP,2,-1)
         IF (IERR.GT.0) WRITE (LP,225) OLDID,IERR
         IF (IERR.GT.0) CALL SUERRS (LP,2,-1)
         INDERR=1
         GO TO 120
115   IF (LDEBUG.GT.0) WRITE (IOSDBG,230) XGENL,NEWID,IFIND
      CALL SULINE (IOSDBG,2)
C
120   IF (INDERR.EQ.1) GO TO 125
C
      CALL SGSTA2 (OLDID,NEWID,LARAY1,ARRAY,LARAY2,ARRAY(LARAY1+1),
     *   LARAY3,ARAY3,IFIRST,NUMID1,NUMID2,NUMERR,IERR)
      IFIRST=0
      IF (IERR.EQ.0) GO TO 125
C
      NCHNGE=NCHNGE+1
      IF (INDPPD.EQ.1) CALL SUDWRT (1,'PPD ',IERR)
      IF (INDPPP.EQ.1) CALL SUDWRT (1,'PPP ',IERR)
      IF (INDPRD.EQ.1) CALL SUDWRT (1,'PRD ',IERR)
C
125   NXTFLD=1
      GO TO 10
C
C  DEQ PREPROCESSOR DATA BASE
130   IF (IPDENQ.EQ.1) THEN
         WRITE (LP,*) ' '
         CALL SULINE (LP,1)
         CALL PDENDQ ('DEQ',IERR)
         IF (IERR.EQ.0) CALL SULINE (LP,1)
         ENDIF
C
      IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,250)
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
140   FORMAT (' *** ENTER SGSTA')
150   FORMAT (' LARRAY=',I5,3X,'NFLD=',I2)
160   FORMAT (' INPUT FIELD = ',5A4)
170   FORMAT (' OLD IDENTIFIER SET TO : ',2A4)
180   FORMAT (' NEW IDENTIFIER SET TO : ',2A4)
185   FORMAT ('0*** ERROR - IN SGSTA - ENQUING PREPROCESSOR DATA ',
     *   'BASE.')
190   FORMAT (' NULL FIELD FOUND IN FIELD ',I2)
200   FORMAT ('0*** NOTE - RIGHT PARENTHESES ASSUMED IN FIELD ',
     *   I2,'.')
220   FORMAT ('0*** WARNING - STATION ',2A4,' IS NOT DEFINED.')
225   FORMAT ('0*** ERROR - ACCESSING STATION ',2A4,' PPFNDR STATUS ',
     *   'CODE=',I2,'.')
227   FORMAT ('0*** ERROR - STATION ',2A4,' ALREADY EXISTS.')
230   FORMAT (1H ,A4,' PARAMETERS FOR IDENTIFIER ',2A4,
     *   ' FOUND AT RECORD ',I5,' OF INDEX')
250   FORMAT (' *** EXIT SGSTA')
C
      END