## RESTAssured

RESTAssured is a minimalist framework that allows you to create API integration tests within DUnit test procedures.

### Getting Started

<details>
<summary>1. First Integration Test <i>(example)</i></summary>

### First Integration Test

1. To get started you first need a DUnit project set up with RESTAssured units.
```pascal
uses
  RESTAssured,
  DUnitX.TestFramework;
```
2. Create a DUnit test procedure.
```pascal
[Test]
procedure CalculatorServiceTest();
```
3. This test verifies that the API is calculating values correctly according to the type of operation.
```pascal
procedure TCalculatorServiceTest.CalculatorServiceTest;
begin
  TRESTAssured.Start()
      .Url('http://127.0.0.1:9000')
      .WithResource('/calculator')
      .WithParameter('x', 50)
      .WithParameter('y', 25)
      .WithParameter('operator', 'plus,multiply')
      .PerformRequest(TRESTMethod.GET)
          .StatusCodeIs(200)
          .BodyAsJson()
              .AssertThat('MultiplyResult', 1250.0)
              .AssertThat('PlusResult', 75.0);
end;
```

</details>

<details>
<summary>2. Test Fixture With Default Settings <i>(example)</i></summary>

### Test Fixture With Default Settings

Sometimes, you don't want to set parameters manually for each test procedure. 
You might use the default settings instead.

1. Create a `SetupFixture` procedure;
```pascal
[SetupFixture]
procedure SetupFixture();

[TearDownFixture]
procedure TeardownFixture();
```
2. Setting up custom RESTAssured default values with `TRESTAssuredSettings`.
```pascal
procedure TCalculatorServiceTest.SetupFixture;
begin
  TRESTAssuredSettings.SetDefaultUrl('http://127.0.0.1:9000');
  TRESTAssuredSettings.AddDefaultHeader('Authorization', BasicAuth('daviddev16', 'passw0rd'));
end;
```
3. Test, Test, Test, ...
4. Clear it up if necessary.
```pascal
procedure TCalculatorServiceTest.TeardownFixture;
begin
  TRESTAssuredSettings.Clear();
end;
```
</details>

<details>
<summary>3. Custom Status Code Validation <i>(example)</i></summary>

### Custom Status Code Validation

You might want to customize the way RESTAssured validates Status code with a custom `TPredicate<Integer>`.
Here is an example of how to do it: 

```pascal
procedure TCalculatorServiceTest.CalculatorServiceWithStatusCodePredicateTest;
begin
  TRESTAssured.Start()
      .Url('http://127.0.0.1:9000')
      .WithResource('/calculator')
      .WithParameter('x', 50)
      .WithParameter('y', 25)
      .WithParameter('operator', 'plus,multiply')
      .PerformRequest(TRESTMethod.GET)

          // Custom predicate
          .StatusCodeIs(
              function (StatusCode: Integer): Boolean
              begin
                Result := (StatusCode >= 200) and (StatusCode <> 204);
              end)

          .BodyAsJson()
              .AssertThat('MultiplyResult', 1250.0)
              .AssertThat('PlusResult', 75.0);
end;
```

</details>

<details>
<summary>4. Before / After Event Trigger <i>(example)</i></summary>

### Before / After Event Trigger

I might want to perform some operation before and after the HTTP request. Here is a
example of how to do it with `DoAfter(TRunnable<IRESTResponse>)` and `DoBefore(TRunnable<IRESTRequest>)`.

```pascal
procedure TMyTestObject.CreateCompanyEventTest;
begin
  TRESTAssured.Start()
      .WithResource('/company')
      .WithParameter('name', 'GitHub')
      .WithHeader('Authorization', BearerAuth('MyJWTSecretToken'))
      //
      // Executes before request to the client.
      //
      .DoBefore(procedure (RESTRequest: IRESTRequest)
                var
                  lCompanyToInsert: String;
                begin
                  lCompanyToInsert := RESTRequest.GetParameter('name');
                  TDatabaseService.Run('/data/INSERT_CASE001_Company_' + lCompanyToInsert + '.SQL');
                end)
      //
      // Executes after request ends.
      //
      .DoAfter(procedure (RESTResponse: IRESTResponse)
                var
                  lCompanyToDelete: String;
                  lRESTRequest: IRESTRequest;
                begin
                  lRESTRequest := RESTResponse.GetRESTRequest();
                  lCompanyToDelete := lRESTRequest.GetParameter('name');
                  TDatabaseService.Run('/data/DELETE_CASE001_Company_' + lCompanyToDelete + '.SQL');
                end)

      .PerformRequest(TRESTMethod.GET)
          .StatusCodeIs(200)
          .BodyAsJson()
              .AssertThat('CompanyId', '0019ABXXC3')
              .AssertThat('CompanyName', 'GitHub')
              .AssertThat('CompanyCreatedAt', EncodeDateTime(2025, 04, 12, 00, 00, 00))
              .AssertThat('CompanyCredits', 19921.2)
              .AssertThat('CompanyDescription', 'Just github.');
end;
```

</details>

<details>
<summary>4. Custom HTTP Client <i>(example)</i></summary>

### Custom HTTP Client

RESTAssured has a built-in HTTP client abstraction located in `RESTAssured.Intf.RESTClient` 
that relies primary on `REST.Client` native Delphi client. All HTTP interaction inside RESTAssured is 
made using this abstractions.


`TRESTAssured` will always use the <b>default HTTP client factory</b>, witch is `TNativeRESTClientFactory`.


if you want to implement your own HTTP Client, you can start by implementing `IRESTRequest`, `IRESTResponse`, `IRESTClient` and finally `IRESTClientFactory`.

```pascal
  TNativeRESTClientFactory = class(TInterfacedObject, IRESTClientFactory)
    public
      function NewRESTClient(): IRESTClient;
    end;

implementation

{ TNativeRESTClientFactory }

function TNativeRESTClientFactory.NewRESTClient;
begin
  Result := TNativeRESTClient.Create();
end;
```


> The default implementation of IRESTClientFactory.


Here is how you can configure your own HTTP client factory.

```pascal
procedure TMyTestObject.SetupFixture;
begin
  TRESTAssuredSettings.SetRESTClientFactory(TMyCustomRESTClientFactory.Create());
end;
```





