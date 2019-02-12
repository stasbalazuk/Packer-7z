program Packer7z;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}
{$R UAC.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
