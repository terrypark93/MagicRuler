unit Main_Frm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ImgList, AppEvnts, StdCtrls, ExtCtrls, System.ImageList;

type
  TOrientation = ( otGaro, otSero );
  TNumberPos = ( npTop, npSide );

  TMain_Form = class(TForm)
    PopupMenu: TPopupMenu;
    Menu_Config: TMenuItem;
    N2: TMenuItem;
    Menu_Close: TMenuItem;
    Menu_Garo: TMenuItem;
    Menu_Sero: TMenuItem;
    N1: TMenuItem;
    ImageList_PopupMenu: TImageList;
    N3: TMenuItem;
    Menu_Magnetic: TMenuItem;
    Menu_MagneticNone: TMenuItem;
    Menu_MagneticWindow: TMenuItem;
    Menu_MagneticControl: TMenuItem;
    Menu_Color: TMenuItem;
    N5: TMenuItem;
    Menu_C: TMenuItem;
    Menu_C1: TMenuItem;
    Menu_C2: TMenuItem;
    Menu_C3: TMenuItem;
    Menu_C4: TMenuItem;
    Menu_C5: TMenuItem;
    Menu_C6: TMenuItem;
    Menu_C7: TMenuItem;
    Menu_C8: TMenuItem;
    Menu_C9: TMenuItem;
    Menu_C10: TMenuItem;
    Menu_C11: TMenuItem;
    Menu_C12: TMenuItem;
    Menu_C13: TMenuItem;
    Menu_C14: TMenuItem;
    Menu_C15: TMenuItem;
    Menu_C16: TMenuItem;
    Menu_Language: TMenuItem;
    Menu_LanguageKor: TMenuItem;
    Menu_LanguageEng: TMenuItem;
    ColorDialog: TColorDialog;
    N4: TMenuItem;
    Menu_AlphaBlend: TMenuItem;
    Menu_About: TMenuItem;
    ApplicationEvents1: TApplicationEvents;
    lbSize: TStaticText;
    Menu_CurPoint: TMenuItem;
    Timer1: TTimer;
    Label_Garo: TLabel;
    Label_Sero: TLabel;
    Menu_GuideLine: TMenuItem;
    procedure MenuClick( Sender : TObject );
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure Menu_C1Click(Sender: TObject);
    procedure Menu_C16DrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure Menu_CMeasureItem(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Menu_ConfigDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    FWorkBmp : TBitmap;
    FLeft, FTop, FWidth, FHeight : Integer;
    FColor : TColor;
    FMMperPixel, FStartMargin : Integer;
    FNumberPos : TNumberPos;
    FOrientation, FOldOrientation : TOrientation;
    FGuideLineDrawed : Boolean;
    FMeasureValue : Integer;
    FLastMagneticRect : TRect;
    FLastMagneticSide : Integer;
    FLastMagneticValid : Boolean;

    FOldPos1, FOldPos2 : Integer;
    procedure WMNCHitTest( var Message : TWMNcHitTest ); message WM_NCHITTEST;
    procedure WMPaint( var Message : TWMPaint ); message WM_PAINT;
    procedure WMMoving( var Message : TMessage ); message WM_MOVING;
    procedure WMHotkey( Var msg: TWMHotkey ) ;   message WM_HOTKEY;

    procedure Register_HotKey;
    procedure UnRegister_HotKey;
    procedure Set_MyPos;
    procedure ResetMagneticTracking;
    function GetMagneticSide( APoint : TPoint; ARect : TRect ) : Integer;
    function GetVisibleWindowRect( AHandle : THandle; var ARect : TRect ) : Boolean;
    function GetMagneticTargetRect( APoint : TPoint; var ARect : TRect ) : Boolean;
    procedure ApplyMagneticTarget( APoint : TPoint; ARect : TRect );
    procedure Draw_GuideLine( APos1, APos2 : Integer );
  public
    procedure CreateParams( var Params : TCreateParams ); override;
    procedure LoadConfig;
    procedure ApplyLanguage;
    procedure SetLanguage( const ALanguage : string );
    procedure DrawRuler( Value : Integer = 0 );
    procedure SetOrientation;
    procedure Show_AboutBox;
    procedure Show_RulerPoint( APoint : Integer );
  end;

var
  Main_Form: TMain_Form;

const
  VK_MAGNETIC   = 192;
  DWMWA_EXTENDED_FRAME_BOUNDS = 9;
  MARK_GARO     = '↓';//'▼';
  MARK_SERO     = '→';//'▶';
  Colors: array [0..16] of TColor = ( clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal, clGray,
                                      clSilver, clRed, clLime, clYellow, clBlue, clFuchsia, clAqua, clWhite, clWindowText );

implementation
uses
  Config_Frm, Types, Lang_Unit;
{$R *.DFM}

type
  TDwmGetWindowAttribute = function( hwnd : HWND; dwAttribute : DWORD;
    pvAttribute : Pointer; cbAttribute : DWORD ) : HRESULT; stdcall;

{ TForm1 }

procedure TMain_Form.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  FGuideLineDrawed := False;
  FMeasureValue := 0;
  FLastMagneticSide := -1;
  FLastMagneticValid := False;

  LoadConfig;
  Lang.Load( Config.App_Language );
  ApplyLanguage;

  FWorkBmp := TBitmap.Create;
  FWorkBmp.Width := Width;
  FWorkBmp.Height := Height;
  Timer1.Enabled := Config.Ruler_MagneticType <> mtNone;

  Register_HotKey;
end;

procedure TMain_Form.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
    Style := (Style or WS_POPUP) and (not WS_DLGFRAME) and (not WS_THICKFRAME);
end;

procedure TMain_Form.DrawRuler( Value : Integer );
var
  i, Pos, Num : Integer;
  Stick_1, Stick_5, Stick_10 : Integer;
  MarkLeft, MarkTop, MarkWidth, MarkHeight : Integer;
begin
  Num      := 0;
  with Canvas do
  begin
    Pen.Style   := psSolid;
    Pen.Color   := clBlack;
    Pen.Width   := 1;

    Brush.Style := bsSolid;
    Brush.Color := FColor;
    Font.Name := 'MS Serif';
    Font.Size := 6;
    Rectangle( ClientRect );
    case FOrientation of
    otGaro : begin
                Stick_1  := Self.Height - 10;
                Stick_5  := Self.Height - 15;
                Stick_10 := Self.Height - 20;

                for i := 0 to Self.Width do
                begin
                  Pos := ( i * FMMperPixel ) + FStartMargin;
                  MoveTo( Pos, Self.Height );

                  if ( Num mod 10 ) = 0 then
                  begin
                    LineTo( Pos, Stick_10 );
                    case FNumberPos of
                    npTop  : TextOut( Pos - ( TextWidth( IntToStr( Num * FMMPerPixel ) ) div 2 ), Stick_10 - 6, IntToStr( Num * FMMPerPixel ) );
                    npSide : TextOut( Pos +2 , Stick_10 - 1, IntToStr( Num * FMMPerPixel ) );
                    end;
                  end
                  else if ( Num mod 5 ) = 0 then
                    LineTo( Pos, Stick_5 )
                  else
                    LineTo( Pos, Stick_1 );
                  Inc( Num );
                end;

                if Value <> 0 then
                begin
                  MarkHeight := TextHeight( MARK_GARO );
                  MarkWidth  := TextWidth( MARK_GARO );
                  MarkLeft := Config.Ruler_Margin + Value - ( MarkWidth div 2 );
                  MarkTop  := Stick_10 - MarkHeight;

                  TextOut( MarkLeft, MarkTop, MARK_GARO );

                  Show_RulerPoint( Value );
                end;
             end;
    otSero : begin
               Stick_1  := Self.Width - 10;
               Stick_5  := Self.Width - 15;
               Stick_10 := Self.Width - 20;

               for i := 0 to Self.Height do
               begin
                 Pos := ( i * FMMperPixel ) + FStartMargin;
                 MoveTo( Self.Width, Pos );

                 if ( Num mod 10 ) = 0 then
                 begin
                   LineTo( Stick_10, Pos );
                   case FNumberPos of
                   npTop  : TextOut( Stick_10 - 5, Pos + 2,  IntToStr( Num * FMMPerPixel ) );
                   npSide : TextOut( Stick_10 - 6, Pos - ( TextHeight( IntToStr( Num * FMMPerPixel ) ) div 2 ),  IntToStr( Num * FMMPerPixel ) );
                   end;
                 end
                 else if ( Num mod 5 ) = 0 then
                   LineTo( Stick_5, Pos )
                 else
                   LineTo( Stick_1, Pos );
                 Inc( Num );
              end;

              if Value <> 0 then
              begin
                MarkHeight := TextHeight( MARK_SERO );
                MarkWidth  := TextWidth( MARK_SERO );
                MarkLeft := Stick_10 - MarkWidth;
                MarkTop  := Config.Ruler_Margin + Value - ( MarkHeight div 2 );

                TextOut( MarkLeft, MarkTop, MARK_SERO );

                Show_RulerPoint( Value );                
              end;
            end;
    end;

    if not Config.Ruler_CurPoint then
      Show_RulerPoint( Width - FStartMargin );
  end;
//  Canvas.Draw( 0, 0, FWorkBmp );
end;

procedure TMain_Form.MenuClick(Sender: TObject);
begin
  case TComponent( Sender ).Tag of
  101, 102 : begin
          if TMenuItem( Sender ).Checked then Exit;
          FOrientation := TOrientation( Ord( TComponent( Sender ).Tag - 101 ) );
          Config.Ruler_Sero := Bool( Ord( TOrientation( FOrientation ) ) );
          TMenuItem( Sender ).Checked := True;
          SetOrientation;
          ResetMagneticTracking;
        end;
  201 : begin
          Show_Config_Form;
          LoadConfig;
          ResetMagneticTracking;
          Timer1.Enabled := Config.Ruler_MagneticType <> mtNone;
          DrawRuler;
        end;
  311..313 : begin
          Config.Ruler_MagneticType := TMagneticType( TComponent( Sender ).Tag - 311 );
          TMenuItem( Sender ).Checked := True;
          ResetMagneticTracking;
          Timer1.Enabled := Config.Ruler_MagneticType <> mtNone;
          if Config.Ruler_MagneticType = mtNone then
            FMeasureValue := 0;
          DrawRuler( FMeasureValue );
        end;
  302 : begin
//          TMenuItem( Sender ).Checked := not TMenuItem( Sender ).Checked;
          Config.Ruler_Alphablend := TMenuItem( Sender ).Checked;

          AlphaBlend := TMenuItem( Sender ).Checked;
        end;
  303 : begin
          Config.Ruler_CurPoint := TMenuItem( Sender ).Checked;
        end;
  304 : begin
          Config.Ruler_GuideLine := TMenuItem( Sender ).Checked;
        end;
  601 : SetLanguage( 'Kor' );
  602 : SetLanguage( 'Eng' );
  401 : Close;
  501 : Show_AboutBox;
  end;
end;

procedure TMain_Form.WMNCHitTest(var Message: TWMNcHitTest);
var
  Rect_1, Rect_2 : TRect;
  CurPt : TPoint;
begin
  Inherited;
  CurPt.x := Message.XPos;
  CurPt.y := Message.YPos;
  CurPt := ScreenToClient( CurPt );

  case FOrientation of
  otGaro : begin
            Rect_1 := Rect( 0, 0, 3, Height );
            Rect_2 := Rect( Width - 3, 0, Width, Height );
            if PtInRect( Rect_1, CurPt ) then
              Message.Result := HTLEFT
            else if PtInRect( Rect_2, CurPt ) then
              Message.Result := HTRIGHT
            else
              Message.Result := HTCLIENT;
           end;
  otSero : begin
            Rect_1 := Rect( 0, 0, Width, 3 );
            Rect_2 := Rect( 0, Height - 3,  Width, Height );
            if PtInRect( Rect_1, CurPt ) then
              Message.Result := HTTOP
            else if PtInRect( Rect_2, CurPt ) then
              Message.Result := HTBOTTOM
            else
              Message.Result := HTCLIENT;
           end;
  end;

  if Config.Ruler_CurPoint then
  begin
    case FOrientation of
    otGaro : Show_RulerPoint( CurPt.X - Config.Ruler_Margin );
    otSero : Show_RulerPoint( CurPt.Y - Config.Ruler_Margin );
    end;
  end;
end;

procedure TMain_Form.WMPaint(var Message: TWMPaint);
begin
  inherited;
  DrawRuler( FMeasureValue );
end;

procedure TMain_Form.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled := False;
  ResetMagneticTracking;
  RedrawWindow( GetDesktopWindow, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW );

  FWorkBmp.Free;

  UnRegister_HotKey;
end;

procedure TMain_Form.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage( Handle, WM_SYSCOMMAND, $F012, 0 );
end;

procedure TMain_Form.FormResize(Sender: TObject);
begin
  FWorkBmp.Width := Width;
  FWorkBmp.Height := Height;
  Config.Ruler_Width  := Self.Width;
  Config.Ruler_Height := Self.Height;
end;

procedure TMain_Form.LoadConfig;
begin
  FNumberPos := npTop;
  FOrientation := TOrientation( Ord( Config.Ruler_Sero ) ) ;
  FOldOrientation := FOrientation;

  FLeft       := Config.Ruler_Left;
  FTop        := Config.Ruler_Top;
  FWidth      := Config.Ruler_Width;
  FHeight     := Config.Ruler_Height;

  FColor       := StringToColor( Config.Ruler_Color );
  FStartMargin := Config.Ruler_Margin;
  FMMPerPixel  := Config.Ruler_Value;

  AlphaBlend   := Config.Ruler_Alphablend;
end;

procedure TMain_Form.ApplyLanguage;
begin
  Menu_Magnetic.Caption := Lang.Text( 'menu.magnetic', Menu_Magnetic.Caption );
  Menu_MagneticNone.Caption := Lang.Text( 'magnetic.none', 'None' );
  Menu_MagneticWindow.Caption := Lang.Text( 'magnetic.window', 'Window' );
  Menu_MagneticControl.Caption := Lang.Text( 'magnetic.control', 'Control' );
  Menu_AlphaBlend.Caption := Lang.Text( 'menu.alphaBlend', Menu_AlphaBlend.Caption );
  Menu_GuideLine.Caption := Lang.Text( 'menu.guideLine', Menu_GuideLine.Caption );
  Menu_CurPoint.Caption := Lang.Text( 'menu.currentPoint', Menu_CurPoint.Caption );
  Menu_Color.Caption := Lang.Text( 'menu.color', Menu_Color.Caption );
  Menu_C.Caption := Lang.Text( 'menu.colorOther', Menu_C.Caption );
  Menu_Garo.Caption := Lang.Text( 'menu.horizontal', Menu_Garo.Caption );
  Menu_Sero.Caption := Lang.Text( 'menu.vertical', Menu_Sero.Caption );
  Menu_Language.Caption := Lang.Text( 'menu.language', 'Language' );
  Menu_LanguageKor.Caption := Lang.Text( 'language.korean', 'Korean' );
  Menu_LanguageEng.Caption := Lang.Text( 'language.english', 'English' );
  Menu_Config.Caption := Lang.Text( 'menu.options', Menu_Config.Caption );
  Menu_About.Caption := Lang.Text( 'menu.about', 'About MagicRuler' );
  Menu_Close.Caption := Lang.Text( 'menu.close', Menu_Close.Caption );
end;

procedure TMain_Form.SetLanguage(const ALanguage: string);
begin
  if CompareText( Config.App_Language, ALanguage ) = 0 then Exit;

  Config.App_Language := ALanguage;
  Lang.Load( Config.App_Language );
  ApplyLanguage;
  PopupMenuPopup( PopupMenu );
end;

procedure TMain_Form.SetOrientation;
begin
  SetBounds( Left, Top, Height, Width );
  lbSize.Left := Width - lbSize.Width;
end;

procedure TMain_Form.Show_AboutBox;
begin
  MessageDlg( 'MagicRuler Ver 2.0 Freeware' + #13#10#13#10 +

              Lang.Text( 'about.license', 'Free to copy and distribute.' ) + #13#10#13#10 +

              'Copyright(c) 2000-2026 terry.' + #13#10 +

              'https://blog.naver.com/terrypark93' + #13#10 +
              'https://github.com/terrypark93' + #13#10 +
              'terrypark93@naver.com',
              mtInformation, [ mbOK ], 0 );

end;

procedure TMain_Form.FormDblClick(Sender: TObject);
begin
  Show_AboutBox;
end;

procedure TMain_Form.WMMoving(var Message: TMessage);
begin
  inherited;
  Config.Ruler_Left := Self.Left;
  Config.Ruler_Top  := Self.Top;

  if FGuideLineDrawed then
  begin
    Draw_GuideLine( FOldPos1, FOldPos2 );
    FGuideLineDrawed := False;
  end;
end;

procedure TMain_Form.PopupMenuPopup(Sender: TObject);
var
  i, Index : Integer;
begin
  Menu_MagneticNone.Checked    := Config.Ruler_MagneticType = mtNone;
  Menu_MagneticWindow.Checked  := Config.Ruler_MagneticType = mtWindow;
  Menu_MagneticControl.Checked := Config.Ruler_MagneticType = mtControl;
  Menu_LanguageKor.Checked := CompareText( Config.App_Language, 'Kor' ) = 0;
  Menu_LanguageEng.Checked := CompareText( Config.App_Language, 'Eng' ) = 0;
  Menu_AlphaBlend.Checked := Config.Ruler_Alphablend;
  Menu_GuideLine.Checked  := Config.Ruler_GuideLine;

  if Config.Ruler_Sero then Menu_Sero.Checked := True
                       else Menu_Garo.Checked := True;

  Index := 16;
  for i := 0 to Length( Colors ) - 1 do
    if Config.Ruler_Color = ColorToString( Colors[ i ] ) then
    begin
      Index := i;
      Break;
    end;

  for i := 0 to Menu_Color.Count - 1 do
    if Menu_Color.Items[ i ].Tag = Index then
    begin
      Menu_Color.Items[ i ].Checked := True;
      Exit;
    end;
end;

procedure TMain_Form.Menu_C1Click(Sender: TObject);
begin
  TMenuItem( Sender ).Checked := True;

  if TComponent(Sender).Tag < 16 then
   begin
     Config.Ruler_Color := ColorToString( Colors[ TComponent( Sender ).Tag ] );
     FColor := Colors[ TComponent( Sender ).Tag ];
     DrawRuler;
   end
  else
   begin
     with TColorDialog.Create( nil ) do
      begin
        Color:= Self.Color;;
        Options:= [cdFullOpen];
        if Execute then
         begin
           Config.Ruler_Color := ColorToString( Color );
           FColor := Color;
           DrawRuler;
         end;
        Free;
      end;
  end;
end;

procedure TMain_Form.Menu_C16DrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
var
  cRect : TRect;
begin
  if Selected then
  begin
    with ACanvas do
    begin
      Brush.Style := bsSolid;
      Brush.Color := $0054B4FF;
      FillRect( ARect );
      if TMenuItem( Sender ).Checked then
      begin
        Pen.Color := clHighLightText;
        Rectangle( ARect );
      end;
      Brush.Color := Colors[ TComponent( Sender ).Tag ];
      cRect := Rect( ARect.Left + 20, ARect.Top + 2, ARect.Right - 2, ARect.Bottom - 2 );
      Rectangle( cRect );
    end;
  end
  else
  begin
    with ACanvas do
    begin
      Brush.Style := bsSolid;
      Brush.Color := $00FFEFE3;
      FillRect( ARect );
      if TMenuItem( Sender ).Checked then
        Rectangle( ARect );
      Brush.Color := Colors[ TComponent( Sender ).Tag ];
      cRect := Rect( ARect.Left + 20, ARect.Top + 2, ARect.Right - 2, ARect.Bottom - 2 );
      Rectangle( cRect );
    end;
  end;
end;

procedure TMain_Form.Menu_CMeasureItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
begin
  Width := 70;
  Height := 15;
end;

procedure TMain_Form.FormShow(Sender: TObject);
begin
  SetBounds( FLeft, FTop, FWidth, FHeight );
  lbSize.Left := Width - lbSize.Width;  
end;

procedure TMain_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( ssShift in Shift ) then
  begin
    case Key of
    VK_LEFT  : Left := Left - 1;
    VK_RIGHT : Left := Left + 1;
    VK_UP    : Top := Top - 1;
    VK_DOWN  : Top := Top + 1;
    end;
  end;
end;

procedure TMain_Form.Show_RulerPoint( APoint : Integer  );
begin
  lbSize.Caption := Format( '%d ', [ APoint ] );
end;

procedure TMain_Form.Menu_ConfigDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
begin
  with ACanvas do
  begin
    if Selected then
    begin
      Brush.Color := $0054B4FF;
      Pen.Color := $004297FB;
      Rectangle( ARect );
    end
    else
    begin
      Brush.Color := $00FFEFE3;
      Pen.Color := $00D99D6F;
      FillRect( ARect );
    end;

    if TMenuItem( Sender ).Caption = '-' then
    begin
      with ACanvas do
      begin
        Pen.Color := clGray;
        MoveTo( ARect.Left + 10, ARect.Top + ( ( ARect.Bottom - ARect.Top) div 2 ) );
        LineTo( ARect.Right - 10, ARect.Top + ( ( ARect.Bottom - ARect.Top) div 2 ) );
      end;
    end
    else
    begin
      if TMenuItem( Sender ).ImageIndex >= 0 then
        ImageList_PopupMenu.Draw( ACanvas, ARect.Left + 2, ARect.Top + 2, TMenuItem( Sender ).ImageIndex )
      else
      begin
        if TMenuItem( Sender ).Checked then
          ImageList_PopupMenu.Draw( ACanvas, ARect.Left + 2, ARect.Top + 2, 10 );
      end;

      TextOut( ARect.Left + 25, ARect.Top + 6, TMenuItem( Sender ).Caption );
    end;
  end;

end;

procedure TMain_Form.Timer1Timer(Sender: TObject);
var
  pt : TPoint;
  MR : TRect;
  Side : Integer;
begin
  if Config.Ruler_MagneticType = mtNone then
  begin
    Timer1.Enabled := False;
    Exit;
  end;

  GetCursorPos( pt );

  if not GetMagneticTargetRect( pt, MR ) then Exit;

  Side := GetMagneticSide( pt, MR );
  if FLastMagneticValid and
     EqualRect( FLastMagneticRect, MR ) and
     ( FLastMagneticSide = Side ) then Exit;

  ApplyMagneticTarget( pt, MR );
  FLastMagneticRect := MR;
  FLastMagneticSide := Side;
  FLastMagneticValid := True;
end;

procedure TMain_Form.Set_MyPos;
var
  pt : TPoint;
  MR : TRect;
begin
  GetCursorPos( pt );

  if GetMagneticTargetRect( pt, MR ) then
    ApplyMagneticTarget( pt, MR );
end;

procedure TMain_Form.ResetMagneticTracking;
begin
  FLastMagneticValid := False;
  FLastMagneticSide := -1;

  if FGuideLineDrawed then
  begin
    Draw_GuideLine( FOldPos1, FOldPos2 );
    FGuideLineDrawed := False;
  end;
end;

function TMain_Form.GetMagneticSide( APoint : TPoint; ARect : TRect ) : Integer;
begin
  case FOrientation of
  otGaro : begin
             if APoint.Y < ( ARect.Top + ( ( ARect.Bottom - ARect.Top ) div 2 ) ) then
               Result := 0
             else
               Result := 1;
           end;
  else
    begin
      if APoint.X < ( ARect.Left + ( ( ARect.Right - ARect.Left ) div 2 ) ) then
        Result := 0
      else
        Result := 1;
    end;
  end;
end;

function TMain_Form.GetVisibleWindowRect( AHandle : THandle; var ARect : TRect ) : Boolean;
var
  Lib : HMODULE;
  DwmGetWindowAttribute : TDwmGetWindowAttribute;
begin
  Result := False;

  Lib := LoadLibrary( 'dwmapi.dll' );
  if Lib <> 0 then
  begin
    try
      @DwmGetWindowAttribute := GetProcAddress( Lib, 'DwmGetWindowAttribute' );
      if Assigned( DwmGetWindowAttribute ) then
        Result := DwmGetWindowAttribute( AHandle, DWMWA_EXTENDED_FRAME_BOUNDS,
          @ARect, SizeOf( ARect ) ) = S_OK;
    finally
      FreeLibrary( Lib );
    end;
  end;

  if not Result then
    Result := GetWindowRect( AHandle, ARect );
end;

function TMain_Form.GetMagneticTargetRect( APoint : TPoint; var ARect : TRect ) : Boolean;
var
  H : THandle;
  TargetProcessId : DWORD;
  ClassName : array[0..31] of Char;
begin
  Result := False;

  if Config.Ruler_MagneticType = mtNone then Exit;

  H := WindowFromPoint( APoint );
  if H = 0 then Exit;

  if ( H = Handle ) or IsChild( Handle, H ) then Exit;

  if Config.Ruler_MagneticType = mtWindow then
    H := GetAncestor( H, GA_ROOT );

  if ( H = 0 ) or ( H = Handle ) or ( H = GetDesktopWindow ) then Exit;
  if GetClassName( H, ClassName, Length( ClassName ) ) > 0 then
    if String( ClassName ) = '#32768' then Exit;

  TargetProcessId := 0;
  GetWindowThreadProcessId( H, TargetProcessId );
  if TargetProcessId = GetCurrentProcessId then Exit;

  if not IsWindowVisible( H ) then Exit;

  if Config.Ruler_MagneticType = mtWindow then
    Result := GetVisibleWindowRect( H, ARect )
  else
    Result := GetWindowRect( H, ARect );
end;

procedure TMain_Form.ApplyMagneticTarget( APoint : TPoint; ARect : TRect );
var
  TargetWidth, TargetHeight : Integer;
  RulerWidth, RulerHeight : Integer;
  Side : Integer;
begin
  TargetWidth  := ARect.Right - ARect.Left;
  TargetHeight := ARect.Bottom - ARect.Top;

  if ( TargetWidth <= 0 ) or ( TargetHeight <= 0 ) then Exit;
  Side := GetMagneticSide( APoint, ARect );

  if FGuideLineDrawed then
  begin
    Draw_GuideLine( FOldPos1, FOldPos2 );
    FGuideLineDrawed := False;
  end;

  case FOrientation of
  otGaro : begin
             FMeasureValue := TargetWidth;
             RulerWidth := FStartMargin + TargetWidth + 1;
             if RulerWidth < 80 then
               RulerWidth := 80;

             if Side = 0 then
               SetBounds( ARect.Left - FStartMargin, ARect.Top - Height, RulerWidth, Height )
             else
               SetBounds( ARect.Left - FStartMargin, ARect.Bottom, RulerWidth, Height );

             lbSize.Left := Width - lbSize.Width;
             DrawRuler( FMeasureValue );

             if Config.Ruler_GuideLine then
             begin
               FOldOrientation := FOrientation;
               Draw_GuideLine( ARect.Left, ARect.Right );
               FGuideLineDrawed := True;
               FOldPos1 := ARect.Left;
               FOldPos2 := ARect.Right;
             end;
           end;
  otSero : begin
             FMeasureValue := TargetHeight;
             RulerHeight := FStartMargin + TargetHeight + 1;
             if RulerHeight < 80 then
               RulerHeight := 80;

             if Side = 0 then
               SetBounds( ARect.Left - Width, ARect.Top - FStartMargin, Width, RulerHeight )
             else
               SetBounds( ARect.Right, ARect.Top - FStartMargin, Width, RulerHeight );

             lbSize.Left := Width - lbSize.Width;
             DrawRuler( FMeasureValue );

             if Config.Ruler_GuideLine then
             begin
               FOldOrientation := FOrientation;
               Draw_GuideLine( ARect.Top, ARect.Bottom );
               FGuideLineDrawed := True;
               FOldPos1 := ARect.Top;
               FOldPos2 := ARect.Bottom;
             end;
           end;
  end;
end;

procedure TMain_Form.Register_HotKey;
begin
  if not RegisterHotkey( Handle, 1, MOD_CONTROL, VK_MAGNETIC) Then
     ShowMessage('Unable to assign Ctrl-` as hotkey.') ;
end;

procedure TMain_Form.UnRegister_HotKey;
begin
  UnregisterHotKey( Handle, 1 );
end;


procedure TMain_Form.WMHotkey(var msg: TWMHotkey);
begin
  case msg.HotKey of
  1 : Set_MyPos;
  end;

end;

procedure TMain_Form.Draw_GuideLine(APos1, APos2: Integer);
var
  DC : HDC;
  C : TCanvas;
begin
  DC := GetDC( 0 );
  C := TCanvas.Create;
  try
    C.Handle := DC;
    with C do
    begin
      Pen.Mode := pmNotXor;
      Pen.Width := 1;

      case FOldOrientation of
      otGaro : begin
                 MoveTo( APos1, 0 );
                 LineTo( APos1, Screen.DesktopHeight );

                 MoveTo( APos2, 0 );
                 LineTo( APos2, Screen.DesktopHeight );
               end;
      otSero : begin
                 MoveTo( 0, APos1 );
                 LineTo( Screen.DesktopWidth, APos1 );

                 MoveTo( 0, APos2 );
                 LineTo( Screen.DesktopWidth, APos2 );
               end;
      end;
    end;
  finally
    C.Free;
  end;

  ReleaseDC( 0, DC );
end;

end.

