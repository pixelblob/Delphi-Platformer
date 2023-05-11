unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, pngimage, StdCtrls, DateUtils, Math;

type
  TPlatform = class(TObject)
    x, y, width, height: Integer;
  end;

type
  TPlayer = class(TObject)
    x, y, yVelocity: Real;
  end;

type
  TForm1 = class(TForm)
    gameCanvas: TImage;
    gameTimer: TTimer;
    fpsReset: TTimer;
    groundedTimer: TTimer;
    fpsLowStart: TTimer;
    procedure gameTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    function createPlatform(x, y: Integer): TPlatform;
    procedure FormResize(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gameCanvasMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Integer);
    procedure fpsResetTimer(Sender: TObject);
    procedure groundedTimerTimer(Sender: TObject);
    procedure fpsLowStartTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TGameThreadThread = class(TThread)
  protected
  public
    constructor Create();
    destructor Destroy; override;
    procedure Execute(); override;
  published
  end;

var
  Form1: TForm1;
  background: TGraphic;
  player: TPlayer;
  platforms: array of TPlatform;
  grounded: Boolean;
  jump, controlleft, controlright, canJump: Boolean;
  fps, lastFps, fpsLow, tps, lastTps, offsetX, offsetY: Integer;
  gameThread: TGameThreadThread;

implementation

{$R *.dfm}

constructor TGameThreadThread.Create();
begin
  inherited Create(false);
  Self.FreeOnTerminate := True;
end;

destructor TGameThreadThread.Destroy;
begin

  inherited;
end;

procedure TGameThreadThread.Execute;
var
  x, y, I: Integer;
  start: TDateTime;
begin
  // Here we do work
  // writeln('Hello From A different Thread!');
  // When we exit the procedure, the thread ends.
  // So we don't exit until we're done.

  while True do begin

    if Terminated then
      Exit;

    grounded := false;

    // form1.groundedTimer.Enabled := true;

    // player.y := player.y + player.yVelocity;
    // player.yVelocity := player.yVelocity - 0.1;

    for I := 0 to LENGTH(platforms) - 1 do begin
      if ((player.x > platforms[I].x - 50+offsetX) and (player.x < platforms[I].x + 50+offsetX) and (player.y <= platforms[I].y + 25 - offsetY) and (player.y > platforms[I].y - 25 -offsetY))
        then begin

        if ((player.y > platforms[I].y - 30 -offsetY) and (player.y <= platforms[I].y + 5 - offsetY)) then begin
          player.y := platforms[I].y - 30 - offsetY;
          player.yVelocity := 0;
        end
        else begin
          grounded := True;
          canJump := True;
        end;

      end;
    end;

    if player.x < Form1.ClientWidth/3 then begin
      offsetX := offsetX+2;
      player.x := player.x+2;
    end
    else if player.x > Form1.ClientWidth/3*2 then begin
      offsetX := offsetX-2;
      player.x := player.x-2;
    end else if player.y > Form1.ClientHeight/4*3 then begin
      offsetY := round(offSetY +ABS(player.yVelocity));
      player.y := round(player.y -ABS(player.yVelocity))
    end else if player.y < Form1.ClientHeight/4*1 then begin
      offsetY := round(offSetY - ABS(player.yVelocity));
      player.y := round(player.y + ABS(player.yVelocity))
    end;






    if ((jump) and canJump) then
      player.yVelocity := 5;
    canJump := false;

    if (controlleft) then
      player.x := player.x - 2;

    if (controlright) then
      player.x := player.x + 2;

    if ((grounded) and (player.yVelocity < 0)) then
      player.yVelocity := 0;

    if player.yVelocity < -4 then
      player.yVelocity := -4;

    player.y := player.y + player.yVelocity;

    if not grounded then begin

      player.yVelocity := player.yVelocity - 0.1;
    end;

    inc(tps);

    sleep(1);

  end;

end;

function AttachConsole(dwProcessID: Integer): Boolean; stdcall; external 'kernel32.dll';
function FreeConsole(): Boolean; stdcall; external 'kernel32.dll';

function TForm1.createPlatform(x, y: Integer): TPlatform;
var
  platform: TPlatform;
begin

  platform := TPlatform.Create;

  platform.x := x;
  platform.y := y;

  // platform.

  SetLength(platforms, LENGTH(platforms) + 1);

  platforms[ HIGH(platforms)] := platform;

  Result := platform;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
  platform: TPlatform;
begin
  try
    AttachConsole(-1);
    writeln;
    writeln('ATTACHED TO EXISTING CONSOLE!');
  except
    on E: Exception do begin
      AllocConsole;
    end;
  end;

  fps := 0;
  lastFps := 0;

  offsetX := 0;
  offsetY := 0;

  player := TPlayer.Create;

  player.x := 200;
  player.y := 100;
  player.yVelocity := 0;

  createPlatform(round(player.x), round(player.y) - 50);

  createPlatform(round(player.x), round(player.y) + 200);

  createPlatform(0, 0);

  gameTimer.Enabled := True;

  Application.Restore;
  Application.BringToFront;

  gameThread := TGameThreadThread.Create();

end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  writeln(ORD(Key));
  if ((ORD(Key) = 32) and (grounded)) then begin
    writeln('JUMP!');
    jump := True;
  end;
  if (ORD(Key) = 65) then begin
    controlleft := True;
  end;
  if (ORD(Key) = 68) then begin
    controlright := True;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  P: TPoint;
begin
  if (ORD(Key) = 32) then begin
    writeln('STOP JUMP!');
    jump := false;
  end;
  if (ORD(Key) = 65) then begin
    controlleft := false;
  end;
  if (ORD(Key) = 68) then begin
    controlright := false;
  end;
  if ((ORD(Key) = 69) or (ORD(Key) = 82)) then begin
    createPlatform(round(player.x)+offsetX, round(player.y - 30));
  end;
  if (ORD(Key) = 27) then begin
    // gameThread.Free;
    // gameThread.Terminate;
    offsetX := offsetX +10;
    offsetY := offsetY + 10;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  gameCanvas.height := Form1.ClientHeight;
  gameCanvas.width := Form1.ClientWidth;

  gameCanvas.Picture.Bitmap.SetSize(Form1.ClientWidth, Form1.ClientHeight);
end;

procedure TForm1.fpsLowStartTimer(Sender: TObject);
begin
  fpsLow := fps
end;

procedure TForm1.fpsResetTimer(Sender: TObject);
begin
  lastFps := fps;
  lastTps := tps;
  if (fpsLow > fps) then
    fpsLow := fps;
  fps := 0;
  tps := 0;
end;

procedure TForm1.gameTimerTimer(Sender: TObject);
var
  x, y, I, textOffset: Integer;
  P: TPoint;
begin

  GetCursorPos(P);
  P := Form1.ScreenToClient(P);

  with Form1.gameCanvas.canvas do begin

    pen.color := clGray;
    brush.color := clGray;
    rectangle(0, 0, Form1.ClientWidth, Form1.ClientHeight);

    pen.color := clBlue;
    brush.color := clBlue;

    rectangle(round(player.x - 5), Form1.ClientHeight - round(player.y) - 10, round(player.x + 5), round(Form1.ClientHeight - player.y + 10));

    pen.color := clYellow;
    brush.Style := bsClear;
  end;

  for I := 0 to LENGTH(platforms) - 1 do begin

    if ((P.x > (platforms[I].x - 50+offsetX)) and (P.x < (platforms[I].x + 50+offsetX)) and (Form1.ClientHeight - P.y < platforms[I].y + 15 -offsetY) and
        (Form1.ClientHeight - P.y > platforms[I].y - 15-offsetY)) then begin
      gameCanvas.canvas.pen.color := clRed;

    end;

    gameCanvas.canvas.rectangle(platforms[I].x - 50+offsetX, Form1.ClientHeight - platforms[I].y - 15 +offsetY, platforms[I].x + 50+offsetX, Form1.ClientHeight - platforms[I].y + 15 + offsetY);
    gameCanvas.canvas.pen.color := clYellow;

  end;

  with Form1.gameCanvas.canvas do begin

    Font.Name := 'Segoe UI';
    Font.color := clWhite;
    brush.Style := bsClear;

    Font.Size := round(Form1.ClientHeight / 20);

    Font.Size := Min(Font.Size, 20);

    Font.Size := Max(Font.Size, 8);

    writeln(Font.Size);

    textOffset := 5;

    TextOut(5, textOffset, Format('X: %g', [player.x]));
    textOffset := textOffset + Font.Size * 2;
    TextOut(5, textOffset, Format('Y: %g', [player.y]));
    textOffset := textOffset + Font.Size * 2;
    TextOut(5, textOffset, Format('VEL: %g', [player.yVelocity]));
    textOffset := textOffset + Font.Size * 2;
    TextOut(5, textOffset, Format('FPS: %d', [lastFps]));
    textOffset := textOffset + Font.Size * 2;
    TextOut(5, textOffset, Format('TPS: %d', [lastTps]));
    textOffset := textOffset + Font.Size * 2;
    TextOut(5, textOffset, Format('Obj: %d', [Length(platforms)]));
    textOffset := textOffset + Font.Size * 2;
    TextOut(5, textOffset, Format('Offset-X: %d', [offsetX]));
    textOffset := textOffset + Font.Size * 2;
    TextOut(5, textOffset, Format('Offset-Y: %d', [offsetY]));
  end;

  inc(fps)

end;

procedure TForm1.groundedTimerTimer(Sender: TObject);
begin
  canJump := false;
  groundedTimer.Enabled := false;
end;

procedure TForm1.gameCanvasMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: Integer);
var
  P: TPoint;
  I: Integer;
  ALength: Cardinal;
  index: Cardinal;
begin
  GetCursorPos(P);
  P := Form1.ScreenToClient(P);

  if Button = mbLeft then begin
    writeln('LEFT button');
    createPlatform(round(P.x)-offsetX, Form1.ClientHeight - (P.y)+offsetY);

  end
  else if Button = mbRight then begin
    writeln('RIGHT button');
    for I := 0 to LENGTH(platforms) - 1 do begin
      if ((P.x > (platforms[I].x - 50+offsetX)) and (P.x < (platforms[I].x + 50+offsetX)) and (Form1.ClientHeight - P.y < platforms[I].y + 15 - offsetY) and
          (Form1.ClientHeight - P.y > platforms[I].y - 15 - offsetY)) then begin
        // platforms[I].Destroy;
        // SetLength(platforms, LENGTH(platforms) - 1);
        ALength := LENGTH(platforms);
        for index := I + 1 to ALength - 1 do
          platforms[index - 1] := platforms[index];
        SetLength(platforms, ALength - 1);

      end;
    end;
  end;
end;

end.
