unit RESTAssured;

interface

uses
  System.Classes,
  System.Variants,
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  RESTAssured.Types,
  RESTAssured.Utils,
  RESTAssured.Assert,
  RESTAssured.Settings,
  RESTAssured.Intf.RESTClient,
  RESTAssured.Default.RESTClient,
  RESTAssured.Utils.ErrorHandling,
  RESTAssured.Spec.Response,
  RESTAssured.Spec.Provider;

type
  TRESTMethod = RESTAssured.Intf.RESTClient.TRESTMethod;
  TRESTAssuredSettings = RESTAssured.Settings.TRESTAssuredSettings;
  TRESTContentType = RESTAssured.Intf.RESTClient.TRESTContentType;
  IRESTRequest = RESTAssured.Intf.RESTClient.IRESTRequest;
  IRESTResponse = RESTAssured.Intf.RESTClient.IRESTResponse;
  TRESTAssuredAssert = RESTAssured.Assert.TRESTAssuredAssert;
  TRESTAssuredSpecProvider = RESTAssured.Spec.Provider.TRESTAssuredSpecProvider;

  IRESTAssuredSpec = interface
    function Url(Value: String): IRESTAssuredSpec;
    function WithBody(Content: String): IRESTAssuredSpec;
    function WithContentType(Value: String): IRESTAssuredSpec;
    function WithResource(Value: String): IRESTAssuredSpec;
    function WithHeader(Key: String; Value: Variant): IRESTAssuredSpec;
    function WithParameter(Key: String; Value: Variant): IRESTAssuredSpec;
    function DoAfter(Runnable: TRunnable<IRESTResponse>): IRESTAssuredSpec;
    function DoBefore(Runnable: TRunnable<IRESTRequest>): IRESTAssuredSpec;
    function PerformRequest(Method: TRESTMethod): IRESTAssuredResponseSpec;
  end;

  TRESTAssured = class sealed(TInterfacedObject, IRESTAssuredSpec)
    strict private
      FRESTClient: IRESTClient;
      FRESTRequest: IRESTRequest;
      FRESTResponse: IRESTResponse;
      FBeforeEventHandler: TRunnableEventHandler<IRESTRequest>;
      FAfterEventHandler: TRunnableEventHandler<IRESTResponse>;
    public
      function Url(Value: String): IRESTAssuredSpec;
      function WithBody(Content: String): IRESTAssuredSpec;
      function WithContentType(Value: String): IRESTAssuredSpec;
      function WithResource(Value: String): IRESTAssuredSpec;
      function WithHeader(Key: String; Value: Variant): IRESTAssuredSpec;
      function WithParameter(Key: String; Value: Variant): IRESTAssuredSpec;
      function DoAfter(Runnable: TRunnable<IRESTResponse>): IRESTAssuredSpec;
      function DoBefore(Runnable: TRunnable<IRESTRequest>): IRESTAssuredSpec;
      function PerformRequest(Method: TRESTMethod): IRESTAssuredResponseSpec;
    public
      constructor Create();
      destructor Destroy(); override;
    public
      class function Start(): IRESTAssuredSpec;
    end;

function BearerAuth(Token: String): Variant;
function BasicAuth(Username: String; Password: String): Variant;

implementation

uses
  System.Rtti,
  System.NetEncoding;

function BearerAuth(Token: String): Variant;
begin
  Result := 'Bearer ' + Token;
end;

function BasicAuth(Username: String; Password: String): Variant;
begin
  Result := 'Basic ' + TBase64Encoding.Base64.Encode(UserName + ':' + Password);
end;

{ TRESTAssured }

constructor TRESTAssured.Create();
begin
  FRESTClient := TRESTAssuredSettings.GetRESTClientFactory().NewRESTClient();
  FAfterEventHandler := TRunnableEventHandler<IRESTResponse>.Create();
  FBeforeEventHandler := TRunnableEventHandler<IRESTRequest>.Create();
  FRESTRequest := FRESTClient.NewRequest();
end;

function TRESTAssured.Url(
  Value: String): IRESTAssuredSpec;
begin
  try
    FRESTClient.SetUrl(Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('Url', [Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithResource(
  Value: String): IRESTAssuredSpec;
begin
  try
    FRESTRequest.SetResource(Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithResource', [Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithBody(
  Content: String): IRESTAssuredSpec;
begin
  try
    FRESTRequest.SetBody(Content);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithBody', [Content], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithContentType(
  Value: String): IRESTAssuredSpec;
begin
  try
    FRESTRequest.SetContentType(Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithContentType', [Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithHeader(
  Key: String;
  Value: Variant): IRESTAssuredSpec;
begin
  try
    FRESTRequest.SetHeader(Key, Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithResource', [Key, Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithParameter(
  Key: String;
  Value: Variant): IRESTAssuredSpec;
begin
  try
    FRESTRequest.SetParameter(Key, Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithParameter', [Key, Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.DoAfter(
  Runnable: TRunnable<IRESTResponse>): IRESTAssuredSpec;
begin
  if Assigned(Runnable) then
    FAfterEventHandler.Enqueue(Runnable);

  Result := Self;
end;

function TRESTAssured.DoBefore(
  Runnable: TRunnable<IRESTRequest>): IRESTAssuredSpec;
begin
  if Assigned(Runnable) then
    FBeforeEventHandler.Enqueue(Runnable);

  Result := Self;
end;

function TRESTAssured.PerformRequest(
  Method: TRESTMethod): IRESTAssuredResponseSpec;
var
  lUrl: String;
  lMethod: String;
  lContentType: String;
  lHeaders: TStringList;
  lRESTResponse: IRESTResponse;
begin
  lUrl := TRESTAssuredSettings.GetDefaultUrl();
  lContentType := TRESTAssuredSettings.GetDefaultContentType();
  lHeaders := TRESTAssuredSettings.GetDefaultHeaders();

  lUrl := TRESTAssuredUtils.First([FRESTClient.GetUrl(), lUrl]);
  lContentType := TRESTAssuredUtils.First([FRESTRequest.GetContentType(), lContentType]);
  try
    try
      FRESTClient.SetUrl(lUrl);
      FRESTRequest.SetContentType(lContentType);

      if Assigned(lHeaders) then
        FRESTRequest.GetHeaders().AddStrings(lHeaders);

      FBeforeEventHandler.TriggerOn(FRESTRequest);

      lRESTResponse := FRESTClient.PerformRequest(FRESTRequest);
      Assert(lRESTResponse <> nil);

      Result := TRESTAssuredSpecProvider.Against(lRESTResponse);
    except
      on Ex: Exception do
        TRESTAssuredErrorHandler.Handle('PerformRequest', [Method.AsString()], Ex);
    end;
  finally
    FAfterEventHandler.TriggerOn(lRESTResponse);
  end;
end;

destructor TRESTAssured.Destroy();
begin
  FRESTClient := nil;
  FRESTRequest := nil;
  FRESTResponse := nil;
  FAfterEventHandler.Free();
  FBeforeEventHandler.Free();
  inherited;
end;

class function TRESTAssured.Start(): IRESTAssuredSpec;
begin
  Result := TRESTAssured.Create();
end;

end.
