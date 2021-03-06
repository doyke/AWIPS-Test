C MODULE SABP51
C
C DESC READ AND STORE PARAMETERS FOR SAB SECTION OF OPERATION 51
C
C--------------------------------------------------------------------
C
C
      SUBROUTINE SABP51(WK,IUSEW,LEFTW,NPSAB)
C
C----------------------------------------------------------------------
C  ARGS:
C     WK - ARRAY TO BE FILLED WITH THE PARAMETERS
C    IUSEW - NUMBER OF WORDS ALREADY USED IN WORK ARRAY
C    LEFTW - NUMBER OF WORDS LEFT IN WORK ARRAY
C    NPSAB - NUMBER OF WORDS NEEDED TO STORE SAB PARAMETERS
C---------------------------------------------------------------------
C
C  KUANG HSU - HRL - APRIL 1994
C----------------------------------------------------------------
      INCLUDE 'common/fld51'
      INCLUDE 'common/read51'
      INCLUDE 'common/err51'
      INCLUDE 'common/comn51'
C
      DIMENSION KEYWDS(2,11),LKEYWD(11),VALUE(100),QSTOR(50),
     . QELBW(600),QEL(3),LQEL(3),OK(7),WK(*),IG(11)
      LOGICAL OK
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_ssarresv/RCS/sabp51.f,v $
     . $',                                                             '
     .$Id: sabp51.f,v 1.5 2000/12/19 14:51:52 dws Exp $
     . $' /
C    ===================================================================
C
      DATA KEYWDS/4HBACK,4HWATR,
     .            4HELVS,4HSTOR,4HQVSE,4HL   ,4HBACK,4HTABL,
     .            4HMAXE,4HL   ,4HMINE,4HL   ,4HMINQ,4HREL ,
     .            4HSHUT,4HRESV,
     .            4HENDP,4H    ,4HENDP,4HARMS,4HENDS,4HAB  /
      DATA LKEYWD/2,2,2,2,2,2,2,2,1,2,2/
      DATA NKEYWD/11/
      DATA NDKEY/2/
C
      DATA QEL/4HFLOW,4HELEV,4HTRIB/
      DATA LQEL/1,1,1/
      DATA NQEL/3/
C
C  INITIALIZE LOCAL VARIABLES AND COUNTERS
C
      NSE = 0
      NQE = 0
      NQBK = 0
      NPSAB = 0
      LCARD = NCARD
      USEDUP = .FALSE.
C
C  DEFAULT BACKWATER CONTROL PARAMETER TO FLOW CONTROL
      IBW = 1
C
C  DEFAULT MINIMUM RELEASE TO ZERO
      QRELMN = 0.0
C
C  DEFAULT MAXIMUM TRIBUTARY FLOW TO SHUT OFF RESERVOIR TO LARGE VALUE
      QSHUT = 1.0E+10
C
C  6 KEYWORD 
c    = BACKWATR, ELVSSTOR, QVSEL, BACKTABL, MAXEL, MINEL, MINQREL
      DO 3 I = 1,7
 3    OK(I) = .TRUE.
C
C        The IG index is probably never more than 8 - dws pirt fix 1232
C
      DO 5 I = 1,11
 5    IG(I) = 0
C-----------------------------------------------------------------
C  NOW LOOK FOR MATCHING KEYWORDS IN INPUT STREAM
C
   10 CONTINUE
      NUMFLD = 0
      CALL UFLD51(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
   20 CONTINUE
      NUMWD = (LEN-1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,KEYWDS,LKEYWD,NKEYWD,NDKEY) + 1
C
      GO TO (100,200,300,400,500,600,700,800,900,1000,1000,1100), IDEST
C
C---------------------------------------------------------------------
C  NO VALID KEYWORD FOUND
C
  100 CONTINUE
      CALL STER51(1,1)
      GO TO 10
C
C-----------------------------------------------------------------------
C  'BACKWATR' KEYWORD FOUND, LOOK FOR VALID FOLLOWING KEYWORD
C
  200 CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).LE.1) GO TO 210
      CALL STER51(39,1)
C
 210  NUMFLD = -2
      CALL UFLD51(NUMFLD,IERF)
C
C  IF NOTHING ON CARD AFTER 'BACKWATR', ERROR OUT
C
      IF (IERF.GE.1) GO TO 9000
      NUMWD = (LEN-1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,QEL,LQEL,NQEL,1)
      IF (IDEST.GT.0) GO TO 220
C
C  NOT A VALID 'BACKWATR' INDICATOR, ERROR OUT
C
      CALL STER51(42,1)
      OK(ID) = .FALSE.
C
  220 CONTINUE
      IBW = IDEST
C
 230  ITRIB=0
      NUMFLD = -2
      CALL UFLD51(NUMFLD,IERF)
C
C  IF NOTHING ON CARD, DEFAULT TO D/S RESERVOIR CONTROL
C
      IF (IERF.GE.1) GO TO 240
      NUMWD = (LEN-1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,QEL,LQEL,NQEL,1)
      IF (IDEST.EQ.3) ITRIB=2
  240 CONTINUE
C
  250 CONTINUE
      GO TO 10
C
C-----------------------------------------------------------------------
C   'ELVSSTOR' FOUND
C  SET INDICATOR THAT CURVE HAS BEEN FOUND, IF CURVE HAS ALREADY BEEN
C  FOUND, IT IS AN ERROR
C
  300 CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).LE.1) GO TO 310
      CALL STER51(39,1)
C
  305 CONTINUE
      NUMFLD = 0
      CALL UFLD51(NUMFLD,IERF)
      IF (IERF.EQ.3) GO TO 9000
      IF (ITYPE.LE.1) GO TO 305
      GO TO 20
C
C  START GETTING NUMBERS FOR CURVE DEFINITION. RULES FOR INPUT ARE
C  A CONTINUATION SYMBOL (&) MUST END THE LINE AS A STAND ALONE CHAR-
C  ACTER, AND SINCE THE CURVE IS A SET OF PAIRS THE TOTAL NUMBER
C  OF VALUES MUST BE EVEN.
C
  310 CONTINUE
C
      NVAL=100
      CALL GLST51(1,1,X,VALUE,X,NVAL,OK(ID))
      IF (.NOT.OK(ID)) GO TO 10
C
C  ALL VALUES ARE REAL AND WE'VE NO MORE INPUT ON A LINE(NO CONTINUATION
C  NOW WE HAVE TO CHECK THE VALUES FOR A CERTAIN AMOUNT OF VALIDITY
C  BEFORE WE CAN STORE THEM. ONE IS THAT THE NUMBER OF VALUES ARE EVEN
C  AS WE HAVE TO INPUT SETS OF PAIRS, THE OTHER IS THAT EACH HALF OF THE
C  VALUES ARE IN ASCENDING ORDER.
C
  350 CONTINUE
      IF (MOD(NVAL,2).EQ.0) GO TO 355
C
      CALL STER51(40,1)
      OK(ID) = .FALSE.
      GO TO 10
C
C  SEE IF EACH HALF ARE IN ASCENDING ORDER
C
  355 CONTINUE
      NHALF = NVAL/2
C
C  STORE THE ELEVATION VS STORAGE CURVE IN /COMN51/.
C
      NSE = NHALF
C
      DO 360 I=1,2
      J = (I-1)*NHALF
      DO 357 K = 2,NHALF
      IF (VALUE(J+K).GT.VALUE(J+K-1)) GO TO 357
      CALL STER51(41,1)
      OK(ID) = .FALSE.
      GO TO 10
C
  357 CONTINUE
  360 CONTINUE
C
C  SEE IF FIRST STORAGE VALUE IS ZERO.
C
      NSTOR1=NVAL/2+1
      NSTOR2=NSTOR1+1
      IF (VALUE(NSTOR1).LE.0.10) GO TO 370
C
      CALL STER51(58,1)
      OK(ID) = .FALSE.
      GO TO 10
  370 CONTINUE
C
C  STORE ELEVATION/STORAGE CURVE
C
      DO 380 I=1,NSE
      ELSTOR(I) = VALUE(I)
      STORGE(I) = VALUE(NHALF+I)
  380 CONTINUE
      ELMIN = ELSTOR(1)
      ELMAX = ELSTOR(NSE)
C
C  INITIALIZE DISCHARGES TO 0.0 IF QVSEL HAS NOT BEEN FOUND
      IF(NQE.GT.0) GO TO 10
      NQE = NSE
      DO 390 I=1,NQE
 390  QSTOR(I) = 0.0
C
      GO TO 10
C
C-----------------------------------------------------------------------
C   'QVSEL' FOUND
C  SET INDICATOR THAT KEYWORD HAS BEEN FOUND, IF KEYWORD HAS ALREADY
C   BEEN FOUND, IT IS AN ERROR
C
  400 CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).LE.1) GO TO 410
      CALL STER51(39,1)
C
  405 CONTINUE
      NUMFLD = 0
      CALL UFLD51(NUMFLD,IERF)
      IF (IERF.EQ.3) GO TO 9000
      IF (ITYPE.LE.1) GO TO 405
      GO TO 20
C
C  START GETTING NUMBERS FOR CURVE DEFINITION. RULES FOR INPUT ARE
C  A CONTINUATION SYMBOL (&) MUST END THE LINE AS A STAND ALONE CHAR-
C  ACTER, NO OF DISCHARGES MUST BE EQUAL TO NO. OF ELEVATIONS
C
  410 CONTINUE
C
      NVAL=50
      CALL GLST51(1,1,X,VALUE,X,NVAL,OK(ID))
      IF (.NOT.OK(ID)) GO TO 10
C
C  ALL VALUES ARE REAL AND WE'VE NO MORE INPUT ON A LINE(NO CONTINUATION
C  NOW WE HAVE TO CHECK THE VALUES FOR A CERTAIN AMOUNT OF VALIDITY
C  BEFORE WE CAN STORE THEM. ONE IS THAT THE NUMBER OF VALUES OF
C  DISCHARGE AND ELEVATION MUST BE EQUAL, THE OTHER IS THAT
C  THE DISCHARGE VALUES ARE IN ASCENDING ORDER.
C
C
C  SEE IF VALUES ARE IN ASCENDING ORDER
C
      NQE = NVAL
      DO 457 K = 2,NQE
      IF (VALUE(K).GT.VALUE(K-1)) GO TO 457
      CALL STER51(41,1)
      OK(ID) = .FALSE.
      NUMFLD = 0
      GO TO 10
  457 CONTINUE
C
C  CHECK EQUAL NO. OF DISCHARGE AND ELEVATION/STORAGE VALUES
C  IN ELVSSTOR CURVE
C
      IF(NQE.EQ.NSE) GO TO 460
      CALL STER51(23,1)
      OK(ID) = .FALSE.
      GO TO 10
  460 CONTINUE
C
C  STORE DISCHARGE VALUES CORRESPONDING TO ELEVATION/STORAGE CURVE
C
      DO 480 I=1,NQE
      QSTOR(I) = VALUE(I)
  480 CONTINUE
C
      GO TO 10
C
C-----------------------------------------------------------------------
C   'BACKTABL' FOUND
C  SET INDICATOR THAT KEYWORD HAS BEEN FOUND, IF KEYWORD HAS ALREADY
C  BEEN FOUND, IT IS AN ERROR
C
  500 CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).LE.1) GO TO 510
      CALL STER51(39,1)
C
  505 CONTINUE
      NUMFLD = 0
      CALL UFLD51(NUMFLD,IERF)
      IF (IERF.EQ.3) GO TO 9000
      IF (ITYPE.LE.1) GO TO 505
      GO TO 20
C
C  START GETTING NUMBERS FOR CURVE DEFINITION. RULES FOR INPUT ARE
C  A CONTINUATION SYMBOL (&) MUST END THE LINE AS A STAND ALONE CHAR-
C  ACTER, NO OF DISCHARGES MUST BE EQUAL TO NO. OF ELEVATIONS
C
  510 CONTINUE
C
      NVAL=600
      CALL GLST51(1,1,X,QELBW,X,NVAL,OK(ID))
      IF (.NOT.OK(ID)) GO TO 10
C
C  ALL VALUES ARE REAL AND WE'VE NO MORE INPUT ON A LINE(NO CONTINUATION
C  NOW WE HAVE TO CHECK THE VALUES FOR A CERTAIN AMOUNT OF VALIDITY
C  BEFORE WE CAN STORE THEM. 
C  ONE IS THAT THE NUMBER OF VALUES MUST BE AN EVEN MULTIPLES OF THREE
C  THE OTHER IS THAT ALL THE VALUES ARE IN ASCENDING ORDER.
C
  550 CONTINUE
C
      IF (MOD(NVAL,3).EQ.0) GO TO 555
      CALL STER51(65,1)
      OK(ID) = .FALSE.
      GO TO 10
C
C  SEE IF VALUES ARE IN ASCENDING ORDER
C
 555  CONTINUE
      NQBKS = 1
      NQBK = NVAL/3
      NQBKM = NQBK - 1
C
C  IF ELEVATION CONTROL, ELEVATION AT SITE MUST BE GREATER THAN
C  CONTROL FOR FLOW TO OCCUR
C
      IF(IBW.LE.1) GO TO 545
      DO 540 K = 1,NQBK
      K3 = 3*K
      IF(QELBW(K3-2).LE.0.01) GO TO 540
      IF(QELBW(K3-1).GE.QELBW(K3)) GO TO 540
      IERR = 24
      IPT = K
      VALUE1 = QELBW(K3-1)
      VALUE2 = QELBW(K3)
      CALL STER51(24,1)
      OK(ID) = .FALSE.
      GO TO 10
 540  CONTINUE
C
 545  DO 560 K = 2,NQBKM
      K3 = 3*K
      K31 = 3*(K-1)
C
C  CHECK ONE FLOW CURVE AT A TIME
      ADQ = ABS(QELBW(K3-2)-QELBW(K31-2))
      IF(ADQ.LE.0.5) GO TO 560
      NQBKS1 = NQBKS+1
      NQBKE = K-1
C
      IF (NQBKE.LT.NQBKS1) THEN
        CALL STER51(22,1)
        OK(ID) = .FALSE.
        GO TO 10
      END IF
C
      DO 557 IK = NQBKS1,NQBKE
      IK3 = 3*IK
      IK31 = 3*(IK-1)
C
C  SECOND INDEPENDENT VARIABLE -- AT SITE --ELEVATION
      IF (QELBW(IK3-1).LT.QELBW(IK31-1)) THEN
        IERR = 41
        IPT = IK
        VALUE1 = QELBW(IK3-1)
        VALUE2 = QELBW(IK31-1)
        GO TO 556
      END IF
C
C  FIRST INDEPENDENT VARIABLE -- CONTROL -- ELEVATION/DISCHARGE
      IF (QELBW(IK31).LT.QELBW(IK3)) GO TO 557
      IERR = 41
      IPT = IK
      VALUE1 = QELBW(IK31)
      VALUE2 = QELBW(IK3)
 556  CALL STER51(41,1)
      OK(ID) = .FALSE.
      GO TO 10
C
  557 CONTINUE
      NQBKS = NQBKE +1
      NQC1 = 3*NQBKE-2
      NQC2 = 3*(NQBKE+1)-2
C
C  DEPENDENT VARIABLE -- DISCHARGE
      IF(QELBW(NQC2).GT.QELBW(NQC1)) GO TO 560
      CALL STER51(41,1)
      IERR = 41
      IPT = IK
      VALUE1 = QELBW(NQC2)
      VALUE2 = QELBW(NQC1)
      OK(ID) = .FALSE.
      GO TO 10
560   CONTINUE
C
C CHECK IF THE ELVSSTOR CURVE IS AVAILABLE
C
      IF(IG(2).LE.0) THEN
        CALL STER51(23,1)
        OK(ID) = .FALSE.
        GO TO 10
      END IF
C
C  CHECK THE LOWEST AND THE HIGHEST ELEVATION AT SITE
C  IS WITHIN BOUNDS OF THE ELVSSTOR CURVE
C
      IF(IG(ID).LE.0 .OR. .NOT.OK(ID)) GO TO 10
      ELBWMN = QELBW(2)        
      CALL ELST51(ELBWMN,1,IERST)
      IF(IERST.GT.0) THEN
        OK(ID) = .FALSE.
        GO TO 10
      END IF
      ELBWMX = QELBW(NVAL-1)        
      CALL ELST51(ELBWMX,1,IERST)
      IF(IERST.GT.0) OK(ID) = .FALSE.
C
      GO TO 10
C
C-------------------------------------------------------------------
C  'MAXEL' FOUND
C
 600  CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).GT.1) CALL STER51(39,1)
C
C  NEXT FIELD MUST BE REAL POSITIVE VALUE, ALSO WITHIN ELVSSTOR CURVE.
C
      NUMFLD= -2
      CALL UFLD51(NUMFLD,IERF)
      IF(IERF.GT.0)GO TO 9000
C
C  SEE IF VALUE IS REAL
      IF(ITYPE.EQ.1)GO TO 620
      CALL STER51(4,1)
      OK(ID) = .FALSE.
      GO TO 10
C
C  SEE IF VALUE IS POSITIVE
 620  IF(REAL.GT.0.0)GO TO 630
      CALL STER51(61,1)
      OK(ID) = .FALSE.
      GO TO 10
C
 630  ELMAX=REAL
      IF(IG(2).LE.0) THEN
        CALL STER51(23,1)
        OK(ID) = .FALSE.
        GO TO 10
      END IF
C
C CHECK 'MAXEL' IS WITHIN BOUNDS OF THE ELVSSTOR CURVE
C
      IF(IG(ID).GT.0 .AND. OK(ID)) THEN
        CALL ELST51(ELMAX,1,IERST)
        IF(IERST.GT.0) OK(ID) = .FALSE.
        GO TO 10
      END IF
C
C-----------------------------------------------------------------------
C  'MINEL' FOUND
C
 700  CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).GT.1) CALL STER51(39,1)
C
C  NEXT FIELD MUST BE REAL POSITIVE VALUE, ALSO WITHIN ELVSSTOR CURVE.
C
      NUMFLD = -2
      CALL UFLD51(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
C  SEE IF VALUE IS REAL
      IF(ITYPE.EQ.1)GO TO 720
      CALL STER51(4,1)
      OK(ID) = .FALSE.
      GO TO 10
C
C  SEE IF VALUE IS POSITIVE
 720  IF(REAL.GT.0.0)GO TO 730
      CALL STER51(61,1)
      OK(ID) = .FALSE.
      GO TO 10
C
 730  ELMIN=REAL
C
C CHECK IF THE ELVSSTOR CURVE IS AVAILABLE
C
      IF(IG(2).LE.0) THEN
        CALL STER51(23,1)
        OK(ID) = .FALSE.
        GO TO 10
      END IF
C
C CHECK MINEL IS WITHIN BOUNDS OF THE ELVSSTOR CURVE
C
      IF(IG(ID).GT.0 .AND. OK(ID)) THEN
        CALL ELST51(ELMIN,1,IERST)
        IF(IERST.GT.0) OK(ID) = .FALSE.
        GO TO 10
      END IF
C
C-----------------------------------------------------------------------
C  'MINQREL' FOUND
C
 800  CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).GT.1) CALL STER51(39,1)
C
C  NEXT FIELD MUST BE REAL POSITIVE VALUE.
C
      NUMFLD = -2
      CALL UFLD51(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
C  SEE IF VALUE IS REAL
      IF(ITYPE.EQ.1)GO TO 820
      CALL STER51(4,1)
      OK(ID) = .FALSE.
      GO TO 10
C
C  SEE IF VALUE IS POSITIVE
 820  IF(REAL.GE.0.0)GO TO 830
      CALL STER51(61,1)
      OK(ID) = .FALSE.
      GO TO 10
 830  QRELMN=REAL
      GO TO 10
C
C-----------------------------------------------------------------------
C  'SHUTRESV' FOUND
C
 900  CONTINUE
      ID = IDEST - 1
      IG(ID) = IG(ID) + 1
      IF(IG(ID).GT.1) CALL STER51(39,1)
C
C  NEXT FIELD MUST BE REAL POSITIVE VALUE.
C
      NUMFLD = -2
      CALL UFLD51(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
C  SEE IF VALUE IS REAL
      IF(ITYPE.EQ.1)GO TO 920
      CALL STER51(4,1)
      OK(ID) = .FALSE.
      GO TO 10
C
C  SEE IF VALUE IS POSITIVE
 920  IF(REAL.GE.0.0)GO TO 930
      CALL STER51(61,1)
      OK(ID) = .FALSE.
      GO TO 10
 930  QSHUT=REAL
      GO TO 10
C
C------------------------------------------------------------------
C  'ENDP' FOUND. 
C  STORE THE CURVES AND OTHER PARMS IN WORK ARRAY IF EVERYTHING OK.
C
 1000 CONTINUE
C
C  'ELVSSTOR', AND 'BACKTABL' ARE REQUIRED KEYWORDS
      DO 1044 I=1,4
      IF(I.EQ.1 .OR. I.EQ.3) GO TO 1044
      IF(IG(I).GT.0) GO TO 1044
      CALL STRN51(59,1,KEYWDS(1,I),LKEYWD(I))
      OK(I) = .FALSE.
 1044 CONTINUE 
C
C CHECK NO. DISCHARGES EQUALS TO NO. OF ELEVATIONS OF THE ELVSSTOR CURVE
C
      IF(IG(3).GT.0) THEN
        IF(NQE.NE.NSE) THEN
          CALL STER51(42,1)
          OK(3) = .FALSE.
        END IF
      END IF
C
      DO 1103 I=1,5
 1103 IF(.NOT.OK(I)) GO TO 9999   
C
      NPSAB = 0
C
C  STORE RESERVOIR TYPE: =0, NON-BACKWATER RESERVOIR
C  =1, RESERVOIR CONTROLLED BY ELEVATION
C  =2, RESERVOIR CONTROLLED BY TRIBUTARY FLOW
C  =3, THREE VARIABLE RELATION WITHOUT BACKWATER ROUTING
C
      RESTYP = 1.0
      IF(ITRIB .EQ. 2) RESTYP=2.0
      CALL FLWK51(WK,IUSEW,LEFTW,RESTYP,501)
      NPSAB = NPSAB+1
C
C  STORE THE NO. OF DATA POINTS IN THE ELEVATION/STORAGE/DISCHARGE CURVE
C  FOLLOWED BY THE CURVE VALUES: ELEVATIONS, THEN STORAGES,
C  THEN DISCHARGE.
C
      COUNT = NSE
C
      CALL FLWK51(WK,IUSEW,LEFTW,COUNT,501)
      NPSAB = NPSAB+1
C
C  STORE ELEVATION VALUES
C
      DO 1620 I=1,NSE
      CALL FLWK51(WK,IUSEW,LEFTW,ELSTOR(I),501)
 1620 CONTINUE
      NPSAB = NPSAB+NSE
C
C  STORE STORAGE VALUES
C
      DO 1625 I=1,NSE
      CALL FLWK51(WK,IUSEW,LEFTW,STORGE(I),501)
 1625 CONTINUE
      NPSAB = NPSAB+NSE
C
C  STORE DISCHARGE VALUES
C
      DO 1630 I=1,NSE
      CALL FLWK51(WK,IUSEW,LEFTW,QSTOR(I),501)
 1630 CONTINUE
      NPSAB = NPSAB+NSE
C
C  STORE THE NO. OF DATA POINTS IN THE BACKWATER TABLE
C  FOLLOWED BY THE CURVE VALUES: ELEVATIONS, THEN STORAGES,
C  THEN DISCHARGE.
C
      COUNT = NQBK
C
      CALL FLWK51(WK,IUSEW,LEFTW,COUNT,501)
      NPSAB = NPSAB+1
C
C  STORE BACKWATER TABLES
C
      NVAL = 3*NQBK
      DO 1650 K=1,NVAL
      CALL FLWK51(WK,IUSEW,LEFTW,QELBW(K),501)
 1650 CONTINUE
      NPSAB = NPSAB+NVAL
C
C  STORE THE BACKWATER INDICATOR
      BW=IBW 
      CALL FLWK51(WK,IUSEW,LEFTW,BW,501)
      NPSAB = NPSAB+1
C
C  STORE MAXIMUM ELEVATION
C
      CALL FLWK51(WK,IUSEW,LEFTW,ELMAX,501)
      NPSAB = NPSAB+1
C
C  STORE MINIMUM ELEVATION
C
      CALL FLWK51(WK,IUSEW,LEFTW,ELMIN,501)
      NPSAB = NPSAB+1
C
C  STORE MINIMUM RESERVOIR RELEASE
C
      CALL FLWK51(WK,IUSEW,LEFTW,QRELMN,501)
      NPSAB = NPSAB+1
C
C  STORE MAXIMUM TRIBUTARY TO SHUTDOWN RESERVOIR RELEASE
C
      CALL FLWK51(WK,IUSEW,LEFTW,QSHUT,501)
      NPSAB = NPSAB+1
C
C  ALL FINISHED WITH THE SAB PARMS. EXIT NOW.
C
      GO TO 9999
C
C---------------------------------------------------------------------
C  ERROR IN UFLD51
C
 9000 CONTINUE
      IF (IERF.EQ.1) CALL STER51(19,1)
      IF (IERF.EQ.2) CALL STER51(20,1)
      IF (IERF.EQ.3) CALL STER51(21,1)
      IF (IERF.EQ.4) CALL STER51(1,1)
C
      IF (IERF.NE.3) GO TO 10
C
C-----------------------------------------------------------------------
C  ENDSAB FOUND WHERE IT SHOULDN'T BE. SIGNAL ERROR AND RETURN
C
 1100 CONTINUE
      USEDUP =.TRUE.
      CALL STER51(43,1)
      GO TO 9999
C
C--------------------------------------------------------------------
C
 9999 CONTINUE
      OKELST = OK(2) .AND. OK(3) .AND. OK(4)
      RETURN
      END
