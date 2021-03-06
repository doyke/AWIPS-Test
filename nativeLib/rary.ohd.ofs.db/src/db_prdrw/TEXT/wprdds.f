C MODULE WPRDDS
C-----------------------------------------------------------------------
C
C  ROUTINE WPRDDS PRINT ERROR MESSAGES WHEN THE STATUS CODE RETURNED
C  FROM ROUTINE WPRDD IS GREATER THAN ZERO.
C
C-----------------------------------------------------------------------
C
C  INPUT ARGUMENTS:
C        ISTAT - STATUS CODE RETURNED BY WPRDD
C        TSID  - TIME SERIES IDENTIFIER
C        DTYPE - DATA TYPE CODE
C        JHOUR - BEGINNING JULIAN HOUR
C       INTVAL - DATA TIME INTERVAL
C        NUMPD - NUMBER OF TIME PERIODS OF DATA
C        NVALS - NUMBER OF DATA VALUES IN ARRAY TSDAT
C       UNITOT - UNITS DESIRED
C       LWKBUF - LENGTH OF ARRAY IWKBUF
C       LTSDAT - LENGTH OF ARRAY TSDAT
C
C-----------------------------------------------------------------------
C
      SUBROUTINE WPRDDS (ISTAT,TSID,DTYPE,JHOUR,INTVAL,NUMPD,NVALS,
     *   UNITOT,LWKBUF,LTSDAT)
C
      CHARACTER*4 DTYPE,UNITOT
      CHARACTER*8 TSID
C
      INCLUDE 'common/ionum'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/db_prdrw/RCS/wprdds.f,v $
     . $',                                                             '
     .$Id: wprdds.f,v 1.1 1999/07/06 16:35:58 page Exp $
     . $' /
C    ===================================================================
C
C
C
      IF (ISTAT.EQ.0) GO TO 20
C
      IF (ISTAT.EQ.1) THEN
         WRITE (IPR,40) TSID,DTYPE
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.2) THEN
         WRITE (IPR,50) TSID,DTYPE
         CALL WARN
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.3) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,60) INTVAL
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.4) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,70) DTYPE
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.5) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,80)
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.6) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,90)
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.7) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,100) DTYPE
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.8) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,110) NUMPD,NVALS
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.9) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,120) UNITOT
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.10) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,130) LWKBUF
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.11) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,140) JHOUR
         CALL ERROR
         GO TO 20
         ENDIF
C
      IF (ISTAT.EQ.12) THEN
         WRITE (IPR,30) TSID,DTYPE
         WRITE (IPR,160) LTSDAT
         CALL ERROR
         GO TO 20
         ENDIF
C
      WRITE (IPR,170) ISTAT,TSID,DTYPE
      CALL ERROR
C
20    RETURN
C
30    FORMAT ('0**ERROR** ENCOUNTERED ATTEMPTING TO WRITE ',
     * 'TIME SERIES ',A,' AND DATA TYPE ',A,' TO THE PROCESSED ',
     * 'DATA BASE.')
40    FORMAT ('0**ERROR** TIME SERIES NOT FOUND ',
     * 'FOR IDENTIFIER ',A,' AND DATA TYPE ',A,'.')
50    FORMAT ('0**WARNING** THE TIME SERIES ',
     * 'FOR IDENTIFIER ',A,' AND DATA TYPE ',A,' ',
     * 'WAS TRUNCATED BEFORE BEING WRITTEN.')
60    FORMAT ('0**ERROR** THE TIME INTERVAL ',I3,' DOES NOT MATCH ',
     * 'THE TIME INTERVAL IN THE PROCESSED DATA BASE.')
70    FORMAT ('0**ERROR** THE DATA TYPE ',A,' CAN NOT BE WRITTEN BY ',
     * 'THE PREPROCESSOR COMPONENT.')
80    FORMAT ('0**ERROR** ERROR READING FROM THE PROCESSED DATA ',
     * 'BASE.')
90    FORMAT ('0**ERROR** THE NUMBER OF VALUES PER TIME PERIOD DOES ',
     * 'NOT MATCH THAT IN THE PROCESSED DATA BASE.')
100   FORMAT ('0**ERROR** MINIMUM DAYS OF OBSERVED DATA ON THE ',
     * 'PROCESSED DATA BASE CANNOT BE PRESERVED FOR DATA TYPE ',A,'.' /
     $ 11X,'DATA NOT WRITTEN FOR ALL STATIONS WITH THIS DATA TYPE.')
110   FORMAT ('0**ERROR** EITHER THE NUMBER OF DATA VALUES ',
     * '(',I4,') OR TIME PERIODS (',I4,') TO BE ',
     * 'WRITTEN TO THE PROCESSED DATA BASE IS ZERO.')
120   FORMAT ('0**ERROR** INVALID UNITS CONVERSION REQUESTED FOR DATA',
     * ' UNIT ',A,'.')
130   FORMAT ('0**ERROR** THE WORK ARRAY DIMENSIONED AT ',I5,' IS ',
     * 'TOO SMALL. NO DATA WRITTEN TO THE PROCESSED DATA BASE.')
140   FORMAT ('0**ERROR** STARTING HOUR (',I6,') IS NOT ',
     * 'COMPATIBLE WITH THE PROCESSED DATA BASE.')
160   FORMAT ('0**ERROR** THE DATA ARRAY DIMENSIONED AT ',I5,' IS ',
     * 'TOO SMALL. NO DATA WRITTEN TO THE PROCESSED DATA BASE.')
170   FORMAT ('0**ERROR** STATUS CODE OF RETURNED FROM WPRDD (',
     $ I2,') NOT RECOGNIZED ',
     * 'FOR IDENTIFIER ',A,' AND DATA TYPE ',A,'.')
C
      END
