unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Clipbrd, Vcl.StdCtrls, Data.DB, Data.Win.ADODB,
  Vcl.ExtCtrls, Vcl.Menus, Vcl.DBCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    ADOConnection1: TADOConnection;
    Image1: TImage;
    ADOTable1: TADOTable;
    PM1: TPopupMenu;
    TrayIcon1: TTrayIcon;
    DataSource1: TDataSource;
    DBMemo1: TDBMemo;
    DBImage1: TDBImage;
    DataSource2: TDataSource;
    ADOTable2: TADOTable;
    procedure FormActivate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
    procedure D1Click(Sender: TObject);
  private
    FNextViewer:HWnd;
    { Private declarations }
    procedure OnHotKey(var Msg: TWMHotKey); message WM_HOTKEY; //deprecated
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.OnHotKey(var Msg: TWMHotKey);//deprecated
var
s:string;
begin
//memo1.Lines.Add(Clipboard.AsText);
end;

procedure TForm1.WMDrawClipboard(var Msg: TWMDrawClipboard);
var
k1, k2:Integer;
s:String;
begin
if form1.Tag=2 then
begin
SendMessage(FNextViewer, WM_DRAWCLIPBOARD, 0, 0);
 Msg.Result:=0;
 k2:=ADOTable1.RecordCount+ADOTable2.RecordCount+1;
 try
 if Clipboard.HasFormat(CF_BITMAP) then
  begin
   k1:=ADOTable2.RecordCount+1;
   ADOTable2.Edit;
   Image1.Picture.Bitmap.Assign(Clipboard);
   pm1.Items.Insert(0,NewItem('��������', 0, False, True, N1Click, 0, 'N'+inttostr(k2)));
//   pm1.Items.Add(NewItem('��������', 0, False, True, N1Click, 0, 'N1'));
//   pm1.Items.Items[pm1.Items.Count-1].Bitmap:=Image1.Picture.Bitmap;
   pm1.Items.Items[0].Bitmap:=Image1.Picture.Bitmap;
   ADOTable2.AppendRecord([k1, k2, Image1.Picture.Bitmap]);
   TrayIcon1.Hint:='������:"��������" ���������. �����:'+timetostr(now());
  end
   else
   if ClipBoard.AsText<>'' then
     begin
       k1:=ADOTable1.RecordCount+1;
       ADOTable1.Edit;
       memo1.Lines.Add(ClipBoard.AsText);
       if length(ClipBoard.AsText)>20 then s:=copy(ClipBoard.AsText,1,18)+'...'
        else s:=ClipBoard.AsText;
    //   pm1.Items.Add(NewItem(s, 0, False, True, N1Click, 0, 'N1'));
       pm1.Items.Insert(0,NewItem(s, 0, False, True, N1Click, 0, 'N'+inttostr(k2)));
       ADOTable1.AppendRecord([k1, k2, ClipBoard.AsText]);
       TrayIcon1.Hint:='������:"'+s+'" ���������. �����:'+timetostr(now());
     end;
 if pm1.Items.Count>30 then pm1.Items.Delete(pm1.Items.Count-3);
 except
 TrayIcon1.Hint:='�������� ������ ��� ���������� ������ ������. �����:'+timetostr(now());
 form1.Caption:='������';
 end;
end;
form1.Tag:=2;
end;

procedure TForm1.N1Click(Sender: TObject);
var
i, j:Integer;
  nom, s:string;
begin
form1.Caption:=TPopupMenu(Sender).Name;
nom:=TPopupMenu(Sender).Name;
delete(nom,1,1);
AdoTable1.First;
Adotable2.First;
try
if AdoTable1.Locate('key_all',nom,[loCaseInsensitive]) then
 begin
  form1.Tag:=1;
  Clipboard.AsText:=dbMemo1.Text;
  if length(dbmemo1.Text)>20 then s:=copy(dbmemo1.Text,1,18)+'...'
   else s:=dbmemo1.Text;
  TrayIcon1.Hint:='������:"'+s+'" ����������� � ����� ������. �����:'+timetostr(now());
 end
  else
  if AdoTable2.Locate('key_all',nom,[loCaseInsensitive]) then
   begin
    form1.Tag:=1;
    Clipboard.Assign(dbImage1.Picture.Bitmap);
    TrayIcon1.Hint:='������:"��������" ����������� � ����� ������. �����:'+timetostr(now());
   end
except
TrayIcon1.Hint:='��� ����������� ������:"'+nom+'" � ����� ������ �������� ������. �����:'+timetostr(now());
form1.Caption:='error';
end;
end;


procedure TForm1.D1Click(Sender: TObject);
begin
ADOTable1.Active:=false;
ADOTable2.Active:=false;
ADOConnection1.Connected:=false;
form1.Close;
end;

procedure TForm1.FormActivate(Sender: TObject);
var
i, f1, f2:Integer;
s:String;
begin
ShowWindow(Handle,SW_HIDE);
form1.Tag:=1;
f1:=0;
f2:=0;
ADOConnection1.Connected:=true;
AdoTable1.Active:=true;
ADOTable1.Last;
ADOTable2.Active:=true;
ADOTable2.Last;
FnextViewer:=SetClipboardViewer(Handle);
if ADOTable1.FieldByName('key_all').AsInteger>ADOTable2.FieldByName('key_all').AsInteger then
 begin
   if ADOTable2.RecNo=-1 then f2:=1;
   if ADOTable1.RecNo>0 then
       begin
         if length(dbmemo1.Text)>20 then s:=copy(dbmemo1.Text,1,18)+'...'
          else s:=dbmemo1.Text;
         pm1.Items.Add(NewItem(s, 0, False, True, N1Click, 0, 'N'+ADOTable1.FieldByName('key_all').AsString));
         try
          ADOTable1.Prior;
         except
          f1:=1;
         end;
       end
     else f1:=1;
 end
  else
    begin
     if ADOTable1.RecNo=-1 then f1:=1;
     if ADOTable2.RecNo>0 then
       begin
         pm1.Items.Add(NewItem('��������', 0, False, True, N1Click, 0, 'N'+ADOTable2.FieldByName('key_all').AsString));
         pm1.Items.Items[pm1.Items.Count-1].Bitmap:=dbImage1.Picture.Bitmap;
         try
          ADOTable2.Prior;
         except
          f2:=1;
         end;
       end
        else f2:=1;
    end;
i:=1;
while (i<31) and ((f1=0) or (f2=0)) do
 begin
  if ADOTable1.FieldByName('key_all').AsInteger>ADOTable2.FieldByName('key_all').AsInteger then
   begin
   if f1=0 then
    begin
     if length(dbmemo1.Text)>20 then s:=copy(dbmemo1.Text,1,18)+'...'
      else s:=dbmemo1.Text;
     pm1.Items.Add(NewItem(s, 0, False, True, N1Click, 0, 'N'+ADOTable1.FieldByName('key_all').AsString));
     if ADOTable1.RecNo>1 then ADOTable1.Prior else f1:=1;
    end
     else
     if f2=0 then
      begin
       pm1.Items.Add(NewItem('��������', 0, False, True, N1Click, 0, 'N'+ADOTable2.FieldByName('key_all').AsString));
       pm1.Items.Items[pm1.Items.Count-1].Bitmap:=dbImage1.Picture.Bitmap;
       if ADOTable2.RecNo>1 then ADOTable2.Prior else f2:=1;
      end
       else break;
   end
  else
   begin
     if f2=0 then
      begin
       pm1.Items.Add(NewItem('��������', 0, False, True, N1Click, 0, 'N'+ADOTable2.FieldByName('key_all').AsString));
       pm1.Items.Items[pm1.Items.Count-1].Bitmap:=dbImage1.Picture.Bitmap;
       if ADOTable2.RecNo>1 then ADOTable2.Prior else f2:=1;
      end
      else
       if f1=0 then
        begin
         if length(dbmemo1.Text)>20 then s:=copy(dbmemo1.Text,1,18)+'...'
          else s:=dbmemo1.Text;
         pm1.Items.Add(NewItem(s, 0, False, True, N1Click, 0, 'N'+ADOTable1.FieldByName('key_all').AsString));
         if ADOTable1.RecNo>1 then ADOTable1.Prior else f1:=1;
        end
         else break;
   end;
  i:=i+1;
 end;
pm1.Items.add(NewLine);
pm1.Items.Add(NewItem('�����', 0, False, True, D1Click, 0, 'D1'));
pm1.Items.Items[pm1.Items.Count-1].Default:=true;
//RegisterHotKey(Handle, Ord('C'), MOD_CONTROL, Ord('C')); //deprecated
end;

end.
