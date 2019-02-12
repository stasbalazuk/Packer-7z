unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  IniFiles,
  DateUtils,
  XPMan,
  ShellAPI,
  ShlObj,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    grp1: TGroupBox;
    d_Memo_Info: TMemo;
    pb1: TProgressBar;
    grp2: TGroupBox;
    d_Shape_Led: TShape;
    Shape1: TShape;
    lbl1: TLabel;
    d_Lbl_Info: TLabel;
    btn1: TButton;
    btn3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    function LedSwich: boolean;
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
  public
    { Public declarations }
  end;

type
   TSettingIni = record
      sMask: string;
      sPathDir1: string;
      sPathDir2: string;
      sExtrDir7z: string;
      sPassword: string;
    end;

const
   Mes: array[1..12] of string = ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12');    

var
  Form1: TForm1;
  rset : TSettingIni;
  FileHandle: Integer;
  FileName,vr: string;
  Year, Month, Day: Word;

implementation

{$R *.dfm}
{$R sts.RES}

//Правильный выход с программы при перезагрузке Винды
procedure TForm1.WMQueryEndSession(var Message: TMessage);
begin
  Message.Result := 1;
  Application.Terminate;
end;

//Самоликвидация
function SelfDelete:boolean;
var
     ppri:DWORD;
     tpri:Integer;
     sei:SHELLEXECUTEINFO;
     szModule, szComspec, szParams: array[0..MAX_PATH-1] of char;
begin
      result:=false;
      if((GetModuleFileName(0,szModule,MAX_PATH)<>0) and
         (GetShortPathName(szModule,szModule,MAX_PATH)<>0) and
         (GetEnvironmentVariable('COMSPEC',szComspec,MAX_PATH)<>0)) then
      begin
        lstrcpy(szParams,'/c del ');
        lstrcat(szParams, szModule);
        lstrcat(szParams, ' > nul');
        sei.cbSize       := sizeof(sei);
        sei.Wnd          := 0;
        sei.lpVerb       := 'Open';
        sei.lpFile       := szComspec;
        sei.lpParameters := szParams;
        sei.lpDirectory  := nil;
        sei.nShow        := SW_HIDE;
        sei.fMask        := SEE_MASK_NOCLOSEPROCESS;
        ppri:=GetPriorityClass(GetCurrentProcess);
        tpri:=GetThreadPriority(GetCurrentThread);
        SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
        SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
        try
          if ShellExecuteEx(@sei) then
          begin
            SetPriorityClass(sei.hProcess,IDLE_PRIORITY_CLASS);
            SetProcessPriorityBoost(sei.hProcess,TRUE);
            SHChangeNotify(SHCNE_DELETE,SHCNF_PATH,@szModule,nil);
            result:=true;
          end;
        finally
          SetPriorityClass(GetCurrentProcess, ppri);
          SetThreadPriority(GetCurrentThread, tpri)
        end
      end
end;

Procedure IniFileProc;
Var
  Ini : TIniFile;
Begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+'settings.ini');
  Ini.WriteString('EXT','MASK','*.*');
  Ini.WriteString('Path','IN',ExtractFilePath(ParamStr(0))+'IN');
  Ini.WriteString('Path','OUT',ExtractFilePath(ParamStr(0))+'OUT');
  //Ini.WriteString('Path','EXP',ExtractFilePath(ParamStr(0))+'EXPORT');
  Ini.WriteString('Pass','Password','');
  Ini.Free;
end;
          
Procedure IniFileLoad;
var
   Ini : TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+'settings.ini');
  rset.sMask:=Ini.ReadString('EXT','MASK','');
  rset.sPathDir1:=Ini.ReadString('Path','IN','');
  rset.sPathDir2:=Ini.ReadString('Path','OUT','');
  //rset.sExtrDir7z:=Ini.ReadString('Path','EXP','');
  rset.sPassword:=Ini.ReadString('Pass','Password','');
  Ini.Free;
  if not DirectoryExists(rset.sPathDir1) then ForceDirectories(rset.sPathDir1);
  if not DirectoryExists(rset.sPathDir2) then ForceDirectories(rset.sPathDir2);
end;

procedure CreateFormInRightBottomCorner;
var
 r : TRect;
begin
 SystemParametersInfo(SPI_GETWORKAREA, 0, Addr(r), 0);
 Form1.Left := r.Right-Form1.Width;
 Form1.Top := r.Bottom-Form1.Height;
end;

//Защита от отладчика
function DebuggerPresent:boolean;
type
  TDebugProc = function:boolean; stdcall;
var
   Kernel32:HMODULE;
   DebugProc:TDebugProc;
begin
   Result:=false;
   Kernel32:=GetModuleHandle('kernel32.dll');
   if kernel32 <> 0 then
    begin
      @DebugProc:=GetProcAddress(kernel32, 'IsDebuggerPresent');
      if Assigned(DebugProc) then
         Result:=DebugProc;
    end;                                  
end;

//Узнать свою версию
function GetFileVersion(FileName: string; var VerInfo : TVSFixedFileInfo): boolean;
var
  InfoSize, puLen: DWORD;
  Pt, InfoPtr: Pointer;
begin
  InfoSize := GetFileVersionInfoSize( PChar(FileName), puLen );
  FillChar(VerInfo, SizeOf(TVSFixedFileInfo), 0);
  if InfoSize > 0 then
  begin
    GetMem(Pt,InfoSize);
    GetFileVersionInfo( PChar(FileName), 0, InfoSize, Pt);
    VerQueryValue(Pt,'\',InfoPtr,puLen);
    Move(InfoPtr^, VerInfo, sizeof(TVSFixedFileInfo) );
    FreeMem(Pt);
    Result := True;
  end
  else
    Result := False;
end;

function ShowVersion(FileName:string):string;
var
  VerInfo : TVSFixedFileInfo;
begin
  if GetFileVersion(FileName, VerInfo) then
    Result:=Format('%u.%u.%u.%u',[HiWord(VerInfo.dwProductVersionMS), LoWord(VerInfo.dwProductVersionMS),
      HiWord(VerInfo.dwProductVersionLS), LoWord(VerInfo.dwProductVersionLS)])
  else
    Result:='------';
end;

function SplitStr(s: string): string;
begin
   Result:= s;
   if s = '' then Exit;
   if s[Length(s)]<>'\' then Result:= s+'\';
end;

function StrTime: string;
begin
   Result:= TimeToStr(GetTime) +'  ';
end;

//ПОСЧИТАТЬ КОЛИЧЕСТВО ФАЙЛОВ В ПАПКЕ//
function CountFiles(const ADirectory: String): Integer;
var
   Rec : TSearchRec;
   sts : Integer ;
   TMP : TStringList;
begin
   Result := 0;
   TMP := TStringList.Create;
   sts := FindFirst(ADirectory + '\*.*', faAnyFile, Rec);
   if sts = 0 then begin
       repeat
         if ((Rec.Attr and faDirectory) <> faDirectory) then begin
            TMP.Add(ADirectory + '\'+ Rec.Name);
            Inc(Result);
         end else
         if (Rec.Name <> '.') and (Rec.Name <> '..') then
            Result := Result + CountFiles(ADirectory + '\'+ Rec.Name);
       until FindNext(Rec) <> 0;
       SysUtils.FindClose(Rec);
   end;
   //TMP.SaveToFile(ExtractFilePath(ParamStr(0))+'logfile.log');
   Form1.d_Memo_Info.Lines.Add(StrTime + 'Количество файлов в директории: '+ADirectory+' -> '+IntToStr(Result));
   TMP.Free;
end;

function TForm1.LedSwich: boolean;
begin
   if DirectoryExists(rset.sPathDir1)
   then begin
         d_Lbl_Info.Font.Color:= clGreen;
         d_Lbl_Info.Caption:= 'Связь с сервером - ОК';
         d_Shape_Led.Brush.Color:= clLime;
         d_Shape_Led.Pen.Color:= clGreen;
         Result:= True;
   end else begin
         d_Lbl_Info.Font.Color:= clRed;
         d_Lbl_Info.Caption:= 'Нет связи с сервером';
         d_Shape_Led.Brush.Color:= clRed;
         d_Shape_Led.Pen.Color:= clMaroon;
         Result:= False;
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  //Load RES
  ms : TMemoryStream;
  rs : TResourceStream;
  m_DllDataSize : integer;
  mp_DllData : Pointer;
begin
if not FileExists(ExtractFilePath(ParamStr(0))+'7za.exe') then begin
  if 0 <> FindResource(hInstance, 'sts', 'exe') then
   begin
    rs := TResourceStream.Create(hInstance, 'sts', 'exe');
    ms := TMemoryStream.Create;
    try
      ms.LoadFromStream(rs);
      ms.Position := 0;
      m_DllDataSize := ms.Size;
      mp_DllData := GetMemory(m_DllDataSize);
      ms.Read(mp_DllData^, m_DllDataSize);
      ms.SaveToFile(pchar(ExtractFilePath(ParamStr(0))+'7za.exe'));
    finally
      ms.Free;
      rs.Free;
    end;
   end;
end;
if FileExists(ExtractFilePath(ParamStr(0))+'settings.ini') then IniFileLoad
else IniFileProc;
if LedSwich then
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  d,m,y,s,path: string;
  TMP: TStringList;
Begin
  pb1.Position:=0;
  btn1.Enabled:=False;
  TMP:= TStringList.Create;
  DecodeDate(Now,Year,Month,Day);
  d := IntToStr(day);
  m := Mes[Month];
  y := IntToStr(Year);
  s:=d+m+y+'.zip';
  if DirectoryExists(rset.sPathDir1) then
     CountFiles(rset.sPathDir1);
     pb1.Position:=30;
  if DirectoryExists(rset.sPathDir2) then begin
  if not DirectoryExists(rset.sPathDir2+'\'+d+m+y) then ForceDirectories(rset.sPathDir2+'\'+d+m+y);
  if DirectoryExists(rset.sPathDir2+'\'+d+m+y) then
  if rset.sPassword = '' then
     path:='a -tzip '+rset.sPathDir2+'\'+d+m+y+'\'+s+' '+rset.sPathDir1+'\'+rset.sMask
  else
     path:='a -tzip -p'+rset.sPassword+' '+rset.sPathDir2+'\'+d+m+y+'\'+s+' '+rset.sPathDir1+'\'+rset.sMask;
  end;
     pb1.Position:=70;
     TMP.Add(path);
  if DirectoryExists(rset.sPathDir2+'\'+d+m+y) then
     ShellExecute(Handle,'open',PChar(ExtractFilePath(ParamStr(0))+'7za.exe'),PChar(path),PChar(ExtractFilePath(ParamStr(0))),SW_SHOWNORMAL);
     //TMP.SaveToFile('tst.txt');
     TMP.Free;
     pb1.Position:=100;
     btn1.Enabled:=True;
end;

procedure TForm1.btn3Click(Sender: TObject);
begin
btn3.Enabled:=False;
if FileExists(ExtractFilePath(ParamStr(0))+'settings.ini') then IniFileLoad
else IniFileProc;
if LedSwich then
btn3.Enabled:=True;
end;

end.
