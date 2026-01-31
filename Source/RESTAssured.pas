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
  RESTAssured.RESTClient,
  RESTAssured.Intf.RESTClient,
  RESTAssured.Spec.Response,
  RESTAssured.Utils.ErrorHandling;

type
  TRESTMethod = RESTAssured.Intf.RESTClient.TRESTMethod;
  TRESTAssuredSettings = RESTAssured.Settings.TRESTAssuredSettings;
  TNativeRESTClient = RESTAssured.RESTClient.TNativeRESTClient;
  TRESTContentType = RESTAssured.Intf.RESTClient.TRESTContentType;
  IRESTRequest = RESTAssured.Intf.RESTClient.IRESTRequest;
  IRESTResponse = RESTAssured.Intf.RESTClient.IRESTResponse;

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
      class procedure Fail(Message: String; Args: Array Of Const);
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

function TRESTAssured.Url;
begin
  try
    FRESTClient.SetUrl(Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('Url', [Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithResource;
begin
  try
    FRESTRequest.SetResource(Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithResource', [Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithBody;
begin
  try
    FRESTRequest.SetBody(Content);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithBody', [Content], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithContentType;
begin
  try
    FRESTRequest.SetContentType(Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithContentType', [Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithHeader;
begin
  try
    FRESTRequest.SetHeader(Key, Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithResource', [Key, Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.WithParameter;
begin
  try
    FRESTRequest.SetParameter(Key, Value);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('WithParameter', [Key, Value], Ex);
  end;
  Result := Self;
end;

function TRESTAssured.DoAfter;
begin
  if Assigned(Runnable) then
    FAfterEventHandler.Enqueue(Runnable);

  Result := Self;
end;

function TRESTAssured.DoBefore;
begin
  if Assigned(Runnable) then
    FBeforeEventHandler.Enqueue(Runnable);

  Result := Self;
end;

function TRESTAssured.PerformRequest;
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
    FRESTClient.SetUrl(lUrl);
    FRESTRequest.SetContentType(lContentType);

    if Assigned(lHeaders) then
      FRESTRequest.GetHeaders().AddStrings(lHeaders);

    FBeforeEventHandler.TriggerOn(FRESTRequest);

    lRESTResponse := FRESTClient.PerformRequest(FRESTRequest);
    Assert(lRESTResponse <> nil);

    FAfterEventHandler.TriggerOn(lRESTResponse);

    Result := TRESTAssuredResponseSpec.Create(lRESTResponse);
  except
    on Ex: Exception do
    begin
      lMethod := TRESTAssuredErrorHandler.Beautify<TRESTMethod>(Method);
      TRESTAssuredErrorHandler.Handle('PerformRequest', [lMethod], Ex);
    end;
  end;
end;

destructor TRESTAssured.Destroy;
begin
  FRESTClient := nil;
  FRESTRequest := nil;
  FRESTResponse := nil;
  FAfterEventHandler.Free();
  FBeforeEventHandler.Free();
  inherited;
end;

class function TRESTAssured.Start;
begin
  Result := TRESTAssured.Create();
end;

class procedure TRESTAssured.Fail;
begin
  TRESTAssuredAssert.Fail(Message, Args);
end;

end.
