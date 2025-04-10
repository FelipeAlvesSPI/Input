unit UPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls, System.ImageList,
  Vcl.ImgList,ShellAPI, System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors,
  Data.Bind.EngExt, Vcl.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, System.NetEncoding,
  Vcl.Imaging.pngimage;

type
  TFPrincipal = class(TForm)
    DBGrid: TDBGrid;
    PPPesquisar: TPanel;
    EPesquisar: TEdit;
    BAdicionar: TButton;
    PPButton: TPanel;
    BExcluir: TButton;
    BAlterar: TButton;
    BConectar: TButton;
    lab: TLabel;
    procedure BAdicionarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EPesquisarChange(Sender: TObject);
    procedure BAlterarClick(Sender: TObject);
    procedure BConectarClick(Sender: TObject);
    procedure BExcluirClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.dfm}

uses UDm, UCadastro, UConfg;

procedure TFPrincipal.BAdicionarClick(Sender: TObject);
begin
  FCadastro.Show;
  FCadastro.Tag := 0;
  FCadastro.ENome.Text := '';
  FCadastro.Eid.Text := '';
end;

procedure TFPrincipal.BAlterarClick(Sender: TObject);
begin
  FCadastro.Tag := 1;
  FCadastro.Show;
  FCadastro.Caption := 'Alteração';

  FCadastro.EId.Text := DBGrid.Fields[0].Value;
  FCadastro.ENome.Text := DBGrid.Fields[1].Value;

end;

procedure TFPrincipal.BConectarClick(Sender: TObject);
begin
  Shellexecute(handle,'open',PChar('C:\Program Files (x86)\AnyDesk\AnyDesk.exe '),pchar(Dm.FDQueryid_maquina.AsString),'', SW_SHOWNORMAL);
end;

procedure TFPrincipal.BExcluirClick(Sender: TObject);
var
 id_maquina :string;
 nome :string;
begin
  nome := DBGrid.Fields[1].Value;
  if MessageDlg('QUER DELETAR O USUÁRIO '+nome, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    id_maquina := DBGrid.Fields[0].Value;

    dm.FDQuery.SQL.Clear;
    dm.FDQuery.SQL.Add('delete from tbregistros where id_maquina =:id_maquina');
    dm.FDQuery.ParamByName('id_maquina').AsString := id_maquina ;
    dm.FDQuery.ExecSQL;

    dm.FDQuery.close;
    dm.FDQuery.SQL.Clear;
    dm.FDQuery.SQL.Add('select * from tbregistros order by nome');
    dm.FDQuery.open;

    DBGrid.DataSource := nil;
    DBGrid.DataSource := dm.DataSource;
    DBGrid.Refresh;

    if Dm.FDQueryid_maquina.AsString = '' then
    begin
      BAlterar.Visible := false;
      BExcluir.Visible := false;
    end;
  end;
end;

procedure TFPrincipal.EPesquisarChange(Sender: TObject);
begin
   if EPesquisar.Text = '' then
  begin
    dm.FDQuery.Close;
    dm.FDQuery.SQL.Clear;
    dm.FDQuery.SQL.Add('select * from tbregistros order by nome');
    dm.FDQuery.open;

    if Dm.FDQueryid_maquina.AsString = '' then
    begin
      BAlterar.Visible := false;
      BExcluir.Visible := false;
    end;
  end
  else
  begin
  dm.FDQuery.Close;
  dm.FDQuery.SQL.Clear;
  dm.FDQuery.SQL.Add('select * from tbregistros where nome like ' + QuotedStr(EPesquisar.Text+'%'));
  dm.FDQuery.open;



      DBGrid.DataSource := nil;
      DBGrid.DataSource := dm.DataSource;
      DBGrid.Refresh;
  end;
end;

procedure TFPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if BAlterar.Visible = true then
  begin
    if key = VK_F4 then
      BExcluirClick(sender);

    if key = VK_F3 then
      BAlterarClick(sender);
  end;

  if key = VK_F2 then
    BAdicionarClick(sender);

  if key = VK_RETURN then
    BConectarClick(sender);

end;

procedure TFPrincipal.FormShow(Sender: TObject);
begin

    EPesquisar.SetFocus;

    dm.DataSource.DataSet.Refresh;

    if Dm.FDQueryid_maquina.AsString = '' then
    begin
      BAlterar.Visible := false;
      BExcluir.Visible := false;
    end;
end;

procedure TFPrincipal.Image1Click(Sender: TObject);
begin
  FConfig.Show;
end;

end.
