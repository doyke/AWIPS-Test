C MODULE SETOPT
C-----------------------------------------------------------------------
C
C  ROUTINE TO SET RUN TIME OPTIONS.
C
      SUBROUTINE SETOPT (LARRAY,ARRAY,NFLD,IDBWT,ISETUP,ISTAT)
C
      CHARACTER*4 PLOT,TITLE,XNWPAG,RUNCHK,OVRPRT,CMDLOG,OPTLOG
      CHARACTER*4 SVDFLT,PDUMP,UNITS,STOPMS,RUNNTW
      CHARACTER*8 DDN,TYPMSG
      CHARACTER*8 XFT/'FT??F001'/
      PARAMETER (MOPTN=28)
      CHARACTER*8 OPTN(MOPTN)/
     *   'NEWPAGE ','PLOT    ','PAGESIZE','UNITS   ',
     *   'TITLE   ','        ','PARMDUMP','CONDCODE',
     *   'RUNCHECK','OVERPRNT','CMDLOG  ','SAVEDFLT',
     *   '        ','MAXERROR','        ','        ',
     *   'STOPMSGS','ALLOCATE','CLOCKTIM','MAXWARN ',
     *   'ORDER   ','OPTLOG  ','MSGLEVEL','NOGOESCK',
     *   'RUNNTWK ','RUNORDR  ','        ','        '/
      CHARACTER*40 STRNG/' '/,STRNG2/' '/
      CHARACTER*44 DSN,DSNOLD
C
      DIMENSION ARRAY(LARRAY)
C
      INCLUDE 'uiox'
      INCLUDE 'uoptnx'
      INCLUDE 'ufreex'
      INCLUDE 'scommon/sudbgx'
      INCLUDE 'scommon/suoptx'
      INCLUDE 'scommon/supagx'
      INCLUDE 'scommon/suerrx'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/ppinit_misc/RCS/setopt.f,v $
     . $',                                                             '
     .$Id: setopt.f,v 1.10 2002/02/11 21:00:50 dws Exp $
     . $' /
C    ===================================================================
C
C
      IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,*) 'ENTER SETOPT'
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  SET DEBUG LEVEL
      LDEBUG=ISBUG('SOPT')
C
      ISTAT=0
C
      LSTRNG=-LEN(STRNG)
      LSTRNG2=-LEN(STRNG2)
      ISTRT=1
C
      IDBWT=0
      ISETUP=0
C
      ILPFND=0
      IRPFND=0
      NUMERR=0
      NUMWRN=0
C
C  SET DEFAULT OPTIONS
      XNWPAG='NO'
      PLOT='YES'
      NPGSIZ=70
      NSGLVL=2
      TITLE='YES'
      SVDFLT='NO'
C
C  PRINT CARD
      CALL SUPCRD
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CHECK FIELDS FOR SETOPT OPTIONS
C
10    CALL UFIELD (NFLD,ISTRT,LENGTH,ITYPE,NREP,INTEGR,REAL,LSTRNG,
     *   STRNG,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,IERR)
      IF (NFLD.EQ.-1) GO TO 930
      IF (LDEBUG.GT.0) THEN
         CALL UPRFLD (NFLD,ISTRT,LENGTH,ITYPE,NREP,INTEGR,REAL,
     *      LSTRNG,STRNG,LLPAR,LRPAR,LASK,LATSGN,LAMPS,LEQUAL,IERR)
         ENDIF
      IF (IERR.NE.1) GO TO 20
         IF (LDEBUG.GT.0) THEN
            WRITE (IOSDBG,1170) NFLD
            CALL SULINE (IOSDBG,1)
            ENDIF
         GO TO 10
C
C  CHECK FOR COMMAND
20    IF (LATSGN.EQ.1) GO TO 930
C
      IF (NFLD.EQ.1) CALL SUPCRD
C
C  CHECK FOR PARENTHESIS IN FIELD
      IF (LLPAR.GT.0) CALL UFPACK (LSTRNG2,STRNG2,ISTRT,1,LLPAR-1,IERR)
      IF (LLPAR.EQ.0) CALL UFPACK (LSTRNG2,STRNG2,ISTRT,1,LENGTH,IERR)
C
C  CHECK FOR OPTION
      DO 30 IOPTN=1,MOPTN
         NWORDS=2
         CALL SUCOMP (NWORDS,STRNG2,OPTN(IOPTN),IMATCH)
         IF (IMATCH.EQ.1) GO TO 40
30       CONTINUE
C
      IF (ILPFND.GT.0.AND.IRPFND.EQ.0) THEN
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         ILPFND=0
         IRPFND=0
         ENDIF
      IF (LLPAR.GT.0) ILPFND=1
C
C  INVALID OPTION
      WRITE (LP,1120) STRNG2
      CALL SUERRS (LP,2,NUMERR)
      GO TO 10
C
40    GO TO (60,70,110,150,
     *       190,50,280,330,
     *       400,440,480,520,
     *       50,600,50,50,
     *       630,670,720,760,
     *       790,830,870,910,
     *       920,921,50,50),IOPTN
50       WRITE (LP,1160) OPTN(IOPTN)
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  NEWPAGE OPTION
C
60    NEWPAG=-1
      CALL SUNEWP (NFLD,ISTRT,STRNG2,LSTRNG2,LLPAR,LRPAR,LENGTH,IRPFND,
     *   OPTN(IOPTN),NUMERR,NUMWRN,NEWPAG,IERR)
      XNWPAG=STRNG2
      IF (XNWPAG.EQ.'YES') IOPNWP=1
      IF (XNWPAG.EQ.'NO') IOPNWP=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),XNWPAG
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  PLOT OPTION
C
70    IF (LLPAR.GT.0) GO TO 80
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 100
80    IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 90
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
90    CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') GO TO 100
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
100   PLOT=STRNG2
      IF (PLOT.EQ.'YES') IOPPLT=1
      IF (PLOT.EQ.'NO') IOPPLT=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),PLOT
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  PAGESIZE OPTION
C
110   IF (LLPAR.GT.0) GO TO 120
         NLINE=NPGSIZ
         WRITE (LP,1040) OPTN(IOPTN),NLINE
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 140
120   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 130
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
130   CALL UFINFX (NLINE,ISTRT,LLPAR+1,LRPAR-1,IERR)
      ICKMIN=50
      ICKMAX=80
      IF (NLINE.GE.ICKMIN.AND.NLINE.LE.80) GO TO 140
         WRITE (LP,1140) OPTN(IOPTN),NLINE,ICKMIN,ICKMAX
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
140   NPSMLN=NLINE
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),NPSMLN
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  UNITS OPTION
C
150   IF (LLPAR.GT.0) GO TO 160
         STRNG2='ENGL'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 180
160   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 170
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
170   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'ENGL'.OR.
     *    STRNG2.EQ.'METR') GO TO 180
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
180   UNITS=STRNG2
      IF (UNITS.EQ.'ENGL') IOPUNT=1
      IF (UNITS.EQ.'METR') IOPUNT=2
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),UNITS
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  TITLE OPTION
C
190   IF (LLPAR.GT.0) GO TO 200
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 220
200   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 210
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
210   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO'.OR.
     *    STRNG2.EQ.'PAGE') GO TO 220
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
220   TITLE=STRNG2
      IF (TITLE.EQ.'YES') IOPTLE=2
      IF (TITLE.EQ.'PAGE') IOPTLE=1
      IF (TITLE.EQ.'NO') IOPTLE=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPTLE
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  PARMDUMP OPTION
C
280   IF (LLPAR.GT.0) GO TO 290
         PDUMP='BOTH'
         WRITE (LP,980) OPTN(IOPTN),PDUMP
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 310
290   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 300
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
300   CALL UFPACK (1,PDUMP,ISTRT,LLPAR+1,LRPAR-1,IERR)
310   IF (PDUMP.EQ.'STRNG'.OR.
     *    PDUMP.EQ.'REAL'.OR.
     *    PDUMP.EQ.'BOTH'.OR.
     *    PDUMP.EQ.'INT') GO TO 320
         WRITE (LP,1100) PDUMP
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
320   IF (PDUMP.EQ.'STRNG') IOPDMP=1
      IF (PDUMP.EQ.'INT') IOPDMP=2
      IF (PDUMP.EQ.'REAL') IOPDMP=3
      IF (PDUMP.EQ.'BOTH') IOPDMP=4
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),PDUMP
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CONDCODE OPTION
C
330   IF (LLPAR.GT.0) GO TO 340
         ICOND=0
         WRITE (LP,1040) OPTN(IOPTN),INTEGR
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 380
340   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 350
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
C
C  CHECK IF INTEGER
350   IBEG=ISTRT+LLPAR
      IEND=ISTRT+LRPAR-2
      NSTRNG=IEND-IBEG+1
      IPRERR=0
      CALL UFA2I (ICDBUF,IBEG,NSTRNG,INTCK,IPRERR,LP,IERR)
      IF (IERR.NE.0) THEN
C     INTEGER VALUE NOT FOUND IN PARENTHESES
         CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
C     CHECK IF RESET OPTION SPECIFIED
         IF (STRNG2.NE.'RESET') THEN
            WRITE (LP,1130) OPTN(IOPTN),STRNG2
            CALL SUERRS (LP,2,NUMWRN)
            GO TO 10
            ENDIF
C     RESET OPTION
         IF (IOPCLG(1).EQ.1) THEN
            IUCLOG=IOPCLG(2)
            WRITE (IUCLOG,1110) NPSNLT,LP
            ENDIF
         NPSNLT=0
         KLSTOP=0
         ISTOP=0
         CALL SUSTOP (ISTOP)
         KLSTOP=1
         KLCODE=0
         NERR=0
         NTERR=0
         NPGERR=0
         DO 360 I=1,MPGERR
            LPGERR(I)=0
360         CONTINUE
         NWARN=0
         NTWARN=0
         NPGWRN=0
         DO 370 I=1,MPGWRN
            LPGWRN(I)=0
370         CONTINUE
         WRITE (LP,1050) OPTN(IOPTN),KLCODE
         CALL SULINE (LP,2)
         GO TO 10
         ENDIF
C
C  SET CONDCODE VALUE
      CALL UFINFX (ICOND,ISTRT,LLPAR+1,LRPAR-1,IERR)
380   ICKMIN=0
      ICKMAX=16
      IF (ICOND.GE.ICKMIN.AND.ICOND.LE.ICKMAX) GO TO 390
         WRITE (LP,1140) OPTN(IOPTN),ICOND,ICKMIN,ICKMAX
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
390   IOPCND=ICOND
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPCND
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  RUNCHECK OPTION
C
400   IF (LLPAR.GT.0) GO TO 410
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 430
410   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 420
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
420   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') GO TO 430
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
430   RUNCHK=STRNG2
      IF (RUNCHK.EQ.'YES') IOPRCK=1
      IF (RUNCHK.EQ.'NO') IOPRCK=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),RUNCHK
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  OVERPRNT OPTION
C
440   IF (LLPAR.GT.0) GO TO 450
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 470
450   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 460
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
460   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') GO TO 470
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
470   OVRPRT=STRNG2
      IF (OVRPRT.EQ.'YES') THEN
         IOPOVP=1
         NOVPRT=2
         ENDIF
      IF (OVRPRT.EQ.'NO') THEN
         IOPOVP=0
         NOVPRT=0
         ENDIF
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),OVRPRT
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CMDLOG OPTION
C
480   IF (LLPAR.GT.0) GO TO 490
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 510
490   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 500
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
500   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') GO TO 510
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
510   CMDLOG=STRNG2
      IF (CMDLOG.EQ.'YES') IOPCLG(1)=1
      IF (CMDLOG.EQ.'NO') IOPCLG(1)=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),CMDLOG
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  SAVEDFLT OPTION
C
520   IF (LLPAR.GT.0) GO TO 530
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 550
530   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 540
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
540   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') GO TO 550
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
550   SVDFLT=STRNG2
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),SVDFLT
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  MAXERROR OPTION
C
600   IF (LLPAR.EQ.0) THEN
         MAXERR=500
         WRITE (LP,1040) OPTN(IOPTN),MAXERR
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 610
         ENDIF
      IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.EQ.0) THEN
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
         ENDIF
      CALL UFINFX (MAXERR,ISTRT,LLPAR+1,LRPAR-1,IERR)
610   ICKMIN=0
      ICKMAX=9999
      IF (MAXERR.GT.ICKMIN.AND.MAXERR.LE.ICKMAX) GO TO 620
         WRITE (LP,1150) OPTN(IOPTN),MAXERR,ICKMIN,ICKMAX
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
620   IOPMXE=MAXERR
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPMXE
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  STOPMSGS OPTION
C
630   IF (LLPAR.GT.0) GO TO 640
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 660
640   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 650
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
650   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') GO TO 660
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
660   IF (STRNG2.EQ.'YES') IOPSTP=1
      IF (STRNG2.EQ.'NO') IOPSTP=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPSTP
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  ALLOCATE OPTION
C
670   IF (LLPAR.GT.0) GO TO 680
         WRITE (LP,990) OPTN(IOPTN)
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 10
680   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 690
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
C
C  SET DATASET NAME
690   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      CALL UINDEX (STRNG2,LSTRNG2*4,':',1,ICOL)
      IF (ICOL.GT.0) GO TO 700
         WRITE (LP,1000) OPTN(IOPTN)
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
700   DSN=' '
      CALL SUBSTR (STRNG2,1,ICOL-1,DSN,1)
      WRITE (LP,1010) DSN
      CALL SULINE (LP,2)
C
C  CHECK IF DDNAME OR UNIT SPECIFIED
      DDN=' '
      CALL ULENTH (STRNG2,LSTRNG2*4,LENTH)
      NSTRNG=LENTH-ICOL
      CALL SUBSTR (STRNG2,ICOL+1,NSTRNG,DDN,1)
C
C  CHECK IF INTEGER
      IBEG=ISTRT+LLPAR+ICOL
      IEND=ISTRT+LRPAR-2
      NSTRNG=IEND-IBEG+1
      IPRERR=0
      CALL UFA2I (ICDBUF,IBEG,NSTRNG,INTCK,IPRERR,LP,IERR)
      IF (IERR.NE.0) THEN
         WRITE (LP,1020) DDN
         CALL SULINE (LP,2)
         NUNIT=0
         GO TO 710
         ENDIF
      CALL UFINFX (NUNIT,ISTRT,LLPAR+ICOL+1,LRPAR-1,IERR)
      CALL SUBSTR (XFT,1,8,DDN,1)
      CALL UFXDDN (DDN,NUNIT,IERR)
      WRITE (LP,1030) NUNIT,DDN
      CALL SULINE (LP,2)
      IENDFL=1
      IF (IENDFL.EQ.1) ENDFILE NUNIT
      IREWFL=1
      IF (IREWFL.EQ.1) REWIND NUNIT
C
C  GET NAME OF DATASET CURRENTLY ALLOCATED
710   INDERR=0
      IPRERR=1
      NPUNIT=0
      CALL UPRDSN (DDN,NUNIT,DSNOLD,IPRERR,NPUNIT,IERR)
      IF (IERR.GT.0) INDERR=1
C
      ICKDDN=0
      IPRERR=1
      IPRINT=1
      IF (NUNIT.EQ.LP) IPRINT=0
      NBLINE=1
C
C  UNALLOCATE DATASET
      IF (INDERR.EQ.0) THEN
         TYPMSG='WARNING'
         CALL UDSAL3 (NUNIT,DDN,DSNOLD,'UNALLOC',ICKDDN,
     *      IPRERR,TYPMSG,IPRINT,NBLINE,IERR)
         ENDIF
C
C  ALLOCATE DATASET
      IPRERR=1
      TYPMSG='ERROR'
      IPRINT=1
      CALL UDSAL3 (NUNIT,DDN,DSN,'ALLOCATE',ICKDDN,
     *   IPRERR,TYPMSG,IPRINT,NBLINE,IERR)
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  CLOCKTIM OPTION
C
720   IF (LLPAR.GT.0) GO TO 730
         CALL UMEMOV (RESET,STRNG2,2)
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 750
730   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 740
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
740   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'RESET') GO TO 750
         WRITE (LP,1130) OPTN(IOPTN),STRNG2
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
750   CALL UDATEI (NMO,NDA,NYR,NHRMIN,NSEC,JULDAY,IERR)
      IELDAY=JULDAY
      NHR=NHRMIN/100
      NMIN=NHRMIN-NHR*100
      IELHMS=(NHR*10000+NMIN*100)+(NSEC/100)
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1080) OPTN(IOPTN),IELDAY,IELHMS
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  MAXWARN OPTION
C
760   IF (LLPAR.EQ.0) THEN
         MAXWRN=500
         WRITE (LP,1040) OPTN(IOPTN),MAXWRN
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 770
         ENDIF
      IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.EQ.0) THEN
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
         ENDIF
      CALL UFINFX (MAXWRN,ISTRT,LLPAR+1,LRPAR-1,IERR)
770   ICKMIN=0
      ICKMAX=9999
      IF (MAXWRN.GT.0.AND.MAXWRN.LE.9999) GO TO 780
         WRITE (LP,1150) OPTN(IOPTN),MAXWRN,ICKMIN,ICKMAX
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
780   IOPMXW=MAXWRN
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPMXW
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  ORDER OPTION
C
790   IF (LLPAR.GT.0) GO TO 800
         CALL UMEMOV (RESET,STRNG2,2)
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 820
800   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 810
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
810   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'RESET') GO TO 820
         WRITE (LP,1130) OPTN(IOPTN),STRNG2
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
820   CALL WPPCOF (IERR)
      IF (IERR.EQ.0) THEN
         WRITE (LP,1180)
         CALL ULINE (LP,2)
         ENDIF
      IF (IERR.EQ.1) THEN
         WRITE (LP,1190)
         CALL ULINE (LP,2)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  OPTLOG OPTION
C
830   IF (LLPAR.GT.0) GO TO 840
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 860
840   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 850
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
850   CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') GO TO 860
         WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
860   OPTLOG=STRNG2
      IF (OPTLOG.EQ.'YES') IOPOLG(1)=1
      IF (OPTLOG.EQ.'NO') IOPOLG(1)=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1060) OPTN(IOPTN),OPTLOG
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  MSGLEVEL OPTION
C
870   IF (LLPAR.GT.0) GO TO 880
         MSGLVL=NSGLVL
         WRITE (LP,1040) OPTN(IOPTN),MSGLVL
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 900
880   IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.GT.0) GO TO 890
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
890   CALL UFINFX (MSGLVL,ISTRT,LLPAR+1,LRPAR-1,IERR)
      ICKMIN=0
      ICKMAX=2
      IF (MSGLVL.GE.ICKMIN.AND.MSGLVL.LE.ICKMAX) GO TO 900
         WRITE (LP,1140) OPTN(IOPTN),MSGLVL,ICKMIN,ICKMAX
         CALL SUERRS (LP,2,NUMERR)
         GO TO 10
900   IOPMLV=MSGLVL
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPMLV
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  NOGOESCK OPTION
C
910   WRITE (LP,970) OPTN(IOPTN)
      CALL SUWRNS (LP,2,NUMWRN)
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  RUNNTWK OPTION
C
920   IF (LLPAR.EQ.0) THEN
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 900
         ENDIF
      IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.EQ.0) THEN
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
         ENDIF
      CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') THEN
         ELSE
            WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
            CALL SUERRS (LP,2,NUMERR)
            GO TO 10
            ENDIF
      RUNNTW=STRNG2
      IF (RUNNTW.EQ.'YES') IOPNTW=1
      IF (RUNNTW.EQ.'NO') IOPNTW=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPNTW
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  RUNORDR OPTION
C
921   IF (LLPAR.EQ.0) THEN
         STRNG2='YES'
         WRITE (LP,980) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
         CALL SUWRNS (LP,2,NUMWRN)
         GO TO 900
         ENDIF
      IF (LRPAR.GT.0) IRPFND=1
      IF (LRPAR.EQ.0) THEN
         WRITE (LP,960) NFLD
         CALL SULINE (LP,2)
         LRPAR=LENGTH+1
         ENDIF
      CALL UFPACK (LSTRNG2,STRNG2,ISTRT,LLPAR+1,LRPAR-1,IERR)
      IF (STRNG2.EQ.'YES'.OR.
     *    STRNG2.EQ.'NO') THEN
         ELSE
            WRITE (LP,1130) OPTN(IOPTN),STRNG2(1:LENSTR(STRNG2))
            CALL SUERRS (LP,2,NUMERR)
            GO TO 10
            ENDIF
      RUNNTW=STRNG2
      IF (RUNNTW.EQ.'YES') IOPORD=1
      IF (RUNNTW.EQ.'NO') IOPORD=0
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,1070) OPTN(IOPTN),IOPORD
         CALL SULINE (IOSDBG,1)
         ENDIF
      GO TO 10
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
930   IF (SVDFLT.EQ.'NO') GO TO 940
C
C  WRITE DEFAULT RUN OPTIONS TO FILE
      CALL SWDFLT (LARRAY,ARRAY,NPSMLN,IOPNWP,IOPOVP,IOPCLG(1),IERR)
      IF (IERR.EQ.0) THEN
         IDBWT=1
         CALL SMDFLT (LARRAY,ARRAY,IERR)
         ENDIF
C
C  PRINT OPTIONS IN EFFECT
940   IF (ISLEFT(5).GT.0) CALL SUPAGE
      WRITE (LP,1200)
      CALL SULINE (LP,2)
      IF (IOPPLT.EQ.0) PLOT='NO'
      IF (IOPPLT.EQ.1) PLOT='YES'
      IF (IOPNWP.EQ.0) XNWPAG='NO'
      IF (IOPNWP.EQ.1) XNWPAG='YES'
      UNITS=' '
      IF (IOPUNT.EQ.0) UNITS='ENGL'
      IF (IOPUNT.EQ.1) UNITS='METR'
      RUNCHK=' '
      IF (IOPRCK.EQ.0) RUNCHK='NO'
      IF (IOPRCK.EQ.1) RUNCHK='YES'
      OVRPRT=' '
      IF (IOPOVP.EQ.0) OVRPRT='NO'
      IF (IOPOVP.EQ.1) OVRPRT='YES'
      IF (IOPTLE.EQ.0) TITLE='NO'
      IF (IOPTLE.EQ.1) TITLE='PAGE'
      IF (IOPTLE.EQ.2) TITLE='YES'
      WRITE (LP,1210) IOPCND,IOPMLV,XNWPAG,OVRPRT,NPSMLN,PLOT,
     *    RUNCHK,TITLE,UNITS
      CALL SULINE (LP,2)
      PDUMP=' '
      IF (IOPDMP.EQ.1) PDUMP='STRNG'
      IF (IOPDMP.EQ.2) PDUMP='INT'
      IF (IOPDMP.EQ.3) PDUMP='REAL'
      IF (IOPDMP.EQ.4) PDUMP='BOTH'
      CMDLOG=' '
      IF (IOPCLG(1).EQ.0) CMDLOG='NO'
      IF (IOPCLG(1).EQ.1) CMDLOG='YES'
      OPTLOG=' '
      IF (IOPOLG(1).EQ.0) OPTLOG='NO'
      IF (IOPOLG(1).EQ.1) OPTLOG='YES'
      STOPMS=' '
      IF (IOPSTP.EQ.0) STOPMS='NO'
      IF (IOPSTP.EQ.1) STOPMS='YES'
      RUNNTW=' '
      IF (IOPNTW.EQ.0) RUNNTW='NO'
      IF (IOPNTW.EQ.1) RUNNTW='YES'
      RUNORD=1h
      IF (IOPORD.EQ.0) RUNORD=h2NO
      IF (IOPORD.EQ.1) RUNORD=h3YES
      WRITE (LP,1220) PDUMP,CMDLOG,OPTLOG,IOPMXE,IOPMXW,STOPMS,
     *   RUNNTW,RUNORD
      CALL SULINE (LP,1)
C
      IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,*) 'EXIT SETOPT'
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
960   FORMAT ('0*** NOTE - RIGHT PARENTHESIS ASSUMED IN FIELD ',I2,'.')
970   FORMAT ('0*** WARNING - ',A,' OPTION IS NO LONGER ALLOWED.')
980   FORMAT ('0*** WARNING - NO LEFT PARENTHESIS FOUND. ',A,
     *   ' OPTION SET TO ',A,'.')
990   FORMAT ('0*** WARNING - NO LEFT PARENTHESIS FOUND FOR OPTION ',
     *   A,'.')
1000  FORMAT ('0*** ERROR - A COLON (:) WAS NOT FOUND IN THE ',
     *   'INPUT FIELD FOR THE ',A,' OPTION.')
1010  FORMAT ('0*** NOTE - DATASET NAME SET TO : ',A)
1020  FORMAT ('0*** NOTE - DDNAME SET TO ',A,'.')
1030  FORMAT ('0*** NOTE - UNIT SET TO ',I2.2,' AND DDNAME SET TO ',
     *   A,'.')
1040  FORMAT ('0*** WARNING - NO LEFT PARENTHESIS FOUND. ',A,
     *   ' OPTION SET TO ',I5,'.')
1050  FORMAT ('0*** NOTE - ',A,' OPTION SET TO ',I5,'.')
1060  FORMAT (' ',A,' OPTION SET TO ',A)
1070  FORMAT (' ',A,' OPTION SET TO ',I5)
1080  FORMAT (' ',A,' OPTION SET : IELDAY=',I4,3X,'IELHMS=',I8)
1100  FORMAT ('0*** ERROR - PARMDUMP VALUE (',A,') MUST BE CHAR, ',
     *   'INT, REAL OR BOTH.')
1110  FORMAT (' NOTE: ',I5,' LINES WRITTEN TO UNIT ',I2.2,'.')
1120  FORMAT ('0*** ERROR - INVALID SETOPT OPTION : ',A)
1130  FORMAT ('0*** ERROR - INVALID ',A,' OPTION : ',A)
1140  FORMAT ('0*** ERROR - ',A,' VALUE (',I2,') MUST BE GREATER ',
     *   'THAN OR EQUAL TO ',I2,' AND LESS THAN OR EQUAL TO ',I2,'.')
1150  FORMAT ('0*** ERROR - ',A,' VALUE (',I5,') MUST BE GREATER ',
     *   'THAN ',I2,' OR LESS THAN OR EQUAL TO ',I4,'.')
1160  FORMAT ('0*** ERROR - ERROR PROCESSING OPTION : ',A)
1170  FORMAT (' BLANK STRING FOUND IN FIELD ',I2)
1180  FORMAT ('0*** NOTE - ALL ORDER PARAMETER RECORDS SUCCESSFULLY ',
     *   'DELETED AND FILE SPACE RELEASED.')
1190  FORMAT ('0*** NOTE - ALL ORDER PARAMETER RECORDS SUCCESSFULLY ',
     *   'DELETED BUT FILE SPACE NOT RELEASED BECAUSE OTHER ',
     *   'ARE STORED IN THE SAME FILE.')
1200  FORMAT ('0- RUN OPTIONS IN EFFECT -')
1210  FORMAT ('0  CONDCODE=',I2,2X,
     *   'MSGLEVEL=',I1,2X,
     *   'NEWPAGE=',A4,2X,
     *   'OVERPRNT=',A4,2X,
     *   'PAGESIZE=',I2,2X,
     *   'PLOT=',A4,2X,
     *   'RUNCHECK=',A4,2X,
     *   'TITLE=',A4,2X,
     *   'UNITS=',A4,2X)
1220  FORMAT ('   PARMDUMP=',A4,2X,
     *   'CMDLOG=',A4,2X,
     *   'OPTLOG=',A4,2X,
     *   'MAXERROR=',I4,2X,
     *   'MAXWARN=',I4,2X,
     *   'STOPMSGS=',A4,2X,
     *   'RUNNTWK=',A4,2X,
     *   'RUNORDR=',A4,2X)
C
      END