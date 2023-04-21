unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, pngimage, StdCtrls;

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
    procedure gameTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    function createPlatform(x, y: Integer): TPlatform;
    procedure FormResize(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);                                           
    procedure gameCanvasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; x, y: Integer);
    procedure fpsResetTimer(Sender: TObject);
    procedure groundedTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  background: TGraphic;
  player: TPlayer;
  platforms: array of TPlatform;
  grounded: Boolean;
  jump, controlleft, controlright, canJump: Boolean;
  fps, lastFps: Integer;

implementation

{$R *.dfm}

function TForm1.createPlatform(x, y: Integer): TPlatform;
var
  platform: TPlatform;
begin

  platform := TPlatform.Create;

  platform.x := x;
  platform.y := y;

  SetLength(platforms, LENGTH(platforms) + 1);

  platforms[ HIGH(platforms)] := platform;

end;

procedure TForm1.FormActivate(Sender: TObject);
var
  platform: TPlatform;
begin
  AllocConsole;

  fps := 0;
  lastFps := 0;

  player := TPlayer.Create;

  player.x := 200;
  player.y := 100;
  player.yVelocity := 0;

  createPlatform(round(player.x), round(player.y) - 50);

  createPlatform(0, 0);

  gameTimer.Enabled := True;

  Application.Restore;
  Application.BringToFront;

end;
    

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  writeln(ORD(Key));
  if ((ORD(Key) = 32) and (grounded)) then
  begin
    writeln('JUMP!');
    jump := True;
  end;
  if (ORD(Key) = 65) then
  begin
    controlleft := True;
  end;
  if (ORD(Key) = 68) then
  begin
    controlright := True;
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  P: TPoint;
begin
  if (ORD(Key) = 32) then
  begin
    writeln('STOP JUMP!');
    jump := False;
  end;
  if (ORD(Key) = 65) then
  begin
    controlleft := False;
  end;
  if (ORD(Key) = 68) then
  begin
    controlright := False;
  end;
  if ((ORD(Key) = 69) or (ORD(Key) = 82)) then
  begin
    createPlatform(round(player.x), round(player.y-30));
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  gameCanvas.height := Form1.ClientHeight;
  gameCanvas.width := Form1.ClientWidth;

  gameCanvas.Picture.Bitmap.SetSize(Form1.ClientWidth, Form1.ClientHeight);
end;

procedure TForm1.fpsResetTimer(Sender: TObject);
begin
lastFps := fps;
fps:=0;
end;

procedure TForm1.gameTimerTimer(Sender: TObject);
var
  x, y, I: Integer;
begin

  grounded := False;

  groundedTimer.Enabled := True;

 //player.y := player.y + player.yVelocity;
    //player.yVelocity := player.yVelocity - 0.1;

  for I := 0 to LENGTH(platforms) - 1 do
  begin
    if ((player.x > platforms[I].x - 50) and (player.x < platforms[I].x + 50)
        and (player.y <= platforms[I].y + 25) and (player.y > platforms[I].y - 25)) then
    begin
      grounded := True;
      canJump := True;
    end;
  end;

  if player.y < 0 then
    player.y := form1.ClientHeight;

  if player.x < 0 then
    player.x := form1.ClientWidth;

    if player.x > form1.ClientWidth then
    player.x := 0;

    if player.y > form1.ClientHeight then
    player.y := 0;


  if ((jump) and canJump) then
    player.yVelocity := 5;
    canJump := False;

  if (controlleft) then
    player.x := player.x - 2;

  if (controlright) then
    player.x := player.x + 2;

    if ((grounded) and (player.yVelocity < 0)) then
      player.yVelocity := 0;

      if player.yVelocity < -4 then
        player.yVelocity := -4;


  player.y := player.y + player.yVelocity;

  if not grounded then
  begin

    player.yVelocity := player.yVelocity-0.1;
  end;

  gameCanvas.canvas.pen.color := clGray;
  gameCanvas.canvas.brush.color := clGray;
  gameCanvas.canvas.rectangle(0, 0, gameCanvas.ClientWidth,
    gameCanvas.ClientHeight);

  gameCanvas.canvas.pen.color := clBlue;
  gameCanvas.canvas.brush.color := clBlue;

  gameCanvas.canvas.rectangle(round(player.x - 5),
    Form1.ClientHeight - round(player.y) - 10, round(player.x + 5),
    round(Form1.ClientHeight - player.y + 10));

    gameCanvas.canvas.pen.color := clYellow;
  gameCanvas.canvas.brush.color := clGray;

  for I := 0 to LENGTH(platforms) - 1 do
  begin
    gameCanvas.canvas.rectangle(platforms[I].x - 50,
      Form1.ClientHeight - platforms[I].y - 15, platforms[I].x + 50,
      Form1.ClientHeight - platforms[I].y + 15);
  end;

  gameCanvas.Canvas.Font.Name := 'Segoe UI';
  gameCanvas.canvas.Font.Color := clWhite;
  gameCanvas.canvas.brush.color := clGray;

  gameCanvas.Canvas.TextOut(5, 5, Format('X: %g Y: %g FPS: %d VEL: %g', [player.x, player.y, lastFps, player.yVelocity]));
  inc(fps);

end;

procedure TForm1.groundedTimerTimer(Sender: TObject);
begin
canJump := False;
groundedTimer.Enabled := False;
end;

procedure TForm1.gameCanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; x, y: Integer);
var
  P: TPoint;
  I : Integer;
begin
  GetCursorPos(P);
  P := Form1.ScreenToClient(P);

  if Button = mbLeft then begin
    writeln('LEFT button');
    createPlatform(round(P.x), Form1.ClientHeight-(P.y));
  end
  else if Button = mbRight then begin
    writeln('RIGHT button');
    for I := 0 to LENGTH(platforms) - 1 do
  begin
    if ((p.X > (platforms[I].x -50)) and (p.X < (platforms[I].x +50)) and (p.y < platforms[I].y + 15) and (p.y > platforms[I].y - 15)) then begin
      //platforms[I].Destroy;
      SetLength(platforms, LENGTH(platforms)-1);
    end;
  end;
  end;
end;

end.
