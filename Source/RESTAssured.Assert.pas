unit RESTAssured.Assert;

interface

uses
  DUnitX.Assert,
  System.Rtti,
  System.SysUtils,
  System.Generics.Defaults,
  RESTAssured.Utils,
  RESTAssured.Miscs;

type
  TRESTAssuredAssert = class
    public
      class procedure DoAssert(); inline;
      class function Make<X>(Value: TValue): X; overload;
      class function Make<X, Y>(Value: X): Y; overload;
      class procedure AreEqual<T>(Expected, Actual: T; Message: String);
      class procedure IsGreaterThan<T>(GreaterValue, Actual: T; Message: String);
      class procedure IsLessThan<T>(LesserValue, Actual: T; Message: String);
      class procedure IsEmpty(Value: String; Message: String);
      class procedure IsNotEmpty(Value: String; Message: String);
      class procedure Fail(Message: String);
      class procedure Pass();
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

class procedure TRESTAssuredAssert.AreEqual<T>(
  Expected, Actual: T; Message: String);
var
  lComparer: IComparer<T>;
  lExpectedValue, lActualValue: TValue;
begin
  DoAssert();

  lComparer := TComparer<T>.Default;
  lActualValue := TValue.From<T>(Actual);
  lExpectedValue := TValue.From<T>(Expected);

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_ACTUAL,
                                       lActualValue.ToString());

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_EXPECTED,
                                       lExpectedValue.ToString());

  if lComparer.Compare(Actual, Expected) <> 0 then
    Fail(Message);
end;

class procedure TRESTAssuredAssert.IsGreaterThan<T>(
  GreaterValue, Actual: T;
  Message: String);
var
  lGreaterValue, lActualValue: TValue;
begin
  DoAssert();

  lActualValue := TValue.From<T>(Actual);
  lGreaterValue := TValue.From<T>(GreaterValue);

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_ACTUAL,
                                       lActualValue.ToString());

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_GREATER,
                                       lGreaterValue.ToString());

  if  Make<Double>(lActualValue) < Make<Double>(lGreaterValue) then
    Fail(Message);
end;

class procedure TRESTAssuredAssert.IsLessThan<T>(
  LesserValue, Actual: T;
  Message: String);
var
  lLesserValue, lActualValue: TValue;
begin
  DoAssert();

  lActualValue := TValue.From<T>(Actual);
  lLesserValue := TValue.From<T>(LesserValue);

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_ACTUAL,
                                       lActualValue.ToString());

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_LESSER,
                                       lLesserValue.ToString());

  if Make<Double>(lActualValue) > Make<Double>(lLesserValue) then
    Fail(Message);
end;

class procedure TRESTAssuredAssert.IsEmpty(
  Value: String;
  Message: String);
begin
  DoAssert();

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_VALUE,
                                       Value);
  if not Value.IsEmpty() then
    Fail(Message);
end;

class procedure TRESTAssuredAssert.IsNotEmpty(
  Value: String;
  Message: String);
begin
  DoAssert();

  Message := TRESTAssuredUtils.Replace(Message,
                                       PLACEHOLDER_VALUE,
                                       Value);
  if Value.IsEmpty() then
    Fail(Message);
end;

class function TRESTAssuredAssert.Make<X, Y>(Value: X): Y;
begin
  Result := TValue.From<X>(Value).AsType<Y>(False);
end;

class function TRESTAssuredAssert.Make<X>(Value: TValue): X;
begin
  Result := Value.AsType<X>();
end;

class procedure TRESTAssuredAssert.Pass();
begin
  Assert.Pass();
end;

class procedure TRESTAssuredAssert.DoAssert();
begin
  if Assigned(Assert.OnAssert) then
    Assert.OnAssert();
end;

class procedure TRESTAssuredAssert.Fail(Message: String);
begin
  Assert.Fail(Message, ReturnAddress);
end;

end.
