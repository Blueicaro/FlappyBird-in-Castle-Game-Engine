unit Gametuberias;

interface

uses CastleTransform,CastleComponentSerialize;

type

  { TTuberia }

  TTuberia = class(TCastleTransform)
   private
      FTuberiaFactory : TCastleComponentFactory;
    public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TTuberia }

constructor TTuberia.Create(AOwner: TComponent);
var
  Tuberia: TCastleTransform;
begin
  inherited Create(AOwner);
  Tuberia :=  FTuberiaFactory.ComponentLoad(FreeAtStop) as TCastleTransform;
end;

end.
