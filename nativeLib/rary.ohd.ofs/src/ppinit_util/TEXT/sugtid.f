C MODULE SUGTID
C-----------------------------------------------------------------------
C
C  ROUTINE TO GET STATION IDENTIFIER AND DESCRIPTION USING THE
C  PREPROCESSOR DATA BASE POINTER.
C
      SUBROUTINE SUGTID (ITM,TYPE,IPPDB,STAID,DESCRP,STATE,IPCHAR,
     *   LARAY,ARRAY,ISTAT)
C
      CHARACTER*4 TYPE,TYPEX,RDISP
      CHARACTER*8 TYPMSG
      INTEGER*2 IPNTR
C
      DIMENSION ARRAY(LARAY)
      DIMENSION UNUSED(10)
C
      INCLUDE 'scommon/dimstan'
      INCLUDE 'scommon/dimpcpn'
      INCLUDE 'scommon/dimtemp'
      INCLUDE 'scommon/dimpe'
      INCLUDE 'scommon/dimrrs'
C
      INCLUDE 'uiox'
      INCLUDE 'scommon/sudbgx'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/ppinit_util/RCS/sugtid.f,v $
     . $',                                                             '
     .$Id: sugtid.f,v 1.6 2002/02/11 21:05:12 dws Exp $
     . $' /
C    ===================================================================
C
C
      IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,*) 'ENTER SUGTID'
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  SET DEBUG LEVEL
      LDEBUG=ISBUG('SYS ')
C
      ISTAT=0
C
      LAPARM=100
      IPPDBX=IPPDB
      IPPPDB=0
      IISTAN=0
      CALL UREPET ('?',STAID,8)
      CALL UREPET ('?',DESCRP,20)
C
C  CHECK FOR VALID TYPE
      IF (TYPE.NE.'PP24'.AND.
     *    TYPE.NE.'PPVR'.AND.
     *    TYPE.NE.'TM24'.AND.
     *    TYPE.NE.'TAVR'.AND.
     *    TYPE.NE.'TF24'.AND.
     *    TYPE.NE.'EA24'.AND.
     *    TYPE.NE.'GENL') THEN
         WRITE (LP,170) TYPE
         CALL SUERRS (LP,2,NUMERR)
         ISTAT=1
         GO TO 140
         ENDIF
C
      IF (TYPE.EQ.'GENL') THEN
         IISTAN=IPPDB
         CALL UREPET (' ',STAID,8)
         GO TO 130
         ENDIF
C
C  CHECK FOR VALID POINTER VALUE
      IF (IPPDB.GT.0.AND.IPPDB.LT.99999) THEN
         ELSE
            WRITE (LP,180) IPPDB
            CALL SUERRS (LP,2,NUMERR)
            ISTAT=1
            GO TO 140
         ENDIF
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
C  SET DIMENSION OF ARRAYS
      IDIM=(LARAY-LAPARM)/3
      IDIM1=IDIM*2
      IDIM2=IDIM
      IDPT1=LAPARM+1
      IDPT2=IDPT1+IDIM1
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,205) LARAY,LAPARM,IDIM,IDIM1,IDIM2,IDPT1,IDPT2
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      IF (ITM.GT.1) GO TO 50
C
C  GET POINTERS FROM PREPROCESSOR DATA BASE
      TYPMSG='ERROR'
      CALL SUGTPT (TYPE,IDIM1,ARRAY(IDPT1),LPFILL,TYPMSG,IERR)
      IF (IERR.EQ.0.OR.IERR.EQ.2.OR.IERR.EQ.4.OR.IERR.EQ.7) GO TO 40
         ISTAT=1
         GO TO 140
C
40    IF (LDEBUG.GT.0) CALL SUDPTR (TYPE,ARRAY(IDPT1),LPFILL)
C
50    IF (TYPE.NE.'TAVR'.AND.TYPE.NE.'TF24') GO TO 70
C
C  GET NEXT SET OF POINTERS
      IPOS=IPPDBX*2-1
      CALL SUBSTR (ARRAY(IDPT1),IPOS,2,IPNTR,1)
      ILOC=IPNTR
      IPPDBX=IABS(ILOC)
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,210) IPPDB,IPPDBX,IPPPDB,IPOS,ILOC
         CALL SULINE (IOSDBG,1)
         ENDIF
      IF (ITM.GT.1) GO TO 70
         TYPEX='TM24'
         TYPMSG='ERROR'
         CALL SUGTPT (TYPEX,IDIM2,ARRAY(IDPT2),LPFILL,TYPMSG,IERR)
         IF (IERR.EQ.0.OR.IERR.EQ.2.OR.IERR.EQ.4.OR.IERR.EQ.7) GO TO 60
            ISTAT=1
            GO TO 140
60       IF (LDEBUG.GT.0) CALL SUDPTR (TYPEX,ARRAY(IDPT2),LPFILL)
C
C  GET POINTER TO PARAMETERS
70    IPOS=IPPDBX*2-1
      IF (TYPE.NE.'TAVR'.AND.TYPE.NE.'TF24') THEN
         CALL SUBSTR (ARRAY(IDPT1),IPOS,2,IPNTR,1)
         ENDIF
      IF (TYPE.EQ.'TAVR'.OR.TYPE.EQ.'TF24') THEN
         CALL SUBSTR (ARRAY(IDPT2),IPOS,2,IPNTR,1)
         ENDIF
      ILOC=IPNTR
      IPPPDB=IABS(ILOC)
      IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,210) IPPDB,IPPDBX,IPPPDB,IPOS,ILOC
         CALL SULINE (IOSDBG,1)
         ENDIF
C
C  CHECK FOR POSITIVE RECORD NUMBER
      IF (IPPPDB.GT.0) GO TO 80
         WRITE (LP,190) IPPPDB,TYPE,IPPDB
         CALL SUERRS (LP,2,NUMERR)
         GO TO 150
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
80    CALL UREPET (' ',STAID,8)
      IPRERR=1
C
      IF (TYPE.EQ.'PP24') THEN
C     READ PCPN PARAMETERS
         IREAD=1
         CALL SRPCPN (IVPCPN,STAID,NUMBER,DESCRP,STATE,STALOC,
     *      STACOR,IPROC,IPTIME,MDRBOX,PCPNCF,IPTWGT,IPNTWK,IPSWGT,
     *      IPCHAR,IPD5PT,STA5WT,STASID,IPDSPT,STASWT,IPD3PT,STA3WT,
     *      UNUSED,LAPARM,ARRAY(1),IPPPDB,IPRERR,IPCPNX,IREAD,IERR)
         IF (IERR.EQ.0) GO TO 140
         WRITE (LP,220) 'PCPN',IPPDB,IPPPDB
         CALL SUERRS (LP,2,NUMERR)
         ISTAT=1
         GO TO 150
         ENDIF
C
      IF (TYPE.EQ.'PPVR') THEN
         IISTAN=IPPPDB
         GO TO 130
         ENDIF
C
      IF (TYPE.EQ.'TM24'.OR.TYPE.EQ.'TAVR'.OR.TYPE.EQ.'TF24') THEN
C     READ TEMP PARAMETERS
         IF (LDEBUG.GT.0) THEN
            WRITE (IOSDBG,*) 'IN SUGTID - IPPPDB=',IPPPDB
            CALL SULINE (IOSDBG,1)
            ENDIF
         IREAD=1
         CALL SRTEMP (IVTEMP,STAID,NBRSTA,DESCRP,STATE,ITYOBS,
     *      IMTN,TEMPCF,IFMM,TEMPFE,ITNTWK,IPMMMT,IPDMMT,WTMMT,IPDINS,
     *      WTINS,IPDFTM,WTFTM,ITMINS,UNUSED,LAPARM,ARRAY(1),
     *      IPPPDB,IPRERR,ITEMPX,IREAD,IERR)
         IF (IERR.EQ.0) GO TO 140
         WRITE (LP,220) 'TEMP',IPPDB,IPPPDB
         CALL SUERRS (LP,2,NUMERR)
         ISTAT=1
         GO TO 150
         ENDIF
C
      IF (TYPE.EQ.'EA24') THEN
C     READ PE PARAMETERS
         CALL SRPE (IVPE,STAID,NBRSTA,DESCRP,STATE,STALAT,
     *      ANEMHT,PFACT,ITYRAD,PECOR,PEB3,PECOEF,PESUM,NPESUM,
     *      JPESUM,UNUSED,LAPARM,ARRAY(1),IPPPDB,IPRERR,IPEX,IERR)
         IF (IERR.EQ.0) GO TO 140
         WRITE (LP,220) 'PE',IPPDB,IPPPDB
         CALL SUERRS (LP,2,NUMERR)
         ISTAT=1
         GO TO 150
         ENDIF
C
C  INVALID TYPE
      WRITE (LP,200) TYPE
      CALL SUERRS (LP,2,NUMERR)
      GO TO 150
C
C  READ STAN PARAMETERS
130   IPTR=IISTAN
      RDISP='OLD'
      LARRAY=LAPARM
      INCLUDE 'scommon/callsrstan'
      IF (IERR.EQ.0) GO TO 140
         WRITE (LP,220) 'STAN',IPPDB,IPPPDB
         CALL SUERRS (LP,2,NUMERR)
         ISTAT=1
C
140   IF (LDEBUG.GT.0) THEN
         WRITE (IOSDBG,230) STAID,DESCRP,STATE
         CALL SULINE (IOSDBG,1)
         ENDIF
C
150   IF (ISTRCE.GT.0) THEN
         WRITE (IOSDBG,*) 'EXIT SUGTID'
         CALL SULINE (IOSDBG,1)
         ENDIF
C
      RETURN
C
C- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
C
170   FORMAT ('0*** ERROR - IN SUGTID - ',A,' IS AN INVALID DATA TYPE.')
180   FORMAT ('0*** ERROR - IN SUGTID - ',I5,' IS AN INVALID ',
     *   'PREPROCESSOR DATA BASE POINTER.')
190   FORMAT ('0*** ERROR - IN SUGTID - ',I5,' IS AN INVALID ',
     *   'PARAMETRIC DATA BASE RECORD NUMBER.',3X,
     *   'TYPE=',A,3X,'IPPDB=',I5)
200   FORMAT ('0*** ERROR - IN SUGTID - DATA TYPE ',A,
     *   ' NOT SUCCESSFULLY PROCESSED.')
205   FORMAT (' LARAY=',I5,3X,'LAPARM=',I5,3X,'IDIM=',I5,3X,
     *   'IDIM1=',I5,3X,'IDIM2=',I5,3X,
     *   'IDPT1=',I5,3X,'IDPT2=',I5)
210   FORMAT (' IPPDB=',I5,3X,'IPPDBX=',I5,3X,'IPPPDB=',I5,3X,
     *   'IPOS=',I5,3X,'ILOC=',I5)
220   FORMAT ('0*** ERROR - IN SUGTID - ERROR READING ',A,
     *   ' PARAMETERS. IPPDB=',I5,3X,'IPPPDB=',I5)
230   FORMAT (' STAID=',A,3X,'DESCRP=',A,3X,'STATE=',A2)
C
      END
