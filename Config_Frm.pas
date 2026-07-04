unit Config_Frm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Registry, StdCtrls, ExtCtrls, ComCtrls, Spin;

type
  TMagneticType = ( mtNone, mtWindow, mtControl );

  TConfig = class
  private
    ConfigFile: TRegIniFile;
  public
    Ruler_Sero : Boolean;

    Ruler_Left,
    Ruler_Top,
    Ruler_Width,
    Ruler_Height : Integer;

    Ruler_Color : String;
    Ruler_Margin : Integer;
    Ruler_Value : Integer;
    Ruler_MagneticType : TMagneticType;
    Ruler_Alphablend : Boolean;
    Ruler_GuideLine : Boolean;
    Ruler_CurPoint : Boolean;
    App_Language : string;

    constructor Create;
    destructor Destroy; override;
  end;

  TConfig_Form = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    SpinEdit_RulerMargin: TSpinEdit;
    Label3: TLabel;
    SpinEdit_RulerValue: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    Panel_Color: TPanel;
    ColorDialog: TColorDialog;
    RadioGroup_Magnetic: TRadioGroup;
    Button_OK: TButton;
    Button_Cancel: TButton;
    CheckBox_CurPoint: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure SpinEdit_RulerMarginChange(Sender: TObject);
    procedure Panel_ColorClick(Sender: TObject);
  private
  public
    procedure Apply;
    procedure ApplyLanguage;
  end;

  procedure Show_Config_Form;

var
  Config_Form: TConfig_Form;
  Config : TConfig;

implementation

uses
  Lang_Unit;

{$R *.DFM}

procedure Show_Config_Form;
begin
  with TConfig_Form.Create( nil ) do
  begin
    try
      if ShowModal = mrOk then
        Apply;
    finally
      Free;
    end;
  end;
end;

{ TConfig }

constructor TConfig.Create;
const
  RegKey = 'SoftWare\Magic Ruler';
var
  MagneticIndex : Integer;
begin
  ConfigFile:= TRegIniFile.Create( RegKey );
  with ConfigFile do
  begin
    Ruler_Sero   := ReadBool( 'Ruler', 'Sero', False );

    Ruler_Left   := ReadInteger( 'Ruler', 'Left', 100 );
    Ruler_Top    := ReadInteger( 'Ruler', 'Top', 100 );
    Ruler_Width  := ReadInteger( 'Ruler', 'Width', 500 );
    Ruler_Height := ReadInteger( 'Ruler', 'Height', 33 );

    Ruler_Color  := ReadString( 'Ruler', 'Color', 'clWhite' );
    Ruler_Margin := ReadInteger( 'Ruler', 'Margin', 20 );
    Ruler_Value  := ReadInteger( 'Ruler', 'Value', 5 );
    MagneticIndex := ReadInteger( 'Ruler', 'MagneticType', Ord( mtNone ) );
    if ( MagneticIndex < Ord( Low( TMagneticType ) ) ) or
       ( MagneticIndex > Ord( High( TMagneticType ) ) ) then
      MagneticIndex := Ord( mtNone );
    Ruler_MagneticType := TMagneticType( MagneticIndex );
    Ruler_Alphablend := ReadBool( 'Ruler', 'Alphablend', True );
    Ruler_GuideLine := ReadBool( 'Ruler', 'GuideLine', True );
    Ruler_CurPoint := ReadBool( 'Ruler', 'CurPoint', True );
    App_Language := ReadString( 'App', 'Language', 'Kor' );
    if ( CompareText( App_Language, 'Kor' ) <> 0 ) and
       ( CompareText( App_Language, 'Eng' ) <> 0 ) then
      App_Language := 'Kor';
  end;
end;

destructor TConfig.Destroy;
begin
  with ConfigFile do
   begin
     try
       WriteBool( 'Ruler', 'Sero', Ruler_Sero );
       WriteInteger( 'Ruler', 'Left', Ruler_Left );
       WriteInteger( 'Ruler', 'Top', Ruler_Top );
       WriteInteger( 'Ruler', 'Width', Ruler_Width );
       WriteInteger( 'Ruler', 'Height', Ruler_Height );

       WriteString( 'Ruler', 'Color', Ruler_Color );
       WriteInteger( 'Ruler', 'Margin', Ruler_Margin );
       WriteInteger( 'Ruler', 'Value', Ruler_Value );
       WriteInteger( 'Ruler', 'MagneticType', Ord( Ruler_MagneticType ) );
       WriteBool( 'Ruler', 'Alphablend', Ruler_Alphablend );
       WriteBool( 'Ruler', 'GuideLine', Ruler_GuideLine );
       WriteBool( 'Ruler', 'CurPoint', Ruler_CurPoint );
       WriteString( 'App', 'Language', App_Language );
     finally
       Free;
     end;
   end;
  inherited Destroy;
end;

{ TConfig_Form }

procedure TConfig_Form.Apply;
begin
  with Config do
  begin
    Ruler_Color      := ColorToString( Panel_Color.Color );
    Ruler_Margin     := SpinEdit_RulerMargin.Value;
    Ruler_Value      := SpinEdit_RulerValue.Value;
    Ruler_MagneticType := TMagneticType( RadioGroup_Magnetic.ItemIndex );
    Ruler_CurPoint   := CheckBox_CurPoint.Checked;
  end;
end;

procedure TConfig_Form.FormCreate(Sender: TObject);
begin
  ClientWidth := 225;
  ClientHeight := 240;

  ApplyLanguage;

  Panel_Color.Color          := StringToColor( Config.Ruler_Color );
  SpinEdit_RulerMargin.Value := Config.Ruler_Margin;
  SpinEdit_RulerValue.Value  := Config.Ruler_Value;
  RadioGroup_Magnetic.ItemIndex := Ord( Config.Ruler_MagneticType );
  CheckBox_CurPoint.Checked  := Config.Ruler_CurPoint;
end;

procedure TConfig_Form.ApplyLanguage;
begin
  Caption := Lang.Text( 'config.title', Caption );
  Label1.Caption := Lang.Text( 'config.backgroundColor', Label1.Caption );
  Label2.Caption := Lang.Text( 'config.startPosition', Label2.Caption );
  Label3.Caption := Lang.Text( 'config.unit', Label3.Caption );
  Label4.Caption := Lang.Text( 'unit.pixels', Label4.Caption );
  Label5.Caption := Lang.Text( 'unit.pixels', Label5.Caption );
  RadioGroup_Magnetic.Caption := Lang.Text( 'menu.magnetic', RadioGroup_Magnetic.Caption );
  RadioGroup_Magnetic.Items[ 0 ] := Lang.Text( 'magnetic.none', 'None' );
  RadioGroup_Magnetic.Items[ 1 ] := Lang.Text( 'magnetic.window', 'Window' );
  RadioGroup_Magnetic.Items[ 2 ] := Lang.Text( 'magnetic.control', 'Control' );
  CheckBox_CurPoint.Caption := Lang.Text( 'menu.currentPoint', CheckBox_CurPoint.Caption );
  Button_OK.Caption := Lang.Text( 'button.ok', Button_OK.Caption );
  Button_Cancel.Caption := Lang.Text( 'button.cancel', Button_Cancel.Caption );
end;

procedure TConfig_Form.SpinEdit_RulerMarginChange(Sender: TObject);
begin
  try
    if TSpinEdit( Sender ).Value > TSpinEdit( Sender ).MaxValue then
      TSpinEdit( Sender ).Value := TSpinEdit( Sender ).MaxValue
    else if TSpinEdit( Sender ).Value < TSpinEdit( Sender ).MinValue then
      TSpinEdit( Sender ).Value := TSpinEdit( Sender ).MinValue
  except
    TSpinEdit( Sender ).Value := 20;
  end;
end;

procedure TConfig_Form.Panel_ColorClick(Sender: TObject);
begin
  with ColorDialog do
  begin
    Color := TPanel( Sender ).Color;
    if Execute then
      Panel_Color.Color := Color;
  end;
end;

initialization
  Config:= TConfig.Create;

finalization
  Config.Free;

end.
