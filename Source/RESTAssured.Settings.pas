unit RESTAssured.Settings;

interface

uses
  System.Classes,
  System.SysUtils,
  RESTAssured.Utils;

type
  TRESTAssuredSettings = class sealed
    private
      class threadvar FDefaultUrl: String;
      class threadvar FDefaultHeaders: TStringList;
    public
      class function GetDefaultUrl(): String; static;
      class function GetDefaultHeaders(): TStringList; static;
    public
      class procedure SetDefaultUrl(Value: String);
      class procedure AddDefaultHeader(Key: String; Value: Variant);
      class procedure Clear();
    public
      class constructor Create();
      class destructor Destroy();
    end;

implementation

{ TRESTAssuredSettings }

class constructor TRESTAssuredSettings.Create;
begin
  FDefaultUrl := '';
  FDefaultHeaders := TStringList.Create();
end;

class procedure TRESTAssuredSettings.SetDefaultUrl;
begin
  FDefaultUrl := Value;
end;

class procedure TRESTAssuredSettings.AddDefaultHeader;
var
  lVariantConversor: TVariantConversor;
begin
  lVariantConversor := TVariantConversor.Create();
  try
    FDefaultHeaders.AddPair(Key, lVariantConversor.Convert(Value));
  finally
    lVariantConversor.Free();
  end;
end;

class function TRESTAssuredSettings.GetDefaultHeaders;
begin
  Result := FDefaultHeaders;
end;

class function TRESTAssuredSettings.GetDefaultUrl;
begin
  Result := FDefaultUrl;
end;

class procedure TRESTAssuredSettings.Clear;
begin
  FDefaultUrl := '';
  FDefaultHeaders.Clear();
end;

class destructor TRESTAssuredSettings.Destroy;
begin
  FDefaultUrl := '';
  FreeAndNil(FDefaultHeaders);
end;

end.
