unit RESTAssured.Spec.Response;

interface

uses
  System.SysUtils,
  RESTAssured.Utils,
  RESTAssured.Assert,
  RESTAssured.Types,
  RESTAssured.Spec.JSON,
  RESTAssured.Intf.RESTClient,
  RESTAssured.Default.RESTClient,
  DUnitX.TestFramework;

type
  IRESTAssuredResponseSpec = interface
    function BodyAsJson(): IRESTAssuredJSONSpec;
    function Bodyless(): IRESTAssuredResponseSpec;
    function BodyIs(Expected: String): IRESTAssuredResponseSpec;
    function StatusCodeIs(Expected: Integer): IRESTAssuredResponseSpec; overload;
    function StatusCodeIs(Predicate: TPredicate<Integer>): IRESTAssuredResponseSpec; overload;
  end;

  TRESTAssuredResponseSpec = class(TInterfacedObject, IRESTAssuredResponseSpec)
    strict private
      FRESTResponse: IRESTResponse;
    public
      function BodyAsJson(): IRESTAssuredJSONSpec;
      function Bodyless(): IRESTAssuredResponseSpec;
      function BodyIs(Expected: String): IRESTAssuredResponseSpec;
      function StatusCodeIs(Expected: Integer): IRESTAssuredResponseSpec; overload;
      function StatusCodeIs(Predicate: TPredicate<Integer>): IRESTAssuredResponseSpec; overload;
    public
      constructor Create(RESTResponse: IRESTResponse);
      destructor Destroy(); override;
    end;

implementation

uses
  System.JSON,
  RESTAssured.Miscs,
  RESTAssured.Spec.Provider,
  RESTAssured.Utils.ErrorHandling;

{ TRESTAssuredResponseSpec }

constructor TRESTAssuredResponseSpec.Create(
  RESTResponse: IRESTResponse);
begin
  FRESTResponse := RESTResponse;
end;

function TRESTAssuredResponseSpec.StatusCodeIs(
  Expected: Integer): IRESTAssuredResponseSpec;
const
  MESSAGE_FMT = 'Status Code expected to be "{{EXPECTED}}" but got "{{ACTUAL}}".';
var
  lStatus: Integer;
  lMessage: TRESTAssuredMessage;
begin
  Result := Self;
  lMessage := TRESTAssuredMessage
      .New('StatusCodeIs')
      .Parameters([Expected])
      .AssertationMessage(MESSAGE_FMT, []);
  try
    lStatus := FRESTResponse.GetStatus();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.AreEqual<Integer>(Expected,
                                       lStatus,
                                       lMessage.Build());
end;

function TRESTAssuredResponseSpec.StatusCodeIs(
  Predicate: TPredicate<Integer>): IRESTAssuredResponseSpec;
const
  MESSAGE_FMT = 'Predicate condition failed.';
var
  lMessage: TRESTAssuredMessage;
  lPredicateResult: TPredicateResult;
begin
  Result := Self;
  lMessage := TRESTAssuredMessage
      .New('StatusCodeIs')
      .Parameters(['<<Predicate Procedure>>'])
      .AssertationMessage(MESSAGE_FMT, []);
  try
    lPredicateResult := Predicate(FRESTResponse.GetStatus());
    lMessage.AssertationMessage(lPredicateResult.AssertationMessage, []);

    if lPredicateResult.Success then
      Exit;
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.Fail(lMessage.Build());
end;

function TRESTAssuredResponseSpec.BodyAsJson(): IRESTAssuredJSONSpec;
const
  MESSAGE_FMT = 'Body must be a valid JSON.';
var
  lBody: String;
  lJSONValue: TJSONValue;
  lMessage: TRESTAssuredMessage;
begin
  lMessage := TRESTAssuredMessage
      .New('BodyAsJson')
      .AssertationMessage(MESSAGE_FMT, []);

  lBody := FRESTResponse.GetBody();
  try
    lJSONValue := TJSONValue.ParseJSONValue(lBody, True, True);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  Result := TRESTAssuredSpecProvider.Against(lJSONValue);
end;

function TRESTAssuredResponseSpec.BodyIs(
  Expected: String): IRESTAssuredResponseSpec;
const
  MESSAGE_FMT = 'Body expected to be "{{EXPECTED}}" but got "{{ACTUAL}}".';
var
  lBody: String;
  lMessage: TRESTAssuredMessage;
begin
  Result := Self;
  lMessage := TRESTAssuredMessage
      .New('BodyIs')
      .Parameters([Expected])
      .AssertationMessage(MESSAGE_FMT, []);

  try
    lBody := FRESTResponse.GetBody();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.AreEqual<String>(Expected,
                                      lBody,
                                      lMessage.Build());
end;

function TRESTAssuredResponseSpec.Bodyless(): IRESTAssuredResponseSpec;
const
  MESSAGE_FMT = 'Body expected to be empty but got "{{VALUE}}".';
var
  lBody: String;
  lMessage: TRESTAssuredMessage;
begin
  Result := Self;
  lMessage := TRESTAssuredMessage
      .New('Bodyless')
      .AssertationMessage(MESSAGE_FMT, []);

  try
    lBody := FRESTResponse.GetBody();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.IsEmpty(lBody,
                             lMessage.Build());
end;

destructor TRESTAssuredResponseSpec.Destroy();
begin
  FRESTResponse := nil;
  inherited;
end;

end.
