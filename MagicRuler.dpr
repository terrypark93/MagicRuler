program MagicRuler;

uses
  Forms,
  Main_Frm in 'Main_Frm.pas' {Main_Form},
  Config_Frm in 'Config_Frm.pas' {Config_Form},
  Lang_Unit in 'Lang_Unit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Magic Ruler';
  Application.CreateForm(TMain_Form, Main_Form);
  Application.Run;
end.
