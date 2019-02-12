object Form1: TForm1
  Left = 614
  Top = 419
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1059#1087#1072#1082#1086#1074#1082#1072' '#1092#1072#1081#1083#1086#1074' - 7z'
  ClientHeight = 184
  ClientWidth = 353
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 0
    Top = 79
    Width = 353
    Height = 105
    Align = alBottom
    Caption = #1051#1086#1075' '#1088#1072#1073#1086#1090#1099
    TabOrder = 0
    object d_Memo_Info: TMemo
      Left = 2
      Top = 15
      Width = 349
      Height = 88
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object pb1: TProgressBar
    Left = 0
    Top = 70
    Width = 353
    Height = 9
    Align = alBottom
    TabOrder = 1
  end
  object grp2: TGroupBox
    Left = 0
    Top = 0
    Width = 353
    Height = 34
    Align = alTop
    TabOrder = 2
    object d_Shape_Led: TShape
      Left = 328
      Top = 5
      Width = 17
      Height = 22
      Brush.Color = clRed
      Pen.Color = clMaroon
      Shape = stCircle
    end
    object Shape1: TShape
      Left = 330
      Top = 9
      Width = 8
      Height = 10
      Pen.Color = clMaroon
      Pen.Style = psClear
      Shape = stCircle
    end
    object lbl1: TLabel
      Left = 200
      Top = 10
      Width = 120
      Height = 13
      Caption = '>==================>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object d_Lbl_Info: TLabel
      Left = 4
      Top = 8
      Width = 137
      Height = 16
      Caption = #1057#1074#1103#1079#1100' '#1089' '#1089#1077#1088#1074#1077#1088#1086#1084':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object btn1: TButton
    Left = 8
    Top = 40
    Width = 139
    Height = 25
    Caption = #1059#1087#1072#1082#1086#1074#1072#1090#1100
    TabOrder = 3
    OnClick = btn1Click
  end
  object btn3: TButton
    Left = 208
    Top = 40
    Width = 139
    Height = 25
    Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100' Settings'
    TabOrder = 4
    OnClick = btn3Click
  end
end
