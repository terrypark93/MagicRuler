unit Lang_Unit;

interface

uses
  SysUtils, Classes;

type
  TLangManager = class
  private
    FValues : TStringList;
    FLanguage : string;
    function GetLangFileName( const ALanguage : string ) : string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load( const ALanguage : string );
    function Text( const AKey, ADefault : string ) : string;
    property Language : string read FLanguage;
  end;

var
  Lang : TLangManager;

implementation

{ TLangManager }

constructor TLangManager.Create;
begin
  inherited Create;
  FValues := TStringList.Create;
  FValues.NameValueSeparator := '=';
  FValues.CaseSensitive := False;
  FLanguage := 'Kor';
end;

destructor TLangManager.Destroy;
begin
  FValues.Free;
  inherited Destroy;
end;

function TLangManager.GetLangFileName(const ALanguage: string): string;
begin
  Result := IncludeTrailingPathDelimiter( ExtractFilePath( ParamStr( 0 ) ) ) +
    ALanguage + '.lang';
end;

procedure TLangManager.Load(const ALanguage: string);
var
  FileName : string;
begin
  FLanguage := ALanguage;
  FileName := GetLangFileName( FLanguage );

  FValues.Clear;
  if FileExists( FileName ) then
    FValues.LoadFromFile( FileName, TEncoding.UTF8 );
end;

function TLangManager.Text(const AKey, ADefault: string): string;
begin
  Result := FValues.Values[ AKey ];
  if Result = '' then
    Result := ADefault;
end;

initialization
  Lang := TLangManager.Create;

finalization
  Lang.Free;

end.
