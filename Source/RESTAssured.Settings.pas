unit RESTAssured.Settings;

interface

uses
  System.Classes,
  System.SysUtils,
  RESTAssured.Utils;

type
  TRESTAssuredSettings = class sealed
    private
      class var FDefaultUrl: String;
      class var FDefaultHeaders: TStringList;
      class var FLockObject: TObject;
    public
      class property DefaultUrl:     String      read FDefaultUrl;
      class property DefaultHeaders: TStringList read FDefaultHeaders;
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
  FLockObject := TObject.Create();
end;

class procedure TRESTAssuredSettings.SetDefaultUrl;
begin
  TMonitor.Enter(FLockObject);
  try
    FDefaultUrl := Value;
  finally
    TMonitor.Exit(FLockObject);
  end;
end;

class procedure TRESTAssuredSettings.AddDefaultHeader;
var
  lVariantConversor: TVariantConversor;
begin
  TMonitor.Enter(FLockObject);
  lVariantConversor := TVariantConversor.Create();
  try
    FDefaultHeaders.AddPair(Key, lVariantConversor.Convert(Value));
  finally
    lVariantConversor.Free();
    TMonitor.Exit(FLockObject);
  end;
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
  FreeAndNil(FLockObject);
end;

end.
