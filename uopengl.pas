unit uOpenGL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, OpenGLContext, gl, glu;

type

  { TForm1 }

  TFPoint = record
    X,Y:real;
  end;


  TForm1 = class(TForm)
    chDrawChart: TCheckBox;
    edDataStep: TEdit;
    edFreq: TEdit;
    edDataVol: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OpenGLControl1: TOpenGLControl;
    Panel1: TPanel;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    function calcSignal(phi:real; freq:real):real;
    procedure edDataVolChange(Sender: TObject);
    procedure edFreqChange(Sender: TObject);
    procedure getSettings;
    procedure calcDataSet;
    procedure FormCreate(Sender: TObject);
    procedure OpenGLControl1Paint(Sender: TObject);
    procedure OpenGLControl1Resize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  currW, currH:integer;
  kw, kh: real;
  rotSpeed:real=0;
  rotAngle:real = 0;
  dVol:integer=10;
  dFreq:real=10;
  dStep:real=10;
  dataSet:array of TFPoint;


implementation

{$R *.lfm}

{ TForm1 }

function TForm1.calcSignal(phi:real; freq:real):real;
begin
  result:=sin(freq*phi*Pi/180);
end;

procedure TForm1.edDataVolChange(Sender: TObject);
begin
    getSettings;
end;

procedure TForm1.edFreqChange(Sender: TObject);
begin
  getSettings;
end;

procedure TForm1.getSettings;
begin
  dFreq:=10;
  dVol:=10;
  TryStrToFloat(edFreq.Text,dFreq);
  TryStrToInt(edDataVol.Text,dVol);
  TryStrToFloat(edDataStep.Text,dStep);
end;

procedure TForm1.calcDataSet;
var dPhi:real;
    i:integer;
begin
  SetLength(dataSet,dVol);
  dPhi:=dStep/dVol;
  for i:=0 to dVol-1 do
  begin
    dataSet[i].X:=rotAngle + dPhi*i;
    dataSet[i].Y:=calcSignal(dataSet[i].X,dFreq);
  end;
end;

procedure TForm1.OpenGLControl1Paint(Sender: TObject);
var i,l:integer;
    dw:real;
begin
  //calculate
  kw:=1;
  kh:=1;
  if (currW > currH) then kw:=currW/currH;
  if (currH > currW) then kh:=currH/currW;

  //draw
  glClear(GL_COLOR_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  if (not chDrawChart.Checked) then gluOrtho2D(-1*kw,1*kw,-1*kh,1*kh)
  else
  begin
    calcDataSet;
    l:=Length(dataSet);
    if l>0 then
    begin
      dw:=dataSet[High(dataSet)].X-dataSet[0].X;
      gluOrtho2D(0,dw*kw,-1*kh,1*kh);
    end;
  end;

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;


  if (chDrawChart.Checked) then
  begin
    if (l>0) then
    begin

      glLineWidth(3);

      glBegin(GL_LINE_STRIP);
      glColor3f(1, 0, 0);
      for i:=0 to l-1 do
      begin
        glVertex2f((dataSet[i].X-dataSet[0].X)*kw,dataSet[i].Y);
      end;
      glEnd;
    end;
  end
  else
  begin

    glPushMatrix;

    glRotatef(rotAngle,0,0,1);

    glBegin(GL_TRIANGLES);
      glColor3f(1, 0, 0);
      glVertex2f(-0.5, -0.5);
      glColor3f(0, 1, 0);
      glVertex2f( 0.5, -0.5);
      glColor3f(0, 0, 1);
      glVertex2f(   0,  0.5);
    glEnd;

    glPopMatrix;

  end;

  OpenGLControl1.SwapBuffers;
end;

procedure TForm1.OpenGLControl1Resize(Sender: TObject);
begin
  currW:=OpenGLControl1.Width;
  currH:=OpenGLControl1.Height;
  glViewport(0,0,currW,currH);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  rotAngle:=rotAngle + rotSpeed*Timer1.Interval*0.001;
  OpenGLControl1.Paint;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  rotSpeed:=TrackBar1.Position * 10;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  glClearColor(0.0, 0.0, 0.0, 1.0);
end;

end.

