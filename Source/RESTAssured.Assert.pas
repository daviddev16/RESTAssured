unit RESTAssured.Assert;

interface

uses
  DUnitX.Assert,
  System.SysUtils,
  System.Generics.Defaults,
  RESTAssured.Utils;

type
  TRESTAssuredAssert = class
    public
      class procedure Fail(Message: String; Args: Array of Const);
      class procedure AreEqual<T>(Expected, Actual: T; Message: String);
    end;

const
  PLACEHOLDER_ACTUAL   = '{{ACTUAL}}';
  PLACEHOLDER_EXPECTED = '{{EXPECTED}}';

implementation

uses
  System.Rtti;

{ TRESTAssuredAssert }

class procedure TRESTAssuredAssert.AreEqual<T>;
var
  lComparer: IComparer<T>;
  lExpectedValue, lActualValue: TValue;
  lMessage: String;
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

class procedure TRESTAssuredAssert.Fail;
begin
  Assert.FailFmt(Message, Args, ReturnAddress);
end;

end.
