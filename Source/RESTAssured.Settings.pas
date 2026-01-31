unit RESTAssured.Settings;

interface

uses
  System.Classes,
  System.SysUtils,
  RESTAssured.Utils,
  RESTAssured.Intf.RESTClient,
  RESTAssured.Default.RESTClient;

type
  TRESTAssuredSettings = class sealed
    private
      class threadvar FDefaultUrl: String;
      class threadvar FDefaultHeaders: TStringList;
      class threadvar FDefaultContentType: String;
      class threadvar FRESTClientFactory: IRESTClientFactory;
    public
      class function GetDefaultUrl(): String; static;
      class function GetDefaultHeaders(): TStringList; static;
      class function GetDefaultContentType(): String; static;
      class function GetRESTClientFactory(): IRESTClientFactory; static;
    public
      class procedure SetDefaultUrl(Value: String);
      class procedure AddDefaultHeader(Key: String; Value: Variant);
      class procedure SetDefaultContentType(Value: String);
      class procedure SetRESTClientFactory(Value: IRESTClientFactory);
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
  FRESTClientFactory := TNativeRESTClientFactory.Create();
end;

class procedure TRESTAssuredSettings.SetDefaultUrl;
begin
  FDefaultUrl := Value;
end;

class procedure TRESTAssuredSettings.SetDefaultContentType;
begin
  FDefaultContentType := Value;
end;

class procedure TRESTAssuredSettings.SetRESTClientFactory;
begin
  FRESTClientFactory := Value;
end;

class function TRESTAssuredSettings.GetRESTClientFactory;
begin
  Result := FRESTClientFactory;
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

class function TRESTAssuredSettings.GetDefaultContentType;
begin
  Result := FDefaultContentType;
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
  FRESTClientFactory := nil;
end;

end.
