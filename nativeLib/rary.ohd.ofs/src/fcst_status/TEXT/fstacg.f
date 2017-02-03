C MODULE FSTACG
C-----------------------------------------------------------------------
C
C  ROUTINE TO PRINT CARRYOVER GROUP STATUS.
C
      SUBROUTINE FSTACG
C
      INCLUDE 'common/fdbug'
      INCLUDE 'common/fccgd'
      INCLUDE 'common/fccgd1'
      INCLUDE 'common/fcfgs'
      INCLUDE 'common/fcunit'
      INCLUDE 'common/ionum'
      INCLUDE 'common/fctime'
      INCLUDE 'common/errdat'
C
      CHARACTER*12 COMPL(2)/'COMPLETE','INCOMPLETE'/
      CHARACTER*12 PROTEC(2)/'PROTECTED ','VOLATILE'/
C
      DIMENSION FGTBLE(2,7,22)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_status/RCS/fstacg.f,v $
     . $',                                                             '
     .$Id: fstacg.f,v 1.4 2002/02/11 20:24:57 dws Exp $
     . $' /
C    ===================================================================
C
      DATA BLANK/4H    /
C
C
      IF (ITRACE.GT.0) WRITE (IODBUG,*)' ENTER FSTACG'
C
      IBUG=0
      IF (IFBUG('STAT').GT.0) IBUG=1
C
C  PRINT PAGE HEADER
      IFIRST=0
      CALL FSTAHD (IFIRST)
      WRITE (IPR,20)
20    FORMAT ('0- CARRYOVER GROUP STATUS -')
C
C  GET NUMBER OF CARRYOVER GROUPS DEFINED
      IREC=1
      CALL UREADT (KFCGD,IREC,NSLOTS,ISTAT)
      IF (ISTAT.NE.0) GO TO 350
C
      IF (NCG.EQ.0) THEN
         WRITE (IPR,340)
340   FORMAT ('0**NOTE** NO CARRYOVER GROUPS ARE DEFINED.')
         GO TO 350
         ENDIF
C
C  PROCESS EACH CARRYOVER GTOUP
      DO 320 ICG=1,NCG
         IF (ICG.GT.1) THEN
            CALL FSTAHD (IFIRST)
            WRITE (IPR,30)
30    FORMAT ('0- CARRYOVER GROUP STATUS (CONTINUED) -')
            ENDIF
         CALL UREADT (KFCGD,ICOREC(ICG),CGIDC,ISTAT)
         IF (ISTAT.NE.0) GO TO 350
         IYEAR=MOD(ITDEF(3),100)
         WRITE (IPR,40) CGIDC,CGNAME,ITDEF(1),ITDEF(2),IYEAR,
     *      ITDEF(4),ITDEF(5)
40    FORMAT ('0',4X,2A4,' -- ',5A4,' -- DEFINED ON ',
     *   I2.2,'/',I2.2,'/',I2.2,'-',I4.4,'.',I4.4)
         WRITE (IPR,60) ICOREC(ICG)
60    FORMAT ('0',13X,'RECORD NUMBER ',I4,' IN FILE FCCOGDEF')
         WRITE (IPR,70) NFG,MINDTC
70    FORMAT ('0',13X,'CONTAINS ',I5,' FORECAST GROUPS.  MINIMUM ',
     *   'TIME STEP = ',I2,' HOURS')
         WRITE (IPR,80)
80    FORMAT ('0',25X,'SAVED',4X,'TIME' /
     *   ' ',13X,
     *   'SLOT',5X,'DAY    HOUR ZONE  TIME DEFINED',15X,'STATUS' /
     *   ' ',13X,'----',2X,'--------- ---- ----  ',19('-'),1X,20('-'))
         DO 120 ISLOT=1,NSLOTS
            ICMPL=2
            IPROT=2
            IF (IPC(ISLOT).EQ.1.OR.IPC(ISLOT).EQ.3) ICMPL=1
            IF (IPC(ISLOT).EQ.2.OR.IPC(ISLOT).EQ.3) IPROT=1
C        GET TIME DEFINED
            CALL MDYH1 (LUPDAY(ISLOT),1,MDEF,IDDEF,IYDEF,IHDEF,
     *         100,0,ZCODE)
            IYDEF=MOD(IYDEF,100)
            IHDEF=LUPTIM(ISLOT)/100000
            ISECDF=MOD(LUPTIM(ISLOT),100000)
C        CHECK IF DAY SAVED IS AN INITIAL DATE
            IF (ICODAY(ISLOT).GT.0) GO TO 100
               WRITE (IPR,90) ISLOT,COMPL(ICMPL),PROTEC(IPROT)
90    FORMAT ('0',13X,I3,6X,'NOT USED  ',13X,'UNDEFINED',6X,A,A)
               GO TO 120
100         CALL MDYH1 (ICODAY(ISLOT),ICOTIM(ISLOT),ICM,ICD,ICY,ICHH,
     *         NOUTZ,NOUTDS,ZCODE)
            ICY=MOD(ICY,100)
            WRITE (IPR,110) ISLOT,ICM,ICD,ICY,ICHH,ZCODE,MDEF,
     *          IDDEF,IYDEF,IHDEF,ISECDF,
     *          COMPL(ICMPL),PROTEC(IPROT)
110   FORMAT ('0',13X,I3,3X,
     *   I2.2,'/',I2.2,'/',I2.2,2X,I3,2X,A4,2X,
     *   I2.2,'/',I2.2,'/',I2.2,'-',I4.4,'.',I4.4,2X,A,A)
120         CONTINUE
C     GET LIST OF FORECAST GROUPS
         CALL UREADT (KFCGD,ICOREC(ICG),CGIDC,ISTAT)
         IF (ISTAT.NE.0) GO TO 350
         NFGRUN=NFG
         IF (IBUG.EQ.1) WRITE (IODBUG,130) ICG,ICOREC(ICG),CGIDC
130   FORMAT (' IN FSTACG - ICG,ICOREC,CGIDC=',I5,',',I5,',',2A4)
C     NFGRUN IS THE NUMBER OF FORECAST GROUPS IN THE CGROUP.
C     IFGRC1 IS THE RECORD TO START THE SEARCH OF FILE FCFGSTAT FOR
C       THE CORRECT FORECAST GROUP.
C     IFGRC2 IS THE RECORD TO END THE SEARCH.
C     THESE ARE SET TO IFGRC1=1 AND IFGRC2=NFGREC AT FIRST, BUT WHEN
C       A FORECAST GROUP IS FOUND, THE SEARCH LIMITS ARE RESET TO SEARCH
C       THE REMAINDER OF THE FILE BEFORE RESTARTING AT RECORD ONE.
C     FIRST READ FIRST RECORD ON FILE FCFGSTAT TO GET NFGREC
         CALL UREADT (KFFGST,1,FGID,ISTAT)
         IF (ISTAT.NE.0) GO TO 350
         NFGREC=IDUMYG
         IF (IBUG.EQ.1) WRITE (IODBUG,150) NFGRUN,NFGREC
150   FORMAT (' IN FSTACG - NFGRUN,NFGREC=',I5,',',I5)
         IFGRC1=1
C     PRINT LIST OF FORECAST GROUPS IN CARRYOVER GROUP
         NPAGES=(NFGRUN-1)/154+1
         DO 300 IPAGE=1,NPAGES
            IF (IPAGE.EQ.1) GO TO 170
               CALL FSTAHD (0)
               WRITE (IPR,20)
               WRITE (IPR,160)CGIDC
160   FORMAT ('0',4X,2A4,' (CONTINUED)')
170         WRITE (IPR,180)
180   FORMAT ('0',13X,'*** LIST OF FORECAST GROUPS IN COMPUTATIONAL ',
     *   'ORDER (READ DOWN) ***')
C        FILL FORECAST  TABLE WITH BLANKS
            DO 190 K=1,22
               DO 190 J=1,7
               DO 190 I=1,2
               FGTBLE(I,J,K)=BLANK
190            CONTINUE
            IS1=(IPAGE-1)*154+1
            IS2=IPAGE*154
            IF (IS2.GT.NFGRUN) IS2=NFGRUN
C        PROCESS EACH FORECAST GROUP
            MLINE=0
            DO 290 IFGRUN=IS1,IS2
               IF (IBUG.EQ.1) WRITE (IODBUG,200) IFGRUN
200   FORMAT (' IN FSTACG - IFGRUN=',I5)
C           RESET END SEARCH LIMIT TO NFGREC AT START OF EACH PASS
               IFGRC2=NFGREC
C           FIND FORECAST GROUP ON FILE
210            IF (IBUG.EQ.1) WRITE (IODBUG,220) IFGRC1,IFGRC2
220   FORMAT (' IN FSTACG - IFGRC1,IFGRC2=',I5,',',I5)
               DO 230 IFGREC=IFGRC1,IFGRC2
                  CALL UREADT (KFFGST,IFGREC,FGID,ISTAT)
                  IF (ISTAT.NE.0) GO TO 350
C              FORECAST GROUP MUST BE THE IFGRUN-TH TO BE IN THE PROPER
C              ORDER
                  IF (ICOSEQ.NE.IFGRUN) GO TO 230
                  IF (CGIDF(1).NE.CGIDC(1)) GO TO 230
                  IF (CGIDF(2).NE.CGIDC(2)) GO TO 230
                  GO TO 240
230               CONTINUE
               GO TO 250
C        FORECAST GROUP TO BE EXECUTED HAS BEEN FOUND -  RESET SEARCH 
C        LIMITS FOR NEXT ONE
240         IFGRC1=IFGREC+1
            IF (IFGRC1.GT.NFGREC) IFGRC1=1
            GO TO 280
C        DID NOT FIND FORECAST GROUP - IF SEARCH STARTED AT RECORD ONE,
C        THE FORECAST GROUP IS NOT ON FILE - IF SEARCH STARTED AT SOME 
C        RECORD OTHER THAN RECORD ONE, THE FIRST PART OF THE FILE HAS TO 
C        BE SEARCHED
250         IF (IFGRC1.NE.1) GO TO 270
               WRITE (IPR,260) IFGRUN,CGIDC
260   FORMAT ('0**ERROR** IN FSTACG - THE FORECAST GROUP TO BE ',
     *   'EXECUTED ',I4,'TH IN CARRYOVER GROUP ',2A4,
     *   ' COULD NOT BE FOUND.')
               CALL ERROR
               GO TO 290
270         IFGRC2=IFGRC1-1
            IFGRC1=1
            GO TO 210
C        FILL SEGMENT TABLE
280         ISP=IFGRUN-IS1+1
            ICOLUM=(ISP-1)/22+1
            LINE=ISP-(ICOLUM-1)*22
            IF (LINE.GT.MLINE) MLINE=LINE
            FGTBLE(1,ICOLUM,LINE)=FGID(1)
            FGTBLE(2,ICOLUM,LINE)=FGID(2)
290         CONTINUE
300      CONTINUE
         WRITE (IPR,310) (((FGTBLE(I,J,K),I=1,2),J=1,7),K=1,MLINE)
310   FORMAT (' ',12X,2A4,2X,2A4,2X,2A4,2X,2A4,2X,2A4,2X,2A4,2X,2A4)
320      CONTINUE 
C
350   RETURN
C
      END