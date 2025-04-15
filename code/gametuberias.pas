unit Gametuberias;

interface

uses Classes, CastleTransform, CastleComponentSerialize, CastleBehaviors,
  CastleVectors, CastleVectorsInternalSingle;

type

  { TTuberiaBehaivor }

  TTuberiaBehaivor = class(TCastleBehavior)
    private

   var  FVerticalSpeed: TGenericScalar;
    FLinearSpeed: TGenericScalar;
    FTopLimit: TGenericScalar;
    FDownLimit: TGenericScalar;
    Fup: boolean;

  public
    procedure Update(const SecondsPassed: single; var RemoveMe: TRemoveType); override;
    procedure AfterCreate(LinearSpeed: TGenericScalar; VerticalSpeed: TGenericScalar);
  end;

type

  { TTuberiaDesign }

  TTuberiaDesign = class(TPersistent)
  published
    TuberiaBehaivor: TTuberiaBehaivor;
  public
    constructor Create;
  end;

implementation

uses CastleLog, Math, SysUtils, CastleViewport;

  { TTuberiaBehaivor }

procedure TTuberiaBehaivor.Update(const SecondsPassed: single;
  var RemoveMe: TRemoveType);
var
  X, Y, YSpeed: TGenericScalar;
  Speed: TVector3;
begin
  inherited Update(SecondsPassed, RemoveMe);

  Y := Parent.Translation.Y;
  if Y > FTopLimit then
  begin
    Y := FTopLimit;
    Fup := False;
  end;
  if Y < FDownLimit then
  begin
    Y := FDownLimit;
    Fup := True;
  end;
  YSpeed := FVerticalSpeed;
  if Fup = False then
  begin
    YSpeed := -YSpeed;
  end;
  Speed := Vector3(FLinearSpeed, YSpeed, 0);
  Parent.Translation := Parent.Translation + Speed * SecondsPassed;
  if Parent.Translation.X < -1100 then
  begin
    RemoveMe := rtRemoveAndFree;
  end
  else
  begin
    RemoveMe := rtNone;
  end;

end;

procedure TTuberiaBehaivor.AfterCreate(LinearSpeed: TGenericScalar;
  VerticalSpeed: TGenericScalar);
var
  Value: int64;
begin
  FLinearSpeed := LinearSpeed;
  FVerticalSpeed := VerticalSpeed;
  Fup := False;
  Randomize;
  Value := RandomRange(0, 10);
  if Value mod 2 = 0 then
  begin
    FUp := True;
  end;
  FDownLimit := -150;
  FTopLimit := 150;
end;

{ TTuberiaDesign }

constructor TTuberiaDesign.Create;
begin
  //TuberiaBehaivor := TTuberiaBehaivor.Create(Self);
end;


end.
