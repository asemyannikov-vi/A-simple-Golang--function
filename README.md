# How to create a λ-function for the Microservice?

## _Executive Summary_

Any actively developing microservice strives to implement and successfully maintain certain architectural features, such as technological heterogeneity, stability, scalability, ease of deployment, and composability.

One of the approaches to the development of the microservice philosophy is to respect the decomposition of its architecture by using shared libraries, as well as allocation of individual modules. Thus, a microservice presented as a set of parts can create both a homogeneous and a heterogeneous environment, when the components are implemented in different programming languages, or with a help of independent third-party resources.

Decomposition allows not only to divide, but also to reduce the size of microservice's modules (__MM__). Yet, it's fairly difficult to predict specific time when __MM__ becomes independent enough to serve as a __λ-function__. In view of the above, __MM__ may contain common global variables, a common logical part and libraries, but shouldn't be directly executed from the main service.

There are no precise requirements when choosing the right candidate to serve as a __λ-function__, except for the fact that a suitable candidate should be both consistent and compliant with the general microservice's philosophy and strive to be a part of the program. Thus, the requirements for the __MM__ executed within the __λ-function__ should be more stringent than for the microservice itself. In the following, the MM which is planned to be performed using the __λ-function__, will be called the __λ-module__. It’s necessary to highlight that the functionality of the λ-module is limited to one or a couple of functions.

A candidate for execution in a __λ-function__ can be represented by a procedure executed in parallel, or by preconfiguration of microservice, such as a database migration process.

In the current article, we propose to consider the possibility of implementing the __MM__ by using __λ-function__.

## _Problem Definition_

Although the current version of microservice's template (__MT__) meets all the requirements, such as stability, scalability, ease of deployment and composability; some parts are still to be modified. For instance, the __MM__ is to be further refined. In view of the foregoing, the implementation __MM__ as part service has a number of issues discussed below:

1. The __MM__ launches as soon as the service is built. This approach mixes service and __MM__ work, while they are logically independent from one another. With that in mind, this service shouldn’t be directly involved in execution __MM__ scripts, yet the __MM__ shouldn’t directly affect any part of the service.

2. In percentage terms, the __MM__ can occupy a large part of the microservice. The code of the __MM__ and its testing are distributed over different parts of the microservice, which may complicate the process of supporting the module.

3. Testing __MM__ should be independent from testing the service. There are many cases where developers mix interface and unit testing, and the reason for this lies in the inseparable connection between the service and __MM__.

## _An advantages of using λ-function_

The __MT__ development seeks to minimize and standardize all the components. One way to reduce the size of the __MT__ and increase the composability of the __MT__ is to implement this component as a standalone __λ-module__ used by __λ-function__.

- _Composability_. The service launch __MM__ processes are separated within __MT__. __λ-module__ contains all necessary parts in one place and is being executed by independent __λ-function__.

- _Homogeneity_. Due to the need to maintain the service homogeneity, the __λ-function__, as well as testing all parts of the __MT__, must be performed in the same programming language.

- _Continuity & Visibility_. The Canaries Testing can be used for running Golang interface-tests packed in the standalone __λ-function__. It is possible to set up a periodic launch of __λ-function__ using AWS::CloudWatch::Synthetics protocol, with logging information on the execution, processing and storing screenshots in AWS::S3 storage.

- _Stability_. Working with the database can be accessed from the __λ-function__ and, as a result, it becomes possible to simplify interface-testing associated with checks for the existence of schemas, tables, and other data. Thus, service interface-testing focuses on testing service endpoints, while __λ-module__ testing becomes an independent process.

- _Ease of deployment & Scalability_. Using the __λ-function__ ensures ease of startup, decouples the service from the __λ-module__, and makes the code more efficient and smaller, enabling the ease of maintenance. The number of __λ-functions__ used by the __MT__ is unlimited and can be replenished anytime with new independent __λ-modules__. The AWS Serverless Application Model (__SAM__) can be used to run and test the __λ-function__ locally.

## _Implementation_

### _Architecture_

The program name of __λ-function__ will be `<λ-function>`. All new __λ-function__ will be placed in the `lambdas` directory.

The __SAM__ is used to evaluate the performance testing of the __λ-function__. To configure __SAM__, you need to prepare the `template.yaml` file, which contains the configuration of the __λ-function__ being developed.

The code that implemented using the __λ-function__ is located in the `<λ-function>.go` file.

The general view of the __λ-function__ architecture for database migration is presented below:
```
/repo root
|--...
|--/lambdas
|----/<λ-function>
|------template.yaml
|------<λ-function>.go
```

### _Configuration of the λ-function_

The `template.yaml` file contains a __λ-function__'s configuration used to specify the name of the __λ-function__, the package with the __λ-function__ source code and accompanying files, the name of the __λ-function__'s handler, and the version of the driver that will be used to execute the __λ-function__ code.
```
Resources:
  <λ-function>Function:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: <λ-function>.zip
      Handler: <λ-function>
      Runtime: go1.x
      Tracing: Active
```
In the `Event` block, we must specify the type, link, and method that the endpoint will use. It's a very useful if we need to separate interface, unit and integration tests for a service. We need always remember that testing the database queries not the same as interface testing.
```
  Properties:
    ...
    Events:
      <name of event>:
        Type: Api
        Properties:
          Path:   <url>
          Method: <http method type>
    Environment:
      Variables:
```
Note, that the resource's property `CodeUri` can store a path of folder with executable file or path to `*.zip` archive, which contain a not only executable file, but additional files with, for example, `*.sql` scripts. We call this archive the __λ-package__, which can be created with next simple commands in the root of the service
```
go build <repo root>/lambdas/<λ-function>/<λ-function>.go && \
mv <repo root>/<λ-function> <repo root>/lambdas/<λ-function>/

zip <repo root>/lambdas/<λ-function>/<λ-function>.zip -j <repo root>/lambdas/<λ-function>/<λ-function>
```
Keep in mind that the size of the __λ-package__ should not exceed 10 MB and, if this condition is violated, Amazon S3 must be used.

The executable `<λ-function>` file and all additional components are run every time the __λ-function__ is called. There is no need to vendor the third-party code as the __λ-function__ allows you to use the compiled code with everything you need. [_Read more about vendoring_](https://teletype.in/@alexander.semyannikov/vendoring).

### _Execution the λ-function_

For example, the `<λ-function>.go` file need to store a `main` function with lambda handler.
```
import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		Body:       "Hello from λ!",
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(handler)
}
```
The `lambda.Start(handler)` command launches the `handler` function, which returns a message in JSON format with `StatusCode` and `Body`.

For local execution of the __λ-function__ using __SAM__, the following commands must be executed
```
sam build --template-file <repo root>/lambdas/<λ-function>/template.yaml

sam local start-api
```
If everything is prepared successfully, we can see the message
```
Running on http://127.0.0.1:3000/ (Press CTRL+C to quit)
```
In order to make sure that everything is working correctly, you need to send an HTTP request using `curl` and get a response from the __λ-function__
```
curl http://127.0.0.1:3000/

Hello from λ!
```
## Refeneces

1. [AWS Documentation: AWS Lambda.](https://docs.aws.amazon.com/lambda/index.html)
2. [AWS Documentation: What is SAM?](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html)
3. [Newman S., Building Microservices, O'Reilly, 2015](https://www.oreilly.com/library/view/building-microservices/9781491950340/)

## Github
[The implementation of __λ-function__]()