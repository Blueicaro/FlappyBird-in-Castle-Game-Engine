{ Main view, where most of the application logic takes place.

  Feel free to use this code as a starting point for your own projects.
  This template code is in public domain, unlike most other CGE code which
  is covered by BSD or LGPL (see https://castle-engine.io/license). }
unit GameViewMain;

interface

uses Classes,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse, CastleScene,
  CastleTransform, CastleWindow, CastleLog, CastleVectorsInternalSingle;

type
  { Main view, where most of the application logic takes place. }

  { TViewMain }

  TViewMain = class(TCastleView)
  private
    CuerpoPajaro: TCastleRigidBody;
    Velocidad: TVector3;
    procedure CuerpoPajaroCollision(
      const CollisionDetails: TPhysicsCollisionDetails);
    procedure Impulso;

  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
    LabelFps: TCastleLabel;
    bird: TCastleScene;
    Camera1: TCastleCamera;
    Fondo: TCastleTransform;
    Suelo1: TCastleScene;
    Suelo2: TCastleScene;
  public
    constructor Create(AOwner: TComponent); override;
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
  WritelnLog(V.ToString);
  CuerpoPajaro.ApplyImpulse(Vector3(V.X, Fuerza, 0), v);
end;

procedure TViewMain.CuerpoPajaroCollision(
  const CollisionDetails: TPhysicsCollisionDetails);
begin
  if CollisionDetails.Transforms[1].Name <> 'Techo' then
  begin
    Velocidad := Vector3(0, 0, 0);
    bird.StopAnimation();
  end;
end;

constructor TViewMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewmain.castle-user-interface';
end;

procedure TViewMain.Start;
begin
  inherited;
  Velocidad := Vector3(-100, 0, 0);
  CuerpoPajaro := Bird.RigidBody;
  CuerpoPajaro.OnCollisionEnter :=
  {$IFDEF FPC}
 @CuerpoPajaroCollision
    {$ELSE}
    CuerpoPajaroCollision
  {$ENDIF}
  ;

  {$IFDEF DEBUG}
 WritelnLog('Posicion suelo 1: ' + FloatToStr(Suelo1.WorldToLocal(Camera1.Translation).x));
  WritelnLog('Posicion suelo 2: ' + FloatToStr(Suelo2.WorldToLocal(Camera1.Translation).x));
     WritelnLog('Posicion de la cámara: '+(Camera1.Translation.ToString));
  bird.RigidBody.LinearVelocity:=Vector3(0,0,0);
  {$ENDIF}
end;

procedure TViewMain.Update(const SecondsPassed: single; var HandleInput: boolean);
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }
  Assert(LabelFps <> nil,
    'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  if (Suelo1.Translation.x < -1024) then
  begin
     Suelo1.Translation := Suelo2.Translation+Vector3(1024-(1024*SecondsPassed),0,0);
  //  Suelo1.Translation := Suelo1.Translation + Velocidad * SecondsPassed;
    WritelnLog('Suelo 1:'+Suelo1.Translation.ToString);
  end
  else
  begin
    Suelo1.Translation := Suelo1.Translation + Velocidad * SecondsPassed;
  end;

  if (Suelo2.Translation.x < -1024) then
  begin
    Suelo2.Translation := Suelo1.Translation+Vector3(1020,0,0);
  //  Suelo2.Translation := Suelo2.Translation + Velocidad * SecondsPassed;
     WritelnLog('Suelo 2:'+Suelo1.Translation.ToString);
  end
  else
  begin
    Suelo2.Translation := Suelo2.Translation + Velocidad * SecondsPassed;
  end;
end;

function TViewMain.Press(const Event: TInputPressRelease): boolean;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys
  if Event.IsKey(keySpace) then
  begin
    Impulso;
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
      if bird.RigidBody.LinearVelocity.X > 0 then
      begin
      bird.RigidBody.LinearVelocity:= Vector3(0,0,0);
       WritelnLog('Posicion suelo 1: ' + FloatToStr(Suelo1.WorldToLocal(Camera1.Translation).x));
       WritelnLog('Posicion suelo 2: ' + FloatToStr(Suelo2.WorldToLocal(Camera1.Translation).x));
       WritelnLog('Posicion de la cámara: '+(Camera1.Translation.ToString));
      end
      else
      begin
        bird.RigidBody.LinearVelocity:= Vector3(100,0,0);
      end;

    end;
  {$ENDIF}
end;

end.
