{
  ** Give this module a header description here **
}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        'Define pins and BAUD rate
        comRx = 20        'Rx/dout is 20
        comTx = 21        'Tx/din is 21
        Baud = 9600

        'Define Commands
        comStart = $7A
        comForward = $01
        comReverse = $02
        comPivotLeft = $03
        comPivotRight = $04
        comAngledRightForward = $05
        comAngledLeftForward = $06
        comDiagonalLeftUp = $07
        comDiagonalRightUp = $08
        comBankedRight = $09
        comBankedLeft = $0A
        comStrafeLeft = $0B
        comStrafeRight = $0C
        comDiagonalLeftDown = $0D
        comDiagonalRightDown = $0E
        comClawControl = $10
        comStopAll = $AA


VAR
  long CommCogID, CommCogStack[64]
  long _Ms_001

OBJ
  Comm  : "FullDuplexSerial.spin"                                            'UART Communication for control
  'Motor : "MotorControl.spin"
PUB Init(DirPtr , RDYPtr, MsVal)                                              'Initialise Core for Communications
  _Ms_001 := MSVal
  StopCore                                                                          'Prevent stacking drivers
  CommCogID := cognew(Start(DirPtr, RDYPtr), @CommCogStack)                        'Initialise new cog with Start method


  return CommCogID

PUB Start(DirPtr, RDYPtr) | hexValue                                             'Looping code for Op-Code update

  'Set up new cog
  Comm.Start(comRx, comTx, 0, Baud)                                 'Start new cog for UART Communication with ZigBee
                                                      'Receive data from PC
  BYTE[RDYPtr] := 0
  'Poll for commands
  repeat                                                                                      'Protocol starts with start BYTE
    hexValue:=Comm.rx
    if BYTE[RDYPtr] == 0
      if hexValue == comStart
        BYTE[RDYPtr] := 1
    if BYTE[RDYPtr] == 1                                                                  'Retrieve direction BYTE
        case hexValue                                                             'Update direction using Op-Code
          comForward:
           BYTE[DirPtr] := 1
          comReverse:
           BYTE[DirPtr] := 2
          comPivotLeft:
           BYTE[DirPtr] := 3
          comPivotRight:
           BYTE[DirPtr] := 4
          comStopALL:
           BYTE[DirPtr] := 5
          comAngledRightForward:
           BYTE[DirPtr] := 6
          comAngledLeftForward:
           BYTE[DirPtr] := 7
          comDiagonalLeftUp:
           BYTE[DirPtr] := 8
          comDiagonalRightUp:
           BYTE[DirPtr] := 9
          comBankedRight:
           BYTE[DirPtr] := 10
          comBankedLeft:
           Byte[DirPtr] := 11
          comStrafeLeft:
           BYTE[DirPtr] := 12
          comStrafeRight:
           BYTE[DirPtr] := 13
          comDiagonalLeftDown:
           BYTE[DirPtr] :=  14
          comDiagonalRightDown:
           BYTE[DirPtr] := 15
          comClawControl:
           Byte[DirPtr] := 16

PUB StopCore                                                                    'Stop active cog
  if CommCogID                                                                  'Check for active cog
    cogStop(CommCogID~)                                                         'Stop the cog and zero out ID
  return CommCogID

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _Ms_001)
  return