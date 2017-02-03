C MODULE EDST26
C ......................................................................
      SUBROUTINE EDST26(PO,W,LOCOWS
     & ,TIME,FACTOR,CHANGE,DNOVAL,DSVALU,TIMLAG,
     & ELVNO,ELRES,RELNO,ANOVAL,RELATN,
     & RULEL,STOR,ELEV,DATE,RULELV)
C ......................................................................
C THIS SUBROUTINE COMPUTES MAXIMUM PERMISSIBLE DISCHARGES FROM REGULA-
C TION SCHEDULES THAT USE A COMBINATION OF POOL ELEVATIONS AND DOWN-
C STREAM STAGES.  RELATIONS OF DOWNSTREAM STAGES (DISCHARGES) VS MAXIMUM
C DISCHARGES ARE USED WITH THE RELATIONS CHANGING ACCORDING TO INDICATED
C INTERVALS OF POOL ELEVATIONS AND THE RISE OR FALL OF DOWNSTREAM
C STAGES.  THE SUBROUTINE CAN DETERMINE PERMISSIBLE DISCHARGES FOR
C EITHER A 24-HR. PERIOD (NQMX24=1) OR FOR THE TIME PERIOD(NQMX24=0).
C SOME REGULATION SCHEDULES SHOW RELATIONS OF PERMISSIBLE DISCHARGES
C VS STAGES FOR A NUMBER OF TIME INTERVAL BUT THIS CAN BE ACCOMMODATED
C IF NEEDED IN  THE  SUBROUTINE BY USING THE SHORTEST TIME DURATION AS
C THE TIME PERIOD FOR COMPUTING INFLOW AND OUTFLOW FOR THE RESERVOIR.
C HOWEVER, USING THE PERMISSIBLE RELEASES FOR THE REGULAR TIME PERIOD
C SHOULD BE SATISFACTORY SINCE THE VARIATION OF DISCHARGES WITHIN THE
C REGULAR TIME PERIOD IS NOT USUALLY KNOWN AND SHOULD NOT CAUSE FLOOD
C STAGES AT THE DOWNSTREAM GAGE.  SOME SCHEDULES SHOW RELATIONS OF
C PERMISSIBLE DISCHARGES VS STAGES FOR TWO DOWNSTREAM GAGES AND THE
C SUBROUTINE PROVIDES FOR THAT POSSIBILITY.
C     A SIMULAYED RUN IS MADE FIRST USING NO OBSERVED DATA EXCEPT FOR
C THE BEGINNING STORAGE.  AN ADJUSTED RUN IS THEN MADE USING OBSERVED
C AND ADJUSTED VALUES.
C     FOR THE ADJUSTED RUN PRIOR TO RUN TIME, POOL STORAGES PASSED TO
C THIS SUBROUTINE MAY BE OBSERVED, COMPUTED FROM OBSERVED MEAN OUTFLOWS
C AND ADJUSTED MEAN INFLOWS, ADJUSTED FROM SIMULATED AND OBSERVED VALUES
C OR MISSING.  POOL ELEVATIONS WILL BE OBSERVED OR MISSING.  MEAN OUT-
C FLOWS MAY BE OBSERVED OR COMPUTED FROM ADJUSTED MEAN INFLOWS AND
C OBSERVED OR ADJUSTED STORAGES.  MEAN OUTFLOWS FOR THE TIME INTERVAL,
C POOL STORAGE, POOL ELEVATION, AND INSTANTANEOUS OUTFLOW AT THE END OF
C THE TIME INTERVAL ARE PASSED TO THIS SUBROUTINE IN THE VARIABLES QOM,
C S2, ELEV2, AND QO2, RESPECTIVELY.  MISSING VALUES ARE PASSED AS -999.0
C ......................................................................
C THIS SUBROUTINE WAS ORIGINALLY PROGRAMMED BY
C     WILLIAM E. FOX -- CONSULTING HYDROLOGIST
C     JANUARY, 1982
C ......................................................................
C SUBROUTINE EDST26 IS IN
C ......................................................................
C VARIABLES PASSED TO OR FROM THIS SUBROUTINE ARE DEFINED AS FOLLOWS:
C     ANOVAL -- ARRAY GIVING TOTAL NO. OF VALUES (NO. OF DISCHARGE OR
C       STAGE VALUES + NO. OF PERMISSIBLE OUTFLOW VALUES) FOR EACH RELA-
C       TION.  NOREL DEFINES THE NO. OF VALUES IN THE ANOVAL ARRAY.
C     DNOVAL -- ARRAY OF ONE OR TWO VALUES GIVING THE NUMBER OF DSVALU
C       VALUES FOR EACH OF THE DOWNSTREAM GAGES.
C     DSVALU -- ARRAY OF DISCHARGES OR STAGES FOR ONE OR TWO DOWNSTREAM
C       GAGES WITH ZERO DAM DISCHARGE FOR THIS TIME PERIOD.
C     ELEV -- ELEVATIONS FOR STORAGE VS ELEVATION CURVE.
C     ELEV1 -- ELEVATION AT BEGINNING OF TIME PERIOD.
C     ELEV2 -- ELEVATION AT END OF TIME PERIOD.
C     ELRES -- ARRAY OF 2 TO 4 SETS OF ELEVATIONS IN ASCENDING ORDER
C       (FOR EACH SET) FOR RELATIONSHIP OF ELEVATION VS RELATION NUMBER.
C       ELVNO ARRAY DEFINES THE NUMBER OF ELEVATIONS IN EACH SET.  A
C       VALUE OF -999.0 FOR ELRES(I) INDICATES RULE CURVE ELEVATION IS
C       USED.
C     ELVNO -- ARRAY GIVING THE NO. OF PAIRS OF ELEVATIONS AND RELATION
C       NUMBERS FOR EACH SET OF VALUES.. IF SEPARATE RELATIONS ARE
C       REQUIRED FOR RISING AND FALLING STAGES, THE POSITION NUMBER IN
C       THE ELVNO ARRAY WILL DEFINE THE FOLLOWING CONDITIONS:  POSITION
C       (1) - NO. OF PAIRS OF ELEVATIONS AND RELATION NUMBERS FOR RISING
C       STAGES AT THE 1ST DOWNSTREAM GAGE;  (2) - FALLING STAGES AT
C       FIRST DOWNSTREAM GAGE;  (3) - RISING STAGES AT SECOND DOWNSTREAM
C       GAGE;  (4) - FALLING STAGES AT SECOND DOWNSTREAM GAGE.
C       IF THE SAME RELATION IS USED FOR RISING AND FALLING STAGES, THE
C       POSITION NO. IN ELVNO WILL DEFINE THE FOLLOWING CONDITIONS:
C       POSITION (1) - NO. OF PAIRS OF ELEVATIONS AND RELATION NUMBERS
C       FOR THE FIRST DOWNSTREAM GAGE;  (2) - NO. OF PAIRS OF ELEVATIONS
C       AND RELATION NUMBERS FOR THE SECOND DOWNSTREAM GAGE.
C     FACTOR -- ARRAY OF FACTORS CORRESPONDING TO TIME VALUES.  FACTOR
C       IS MULTIPLIED BY THE 24-HR PERMISSIBLE DISCHARGE TO GET THE MEAN
C       DISCHARGE FOR THE REGULAR TIME PERIOD.  PRIMARILY USED FOR POWER
C       DAMS.
C     FCST -- LOGICAL VARIABLE.  IF TRUE, TIME PERIOD IS IN THE FORECAST
C       PERIOD.
C     IFCST -- SIMULATED RUN (IFCST=0) AND ADJUSTED RUN (IFCST=1).
C     KHRPRD -- TIME AT END OF THIS TIME PERIOD ACCORDING TO 24-HR. CLOC
C     NELVNO - NO. OF VALUES IN ELVNO ARRAY.  WILL BE ONE, TWO, OR FOUR.
C     NOREL -- TOTAL NO. OF RELATIONS NEEDED FOR DOWNSTREAM DISCHARGE
C       (STAGE) VS MAX. PERMISSIBLE OUTFLOW.
C     NQMX24 -- PERMISSIBLE DISCHARGE IS BEING COMPUTED FOR THE REGULAR
C       TIME PERIOD (NQMX24=0) OR FOR A 24-HR. PERIOD (NQMX24=1).
C     NGAGES -- NO. OF DOWNSTREAM GAGES USED IN REGULATION SCHEME (MAX.
C       OF 2).
C     NS2 -- POSITION IN ARRAYS AT END OF TIME PERIOD.
C     NSE -- NO. OF PAIRS OF STOR AND ELEV VALUES.
C     ISTAGE -- INDICATES DISCHARGES (ISTAGE=0) OR STAGES (ISTAGE=1) IN
C       DSVALU AND RELATN ARRAYS.
C     NTERP -- INDICATES ARITHMETIC (NTERP=0) OR LOGARITHMIC
C       INTERPOLATION (NTERP=1).
C     NTIM24 -- NUMBER OF REGULAR TIME PERIODS IN A 24-HR. PERIOD.
C     QI1 -- INFLOW AT BEGINNING OF TIME PERIOD.
C     QI2 -- INFLOW AT END OF TIME PERIOD.
C     QIM -- MEAN INFLOW FOR TIME PERIOD.
C     QO1 -- OUTFLOW AT BEGINNING OF TIME PERIOD.
C     QO2 -- OUTFLOW AT END OF TIME PERIOD.
C     QOM -- MEAN OUTFLOW FOR TIME PERIOD.
C     RELATN -- SETS OF RELATIONS OF DOWNSTREAM GAGE VALUES VS PERMISS-
C       IBLE OUTFLOWS.  THE POSITION OF THE RELATION VALUES IN THE
C       RELATN ARRAY (AS DETERMINED BY THE ANOVAL ARRAY) DEFINES THE
C       RELATION NUMBER CORRESPONDING TO NUMBERS IN THE RELNO ARRAY.
C     RELNO - ARRAY OF RELATION NUMBERS CORRESPONDING TO ELEVATIONS IN
C       THE ELRES ARRAY.  THE RELATION NO. WILL DEFINE WHICH RELATION
C       OF DOWNSTREAM DISCHARGE (OR  STAGE) VS MAX. OUTFLOW TO USE.  THE
C       RELATION INDICATED BY THE NO. IN RELNO(I) WILL BE USED FROM
C       ELRES(I) TO ELRES(I+1) EXCEPT THAT WHEN I IS THE LAST  POSITION
C       FOR A SET OF ELEVATIONS, THE RELATION WILL BE USED FOR ALL ELEV.
C       GREATER THAN OR EQUAL TO THE ELRES VALUE IN THIS LAST POSITION.
C       THE LOWEST POSSIBLE ELEVATION MUST ALWAYS BE THE FIRST ELEVATION
C       IN A SET OF ELEVATIONS IF THE MANUAL INDICATES THAT THE FIRST
C       RELATION WILL BE USED FOR ALL ELEVATIONS LESS THAN A SPECIFIED
C      ELEVATION.
C     RULEL1 -- RULE CURVE ELEVATION AT BEGINNING OF TIME PERIOD.
C     RULEL2 -- RULE CURVE ELEVATION AT END OF TIME PERIOD.
C     S1 -- STORAGE AT BEGINNING OF TIME PERIOD IN UNITS OF MEAN
C       DISCHARGE FOR THE TIME PERIOD.
C     S2 -- STORAGE AT END OF TIME PERIOD IN UNITS OF MEAN DISCHARGE FOR
C       THE TIME PERIOD.
C     STOR -- STORAGES FOR STORAGE VS ELEVATION CURVE.  MUST BE IN UNITS
C       OF MEAN DISCHARGE FOR THE TIME PERIOD.
C     TIME -- TIME VALUES FOR TIME VS FACTOR RELATION.  TIME IS FOR A
C       24-HR CLOCK AND IS THE TIME AT THE END OF A PERIOD.
C     TIMLAG -- LAG VALUES FROM THE DAM TO DOWNSTREAM GAGE(S) IN TIME
C       PERIOD UNITS.  VALUES ARE FOR FOLLOWING CONDITIONS:  POSITION 1-
C       TIME FROM END OF THIS TIME PERIOD TO DESIRED FORECAST STAGE OR
C       DISCHARGE AT FIRST DOWNSTREAM GAGE;  (2) - TIME FROM END OF
C       TIME PERIOD TO DESIRED FORECAST STAGE OR DISCHARGE AT SECOND
C       DOWNSTREAM GAGE.
C S2, ELEV2, QO2, AND QOM WILL BE COMPUTED IN THIS SUBROUTINE EXCEPT IN
C THOSE TIME PERIODS IN THE ADJUSTED RUN WHEN THE VALUES ARE OBSERVED.
C ......................................................................
C
      INCLUDE 'common/fdbug'
      INCLUDE 'common/resv26'
      INCLUDE 'common/dste26'
      INCLUDE 'common/rulc26'
C
      DIMENSION W(1),PO(1),LOCOWS(*)
      DIMENSION TIME(*),FACTOR(*),DNOVAL(*),DSVALU(*),TIMLAG(*),ELVNO(*)
     $,ELRES(*),RELNO(*),ANOVAL(*),RELATN(*),
     $ RULEL(*),STOR(*),ELEV(*),DATE(*),RULELV(*)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_res/RCS/edst26.f,v $
     . $',                                                             '
     .$Id: edst26.f,v 1.11 2002/10/10 17:24:49 wkwock Exp $
     . $' /
C    ===================================================================
C
C
C ......................................................................
C WRITE TRACE AND DEBUG IF REQUIRED.
C ......................................................................
      IF(IBUG-1)50,10,20
   10 WRITE(IODBUG,30)
      GO TO 50
   20 WRITE(IODBUG,30)
   30 FORMAT(1H0,10X,17H** EDST26 ENTERED)
      WRITE(IODBUG,40) IFCST,FCST,NS2,NQMX24,NTIM24,KHRPRD,
     & NGAGES,NELVNO,NOREL,NTERP,RULEL1,RULEL2,ELEV1,ELEV2,
     & QI1,QI2,QIM,QO1,QO2,QOM,S1,S2
   40 FORMAT(1H0,' IFCST,FCST,NS2,NQMX24,NTIM24,KHRPRD,',
     & 'NGAGES,NELVNO,NOREL,NTERP,RULEL1,RULEL2,ELEV1,ELEV2,',
     & 'QI1,QI2,QIM,QO1,QO2,QOM,S1,S2',
     $ /I6,L6,8I6,4F10.3/8F10.0)
   50 IGO=0
      IF(IFCST.EQ.0) GO TO 60
      IF(FCST) GO TO 60
      OBSQO2=QO2
C ......................................................................
C USE FUNCTION OBSV26 TO CHECK FOR A VALUE OF STORAGE AT THE END OF THE
C TIME INTERVAL.  THE TIME INTERVAL IS PRIOR TO OR AT RUN TIME.
C
      IGO=OBSV26(S2,IBUG)
      IF(IGO.EQ.1) GO TO 290
C
C WHEN IGO IS 1, THE POOL STORAGE IS OBSERVED; COMPUTED FROM OBSERVED
C MEAN OUTFLOWS AND ADJUSTED MEAN INFLOWS; ADJUSTED BETWEEN OBSERVED
C VALUES USING SIMULATED AND OBSERVED VALUES; OR INTERPOLATED BETWEEN
C OBSERVED VALUES.  WHEN IGO IS 0, THE STORAGE IS MISSING.  IF THE MEAN
C OUTFLOW IS OBSERVED BUT THE STORAGE AT THE END OF THE TIME INTERVAL IS
C MISSING, THE ENDING STORAGE WILL BE COMPUTED IN STATEMENT 281
C FROM THE OBSERVED MEAN INFLOW, THE ADJUSTED MEAN INFLOW, AND THE
C COMPUTED STORAGE AT THE BEGINNING OF THE TIME INTERVAL.
C
      IF(QOM.NE.-999.0) GO TO 281
C
C  REVISION: NO NEED TO COMPUTE THE RULE CURVE STORAGE AT END OF PERIOD
C   (JTO - 10/83)
C
C  60 CALL NTER26(RULEL2,RULST2,ELEV,STOR,NSE,IFLAG,NTERP,IBUG)
   60 CONTINUE
C ......................................................................
C SET NRF TO 0 IF THE SAME ELEVATION VS PERMISSIBLE OUTFLOW RELATIONS
C ARE USED FOR BOTH RISING AND FALLING DOWNSTREAM STAGES.  IF SEPARATE
C RELATIONS ARE USED, SET NRF=1.
C
      NRF=1
      IF(NGAGES.EQ.1.AND.NELVNO.EQ.1) NRF=0
      IF(NGAGES.EQ.2.AND.NELVNO.EQ.2)NRF=0
C
C FOLLOWING DO LOOP 250 COMPUTES MAX. PERMISSIBLE OUTFLOW FOR EITHER ONE
C OR TWO DOWNSTREAM GAGES.
C ......................................................................
      DO 250 IG=1,NGAGES
ccc      IF (IBUG.GE.2) WRITE(IODBUG,1636)
ccc 1636 FORMAT('  AT START OF 250 LOOP')
C ......................................................................
C COMPUTE CHANGE OF STAGE OR DISCHARGE AT THE DOWNSTREAM GAGE(S).
C                               DNOVAL ARRAY GIVES THE NO. OF DOWNSTREAM
C VALUES FOR EACH GAGE IN THE DSVALU ARRAY.  THE TIMLAG ARRAY GIVES THE
C TIME IN TIME PERIOD UNITS FROM THE DAM TO EACH DOWNSTREAM GAGE.
C ......................................................................
      M1 = IFIX(TIMLAG(IG))
      N1=M1 + 1
      NDSVA1=DNOVAL(1)+0.05
      IF(IG.EQ.2) GO TO 70
C ......................................................................
C CHECK THAT (N1+1) DOESN'T EXCEED NUMBER OF AVAILABLE VALUES.  IF IT
C DOES, REVISE N1.
C ......................................................................
      NDSUM=DNOVAL(1)+0.05
      IF((N1+1).LE.NDSVA1) GO TO 80
      N1=NDSVA1-1
      GO TO 80
   70 N1=N1+NDSVA1
      NDSUM=DNOVAL(1)+DNOVAL(IG)+0.05
      IF((N1+1).LE.NDSUM) GO TO 80
      N1=NDSUM-1
   80 REALM1=M1
      DSVX=DSVALU(N1+1)-DSVALU(N1)
      CHANGE=DSVX
C
C  ADJUSTMENT OF TIME FRACTION ALREADY MADE IN LAG/K AND
C  LATERAL FLOW COMPUTATION
C
      dsvx=0.0
      FCSTVA=DSVALU(N1+1)+DSVX*(TIMLAG(IG)-REALM1)
C ......................................................................
C DETERMINE PROPER POSITION IN ELVNO ARRAY WHICH GIVES THE NUMBER OF
C ELEVATION VALUES FOR EACH OF THE SETS OF VALUES.  IF SEPARATE RELA-
C TIONS ARE REQUIRED FOR RISING AND FALLING STAGES, THE POSITION IN
C ELVNO ARRAY DENOTES THE FOLLOWING CONDITIONS:  POSITION (1) - RISING
C STAGE OR DISCHARGE VALUE FOR FIRST DOWNSTREAM GAGE;  (2) - FALLING
C VALUES FOR FIRST DOWNSTREAM GAGE;  (3) - RISING VALUES FOR SECOND
C DOWNSTREAM GAGE;  (4) - FALLING VALUES FOR SECOND DOWNSTREAM GAGE.
C IF THE SAME RELATION IS USED FOR RISING AND FALLING STAGES, THE
C POSITION IN THE ELVNO ARRAY DENOTES THE FOLLOWING CONDITIONS:
C POSITION (1) - STAGE OR DISCHARGE VALUE FOR FIRST DOWNSTREAM GAGE
C POSITION (2) - STAGE OR DISCHARGE VALUE FOR SECOND DOWNSTREAM GAGE.
C ......................................................................
      IF(IG.EQ.1) GO TO 100
      IF(CHANGE.LT.0) GO TO 90
      NPOS=3
      IF(NRF.EQ.0) NPOS=2
      GO TO 120
   90 NPOS=4
      IF(NRF.EQ.0) NPOS=2
      GO TO 120
  100 IF(CHANGE.LT.0) GO TO 110
      NPOS=1
      GO TO 120
  110 NPOS=2
      IF(NRF.EQ.0) NPOS=1
C ......................................................................
C COMPUTE BEGINNING (JBGN) AND ENDING (JEND) POSITIONS OF ELEVATIONS
C IN ELRES ARRAY  FOR THIS SET OF VALUES.
C ......................................................................
  120 JSUM=0
      DO 130 J=1,NPOS
      NOELV=ELVNO(J)+0.05
  130 JSUM=JSUM+NOELV
      JEND=JSUM
      JBGN=JEND-NOELV+1
C ......................................................................
C COMPUTE POSITION OF ELEV1 IN ELRES ARRAY IN DO LOOP 140 AND DETERMINE
C THE RELATION NUMBER TO USE IN COMPUTING PERMISSIBLE OUTFLOW.  IF ELRES
C (J) IS -999.0, THE RULE CURVE ELEVATION WILL BE USED.
      ELRESJ=ELRES(JBGN)
      IF(IFMSNG(ELRESJ).EQ.1) ELRESJ=RULEL1
      IF(ELEV1.LE.ELRESJ) THEN
        JRELNO=RELNO(JBGN)+0.05
        GO TO 145
      ENDIF
      DO 140 J=JBGN,JEND
      ELRESJ=ELRES(J)
      IF(ELRESJ.NE.-999.0) GO TO 140
      ELRESJ=RULEL1
  140 IF(ELEV1.GE.ELRESJ) JRELNO=RELNO(J)+0.05
C ......................................................................
C JRELNO IS THE NUMBER OF THE RELATION OF DOWNSTREAM STAGE (DISCHARGE)
C VS MAXIMUM PERMISSIBLE OUTFLOW THAT WILL BE USED.  THESE RELATIONS ARE
C IN THE RELATN ARRAY IN SETS.  THE JRELNO RELATION WILL BE USED FROM
C ELRES(J) TO ELRES(J+1) EXCEPT WHEN J IS THE LAST  POSITION FOR THIS
C SET OF VALUES.  IN THAT CASE THE RELATION WILL BE USED FOR ALL ELEVA-
C TIONS GREATER THAN OR EQUAL TO ELRES(J).  COMPUTE THE BEGINNING AND
C ENDING POSITIONS IN THE RELATN ARRAY FOR THE SET OF VALUES AND THE
C NUMBER OF PAIRS (KSE) OF VALUES.
C ......................................................................
 145  JSUM=0
      DO 150 J=1,JRELNO
      NOVAL=ANOVAL(J)+0.05
  150 JSUM=JSUM+NOVAL
      KSE=NOVAL/2
      JEND2=JSUM
      JEND1=JSUM-KSE
      JBGN2=JEND1+1
      JBGN1=JBGN2-KSE
C ......................................................................
C KSE, JBGN1,JEND1,JBGN2,JEND2 ARE, RESPECTIVELY, THE NO. OF PAIRS OF
C VALUES IN THE RELATION, STARTING AND ENDING POSITIONS IN RELATN ARRAY
C OF DOWNSTREAM STAGES (DISCHARGES), STARTING AND ENDING POSITIONS IN
C RELATN ARRAY OF MAX. PERMISSIBLE OUTFLOWS.  COMPUTE PERMISSIBLE
C OUTFLOW (QMAX).
C ......................................................................

C
C  LIMIT RELEASE TO LAST VALUE IN RELATIONSHIP IF STAGE/Q IS ABOVE
C  LAST VALUE IN SPECIFICATION CURVE. (JTO - 7/84)
C
      IF (FCSTVA.LT.RELATN(JBGN1)) THEN
        QMAX = RELATN(JBGN2)
	GO TO 152
      ENDIF
      IF (FCSTVA.GT.RELATN(JEND1)) THEN
        QMAX = RELATN(JEND2)
	GO TO 152
      ENDIF	
C

      CALL TERP26(FCSTVA,QMAX,RELATN(JBGN1),RELATN(JBGN2),KSE,IFLAG,
     $IBUG)
      if(kse.ge.0) go to 99991
      N=KSE
      DO 1060 I=2,N
      IF(FCSTVA-RELATN(I)) 1050,1040,1060
 1040 QMAX=RELATN(I+N-1)
      GO TO 152
 1050 L=I
      J=I-1
      GO TO 1070
 1060 CONTINUE
      L=N
      J=N-1
 1070 X2=RELATN(L)
      X1=RELATN(J)
      Y2=RELATN(L+N-1)
      Y1=RELATN(J+N-1)
      IF(Y1.LE.-999) THEN
        QMAX = Y1
	GO TO 152
      ENDIF
      IF(Y2.LE.-999) THEN
        QMAX = Y2
	GO TO 152
      ENDIF
      QMAX=(y2-Y1)*(FCSTVA-X1)/(X2-X1) + Y1
152   CONTINUE
99991 continue
C
C  USE RULE CURVE IF QMAX < 0.0
      IF(QMAX.GE.0.0) GO TO 155
      SUNUM=ABS(QMAX)
      IF (ABS(QMAX+999.0).LT.0.1) SUNUM=1041
cc      IF(QMAX.LE.-999.0) SUNUM=1041
      ISUNUM=SUNUM
      IBASE=ISUNUM/10
      LEVEL=ISUNUM-IBASE*10
	
      IF(IBASE.EQ.104) CALL XS0426(SUNUM,PO,W,LOCOWS)
      IF(IBASE.EQ.107) CALL XS0726(SUNUM,PO,W,LOCOWS)
c      CALL RULE26(RULEL,STOR,ELEV,DATE,RULELV)
      GO TO 310
 155  CONTINUE
C ......................................................................
C CHECK IF QMAX IS A MEAN VALUE FOR THE TIME PERIOD OR FOR 24 HRS.
C ......................................................................
      IF(NQMX24.NE.1) GO TO 210
C ......................................................................
C WHEN NQMX24 IS 1, QMAX IS FOR A 24-HR PERIOD AND THE TIME PERIOD VALUE
C IS DETERMINED BY USING THE TIME VS FACTOR RELATION.  THIS RELATION
C GIVES THE FACTOR TO MULTIPLY BY QMAX TO GET THE OUTFLOW FOR EACH TIME
C PERIOD.  FACTOR IS NEEDED TO SHOW VARIATION IN TURBINE OUTFLOW FOR
C POWER DAMS.  KHRPRD  IS THE TIME AT THE END OF THIS TIME PERIOD ON A 2
C HR CLOCK AND SHOULD EXACTLY CORRESPOND WITH ONE VLLUE IN THE TIME
C ARRAY.  HOWEVER, IN CASE THERE IS A DIFFERENCE, THE CLOSEST TIME VALUE
C WILL BE DETERMINED.  FIRST, CHECK IN DO LOOP 160 IF KHRPRD EXACTLY
C CORRESPONDS WITH A TIME VALUE.
C ......................................................................
      DO 160 J=1,NTIM24
      KTIME=TIME(J)+0.05
      IF(KHRPRD.NE.KTIME) GO TO 160
      FAC=FACTOR(J)
      GO TO 200
  160 CONTINUE
C ......................................................................
C COMPUTE NEAREST TIME VALUE TO KHRPRD IN FOLLOWING DO LOOP 190.  MIDNIG
C VALUE MUST BE 24 RATHER THAN 0.
C ......................................................................
      DO 190 J=1,NTIM24
      KTIME=TIME(J)+0.05
      TIM=KHRPRD
      IF(KHRPRD.GT.KTIME) GO TO 190
      IF(J.GT.1) GO TO 180
      IF(TIM.GE.(TIME(1)*0.5)) GO TO 170
      FAC=FACTOR(NTIM24)
      GO TO 200
  170 FAC=FACTOR(J)
      GO TO 200
  180 TEST=(TIME(J)+TIME(J-1))*0.5
      IF(TIM.GE.TEST) GO TO 170
      FAC=FACTOR(J-1)
      GO TO 200
  190 CONTINUE
C ......................................................................
C CHANGE 24-HR. MEAN OUTFLOW TO VOLUME AND THEN COMPUTE MAXIMUM FOR
C THE TIME PERIOD.
C ......................................................................
  200 TIM24=NTIM24
      QMX24=QMAX*TIM24
      QMAX=FAC*QMX24
C ......................................................................
C IF THERE ARE TWO DOWNSTREAM GAGES USED FOR CONTROLLING OUTFLOW, THE
C MAXIMUM PERMISSIBLE OUTFLOW IS COMPUTED FROM BOTH GAGES AND THE LESSER
C OF THE TWO VALUES IS USED.
C ......................................................................
  210 IF (IBUG.LT.2) GO TO 215
      WRITE(IODBUG,220) IG,FCSTVA,CHANGE,JRELNO,M1,N1,NDSVA1,NDSUM,NPOS,
     & JBGN,JEND,JBGN1,JEND1,JBGN2,JEND2,QMAX
  220 FORMAT(1H0,'GAGE NO.',I2,5X,'VALUES=',F10.3,5X,
     & 'STAGE/FLOW CHANGE=',F10.2,5X,'RELATION NO =',I2,
     & /' M1,N1,NDSVA1,NDSUM,NPOS,JBGN,JEND,JBGN1,JEND1,',
     & 'JBGN2,JEND2,QMAX'/1X,11I5,F10.0)
  215 IF(NGAGES.EQ.2) GO TO 230
      GO TO 260
  230 IF(IG.EQ.2) GO TO 240
      QMAX1=QMAX
      GO TO 250
  240 IF(QMAX.LE.QMAX1) GO TO 260
      QMAX=QMAX1
      GO TO 260
  250 CONTINUE
C ......................................................................
C QMAX WILL BE CHECKED AGAINST QOM SINCE QOM SHOULD HAVE BEEN COMPUTED
C IN A PREVIOUS SUBROUTINE.  HOWEVER, IF NOT PREVIOUSLY COMPUTED, QOM
C WILL BE SET EQUAL TO THE GREATER OF QIM AND(S1-RULST2) AND THEN CHECK-
C ED AGAINST QMAX.                   THE PROGRAM WILL TAKE THE LESSER OF
C QMAX OR QOM FOR THE VALUE OF QOM.
C ......................................................................
C 260 IF(QOM.NE.-999.0) GO TO 280
C     IF(QIM.GE.(S1-RULST2)) GO TO 270
C     QOM=S1-RULST2
C     GO TO 280
C 270 QOM=QIM
C 280 IF(QOM.GT.QMAX) QOM=QMAX
C     IF(QOM.LT.0.) QOM=0.
C--------------------------------------------------------
C  MODIFICATION (JTO - 10/83) : THIS ROUTINE WILL SET THE MAXIMUM
C  ALLOWABLE DISCHARGE ONLY. IF A MINIMUM OF VALUES IS TO BE CHOSEN
C  AS THE RELEASE FOR THE TIME PERIOD, THAT WILL BE THE RESPONSIBILITY
C  OF THE FORECASTER TO USE THE 'SETMIN' UTILITY IN THE RCL.
C
  260 CONTINUE
      QOM = QMAX
  281 S2=S1+QIM-QOM
      QO2=QOM
      IF(IFCST.EQ.0) GO TO 300
      IF(FCST) GO TO 300
  290 QO2=QOM
      IF(OBSQO2.NE.-999.0) QO2=OBSQO2
C ......................................................................
C COMPUTE ELEV2 IF NOT OBSERVED.
C ......................................................................
      IF(ELEV2.NE.-999.0) GO TO 310
  300 CALL NTER26(S2,ELEV2,STOR,ELEV,NSE,IFLAG,NTERP,IBUG)
  310 IF(IBUG-1) 520,500,320
  320 WRITE(IODBUG,330)
  330 FORMAT(1H0,51H FOLLOWING ARE VARIABLE VALUES AT THE END OF EDST26)
      WRITE(IODBUG,40) IFCST,FCST,NS2,NQMX24,NTIM24,KHRPRD,
     & NGAGES,NELVNO,NOREL,NTERP,RULEL1,RULEL2,ELEV1,ELEV2,
     & QI1,QI2,QIM,QO1,QO2,QOM,S1,S2
      IF(IGO.EQ.1) GO TO 500
      IF(NQMX24.GT.0) WRITE(IODBUG,340) (TIME(I),FACTOR(I),I=1,NTIM24)
  340 FORMAT(1H0,42H ALTERNATING VALUES OF TIME AND FACTOR ARE/(1X,8(F4
     $.0,F6.3)))
      JBGN=1
      JEND=DNOVAL(1)+0.05
      WRITE(IODBUG,390) (DSVALU(I),I=JBGN,JEND)
  390 FORMAT(1H0,' PREVIOUS AND CURRENT PERIOD VALUES FOR 1ST GAGE =',
     $ 2F12.3)
cc  390 FORMAT(1H0,110HFOLLOWING ARE OBSERVED OR FORECAST VALUES FOR FIRST
cc     $ DOWNSTREAM GAGE EXCLUDING DAM OUTFLOW FOR THIS TIME PERIOD/(1X,10
cc     $F12.3))
      IF(NGAGES.EQ.1) GO TO 410
      JBGN=JEND+1
      AEND=JEND
      JEND=AEND+DNOVAL(NGAGES)+0.05
      WRITE(IODBUG,400) (DSVALU(I),I=JBGN,JEND)
  400 FORMAT(1H0,' PREVIOUS AND CURRENT PERIOD VALUES FOR 2ND GAGE =',
     $ 2F12.3)
cc  400 FORMAT(1H0,107HFOLLOWING ARE OBSERVED OR FORECAST VALUES FOR SECON
cc     $D DOWNSTREAM GAGE EXCLUDING OUTFLOW FOR THIS TIME PERIOD/(1X,10F12
cc     $.3))
  410 WRITE(IODBUG,420) (TIMLAG(I),I=1,NGAGES)
  420 FORMAT(1H0,' NO. OF TIME STEP LAG FROM DAM TO D/S GAGES =',2F10.3)
cc 420  FORMAT(1H0,110H LAG VALUES FOR GETTING FCST DOWNSTREAM GAGE VALUES
cc     $ FOR STAGE (OR DISCHARGE) VS PERMISSIBLE DISCHARGE RELATION/(1X,10
cc     $F12.3))
      JBGN=1
      JEND=ELVNO(1)+0.05
      DO 440 I=1,NELVNO
      WRITE(IODBUG,430) I,(ELRES(J),RELNO(J),J=JBGN,JEND)
  430 FORMAT(1H0,65H ALTERNATING VALUES OF ELEVATION AND RELATION NUMBER
     $S FOR SET NO.,I4, 4H ARE/(1X,10F12.3))
      IF(I.EQ.NELVNO) GO TO 440
      JBGN=JEND+1
      AEND=JEND
      JEND=AEND+ELVNO(I+1)+0.05
  440 CONTINUE
      JBGN=1
      DO 480 I=1,NOREL
      JJ=(ANOVAL(I)*0.5)+0.05
      JEND=JBGN+JJ-1
      WRITE(IODBUG,450)I,(RELATN(J),J=JBGN,JEND)
  450 FORMAT(1H0,59H DOWNSTREAM GAGE VALUES IN PERMISSIBLE OUTFLOW RELAT
     $ION NO.,I4, 4H ARE/(1X,10F12.3))
      WRITE(IODBUG,460)
  460 FORMAT(1H0,33H CORRESPONDING OUTFLOW VALUES ARE)
      JBGN=JEND+1
      JEND=JBGN+JJ-1
      WRITE(IODBUG,470)  (RELATN(J),J=JBGN,JEND)
  470 FORMAT(1X,10F12.3)
      JBGN=JEND+1
  480 CONTINUE
CC      WRITE(IODBUG,490)IFLAG,NSE,(STOR(I),ELEV(I),I=1,NSE)
CC  490 FORMAT(1H0,9H IFLAG IS,I6,43H.  NO OF POINTS ON ELEV. - STORAGE CU
CC     $RVE IS,I4,1H./1H0,48H ALTERNATING VALUES OF STORAGE AND ELEVATION
CC     $ARE/(1X,5(F12.3,F9.3,3X)))
  500 WRITE(IODBUG,510)
  510 FORMAT(1H0,10X,17H** LEAVING EDST26)
  520 RETURN
      END