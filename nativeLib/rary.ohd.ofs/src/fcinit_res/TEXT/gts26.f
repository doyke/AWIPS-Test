C MEMBER GTS26
C  (from old member FCGTS26)
C
C DESC GET TIME-SERIES INFO FOR GENERAL SUB-SECTION OF OPERATION 26
C-----------------------------------------------------------------
C
      SUBROUTINE GTS26(WORK,IUSEW,LEFTW,NTSG)
C
C-------------------------------------------------------------------
C  ARGS:
C     WORK - ARRAY TO HOLD ENCODED TIME-SERIES INFO
C    IUSEW - NUMBER OF WORDS ALREADY USED IN WORK ARRAY
C    LEFTW - NUMBER OF WORDS LEFT IN WORK ARRAY
C     NTSG - NUMBER OF WORDS NEEDED TO STORE TS INFO
C-------------------------------------------------------------------
C
C  JTOSTROWSKI - HRL - MARCH 1983
C----------------------------------------------------------------
      INCLUDE 'common/read26'
      INCLUDE 'common/fld26'
      INCLUDE 'common/comn26'
      INCLUDE 'common/fdbug'
C
      DIMENSION KEYWDS(2,9),LKEYWD(9),UC(6),DIM(6),WORK(1)
      DIMENSION TSID(2,6),DTYPE(6),IDT(6),TSIO(6)
      LOGICAL RQDFND(3),TSOK(6),NRQFND(3)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcinit_res/RCS/gts26.f,v $
     . $',                                                             '
     .$Id: gts26.f,v 1.1 1995/09/17 18:51:45 dws Exp $
     . $' /
C    ===================================================================
C
C
      DATA KEYWDS/
     .            4HINST,4HQIN ,4HMEAN,4HQIN ,
     .            4HMEAN,4HQOUT,4HINST,4HQOUT,
     .            4HPOOL,4H    ,4HSTOR,4HAGE ,
     .            4HENDT,4H    ,4HENDT,4HS   ,
     .            4HENDG,4HENL /
      DATA LKEYWD/2,2,2,2,1,2,1,2,2/
      DATA NKEYWD/9/
      DATA NDKEY/2/
C
      DATA UC/4HCMS ,4HCMSD,4HCMSD,4HCMS ,4HM   ,4HCMSD/
      DATA DIM/4HL3/T,4HL3  ,4HL3  ,4HL3/T,4HL   ,4HL3  /
      DATA BLANK/4H    /
C
      DATA TSIO/0.01,0.01,1.01,1.01,1.01,1.01/
C
C  INITIALIZE LOCAL VARIABLES
C
      NTSG = 0
      USEDUP = .FALSE.
      DO 1 I=1,3
      RQDFND(I) = .FALSE.
      NRQFND(I) = .FALSE.
    1 CONTINUE
C
C  INITIALIZE TIME-SERIES ID'S TO BLANKS
C
      DO 5 I=1,6
      TSID(1,I) = BLANK
      TSID(2,I) = BLANK
      TSOK(I) = .FALSE.
    5 CONTINUE
C
C----------------------------------------------------------------
C  LOOK FOR PROPER TIME-SERIES KEYWORDS
C
   10 CONTINUE
      NUMFLD = 0
      CALL UFLD26(NUMFLD,IERF)
      IF (IERF.GT.0) GO TO 9000
C
   20 CONTINUE
      NUMWD = (LEN-1)/4 + 1
      IDEST = IKEY26(CHAR,NUMWD,KEYWDS,LKEYWD,NKEYWD,NDKEY) + 1
C
      GO TO (100,200,200,200,300,300,300,400,400,500) , IDEST
C
C------------------------------------------------------------
C  NO VALID KEYWORD FOUND
C
  100 CONTINUE
      CALL STER26(1,1)
      GO TO 10
C
C-------------------------------------------------------------
C  A REQUIRED TIME-SERIES KEYWORD HAS BEEN FOUND. WE MUST NOW GET
C   THE TS ID, DATA TYPE AND TIME INTERVAL. ALSO, IF THIS KEYWORD
C   WAS ALREADY FOUND, SIGNAL AN ERROR.
C
C
C  REQUIRED TYPES ARE: INSTQIN, MEANQIN, AND MEANQOUT
C
  200 CONTINUE
      ID = IDEST-1
      IF (.NOT.RQDFND(ID)) GO TO 210
C
      CALL STER26(44,1)
      GO TO 10
C
C  SIGNAL THAT THIS TIME-SERIES HAS BEEN FOUND, AND GO GET NEXT THREE
C  FIELDS ON LINE.
C
  210 CONTINUE
      RQDFND(ID) = .TRUE.
C
      CALL TSID26(TSID(1,ID),DTYPE(ID),IDT(ID),TSOK(ID))
      IF (.NOT.TSOK(ID)) GO TO 10
C
C  SEE IF TIME-SERIES EXISTS
C
      ICHK = 0
      IF (IBUG.GE.2) WRITE(IODBUG,1666) ICHK
 1666 FORMAT('  VALUE OF ICHK = ',I10)
      CALL CHEKTS(TSID(1,ID),DTYPE(ID),IDT(ID),ICHK,DCODE,0,1,IERCK)
      IF (IERCK.EQ.0) GO TO 220
C
      CALL STER26(45,1)
      TSOK(ID) = .FALSE.
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES
C
  220 CONTINUE
      CALL FDCODE(DTYPE(ID),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UC(ID)) GO TO 230
C
      CALL STRN26(93,1,UCODE,1)
      TSOK(ID) = .FALSE.
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  230 CONTINUE
      IF (DCODE.EQ.DIM(ID)) GO TO 10
C
      CALL STER26(46,1)
      TSOK(ID) = .FALSE.
      GO TO 10
C
C-----------------------------------------------------------------------
C AN OPTIONAL TIME-SERIES KEYWORD HAS BEEN FOUND. WE MUST NOW GET
C  THE TS ID, DATA TYPE, AND TIME INTERVAL.  IF THIS TYPE OF
C  TS HAS ALREADY BEEN FOUND, SIGNAL AN ERROR.
C
  300 CONTINUE
      ID = IDEST-1
      IF (.NOT.NRQFND(ID-3)) GO TO 310
C
      CALL STER26(44,1)
      GO TO 10
C
C  SIGNAL THAT TIME-SERIES HAS BEEN FOUND AND GET NEXT THREE FIELDS
C  ON LINE
C
  310 CONTINUE
      NRQFND(ID-3) = .TRUE.
C
      CALL TSID26(TSID(1,ID),DTYPE(ID),IDT(ID),TSOK(ID))
C
      IF (.NOT.TSOK(ID)) GO TO 10
C
C  SEE IF TIME-SERIES EXISTS
C
      ICHK = 0
      IF (IBUG.GE.2) WRITE(IODBUG,1666) ICHK
      CALL CHEKTS(TSID(1,ID),DTYPE(ID),IDT(ID),ICHK,DCODE,0,1,IERCK)
      IF (IERCK.EQ.0) GO TO 320
C
      CALL STER26(45,1)
      TSOK(ID) = .FALSE.
      GO TO 10
C
C  CHECK UNITS FOR THIS TIME-SERIES
C
  320 CONTINUE
      CALL FDCODE(DTYPE(ID),UCODE,X,IX,IX,X,IX,IERD)
      IF (UCODE.EQ.UC(ID)) GO TO 330
C
      CALL STRN26(93,1,UCODE,1)
      TSOK(ID) = .FALSE.
      GO TO 10
C
C  CHECK DIMENSIONS AGAINST ALLOWED FOR THIS TIME SERIES.
C
  330 CONTINUE
      IF (DCODE.EQ.DIM(ID)) GO TO 10
C
      CALL STER26(46,1)
      TSOK(ID) = .FALSE.
      GO TO 10
C
C--------------------------------------------------------------------
C  'ENDT' HAS BEEN FOUND. TIME TO PROCESS AND STORE TS INFO IN THE ORDER
C    1) INSTQIN (INPUT)
C    2) MEANQIN (INPUT)
C    3) MEANQOUT (OUTPUT)
C  FOLLOWING ARE OPTIONAL
C    4) INSTQOUT (OUTPUT)
C    5) POOL (OUTPUT)
C    6) STORAGE (OUTPUT)
C
  400 CONTINUE
      IDELT = 0
C
C  FIRST LOOP THROUGH THE THREE REQUIRED TIME-SERIES. THEY MUST HAVE BEE
C  ENTERED WITH NO ERRORS
C
      DO 440 I=1,3
C
C  IF NOT OK, (EITHER NOT FOUND OR ERRORS ON INPUT) SKIP TO NEXT TS.
C
      IF (RQDFND(I)) GO TO 405
C
      CALL STRN26(59,1,KEYWDS(1,I),LKEYWD(I))
      GO TO 440
C
  405 CONTINUE
      IF (.NOT.TSOK(I)) GO TO 440
C
  410 CONTINUE
C
C  STORE THE ID, DATATYPE, AND TIME INTERVAL. BUT FIRST CHECK TO SEE THA
C  THE TIME INTERVALS ARE THE SAME.
C
      IF (I.GT.1) GO TO 420
      IDELT = IDT(1)
      GO TO 430
C
  420 CONTINUE
      IF (IDELT .EQ. 0) GO TO 430
      IF (IDT(I).EQ.IDELT) GO TO 430
      CALL STER26(48,1)
      GO TO 9999
C
  430 CONTINUE
C
      CALL FLWK26(WORK,IUSEW,LEFTW,TSID(1,I),501)
      CALL FLWK26(WORK,IUSEW,LEFTW,TSID(2,I),501)
      CALL FLWK26(WORK,IUSEW,LEFTW,DTYPE(I),501)
      DT = IDT(I) + 0.01
      CALL FLWK26(WORK,IUSEW,LEFTW,DT,501)
      CALL FLWK26(WORK,IUSEW,LEFTW,TSIO(I),501)
C
      NTSG = NTSG + 5
C
  440 CONTINUE
C
C  SET OPERATION TIME INTERVAL
C
      MINODT = IDELT
C
C--------------------------------------------------------------------
C  NOW STORE ANY OPTIONAL TIME-SERIES. THESE MUST BE ENTERED WITH
C  NO ERRORS TO BE STORED FULLY. IF THEY HAVEN'T BEEN DEFINED, AN ALL
C  BLANK ID IS STORED IN WORK ARRAY
C
      DO 490 I=4,6
C
C  IF AN OPTIONAL TIME-SERIES HASN'T BEEN ENTERED, JUST STORE BLANKS
C
      IF (.NOT.NRQFND(I-3)) GO TO 480
C
C  IF AN ERROR OCCURRED ON INPUT, SKIP TO NEXT TIME-SERIES.
C
      IF (.NOT.TSOK(I)) GO TO 490
C
C  STORE THE ID, DATA TYPE AND TIME INTERVAL
C
      CALL FLWK26(WORK,IUSEW,LEFTW,TSID(1,I),501)
      CALL FLWK26(WORK,IUSEW,LEFTW,TSID(2,I),501)
      CALL FLWK26(WORK,IUSEW,LEFTW,DTYPE(I),501)
C
C  OPTIONAL TIME-SERIES TIME INTERVAL MUST BE AN EVEN MULTIPLE OF THE
C  OPERATION TIME INTERVAL
C
      IF (IDELT .EQ. 0) GO TO 470
      IF (MOD(IDT(I),IDELT) .EQ. 0) GO TO 470
C
      CALL STER26(47,1)
      GO TO 9999
C
  470 CONTINUE
      DT = IDT(I) + 0.01
      CALL FLWK26(WORK,IUSEW,LEFTW,DT,501)
      CALL FLWK26(WORK,IUSEW,LEFTW,TSIO(I),501)
C
      NTSG = NTSG + 5
      GO TO 490
C
C  JUST STORE A BLANK ID IN WORK
C
  480 CONTINUE
      CALL FLWK26(WORK,IUSEW,LEFTW,BLANK,501)
      CALL FLWK26(WORK,IUSEW,LEFTW,BLANK,501)
C
      NTSG = NTSG + 2
C
  490 CONTINUE
      GO TO 9999
C
C-----------------------------------------------------------------------
C  ENDGENL FOUND WHERE IT SHOULDN'T BE. SIGNAL ERROR AND RETURN
C
  500 CONTINUE
      USEDUP = .TRUE.
      CALL STER26(43,1)
      GO TO 9999
C
 9000 CONTINUE
      IF (IERF.EQ.1) CALL STER26(19,1)
      IF (IERF.EQ.2) CALL STER26(20,1)
      IF (IERF.EQ.3) CALL STER26(21,1)
      IF (IERF.EQ.4) CALL STER26(1,1)
      IF (IERF.NE.3) GO TO 10
      USEDUP = .TRUE.
C
C-------------------------------------------------------
C
 9999 CONTINUE
      RETURN
      END