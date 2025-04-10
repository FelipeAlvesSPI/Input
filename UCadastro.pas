unit UCadastro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask,
  Vcl.DBCtrls, IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient, IdTimeUDP,
  System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope;

type
  TFCadastro = class(TForm)
    PCadastro: TPanel;
    LCID: TLabel;
    LCNome: TLabel;
    ENome: TEdit;
    EId: TEdit;
    PPCButton: TPanel;
    BCCancelar: TButton;
    BCSalvar: TButton;
    procedure BCSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BCCancelarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCadastro: TFCadastro;

implementation

{$R *.dfm}

uses UDm, UPrincipal;

procedure TFCadastro.BCCancelarClick(Sender: TObject);
begin
  FCadastro.close;
  FCadastro.Position := poScreenCenter;
  FCadastro.Tag := 0;
  ENome.Text := '';
  EId.Text := '';
  FCadastro.Caption := 'Cadastro';
end;

procedure TFCadastro.BCSalvarClick(Sender: TObject);
var
nome :string;
id :string;

const
MinLength = 9;
begin

  //FPrincipal.EPesquisar.SetFocus;

  if Length(EId.Text) < MinLength  then
    MessageDlg('INFORME PELOS MENOS 9 NÚMEROS!', mtInformation, [mbok], 0)
  else
  begin
    if not (dm.FDQueryid_maquina.AsString = '') then
    begin
      nome := FPrincipal.DBGrid.Fields[1].Value;
      id := FPrincipal.DBGrid.Fields[0].Value;
    end;

    if FCadastro.Tag = 1 then
    begin
      if EId.Text <> id  then
      begin
        id := EId.Text;

        dm.FDQuery.SQL.Clear;
        dm.FDQuery.SQL.Add('update tbregistros set id_maquina = :id_maquina where nome = :nome');
        dm.fdquery.ParamByName('id_maquina').AsString := id;
        dm.fdquery.ParamByName('nome').AsString := nome;
        Dm.FDQuery.ExecSQL;
        FCadastro.Tag := 0;
      end;

      if ENome.Text <> nome  then
      begin
        nome := ENome.Text;

        dm.FDQuery.SQL.Clear;
        dm.FDQuery.SQL.Add('update tbregistros set nome = :nome where id_maquina = :id_maquina');
        dm.fdquery.ParamByName('id_maquina').AsString := id;
        dm.fdquery.ParamByName('nome').AsString := nome;
        Dm.FDQuery.ExecSQL;
        FCadastro.Tag := 0;
      end;


      FCadastro.Close;
      FPrincipal.EPesquisar.SetFocus;
      dm.FDQuery.close;
      dm.FDQuery.SQL.Clear;
      dm.FDQuery.SQL.Add('select * from tbregistros order by nome');
      dm.FDQuery.open;



      FPrincipal.DBGrid.DataSource := nil;
      FPrincipal.DBGrid.DataSource := dm.DataSource;
      FPrincipal.DBGrid.Refresh;


      ENome.Text := '';
      EId.Text := '';
      FCadastro.Caption := 'Cadastro';
      FPrincipal.BAlterar.Visible := true;
      FPrincipal.BExcluir.Visible := true;

    end
    else
    begin

      nome := ENome.Text;
      id := EId.Text;

      dm.FDQuery.SQL.Clear;
      dm.FDQuery.SQL.Add('select * from tbregistros where id_maquina like ' + QuotedStr(EId.Text+'%'));
      dm.FDQuery.Active := true;

      if (EId.Text = '') and (ENome.Text = '') then
       ShowMessage('Informe os campos!')
      else
      begin
        if dm.FDQueryid_maquina.AsString = EId.Text then
        begin
          ShowMessage('Esse ID já está cadastrado!');
          EId.Text := '';
          EId.SetFocus;
          dm.FDQuery.SQL.Clear;
          dm.FDQuery.SQL.Add('select * from tbregistros order by nome');
          dm.FDQuery.Active := true;
        end
        else
        begin
          if EId.Text = '' then
            ShowMessage('Informe o ID da maquina!')
          else
          if ENome.Text = '' then
           ShowMessage('Informe o NOME!')
          else
          begin
            dm.FDQuery.Active := true;
            Dm.FDQuery.SQL.Clear;
            dm.FDQuery.SQL.Add('insert into tbregistros values (:id_maquina, :nome)');
            dm.FDQuery.ParamByName('id_maquina').AsString := Id;
            dm.FDQuery.ParamByName('nome').AsString := nome;
            dm.FDQuery.ExecSQL;

            FCadastro.Tag := 1;

            ENome.Text := '';
            EId.Text := '';
            FCadastro.close;
            FPrincipal.EPesquisar.SetFocus;
            dm.FDQuery.close;
            dm.FDQuery.SQL.Clear;
            dm.FDQuery.SQL.Add('select * from tbregistros order by nome');
            dm.FDQuery.open;



            FPrincipal.DBGrid.DataSource := nil;
            FPrincipal.DBGrid.DataSource := dm.DataSource;
            FPrincipal.DBGrid.Refresh;
            FPrincipal.BAlterar.Visible := true;
            FPrincipal.BExcluir.Visible := true;

            FPrincipal.SetFocus;

            FPrincipal.EPesquisarChange(Sender);
          end;
        end;
      end;
    end;
  end;
   FCadastro.Position := poScreenCenter;
end;

procedure TFCadastro.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_F2 then
    BCSalvarClick(sender);

  if key = VK_ESCAPE then
  BCCancelarClick(sender);
end;

procedure TFCadastro.FormShow(Sender: TObject);
begin
  EId.SetFocus;
end;

end.
