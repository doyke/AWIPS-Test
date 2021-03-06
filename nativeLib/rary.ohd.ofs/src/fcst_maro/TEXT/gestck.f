C MEMBER GESTCK
C  (from old member PPGESTCK)
C
      SUBROUTINE GESTCK(PCEST, PCAVG, PCNEAR)
C
C.....THIS SUBROUTINE CHECKS THE PRECIPITATION ESTIMATE AND FORCES IT
C.....NOT TO EXCEED THE AVERAGE OF ALL ESTIMATORS AND THE MAGNITUDE OF
C.....THE NEAREST PRECIPITATION.
C
C.....IF BOTH ARE EXCEEDED...THE ESTIMATE IS CHANGED TO THE SMALLER OF
C.....(1) THE LINEAR AVERAGE (I.E., EACH ESTIMATOR HAS THE SAME WEIGHT),
C.....(2) THE MAGNITUDE OF THE NEAREST PRECIPITATION REPORT.
C
C.....HERE ARE THE ARGUMENTS.
C
C.....PCEST  - THE CURRENT PRECIPITATION ESTIMATE.
C.....PCAVG  - THE LINEAR AVERAGE OALL THE ESTIMATORS.
C.....PCNEAR - THE MAGNITUDE OF THE NEAREST PRECIPITATION ESTIMATOR.
C
C.....ORIGINALLY WRITTEN BY
C
C.....JERRY M. NUNN       WGRFC FT. WORTH, TEXAS       OCTOBER 1986
C
C
      INTEGER*2 PCEST, PCAVG, PCNEAR, PW, PSMALL
C
      INCLUDE 'gcommon/gsize'
      INCLUDE 'common/pudbug'
      INCLUDE 'gcommon/boxtrc'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_maro/RCS/gestck.f,v $
     . $',                                                             '
     .$Id: gestck.f,v 1.1 1995/09/17 19:01:32 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA QUAD /4hQUAD/
C
  900 FORMAT(1X,  'SUBROUTINE GESTCK.  CHANGE FORCED IN PRECIPITATION ES
     *TIMATE...AS IT EXCEEDS BOTH CHECK VALUES.', /, 5X, 'ORIGINAL ESTIM
     *ATE = ', I5, 3X, 'AVERAGE OF ALL ESTIMATORS = ', I5, 3X, 'MAGNITUD
     *E OF NEAREST ESTIMATOR = ', I5, 3X, 'NEW ESTIMATE = ', I5)
C
      IF(PCEST .EQ. MSGGRD) GOTO 999
C
      NQBUG = IPBUG(QUAD)
      IF(IBTCON .EQ. 0) NQBUG = 0
C
      PW = -PCEST
C
C.....CHECK THE MAGNITUDE OF THE ESTIMATE. DO NOT LET IT EXCEED BOTH
C.....CHECK VALUES.
C
      IF(PW .LE. PCAVG)  GOTO 999
      IF(PW .LE. PCNEAR) GOTO 999
C
C.....BOTH VALUES ARE EXCEEDED. MAKE THE NEW ESTIMATE THE SMALLER OF THE
C.....TWO OTHER CHECK VALUES.
C
      IF((PCAVG .NE. MSGGRD) .AND. (PCNEAR .NE. MSGGRD)) GOTO 300
      IF((PCAVG .EQ. MSGGRD) .AND. (PCNEAR .EQ. MSGGRD)) GOTO 999
      IF(PCAVG .EQ. MSGGRD) GOTO 200
      PCEST = PCAVG
      GOTO 700
C
  200 PCEST = PCNEAR
      GOTO 700
C
  300 PSMALL = PCAVG
      IF(PCNEAR .LT. PSMALL) PSMALL = PCNEAR
C
      PCEST = PSMALL
      IF(NQBUG .EQ. 1) WRITE(IOPDBG,900) PW, PCAVG, PCNEAR, PCEST
C
  700 PCEST = -PCEST
  999 RETURN
      END
