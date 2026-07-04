object Config_Form: TConfig_Form
  Left = 389
  Top = 269
  BorderStyle = bsToolWindow
  Caption = #54872#44221#49444#51221
  ClientHeight = 240
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #44404#47548
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 12
  object Bevel1: TBevel
    Left = 8
    Top = 200
    Width = 210
    Height = 9
    Shape = bsTopLine
  end
  object Label1: TLabel
    Left = 20
    Top = 13
    Width = 36
    Height = 12
    Alignment = taRightJustify
    Caption = #48148#53461#49353
  end
  object Label2: TLabel
    Left = 8
    Top = 43
    Width = 48
    Height = 12
    Alignment = taRightJustify
    Caption = #49884#51089#50948#52824
  end
  object Label3: TLabel
    Left = 32
    Top = 72
    Width = 24
    Height = 12
    Alignment = taRightJustify
    Caption = #45800#50948
  end
  object Label4: TLabel
    Left = 151
    Top = 42
    Width = 34
    Height = 12
    Caption = 'pixels'
  end
  object Label5: TLabel
    Left = 151
    Top = 74
    Width = 34
    Height = 12
    Caption = 'pixels'
  end
  object SpinEdit_RulerMargin: TSpinEdit
    Tag = 202
    Left = 64
    Top = 37
    Width = 81
    Height = 21
    MaxValue = 100
    MinValue = 0
    TabOrder = 0
    Value = 0
    OnChange = SpinEdit_RulerMarginChange
  end
  object SpinEdit_RulerValue: TSpinEdit
    Tag = 203
    Left = 64
    Top = 67
    Width = 81
    Height = 21
    MaxValue = 20
    MinValue = 1
    TabOrder = 1
    Value = 1
    OnChange = SpinEdit_RulerMarginChange
  end
  object Panel_Color: TPanel
    Left = 64
    Top = 8
    Width = 113
    Height = 25
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    OnClick = Panel_ColorClick
  end
  object RadioGroup_Magnetic: TRadioGroup
    Left = 64
    Top = 92
    Width = 113
    Height = 79
    Caption = #51088#49437#54952#44284
    Items.Strings = (
      'None'
      'Window'
      'Control')
    TabOrder = 3
  end
  object Button_OK: TButton
    Left = 30
    Top = 208
    Width = 75
    Height = 23
    Caption = #54869#51064
    ModalResult = 1
    TabOrder = 4
  end
  object Button_Cancel: TButton
    Left = 118
    Top = 208
    Width = 75
    Height = 23
    Caption = #52712#49548
    ModalResult = 2
    TabOrder = 5
  end
  object CheckBox_CurPoint: TCheckBox
    Left = 64
    Top = 177
    Width = 97
    Height = 17
    Caption = #54788#51116#50948#52824' '#54364#49884
    TabOrder = 6
  end
  object ColorDialog: TColorDialog
    Top = 128
  end
end
