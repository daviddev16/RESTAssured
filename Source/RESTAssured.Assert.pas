unit RESTAssured.Assert;

interface

uses
  DUnitX.Assert,
  System.Rtti,
  System.SysUtils,
  System.Generics.Defaults,
  RESTAssured.Utils;

type
  TRESTAssuredAssert = class
    public
      class function Make<X>(Value: TValue): X; overload;
      class function Make<X, Y>(Value: X): Y; overload;
      class procedure Fail(Message: String; Args: Array of Const);
      class procedure AreEqual<T>(Expected, Actual: T; Message: String);
      class procedure IsGreaterThan<T>(GreaterValue, Actual: T; Message: String);
      class procedure IsLessThan<T>(LesserValue, Actual: T; Message: String);
      class procedure IsEmpty(Value: String; Message: String);
    end;

const
  PLACEHOLDER_VALUE    = '{{VALUE}}';
  PLACEHOLDER_ACTUAL   = '{{ACTUAL}}';
  PLACEHOLDER_GREATER  = '{{GREATER}}';
  PLACEHOLDER_LESSER   = '{{LESSER}}';
  PLACEHOLDER_EXPECTED = '{{EXPECTED}}';

implementation

uses
  System.TypInfo;

{ TRESTAssuredAssert }

class procedure TRESTAssuredAssert.AreEqual<T>;
var
  lComparer: IComparer<T>;
  lExpectedValue, lActualValue: TValue;
begin
  lComparer := TComparer<T>.Default;
  if lComparer.Compare(Expected, Actual) <> 0 then
  begin
    lActualValue := TValue.From<T>(Actual);
    lExpectedValue := TValue.From<T>(Expected);

    Message := TRESTAssuredUtils.Replace(Message,
                                         PLACEHOLDER_ACTUAL,
                                         lActualValue.ToString());

    Message := TRESTAssuredUtils.Replace(Message,
                                         PLACEHOLDER_EXPECTED,
                                         lExpectedValue.ToString());

    Fail(Message, []);
  end;
end;

class procedure TRESTAssuredAssert.IsGreaterThan<T>;
var
  lIsGreaterThan: Boolean;
  lGreaterValue, lActualValue: TValue;
begin
  lActualValue := TValue.From<T>(Actual);
  lGreaterValue := TValue.From<T>(GreaterValue);

  if lActualValue.Kind = tkInteger then
    lIsGreaterThan := Make<Integer>(lActualValue) > Make<Integer>(lGreaterValue)

  else if lActualValue.Kind = tkInt64 then
    lIsGreaterThan := Make<Integer>(lActualValue) > Make<Integer>(lGreaterValue)

  else if lActualValue.Kind = tkFloat then
    lIsGreaterThan := Make<Double>(lActualValue) > Make<Double>(lGreaterValue);


  if not lIsGreaterThan then
  begin
    Message := TRESTAssuredUtils.Replace(Message,
                                         PLACEHOLDER_ACTUAL,
                                         lActualValue.ToString());

    Message := TRESTAssuredUtils.Replace(Message,
                                         PLACEHOLDER_GREATER,
                                         lGreaterValue.ToString());

    Fail(Message, []);
  end;
end;

class procedure TRESTAssuredAssert.IsLessThan<T>;
var
  lIsLessThan: Boolean;
  lLesserValue, lActualValue: TValue;
begin
  lActualValue := TValue.From<T>(Actual);
  lLesserValue := TValue.From<T>(LesserValue);

  if lActualValue.Kind = tkInteger then
    lIsLessThan := Make<Integer>(lActualValue) < Make<Integer>(lLesserValue)

  else if lActualValue.Kind = tkInt64 then
    lIsLessThan := Make<Integer>(lActualValue) < Make<Integer>(lLesserValue)

  else if lActualValue.Kind = tkFloat then
    lIsLessThan := Make<Double>(lActualValue) < Make<Double>(lLesserValue);


  if not lIsLessThan then
  begin
    Message := TRESTAssuredUtils.Replace(Message,
                                         PLACEHOLDER_ACTUAL,
                                         lActualValue.ToString());

    Message := TRESTAssuredUtils.Replace(Message,
                                         PLACEHOLDER_LESSER,
                                         lLesserValue.ToString());

    Fail(Message, []);
  end;
end;

class procedure TRESTAssuredAssert.IsEmpty;
begin
  if Value.IsEmpty() then
    Exit;

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_VALUE,
                                       Value);

  Fail(Message, []);
end;

class function TRESTAssuredAssert.Make<X, Y>(Value: X): Y;
begin
  Result := TValue.From<X>(Value).AsType<Y>(False);
end;

class function TRESTAssuredAssert.Make<X>(Value: TValue): X;
begin
  Result := Value.AsType<X>;
end;

class procedure TRESTAssuredAssert.Fail;
begin
  Assert.FailFmt(Message, Args, ReturnAddress);
end;


end.
