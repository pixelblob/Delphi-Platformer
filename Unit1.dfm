object Form1: TForm1
  Left = 617
  Top = 386
  Caption = 'Form1'
  ClientHeight = 463
  ClientWidth = 850
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnActivate = FormActivate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object gameCanvas: TImage
    Left = 0
    Top = 0
    Width = 850
    Height = 463
    Align = alClient
    OnMouseDown = gameCanvasMouseDown
    ExplicitLeft = 8
    ExplicitWidth = 527
    ExplicitHeight = 242
  end
  object gameTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = gameTimerTimer
    Left = 480
    Top = 16
  end
  object fpsReset: TTimer
    OnTimer = fpsResetTimer
    Left = 480
    Top = 72
  end
  object groundedTimer: TTimer
    Enabled = False
    OnTimer = groundedTimerTimer
    Left = 416
    Top = 152
  end
  object fpsLowStart: TTimer
    Interval = 5000
    OnTimer = fpsLowStartTimer
    Left = 176
    Top = 88
  end
end
