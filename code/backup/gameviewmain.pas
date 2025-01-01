{ Main view, where most of the application logic takes place.

  Feel free to use this code as a starting point for your own projects.
  This template code is in public domain, unlike most other CGE code which
  is covered by BSD or LGPL (see https://castle-engine.io/license). }
{$mode objfpc}{$H+}
unit GameViewMain;

interface

uses Classes, fgl,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse, CastleScene,
  CastleTransform, CastleWindow, CastleLog, CastleVectorsInternalSingle,
  CastleViewport;

type
  { Main view, where most of the application logic takes place. }

  { TViewMain }

  TViewMain = class(TCastleView)
  private
    Puntuacion: integer;
    CuerpoPajaro: TCastleRigidBody;
    Velocidad: TVector3;
    TuberiaFactory: TCastleComponentFactory;


    procedure CuerpoPajaroCollision(
      const CollisionDetails: TPhysicsCollisionDetails);
    procedure Impulso;


  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
    LabelFps: TCastleLabel;
    labelInfo: TCastleLabel;
    LabelPuntos: TCastleLabel;
    bird: TCastleScene;
    Camera1: TCastleCamera;
    Fondo: TCastleTransform;
    Suelo1: TCastleScene;
    Suelo2: TCastleScene;
    Suelo3: TCastleScene;
    MainViewPort: TCastleViewport;
    Tuberias: TCastleTransform;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start; override;
    procedure Update(const SecondsPassed: single; var HandleInput: boolean); override;
    function Press(const Event: TInputPressRelease): boolean; override;
  end;

const
  Fuerza: integer = 100000;

var
  ViewMain: TViewMain;

implementation

uses SysUtils;



  { TViewMain ----------------------------------------------------------------- }

procedure TViewMain.Impulso;
var
  v: TVector3;
begin
  v := bird.WorldTranslation;
  CuerpoPajaro.ApplyImpulse(Vector3(V.X, Fuerza, 0), v);
end;



procedure TViewMain.CuerpoPajaroCollision(
  const CollisionDetails: TPhysicsCollisionDetails);
begin

  if (CollisionDetails.Transforms[1].Name = 'Techo') or
    (CollisionDetails.Transforms[1].Name = 'Suelo1') or
    (CollisionDetails.Transforms[1].Name = 'Suelo2') or
    (CollisionDetails.Transforms[1].Name = 'Suelo3') then
  begin
    Velocidad := Vector3(0, 0, 0);
    bird.StopAnimation();
    WritelnLog('Colision Pajaro: ', CollisionDetails.Transforms[1].Name);
  end;
  //else if CollisionDetails.OtherTransform.RigidBody.Trigger = True then
  //begin
  //  //Añadir puntuacion
  //  Puntuacion := Puntuacion + 1;
  //  LabelPuntos.Caption := IntToStr(Puntuacion);
  //end;
end;



constructor TViewMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewmain.castle-user-interface';
end;

destructor TViewMain.Destroy;
begin
  inherited Destroy;
end;

procedure TViewMain.Start;
begin
  inherited;
  Puntuacion := 0;
  Velocidad := Vector3(-150, 0, 0);
  CuerpoPajaro := Bird.RigidBody;
  CuerpoPajaro.OnCollisionEnter :=
  {$IFDEF FPC}
     @CuerpoPajaroCollision;
    {$ELSE}
    CuerpoPajaroCollision;
  {$ENDIF}
  TuberiaFactory := TCastleComponentFactory.Create(FreeAtStop);
  TuberiaFactory.url := ('castle-data:/tuberias.castle-transform');
end;

procedure TViewMain.Update(const SecondsPassed: single; var HandleInput: boolean);
var
  I: integer;
  TuberiaActual: TCastleTransform;
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }
  Assert(LabelFps <> nil,
    'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  labelInfo.Caption := 'Animación: ' + bird.AutoAnimation +
    '. Velocidad Y: ' + CuerpoPajaro.LinearVelocity.Y.ToString();


  if (Bird.AutoAnimation = 'idle') and (CuerpoPajaro.LinearVelocity.Y > 0) then
  begin
    bird.AutoAnimation := 'main';
  end
  else if (bird.AutoAnimation = 'main') and (CuerpoPajaro.LinearVelocity.Y < 0) then
  begin
    bird.AutoAnimation := 'idle';
  end;

  //Pipe Pooling
  for I := Tuberias.Count - 1 downto 0 do
  begin
    if Tuberias.Items[I].Translation.X < -1100 then
    begin
       Tuberias.RemoveDelayed(Tuberias.Items[I],Free);
    end
    else
    begin
      Tuberias.Items[I].Translation :=
      Tuberias.Items[I].Translation + Velocidad * SecondsPassed;
    end;
  end;

  //Ground Pooling
  if (Suelo1.Translation.x < -1024) then
  begin
    Suelo1.Translation := Suelo3.Translation + Vector3(1024, 0, 0) +
      Velocidad * SecondsPassed;
    WritelnLog('Suelo 1:' + Suelo1.Translation.ToString);
    WritelnLog('Update', bird.AutoAnimation);
  end
  else
  begin
    Suelo1.Translation := Suelo1.Translation + Velocidad * SecondsPassed;
  end;

  if (Suelo2.Translation.x < -1024) then
  begin
    Suelo2.Translation := Suelo1.Translation + Vector3(1024, 0, 0) +
      Velocidad * SecondsPassed;
    WritelnLog('Suelo 2:' + Suelo2.Translation.ToString);
    WritelnLog('Update', bird.AutoAnimation);
  end
  else
  begin
    Suelo2.Translation := Suelo2.Translation + Velocidad * SecondsPassed;
  end;
  if Suelo3.Translation.X < -1024 then
  begin
    Suelo3.Translation := Suelo2.Translation + Vector3(1024, 0, 0) +
      Velocidad * SecondsPassed;
    WritelnLog('Suelo 3:' + Suelo3.Translation.ToString);
  end
  else
  begin
    Suelo3.Translation := Suelo3.Translation + Velocidad * SecondsPassed;
  end;

end;

function TViewMain.Press(const Event: TInputPressRelease): boolean;
var
  Tuberia: TCastleTransform;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys
  if Event.IsKey(keySpace) then
  begin
    Impulso;
    WritelnLog('Press', bird.AutoAnimation);
    Exit(True);
  end;
  if Event.IsKey(keyEscape) then
  begin
    Application.Terminate;
    Exit(True);
  end;
  {$IFDEF DEBUG}
    if Event.IsKey(keyEnter) then
    begin
      Tuberia := TuberiaFactory.ComponentLoad(FreeAtStop) as TCastleTransform;
      Tuberias.Add(Tuberia);
      Tuberia.Translation :=Vector3(0,0,0);
    end;
  {$ENDIF}
end;

end.
